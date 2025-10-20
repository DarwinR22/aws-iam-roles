# ==============================================================================
# LAYER 1: FOUNDATION
# IAM Roles, Policies, and S3 Backend Configuration
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
    key            = "sgsi/layer1-foundation/terraform.tfstate"
    region         = "us-east-1"
    dynamodb_table = "terraform-locks"
    encrypt        = true
    
    # Optional: Use workspace for environment separation
    workspace_key_prefix = "environments"
  }
}

# ==============================================================================
# AWS PROVIDER CONFIGURATION
# ==============================================================================
provider "aws" {
  region = var.aws_region
  
  default_tags {
    tags = {
      Project              = "SGSI_Implementation"
      Layer                = "Foundation"
      Environment          = var.environment
      ManagedBy           = "Terraform"
      SecurityLevel       = "Critical"
      ComplianceScope     = "ISO27001_NIST_CSF"
      CreatedBy           = "GitHub_Actions"
      MaintenanceWindow   = "Sunday_2AM_6AM"
    }
  }
}

# ==============================================================================
# OIDC IDENTITY PROVIDER FOR GITHUB ACTIONS
# ==============================================================================
# OIDC Provider already exists and is managed outside Terraform
# GitHub Actions uses: arn:aws:iam::051963532279:oidc-provider/token.actions.githubusercontent.com
# No need to create or reference it in Terraform - GitHub Actions handles OIDC automatically

# ==============================================================================
# IAM DEPLOYMENT ROLE (Use existing role for now)
# ==============================================================================
# Using existing role: github-actions-deployment-role for this deployment
data "aws_iam_role" "github_actions_deployment_role" {
  name = "github-actions-deployment-role"
}

# ==============================================================================
# TEMPORARY INLINE POLICY FOR DEPLOYMENT (Remove after managed policies work)
# ==============================================================================
# Commented out - using existing role with existing permissions
# resource "aws_iam_role_policy" "temp_deployment_policy" {
#   name = "temp-full-deployment-policy"
#   role = data.aws_iam_role.github_actions_deployment_role.id
#
#   policy = jsonencode({
#     Version = "2012-10-17"
#     Statement = [
#       {
#         Effect = "Allow"
#         Action = "*"
#         Resource = "*"
#       }
#     ]
#   })
# }

# ==============================================================================
# IAM POLICY MODULES (9 Consolidated Policies - Within AWS 10-Policy Limit)
# ==============================================================================

# Core IAM + STS Management (Consolidated)
module "github_deployment_iam" {
  source = "../../generated/modules/policies/github_deployment_iam"
  
  environment      = var.environment
  abac_conditions  = var.abac_conditions
  common_tags     = var.common_tags
}

# Network Infrastructure (VPC, Subnets, Security Groups)
module "github_deployment_network" {
  source = "../../generated/modules/policies/github_deployment_network"
  
  environment      = var.environment
  abac_conditions  = var.abac_conditions
  common_tags     = var.common_tags
}

# CloudWatch (Logs, Metrics, SNS)
module "github_deployment_cloudwatch" {
  source = "../../generated/modules/policies/github_deployment_cloudwatch"
  
  environment      = var.environment
  abac_conditions  = var.abac_conditions
  common_tags     = var.common_tags
}

# Security Monitoring (CloudTrail, Config, GuardDuty)
module "github_deployment_monitoring" {
  source = "../../generated/modules/policies/github_deployment_monitoring"
  
  environment      = var.environment
  abac_conditions  = var.abac_conditions
  common_tags     = var.common_tags
}

# Deployment Tools (CloudFormation + Terraform State)
module "github_deployment_deployment" {
  source = "../../generated/modules/policies/github_deployment_deployment"
  
  environment      = var.environment
  abac_conditions  = var.abac_conditions
  common_tags     = var.common_tags
}

# Application Services (Lambda, EventBridge, etc.)
module "github_deployment_application" {
  source = "../../generated/modules/policies/github_deployment_application"
  
  environment      = var.environment
  abac_conditions  = var.abac_conditions
  common_tags     = var.common_tags
}

# Database Services
module "github_deployment_database" {
  source = "../../generated/modules/policies/github_deployment_database"
  
  environment      = var.environment
  abac_conditions  = var.abac_conditions
  common_tags     = var.common_tags
}

# Storage Services
module "github_deployment_storage" {
  source = "../../generated/modules/policies/github_deployment_storage"
  
  environment      = var.environment
  abac_conditions  = var.abac_conditions
  common_tags     = var.common_tags
}

# Glue/ETL Services
module "github_deployment_glue" {
  source = "../../generated/modules/policies/github_deployment_glue"
  
  environment      = var.environment
  abac_conditions  = var.abac_conditions
  common_tags     = var.common_tags
}

# Compute Services (ELB, ALB, ASG, EC2)
module "github_deployment_compute" {
  source = "../../generated/modules/policies/github_deployment_compute"
  
  environment      = var.environment
  abac_conditions  = var.abac_conditions
  common_tags     = var.common_tags
}

# ==============================================================================
# POLICY ATTACHMENTS (10 Optimized Policies)
# ==============================================================================
resource "aws_iam_role_policy_attachment" "github_deployment_policies" {
  for_each = {
    iam         = module.github_deployment_iam.policy_arn         # IAM + STS consolidated
    network     = module.github_deployment_network.policy_arn     # VPC infrastructure  
    cloudwatch  = module.github_deployment_cloudwatch.policy_arn  # Logs, metrics, SNS
    monitoring  = module.github_deployment_monitoring.policy_arn  # Security monitoring
    deployment  = module.github_deployment_deployment.policy_arn  # CloudFormation + tfstate
    application = module.github_deployment_application.policy_arn # Lambda, EventBridge
    database    = module.github_deployment_database.policy_arn    # RDS
    storage     = module.github_deployment_storage.policy_arn     # S3, EFS
    glue        = module.github_deployment_glue.policy_arn        # AWS Glue
    compute     = module.github_deployment_compute.policy_arn     # ELB, ALB, ASG, EC2
  }

  role       = data.aws_iam_role.github_actions_deployment_role.name
  policy_arn = each.value
}

# ==============================================================================
# SECURITY ENHANCEMENT MODULES (CAPA 1 - 100% COMPLIANCE)
# ==============================================================================

# IAM Access Analyzer - External Access Detection
module "iam_access_analyzer" {
  source = "../../modules/security/iam-access-analyzer"
  
  environment    = var.environment
  analyzer_type  = "ACCOUNT"
  common_tags    = var.common_tags
  
  create_cloudwatch_alarm = true
  alarm_threshold        = 0
  alarm_actions          = [] # Add SNS topic ARN when available
  
  create_eventbridge_rule = true
  event_targets          = [] # Add SNS topic ARN when available
}

# Credential Rotation Policy - Password & Access Key Management
module "credential_rotation" {
  source = "../../modules/security/credential-rotation"
  
  environment    = var.environment
  common_tags    = var.common_tags
  
  # Password Policy (ISO 27001 A.9.4.3 compliant)
  minimum_password_length        = 14
  require_lowercase              = true
  require_uppercase              = true
  require_numbers               = true
  require_symbols               = true
  allow_users_to_change_password = true
  max_password_age              = 90  # NIST 800-63B recommendation
  password_reuse_prevention     = 12
  hard_expiry                   = false
  
  # Access Key Monitoring
  enable_access_key_monitoring = false # Enable when Lambda package ready
  access_key_max_age          = 90
  notification_topic_arn      = ""    # Add SNS topic ARN when available
  lambda_package_path         = ""    # Path to Lambda zip when ready
  log_retention_days          = 30
}

# ==============================================================================
# DATA SOURCES
# ==============================================================================
data "aws_caller_identity" "current" {}
data "aws_region" "current" {}