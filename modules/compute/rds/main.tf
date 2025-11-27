# ==============================================================================
# MÓDULO: RDS (Relational Database Service)
# Propósito: Base de datos PostgreSQL Multi-AZ con alta disponibilidad
# Compliance: ISO 27001 A.12.3.1, A.10.1.1, A.10.1.2 | NIST CSF PR.DS-1
# ==============================================================================

# ------------------------------------------------------------------------------
# DB SUBNET GROUP
# ------------------------------------------------------------------------------
resource "aws_db_subnet_group" "main" {
  name       = "${var.project_name}-${var.environment}-db-subnet-group"
  subnet_ids = var.subnet_ids

  tags = merge(
    var.common_tags,
    {
      Name              = "${var.project_name}-${var.environment}-db-subnet-group"
      Module            = "compute/rds"
      AssetType         = "DB-Subnet-Group"
    }
  )
}

# ------------------------------------------------------------------------------
# DB PARAMETER GROUP (PostgreSQL Optimizations)
# ------------------------------------------------------------------------------
resource "aws_db_parameter_group" "main" {
  name   = "${var.project_name}-${var.environment}-pg-params"
  family = var.parameter_group_family

  # Security Parameters (ISO 27001 A.9.4.2 - Secure log-on procedures)
  parameter {
    name  = "log_connections"
    value = "1"
  }

  parameter {
    name  = "log_disconnections"
    value = "1"
  }

  parameter {
    name  = "log_duration"
    value = "1"
  }

  parameter {
    name  = "log_statement"
    value = "all"
  }

  # Performance Parameters
  parameter {
    name  = "shared_preload_libraries"
    value = "pg_stat_statements"
  }

  tags = merge(
    var.common_tags,
    {
      Name              = "${var.project_name}-${var.environment}-pg-params"
      Module            = "compute/rds"
      AssetType         = "DB-Parameter-Group"
      ISO27001Control   = "A.9.4.2"
    }
  )
}

# ------------------------------------------------------------------------------
# RDS INSTANCE (PostgreSQL Multi-AZ)
# ------------------------------------------------------------------------------
resource "aws_db_instance" "main" {
  identifier = "${var.project_name}-${var.environment}-db"

  # Engine Configuration
  engine         = var.engine
  engine_version = var.engine_version
  instance_class = var.instance_class

  # Storage Configuration (ISO 27001 A.10.1.1 - Encryption)
  allocated_storage     = var.allocated_storage
  max_allocated_storage = var.max_allocated_storage
  storage_type          = var.storage_type
  storage_encrypted     = true
  kms_key_id            = var.kms_key_id != "" ? var.kms_key_id : null
  iops                  = var.storage_type == "io1" ? var.iops : null

  # Database Configuration
  db_name  = var.db_name
  username = var.master_username
  password = var.master_password
  port     = var.db_port

  # Network Configuration
  db_subnet_group_name   = aws_db_subnet_group.main.name
  vpc_security_group_ids = var.security_group_ids
  publicly_accessible    = false

  # High Availability (ISO 27001 A.17.2.1)
  multi_az               = var.multi_az
  availability_zone      = var.multi_az ? null : var.availability_zone

  # Backup Configuration (AWS Free Tier Compatible)
  backup_retention_period   = 0  # FORCED: Free Tier requires 0 (no automated backups)
  backup_window             = var.backup_window
  copy_tags_to_snapshot     = true
  delete_automated_backups  = false
  skip_final_snapshot       = var.skip_final_snapshot
  final_snapshot_identifier = var.skip_final_snapshot ? null : "${var.project_name}-${var.environment}-final-snapshot-${formatdate("YYYY-MM-DD-hhmm", timestamp())}"

  # Maintenance Configuration
  maintenance_window              = var.maintenance_window
  auto_minor_version_upgrade      = var.auto_minor_version_upgrade
  allow_major_version_upgrade     = false
  apply_immediately               = var.apply_immediately

  # Monitoring Configuration (ISO 27001 A.12.4.1)
  enabled_cloudwatch_logs_exports = var.enabled_cloudwatch_logs_exports
  monitoring_interval             = var.monitoring_interval
  monitoring_role_arn             = var.monitoring_interval > 0 ? aws_iam_role.rds_monitoring[0].arn : null
  performance_insights_enabled    = var.performance_insights_enabled
  performance_insights_retention_period = var.performance_insights_enabled ? var.performance_insights_retention : null
  performance_insights_kms_key_id = var.performance_insights_enabled && var.kms_key_id != "" ? var.kms_key_id : null

  # Parameter and Option Groups
  parameter_group_name = aws_db_parameter_group.main.name

  # Protection Configuration
  deletion_protection = var.deletion_protection

  tags = merge(
    var.common_tags,
    {
      Name              = "${var.project_name}-${var.environment}-db"
      Module            = "compute/rds"
      AssetID           = "COMP-RDS-001"
      AssetType         = "Database"
      Engine            = var.engine
      SecurityLevel     = "Critical"
      BackupEnabled     = "Yes"
      Encrypted         = "Yes"
      MultiAZ           = var.multi_az ? "Yes" : "No"
      ISO27001Control   = "A.12.3.1+A.10.1.1+A.17.2.1"
      NISTControl       = "PR.DS-1+PR.IP-1"
    }
  )

  lifecycle {
    ignore_changes = [
      password,
      final_snapshot_identifier
    ]
  }
}

# ------------------------------------------------------------------------------
# IAM ROLE FOR ENHANCED MONITORING
# ------------------------------------------------------------------------------
resource "aws_iam_role" "rds_monitoring" {
  count = var.monitoring_interval > 0 ? 1 : 0
  name  = "${var.project_name}-${var.environment}-rds-monitoring-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "monitoring.rds.amazonaws.com"
        }
      }
    ]
  })

  tags = merge(
    var.common_tags,
    {
      Name              = "${var.project_name}-${var.environment}-rds-monitoring-role"
      Module            = "compute/rds"
      AssetType         = "IAM-Role"
    }
  )
}

resource "aws_iam_role_policy_attachment" "rds_monitoring" {
  count      = var.monitoring_interval > 0 ? 1 : 0
  role       = aws_iam_role.rds_monitoring[0].name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonRDSEnhancedMonitoringRole"
}

# ------------------------------------------------------------------------------
# CLOUDWATCH ALARMS - RDS MONITORING
# ------------------------------------------------------------------------------

# Alarm: High CPU Utilization
resource "aws_cloudwatch_metric_alarm" "cpu_high" {
  alarm_name          = "${var.project_name}-${var.environment}-rds-cpu-high"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "2"
  metric_name         = "CPUUtilization"
  namespace           = "AWS/RDS"
  period              = "300"
  statistic           = "Average"
  threshold           = var.cpu_threshold
  alarm_description   = "RDS CPU utilization alta"
  treat_missing_data  = "notBreaching"

  dimensions = {
    DBInstanceIdentifier = aws_db_instance.main.id
  }

  tags = merge(
    var.common_tags,
    {
      Name              = "${var.project_name}-rds-cpu-high"
      Module            = "compute/rds"
      AlarmType         = "Performance"
    }
  )
}

# Alarm: Low Free Storage Space
resource "aws_cloudwatch_metric_alarm" "storage_low" {
  alarm_name          = "${var.project_name}-${var.environment}-rds-storage-low"
  comparison_operator = "LessThanThreshold"
  evaluation_periods  = "1"
  metric_name         = "FreeStorageSpace"
  namespace           = "AWS/RDS"
  period              = "300"
  statistic           = "Average"
  threshold           = var.storage_threshold_bytes
  alarm_description   = "RDS espacio de almacenamiento bajo"
  treat_missing_data  = "notBreaching"

  dimensions = {
    DBInstanceIdentifier = aws_db_instance.main.id
  }

  tags = merge(
    var.common_tags,
    {
      Name              = "${var.project_name}-rds-storage-low"
      Module            = "compute/rds"
      AlarmType         = "Capacity"
    }
  )
}

# Alarm: High Database Connections
resource "aws_cloudwatch_metric_alarm" "connections_high" {
  alarm_name          = "${var.project_name}-${var.environment}-rds-connections-high"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "2"
  metric_name         = "DatabaseConnections"
  namespace           = "AWS/RDS"
  period              = "300"
  statistic           = "Average"
  threshold           = var.connections_threshold
  alarm_description   = "RDS conexiones altas"
  treat_missing_data  = "notBreaching"

  dimensions = {
    DBInstanceIdentifier = aws_db_instance.main.id
  }

  tags = merge(
    var.common_tags,
    {
      Name              = "${var.project_name}-rds-connections-high"
      Module            = "compute/rds"
      AlarmType         = "Connections"
    }
  )
}
