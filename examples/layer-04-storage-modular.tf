# ==============================================================================
# LAYER 04 - STORAGE (MODULAR APPROACH EXAMPLE)
# ==============================================================================
# This example shows how to use the new modular structure instead of 
# monolithic main.tf files. This approach scales to hundreds of resources.
# ==============================================================================

terraform {
  required_version = ">= 1.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
  
  backend "s3" {
    # Backend configuration will be provided via backend.hcl
  }
}

# ==============================================================================
# DATA SOURCES
# ==============================================================================

data "terraform_remote_state" "foundation" {
  backend = "s3"
  config = {
    bucket = var.state_bucket
    key    = "layers/01-foundation/terraform.tfstate"
    region = var.aws_region
  }
}

data "terraform_remote_state" "network" {
  backend = "s3"
  config = {
    bucket = var.state_bucket
    key    = "layers/02-network/terraform.tfstate"
    region = var.aws_region
  }
}

# ==============================================================================
# LOCALS FOR COMMON CONFIGURATION
# ==============================================================================

locals {
  common_tags = {
    Project     = "SGSI-Implementation"
    Environment = var.environment
    Layer       = "04-storage"
    ManagedBy   = "Terraform"
    CreatedDate = formatdate("YYYY-MM-DD", timestamp())
  }
  
  # KMS key for encryption (from foundation layer)
  kms_key_arn = data.terraform_remote_state.foundation.outputs.kms_key_arn
}

# ==============================================================================
# APPLICATION DATA BUCKETS (Using S3 Bucket Module)
# ==============================================================================

# Primary application data bucket
module "app_data_bucket" {
  source = "../../modules/storage/s3-bucket"
  
  bucket_name    = "${var.project_name}-app-data-${var.environment}"
  bucket_purpose = "app-data"
  
  # Security configuration
  versioning_enabled    = true
  sse_algorithm        = "aws:kms"
  kms_master_key_id    = local.kms_key_arn
  block_public_acls    = true
  block_public_policy  = true
  ignore_public_acls   = true
  restrict_public_buckets = true
  
  # Lifecycle configuration
  lifecycle_rules = [
    {
      id     = "app_data_lifecycle"
      status = "Enabled"
      transitions = [
        {
          days          = 30
          storage_class = "STANDARD_IA"
        },
        {
          days          = 90
          storage_class = "GLACIER"
        },
        {
          days          = 365
          storage_class = "DEEP_ARCHIVE"
        }
      ]
      expiration = {
        days = 2555  # 7 years retention
      }
      noncurrent_version_transitions = [
        {
          days          = 30
          storage_class = "STANDARD_IA"
        }
      ]
      noncurrent_version_expiration = {
        days = 365
      }
    }
  ]
  
  # CloudWatch monitoring
  create_cloudwatch_alarms = true
  bucket_size_alarm_threshold = 107374182400  # 100 GB
  alarm_actions = [data.terraform_remote_state.foundation.outputs.alert_topic_arn]
  
  environment    = var.environment
  common_tags    = local.common_tags
  additional_tags = {
    DataClassification = "Confidential"
    BackupRequired     = "true"
  }
}

# Backup bucket for critical data
module "backup_bucket" {
  source = "../../modules/storage/s3-bucket"
  
  bucket_name    = "${var.project_name}-backups-${var.environment}"
  bucket_purpose = "backups"
  
  # Enhanced security for backups
  versioning_enabled    = true
  sse_algorithm        = "aws:kms"
  kms_master_key_id    = local.kms_key_arn
  block_public_acls    = true
  block_public_policy  = true
  ignore_public_acls   = true
  restrict_public_buckets = true
  
  # Long-term retention for backups
  lifecycle_rules = [
    {
      id     = "backup_lifecycle"
      status = "Enabled"
      transitions = [
        {
          days          = 1
          storage_class = "GLACIER"
        },
        {
          days          = 90
          storage_class = "DEEP_ARCHIVE"
        }
      ]
      expiration = {
        days = 3650  # 10 years retention for backups
      }
      noncurrent_version_transitions = []
      noncurrent_version_expiration = {
        days = 30
      }
    }
  ]
  
  environment    = var.environment
  common_tags    = local.common_tags
  additional_tags = {
    DataClassification = "Critical"
    RetentionPolicy    = "10-years"
  }
}

# Logs bucket with access logging
module "logs_bucket" {
  source = "../../modules/storage/s3-bucket"
  
  bucket_name    = "${var.project_name}-logs-${var.environment}"
  bucket_purpose = "logs"
  
  # Security configuration
  versioning_enabled    = true
  sse_algorithm        = "AES256"  # AES256 for logs is sufficient
  block_public_acls    = true
  block_public_policy  = true
  ignore_public_acls   = true
  restrict_public_buckets = true
  
  # Lifecycle for log retention
  lifecycle_rules = [
    {
      id     = "logs_lifecycle"
      status = "Enabled"
      transitions = [
        {
          days          = 30
          storage_class = "STANDARD_IA"
        },
        {
          days          = 90
          storage_class = "GLACIER"
        }
      ]
      expiration = {
        days = 1095  # 3 years retention for logs
      }
      noncurrent_version_transitions = []
      noncurrent_version_expiration = {
        days = 30
      }
    }
  ]
  
  environment    = var.environment
  common_tags    = local.common_tags
  additional_tags = {
    DataClassification = "Internal"
    LogType           = "Application"
  }
}

# ==============================================================================
# EFS FILE SYSTEMS (Using EFS Module)
# ==============================================================================

module "app_shared_storage" {
  source = "../../modules/storage/efs-file-system"
  
  name             = "${var.project_name}-shared-${var.environment}"
  performance_mode = "generalPurpose"
  throughput_mode  = "provisioned"
  encrypted        = true
  
  # Mount targets in private subnets
  subnet_ids = data.terraform_remote_state.network.outputs.private_subnet_ids
  vpc_id     = data.terraform_remote_state.network.outputs.vpc_id
  
  environment    = var.environment
  common_tags    = local.common_tags
  additional_tags = {
    Purpose      = "SharedApplicationData"
    Availability = "Multi-AZ"
  }
}

# ==============================================================================
# BACKUP CONFIGURATION (Using Backup Vault Module)
# ==============================================================================

module "backup_vault" {
  source = "../../modules/storage/backup-vault"
  
  vault_name       = "${var.project_name}-vault-${var.environment}"
  kms_key_arn      = local.kms_key_arn
  backup_plan_name = "${var.project_name}-backup-plan-${var.environment}"
  
  # Daily backups at 5 AM UTC
  schedule        = "cron(0 5 ? * * *)"
  retention_days  = 30
  
  environment    = var.environment
  common_tags    = local.common_tags
  additional_tags = {
    BackupType = "Automated"
    Schedule   = "Daily"
  }
}

# ==============================================================================
# BUCKET POLICIES (Example of additional configuration)
# ==============================================================================

# Restrict access to app data bucket to specific roles
resource "aws_s3_bucket_policy" "app_data_policy" {
  bucket = module.app_data_bucket.bucket_id
  
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "RestrictToAuthorizedRoles"
        Effect = "Allow"
        Principal = {
          AWS = [
            data.terraform_remote_state.foundation.outputs.app_execution_role_arn,
            data.terraform_remote_state.foundation.outputs.admin_role_arn
          ]
        }
        Action = [
          "s3:GetObject",
          "s3:PutObject",
          "s3:DeleteObject"
        ]
        Resource = "${module.app_data_bucket.bucket_arn}/*"
      },
      {
        Sid    = "DenyInsecureConnections"
        Effect = "Deny"
        Principal = "*"
        Action = "s3:*"
        Resource = [
          module.app_data_bucket.bucket_arn,
          "${module.app_data_bucket.bucket_arn}/*"
        ]
        Condition = {
          Bool = {
            "aws:SecureTransport" = "false"
          }
        }
      }
    ]
  })
}

# ==============================================================================
# EXAMPLE: SCALING TO HUNDREDS OF RESOURCES
# ==============================================================================

# With the modular approach, you can easily scale to hundreds of S3 buckets:
# 
# module "bucket_001" { source = "../../modules/storage/s3-bucket"; ... }
# module "bucket_002" { source = "../../modules/storage/s3-bucket"; ... }
# ... 
# module "bucket_200" { source = "../../modules/storage/s3-bucket"; ... }
#
# This is much more maintainable than having 200 aws_s3_bucket resources
# in a single monolithic main.tf file.

# ==============================================================================
# OUTPUTS
# ==============================================================================

output "storage_info" {
  description = "Information about storage resources"
  value = {
    app_data_bucket = {
      id   = module.app_data_bucket.bucket_id
      arn  = module.app_data_bucket.bucket_arn
      name = module.app_data_bucket.bucket_domain_name
    }
    backup_bucket = {
      id   = module.backup_bucket.bucket_id
      arn  = module.backup_bucket.bucket_arn
      name = module.backup_bucket.bucket_domain_name
    }
    logs_bucket = {
      id   = module.logs_bucket.bucket_id
      arn  = module.logs_bucket.bucket_arn
      name = module.logs_bucket.bucket_domain_name
    }
    shared_storage = {
      id       = module.app_shared_storage.file_system_id
      arn      = module.app_shared_storage.file_system_arn
      dns_name = module.app_shared_storage.dns_name
    }
    backup_vault = {
      id  = module.backup_vault.backup_vault_id
      arn = module.backup_vault.backup_vault_arn
    }
  }
}