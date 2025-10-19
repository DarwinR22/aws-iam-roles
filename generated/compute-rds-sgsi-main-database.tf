# RDS Terraform generated from sgsi-main-database.yaml
# MySQL Database for SGSI Layer 3

# DB Subnet Group
resource "aws_db_subnet_group" "sgsi_db_subnet_group" {
  name       = "sgsi-db-subnet-group"
  subnet_ids = local.db_subnet_ids

  tags = {
    Name        = "sgsi-db-subnet-group"
    Environment = "dev"
    Layer       = "3-compute"
    Component   = "database"
  }
}

# DB Parameter Group
resource "aws_db_parameter_group" "sgsi_mysql_params" {
  family = "mysql8.0"
  name   = "sgsi-mysql-params"

  parameter {
    name  = "innodb_buffer_pool_size"
    value = "{DBInstanceClassMemory*3/4}"
  }

  parameter {
    name  = "max_connections"
    value = "1000"
  }

  tags = {
    Name        = "sgsi-mysql-params"
    Environment = "dev"
    Layer       = "3-compute"
  }
}

# RDS Instance
resource "aws_db_instance" "sgsi_main_database" {
  identifier     = "sgsi-main-database"
  engine         = "mysql"
  engine_version = "8.0"
  instance_class = "db.t3.micro"

  allocated_storage     = 20
  max_allocated_storage = 100
  storage_type          = "gp2"
  storage_encrypted     = true

  db_name  = "sgsidb"
  username = "admin"
  password = "ChangeMe123!"

  vpc_security_group_ids = [local.db_sg_id]
  db_subnet_group_name   = aws_db_subnet_group.sgsi_db_subnet_group.name
  parameter_group_name   = aws_db_parameter_group.sgsi_mysql_params.name

  multi_az                = true
  publicly_accessible     = false
  backup_retention_period = 7
  backup_window           = "03:00-04:00"
  maintenance_window      = "sun:04:00-sun:05:00"

  deletion_protection       = false
  skip_final_snapshot       = false
  final_snapshot_identifier = "sgsi-main-database-final-snapshot"

  # Performance Insights
  performance_insights_enabled          = true
  performance_insights_retention_period = 7

  # Enhanced monitoring
  monitoring_interval = 60
  monitoring_role_arn = aws_iam_role.sgsi_rds_monitoring_role.arn

  enabled_cloudwatch_logs_exports = ["error", "general", "slowquery"]

  tags = {
    Name        = "sgsi-main-database"
    Environment = "dev"
    Layer       = "3-compute"
    Component   = "database"
    Proposito   = "sgsi-application-database"
  }
}

# IAM Role for Enhanced Monitoring
resource "aws_iam_role" "sgsi_rds_monitoring_role" {
  name = "sgsi-rds-monitoring-role"

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

  tags = {
    Name        = "sgsi-rds-monitoring-role"
    Environment = "dev"
    Layer       = "3-compute"
  }
}

resource "aws_iam_role_policy_attachment" "sgsi_rds_monitoring" {
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonRDSEnhancedMonitoringRole"
  role       = aws_iam_role.sgsi_rds_monitoring_role.name
}
