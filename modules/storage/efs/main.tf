# ==============================================================================
# STORAGE MODULE: EFS (Elastic File System)
# Propósito: File system compartido NFS para EC2, encrypted, HA
# Compliance: ISO 27001 A.12.3.1, A.12.6.1 | NIST CSF PR.DS-1, PR.IP-12
# ==============================================================================

# ------------------------------------------------------------------------------
# EFS FILE SYSTEM
# ------------------------------------------------------------------------------
resource "aws_efs_file_system" "main" {
  creation_token = var.efs_name
  encrypted      = var.enable_encryption
  kms_key_id     = var.kms_key_arn
  
  performance_mode                = var.performance_mode
  throughput_mode                 = var.throughput_mode
  provisioned_throughput_in_mibps = var.throughput_mode == "provisioned" ? var.provisioned_throughput : null
  
  # Lifecycle Management - Mover archivos inactivos a IA
  lifecycle_policy {
    transition_to_ia = var.lifecycle_policy_transition_to_ia
  }
  
  # Opcional: Transición de regreso a Standard
  dynamic "lifecycle_policy" {
    for_each = var.lifecycle_policy_transition_to_primary != null ? [1] : []
    content {
      transition_to_primary_storage_class = var.lifecycle_policy_transition_to_primary
    }
  }
  
  tags = merge(
    var.common_tags,
    {
      Name       = var.efs_name
      Layer      = "Storage"
      Module     = "EFS"
      Compliance = "ISO27001-A.12.3.1,A.12.6.1"
    }
  )
}

# ------------------------------------------------------------------------------
# EFS MOUNT TARGETS - Multi-AZ para HA
# ------------------------------------------------------------------------------
resource "aws_efs_mount_target" "main" {
  count = length(var.subnet_ids)
  
  file_system_id  = aws_efs_file_system.main.id
  subnet_id       = var.subnet_ids[count.index]
  security_groups = var.security_group_ids
}

# ------------------------------------------------------------------------------
# EFS BACKUP POLICY
# ------------------------------------------------------------------------------
resource "aws_efs_backup_policy" "main" {
  count = var.enable_backup ? 1 : 0
  
  file_system_id = aws_efs_file_system.main.id
  
  backup_policy {
    status = "ENABLED"
  }
}

# ------------------------------------------------------------------------------
# EFS FILE SYSTEM POLICY - Access Control
# ------------------------------------------------------------------------------
resource "aws_efs_file_system_policy" "main" {
  count = var.file_system_policy_json != null ? 1 : 0
  
  file_system_id = aws_efs_file_system.main.id
  policy         = var.file_system_policy_json
}

# ------------------------------------------------------------------------------
# EFS ACCESS POINTS - Abstraction Layer para Multi-Tenancy
# ------------------------------------------------------------------------------
resource "aws_efs_access_point" "app" {
  count = var.create_access_points ? 1 : 0
  
  file_system_id = aws_efs_file_system.main.id
  
  posix_user {
    gid = 1000
    uid = 1000
  }
  
  root_directory {
    path = "/app"
    creation_info {
      owner_gid   = 1000
      owner_uid   = 1000
      permissions = "755"
    }
  }
  
  tags = merge(
    var.common_tags,
    {
      Name = "${var.efs_name}-app-access-point"
    }
  )
}

resource "aws_efs_access_point" "data" {
  count = var.create_access_points ? 1 : 0
  
  file_system_id = aws_efs_file_system.main.id
  
  posix_user {
    gid = 1000
    uid = 1000
  }
  
  root_directory {
    path = "/data"
    creation_info {
      owner_gid   = 1000
      owner_uid   = 1000
      permissions = "750"
    }
  }
  
  tags = merge(
    var.common_tags,
    {
      Name = "${var.efs_name}-data-access-point"
    }
  )
}

# ------------------------------------------------------------------------------
# CLOUDWATCH ALARMS - MONITORING
# ------------------------------------------------------------------------------
resource "aws_cloudwatch_metric_alarm" "burst_credit_balance" {
  count = var.enable_cloudwatch_alarms ? 1 : 0
  
  alarm_name          = "${var.efs_name}-burst-credit-low"
  comparison_operator = "LessThanThreshold"
  evaluation_periods  = 2
  metric_name         = "BurstCreditBalance"
  namespace           = "AWS/EFS"
  period              = 600
  statistic           = "Average"
  threshold           = 1000000000000 # 1 TB
  alarm_description   = "EFS Burst Credit Balance bajo - considerar Provisioned Throughput"
  treat_missing_data  = "notBreaching"
  
  dimensions = {
    FileSystemId = aws_efs_file_system.main.id
  }
  
  alarm_actions = var.sns_topic_arn != null ? [var.sns_topic_arn] : []
  
  tags = var.common_tags
}

resource "aws_cloudwatch_metric_alarm" "client_connections" {
  count = var.enable_cloudwatch_alarms ? 1 : 0
  
  alarm_name          = "${var.efs_name}-high-connections"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 2
  metric_name         = "ClientConnections"
  namespace           = "AWS/EFS"
  period              = 300
  statistic           = "Sum"
  threshold           = var.max_client_connections
  alarm_description   = "Alto número de conexiones a EFS"
  treat_missing_data  = "notBreaching"
  
  dimensions = {
    FileSystemId = aws_efs_file_system.main.id
  }
  
  alarm_actions = var.sns_topic_arn != null ? [var.sns_topic_arn] : []
  
  tags = var.common_tags
}
