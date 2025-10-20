# ==============================================================================
# LAYER 4: STORAGE - MODULAR ARCHITECTURE
# Propósito: Capa de almacenamiento con S3 Enhanced, EFS, AWS Backup
# Compliance: ISO 27001 A.12.3.1, A.18.1.3, A.17.1.2 | NIST CSF PR.DS-1, PR.IP-4
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
    key            = "sgsi/layer4-storage/terraform.tfstate"
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

data "terraform_remote_state" "compute" {
  backend = "s3"
  config = {
    bucket = "terraform-state-bucket-051963532279"
    key    = "sgsi/layer3-compute/terraform.tfstate"
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
    tags = {
      Project     = var.project_name
      Environment = var.environment
      ManagedBy   = "Terraform"
      Layer       = "Storage"
      Compliance  = "ISO27001,NIST-CSF"
      Owner       = var.owner
    }
  }
}

# ==============================================================================
# LOCAL VARIABLES
# ==============================================================================
locals {
  common_tags = {
    Project     = var.project_name
    Environment = var.environment
    Layer       = "Storage"
    Compliance  = "ISO27001,NIST-CSF"
  }
  
  # Subnets privadas de Layer 2 para EFS mount targets
  app_private_subnet_ids = data.terraform_remote_state.network.outputs.app_private_subnet_ids
  
  # Security Group para EFS (usar map de security_group_ids)
  app_sg_id = data.terraform_remote_state.network.outputs.security_group_ids.app
  
  # Información de RDS para backup
  rds_instance_arn = try(data.terraform_remote_state.compute.outputs.db_instance_arn, null)
}

# ==============================================================================
# MODULE: S3 APPLICATION BUCKET
# ==============================================================================
module "s3_app_data" {
  source = "../../modules/storage/s3"
  
  bucket_name             = "${var.project_name}-${var.environment}-app-data"
  data_classification     = "Internal"
  enable_versioning       = true
  enable_mfa_delete       = false
  enable_lifecycle        = true
  lifecycle_ia_days       = 30
  lifecycle_glacier_days  = 90
  version_expiration_days = 365
  enable_logging          = true
  enable_object_lock      = false
  enable_replication      = var.enable_s3_replication
  enable_metrics          = true
  enable_inventory        = true
  
  common_tags = merge(
    local.common_tags,
    {
      Name      = "${var.project_name}-${var.environment}-app-data"
      Purpose   = "Application data storage"
      DataClass = "Internal"
    }
  )
}

# ==============================================================================
# MODULE: S3 LOGS BUCKET
# ==============================================================================
module "s3_logs" {
  source = "../../modules/storage/s3"
  
  bucket_name             = "${var.project_name}-${var.environment}-logs"
  data_classification     = "Internal"
  enable_versioning       = false
  enable_lifecycle        = true
  lifecycle_ia_days       = 30
  lifecycle_glacier_days  = 90
  version_expiration_days = 90
  enable_logging          = false # Los logs no necesitan logs recursivos
  enable_object_lock      = true  # WORM para cumplir auditoría
  object_lock_retention_days = 90
  enable_metrics          = true
  
  common_tags = merge(
    local.common_tags,
    {
      Name      = "${var.project_name}-${var.environment}-logs"
      Purpose   = "Centralized logging"
      DataClass = "Internal"
    }
  )
}

# ==============================================================================
# MODULE: S3 BACKUP BUCKET (OPCIONAL)
# ==============================================================================
module "s3_backup" {
  count  = var.enable_s3_backup_bucket ? 1 : 0
  source = "../../modules/storage/s3"
  
  bucket_name             = "${var.project_name}-${var.environment}-backup"
  data_classification     = "Confidential"
  enable_versioning       = true
  enable_lifecycle        = true
  lifecycle_ia_days       = 30
  lifecycle_glacier_days  = 90
  version_expiration_days = 730 # 2 años
  enable_logging          = true
  enable_object_lock      = true
  object_lock_retention_days = 365
  enable_metrics          = true
  
  common_tags = merge(
    local.common_tags,
    {
      Name      = "${var.project_name}-${var.environment}-backup"
      Purpose   = "Backup archives"
      DataClass = "Confidential"
    }
  )
}

# ==============================================================================
# MODULE: EFS - SHARED FILE SYSTEM
# ==============================================================================
module "efs" {
  source = "../../modules/storage/efs"
  
  efs_name                               = "${var.project_name}-${var.environment}-efs"
  enable_encryption                      = true
  performance_mode                       = var.efs_performance_mode
  throughput_mode                        = var.efs_throughput_mode
  provisioned_throughput                 = var.efs_provisioned_throughput
  lifecycle_policy_transition_to_ia      = var.efs_lifecycle_transition_to_ia
  lifecycle_policy_transition_to_primary = var.efs_lifecycle_transition_to_primary
  
  # Network
  subnet_ids         = local.app_private_subnet_ids
  security_group_ids = [local.app_sg_id]
  
  # Features
  enable_backup            = true
  create_access_points     = true
  enable_cloudwatch_alarms = true
  max_client_connections   = 50
  
  common_tags = merge(
    local.common_tags,
    {
      Name    = "${var.project_name}-${var.environment}-efs"
      Purpose = "Shared application file storage"
      Backup  = "true" # Tag para AWS Backup
    }
  )
}

# ==============================================================================
# IAM ROLE: AWS BACKUP SERVICE
# ==============================================================================
resource "aws_iam_role" "backup" {
  name = "${var.project_name}-${var.environment}-backup-role"
  
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "backup.amazonaws.com"
        }
        Action = "sts:AssumeRole"
      }
    ]
  })
  
  tags = merge(
    local.common_tags,
    {
      Name = "${var.project_name}-${var.environment}-backup-role"
    }
  )
}

# Attach AWS managed policy para backup
resource "aws_iam_role_policy_attachment" "backup_service" {
  role       = aws_iam_role.backup.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSBackupServiceRolePolicyForBackup"
}

resource "aws_iam_role_policy_attachment" "backup_restore" {
  role       = aws_iam_role.backup.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSBackupServiceRolePolicyForRestores"
}

# ==============================================================================
# MODULE: AWS BACKUP
# ==============================================================================
module "backup" {
  source = "../../modules/storage/backup"
  
  vault_name = "${var.project_name}-${var.environment}-vault"
  plan_name  = "${var.project_name}-${var.environment}-plan"
  
  # Encryption
  kms_key_arn = null # Usar AWS managed key
  
  # Vault Lock (WORM)
  enable_vault_lock             = var.enable_backup_vault_lock
  vault_lock_changeable_days    = 3
  vault_lock_min_retention_days = 30
  vault_lock_max_retention_days = 365
  
  # Schedules
  daily_backup_schedule   = "cron(0 2 * * ? *)"   # 02:00 AM UTC diario
  weekly_backup_schedule  = "cron(0 3 ? * SUN *)" # 03:00 AM UTC domingos
  monthly_backup_schedule = "cron(0 4 1 * ? *)"   # 04:00 AM UTC día 1
  
  # Retention
  daily_retention_days   = var.backup_daily_retention_days
  weekly_retention_days  = var.backup_weekly_retention_days
  monthly_retention_days = var.backup_monthly_retention_days
  
  # Cross-region backup
  enable_cross_region_backup = var.enable_cross_region_backup
  destination_vault_arn      = var.backup_destination_vault_arn
  
  # Resource selection
  backup_role_arn  = aws_iam_role.backup.arn
  backup_tag_key   = "Backup"
  backup_tag_value = "true"
  
  # Notifications
  create_sns_topic         = true
  enable_cloudwatch_alarms = true
  
  common_tags = local.common_tags
  
  depends_on = [
    aws_iam_role_policy_attachment.backup_service,
    aws_iam_role_policy_attachment.backup_restore
  ]
}