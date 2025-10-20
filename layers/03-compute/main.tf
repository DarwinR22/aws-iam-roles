# ==============================================================================
# LAYER 3: COMPUTE - MODULAR ARCHITECTURE
# Propósito: Capa de cómputo con ALB + ASG + RDS Multi-AZ
# Compliance: ISO 27001 A.17.2.1, A.12.3.1, A.13.1.3 | NIST CSF PR.IP-1, PR.DS-1
# ==============================================================================

terraform {
  required_version = ">= 1.5.0"
  
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
  
  backend "s3" {
    bucket         = "terraform-state-bucket-051963532279"
    key            = "sgsi/layer3-compute/terraform.tfstate"
    region         = "us-east-1"
    dynamodb_table = "terraform-locks"
    encrypt        = true
  }
}

# ==============================================================================
# DATA SOURCES - PREVIOUS LAYERS
# ==============================================================================
data "terraform_remote_state" "foundation" {
  backend = "s3"
  config = {
    bucket = "terraform-state-bucket-051963532279"
    key    = "sgsi/layer1-foundation/terraform.tfstate"
    region = "us-east-1"
  }
}

data "terraform_remote_state" "network" {
  backend = "s3"
  config = {
    bucket = "terraform-state-bucket-051963532279"
    key    = "sgsi/layer2-network/terraform.tfstate"
    region = "us-east-1"
  }
}

data "aws_caller_identity" "current" {}
data "aws_region" "current" {}

# ==============================================================================
# AWS PROVIDER CONFIGURATION
# ==============================================================================
provider "aws" {
  region = var.aws_region
  
  default_tags {
    tags = var.common_tags
  }
}

# ==============================================================================
# MODULE: APPLICATION LOAD BALANCER
# ==============================================================================
module "alb" {
  source = "../../modules/compute/alb"

  project_name   = var.project_name
  environment    = var.environment
  vpc_id         = data.terraform_remote_state.network.outputs.vpc_id
  subnet_ids     = data.terraform_remote_state.network.outputs.public_subnet_ids
  security_group_ids = [data.terraform_remote_state.network.outputs.security_group_ids.alb]

  # ALB Configuration
  internal                   = false
  enable_deletion_protection = var.alb_enable_deletion_protection
  idle_timeout               = 60
  access_logs_bucket         = var.alb_access_logs_bucket

  # Target Group Configuration
  target_port     = 80
  target_protocol = "HTTP"

  # Health Check Configuration
  health_check_path                = "/"
  health_check_matcher             = "200"
  health_check_interval            = 30
  health_check_timeout             = 5
  health_check_healthy_threshold   = 2
  health_check_unhealthy_threshold = 2
  enable_stickiness                = false

  # HTTPS Configuration (opcional)
  enable_https    = var.alb_enable_https
  certificate_arn = var.alb_certificate_arn
  ssl_policy      = "ELBSecurityPolicy-TLS13-1-2-2021-06"

  # CloudWatch Alarms Thresholds
  response_time_threshold = 1.0
  error_5xx_threshold     = 10

  common_tags = var.common_tags
}

# ==============================================================================
# MODULE: AUTO SCALING GROUP
# ==============================================================================
module "asg" {
  source = "../../modules/compute/asg"

  project_name       = var.project_name
  environment        = var.environment
  subnet_ids         = data.terraform_remote_state.network.outputs.app_private_subnet_ids
  security_group_ids = [data.terraform_remote_state.network.outputs.security_group_ids.web]
  target_group_arns  = [module.alb.target_group_arn]

  # Instance Configuration
  ami_id                    = var.asg_ami_id
  instance_type             = var.asg_instance_type
  root_volume_size          = 20
  detailed_monitoring       = true
  enable_cloudwatch_agent   = true

  # Auto Scaling Configuration
  min_size                  = var.asg_min_size
  max_size                  = var.asg_max_size
  desired_capacity          = var.asg_desired_capacity
  health_check_type         = "ELB"
  health_check_grace_period = 300

  # Scaling Policies
  scale_up_adjustment   = 1
  scale_up_cooldown     = 300
  scale_down_adjustment = -1
  scale_down_cooldown   = 300

  # CloudWatch Alarm Thresholds
  cpu_high_threshold = 70
  cpu_low_threshold  = 30

  common_tags = var.common_tags

  depends_on = [module.alb]
}

# ==============================================================================
# MODULE: RDS DATABASE (PostgreSQL Multi-AZ)
# ==============================================================================
module "rds" {
  source = "../../modules/compute/rds"

  project_name       = var.project_name
  environment        = var.environment
  subnet_ids         = data.terraform_remote_state.network.outputs.db_private_subnet_ids
  security_group_ids = [data.terraform_remote_state.network.outputs.security_group_ids.db]

  # Database Engine Configuration
  engine                  = var.rds_engine
  engine_version          = var.rds_engine_version
  instance_class          = var.rds_instance_class
  parameter_group_family  = var.rds_parameter_group_family
  db_name                 = var.rds_db_name
  db_port                 = var.rds_db_port
  master_username         = var.rds_master_username
  master_password         = var.rds_master_password

  # Storage Configuration
  allocated_storage     = var.rds_allocated_storage
  max_allocated_storage = var.rds_max_allocated_storage
  storage_type          = "gp3"
  iops                  = null
  kms_key_id            = ""

  # High Availability Configuration (ISO 27001 A.17.2.1)
  multi_az          = var.rds_multi_az
  availability_zone = ""

  # Backup Configuration (ISO 27001 A.12.3.1)
  backup_retention_period = var.rds_backup_retention_period
  backup_window           = "03:00-04:00"
  skip_final_snapshot     = var.rds_skip_final_snapshot

  # Maintenance Configuration
  maintenance_window         = "sun:04:00-sun:05:00"
  auto_minor_version_upgrade = true
  apply_immediately          = false

  # Monitoring Configuration (ISO 27001 A.12.4.1)
  enabled_cloudwatch_logs_exports = ["postgresql", "upgrade"]
  monitoring_interval             = 60
  performance_insights_enabled    = true
  performance_insights_retention  = 7

  # Protection Configuration
  deletion_protection = var.rds_deletion_protection

  # CloudWatch Alarm Thresholds
  cpu_threshold            = 80
  storage_threshold_bytes  = 10737418240  # 10 GB
  connections_threshold    = 80

  common_tags = var.common_tags
}

# ==============================================================================
# CLOUDWATCH LOG GROUP FOR APPLICATION LOGS
# ==============================================================================
resource "aws_cloudwatch_log_group" "application" {
  name              = "/aws/ec2/${var.project_name}-${var.environment}/httpd"
  retention_in_days = 30

  tags = merge(
    var.common_tags,
    {
      Name              = "${var.project_name}-${var.environment}-app-logs"
      Module            = "compute"
      AssetType         = "CloudWatch-LogGroup"
      ISO27001Control   = "A.12.4.1"
    }
  )
}

# ==============================================================================
# SNS TOPIC FOR ALARMS (Optional)
# ==============================================================================
resource "aws_sns_topic" "compute_alarms" {
  count = var.enable_sns_alarms ? 1 : 0
  name  = "${var.project_name}-${var.environment}-compute-alarms"

  tags = merge(
    var.common_tags,
    {
      Name              = "${var.project_name}-${var.environment}-compute-alarms"
      Module            = "compute"
      AssetType         = "SNS-Topic"
    }
  )
}

resource "aws_sns_topic_subscription" "compute_alarms_email" {
  count     = var.enable_sns_alarms && var.sns_alarm_email != "" ? 1 : 0
  topic_arn = aws_sns_topic.compute_alarms[0].arn
  protocol  = "email"
  endpoint  = var.sns_alarm_email
}
