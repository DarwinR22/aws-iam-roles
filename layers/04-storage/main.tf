# ==============================================================================
# LAYER 4: STORAGE
# S3, EFS, EBS, Backup Services
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
# DATA SOURCES (Read from previous layers)
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
      Project              = "SGSI-Implementation"
      Layer                = "Storage"
      Environment          = var.environment
      ManagedBy           = "Terraform"
      SecurityLevel       = "High"
      ComplianceScope     = "ISO27001,NIST-CSF"
      CreatedBy           = "GitHub-Actions"
      MaintenanceWindow   = "Sunday-2AM-6AM"
    }
  }
}

# ==============================================================================
# S3 BUCKETS
# ==============================================================================
# Application Data Bucket
resource "aws_s3_bucket" "sgsi_app_data" {
  bucket = "sgsi-app-data-${var.environment}-${random_string.bucket_suffix.result}"

  tags = merge(
    var.common_tags,
    {
      Name                = "sgsi-app-data"
      AssetID             = "STOR-S3-001"
      AssetType           = "S3-Bucket"
      DataClassification  = "Internal"
      BackupRequired      = "Yes"
    }
  )
}

# Log Storage Bucket
resource "aws_s3_bucket" "sgsi_logs" {
  bucket = "sgsi-logs-${var.environment}-${random_string.bucket_suffix.result}"

  tags = merge(
    var.common_tags,
    {
      Name                = "sgsi-logs"
      AssetID             = "STOR-S3-002"
      AssetType           = "S3-Bucket"
      DataClassification  = "Internal"
      BackupRequired      = "Yes"
    }
  )
}

# Backup Storage Bucket
resource "aws_s3_bucket" "sgsi_backups" {
  bucket = "sgsi-backups-${var.environment}-${random_string.bucket_suffix.result}"

  tags = merge(
    var.common_tags,
    {
      Name                = "sgsi-backups"
      AssetID             = "STOR-S3-003"
      AssetType           = "S3-Bucket"
      DataClassification  = "Critical"
      BackupRequired      = "No"  # This IS the backup
    }
  )
}

resource "random_string" "bucket_suffix" {
  length  = 8
  special = false
  upper   = false
}

# S3 Bucket Configurations
resource "aws_s3_bucket_encryption" "sgsi_app_data" {
  bucket = aws_s3_bucket.sgsi_app_data.id

  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        sse_algorithm = "AES256"
      }
    }
  }
}

resource "aws_s3_bucket_versioning" "sgsi_app_data" {
  bucket = aws_s3_bucket.sgsi_app_data.id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_public_access_block" "sgsi_app_data" {
  bucket = aws_s3_bucket.sgsi_app_data.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# ==============================================================================
# EFS FILE SYSTEM
# ==============================================================================
resource "aws_efs_file_system" "sgsi_shared" {
  creation_token   = "sgsi-shared-fs"
  performance_mode = "generalPurpose"
  throughput_mode  = "provisioned"
  provisioned_throughput_in_mibps = 100

  encrypted = true

  tags = merge(
    var.common_tags,
    {
      Name                = "sgsi-shared-fs"
      AssetID             = "STOR-EFS-001"
      AssetType           = "EFS-FileSystem"
      BackupRequired      = "Yes"
    }
  )
}

# EFS Mount Targets
resource "aws_efs_mount_target" "sgsi_shared" {
  count           = length(data.terraform_remote_state.network.outputs.app_private_subnet_ids)
  file_system_id  = aws_efs_file_system.sgsi_shared.id
  subnet_id       = data.terraform_remote_state.network.outputs.app_private_subnet_ids[count.index]
  security_groups = [aws_security_group.efs.id]
}

# EFS Security Group
resource "aws_security_group" "efs" {
  name        = "sgsi-efs-sg"
  description = "Security group for EFS mount targets"
  vpc_id      = data.terraform_remote_state.network.outputs.vpc_id

  ingress {
    from_port   = 2049
    to_port     = 2049
    protocol    = "tcp"
    cidr_blocks = [data.terraform_remote_state.network.outputs.vpc_cidr_block]
    description = "NFS access from VPC"
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
    description = "All outbound traffic"
  }

  tags = merge(
    var.common_tags,
    {
      Name                = "sgsi-efs-sg"
      AssetType           = "Security-Group"
    }
  )
}

# ==============================================================================
# AWS BACKUP
# ==============================================================================
resource "aws_backup_vault" "sgsi_vault" {
  name        = "sgsi-backup-vault"
  kms_key_arn = aws_kms_key.backup.arn

  tags = merge(
    var.common_tags,
    {
      Name                = "sgsi-backup-vault"
      AssetID             = "STOR-BACKUP-001"
      AssetType           = "Backup-Vault"
    }
  )
}

resource "aws_backup_plan" "sgsi_plan" {
  name = "sgsi-backup-plan"

  rule {
    rule_name         = "daily_backups"
    target_vault_name = aws_backup_vault.sgsi_vault.name
    schedule          = "cron(0 2 ? * * *)"  # Daily at 2 AM

    recovery_point_tags = var.common_tags

    lifecycle {
      cold_storage_after = 30
      delete_after       = 365
    }
  }

  tags = merge(
    var.common_tags,
    {
      Name                = "sgsi-backup-plan"
      AssetType           = "Backup-Plan"
    }
  )
}

# ==============================================================================
# KMS KEY FOR BACKUP ENCRYPTION
# ==============================================================================
resource "aws_kms_key" "backup" {
  description             = "KMS key for SGSI backup encryption"
  deletion_window_in_days = 7

  tags = merge(
    var.common_tags,
    {
      Name                = "sgsi-backup-key"
      AssetType           = "KMS-Key"
    }
  )
}

resource "aws_kms_alias" "backup" {
  name          = "alias/sgsi-backup-key"
  target_key_id = aws_kms_key.backup.key_id
}