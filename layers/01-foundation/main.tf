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
      Project              = "SGSI-Implementation"
      Layer                = "Foundation"
      Environment          = var.environment
      ManagedBy           = "Terraform"
      SecurityLevel       = "Critical"
      ComplianceScope     = "ISO27001-NIST-CSF"
      CreatedBy           = "GitHub-Actions"
      MaintenanceWindow   = "Sunday-2AM-6AM"
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
# IAM POLICY MODULES (Import from existing modules)
# ==============================================================================
module "github_deployment_iam" {
  source = "../../generated/modules/policies/github_deployment_iam"
  
  environment      = var.environment
  abac_conditions  = var.abac_conditions
  common_tags     = var.common_tags
}

module "github_deployment_sts" {
  source = "../../generated/modules/policies/github_deployment_sts"
  
  environment      = var.environment
  abac_conditions  = var.abac_conditions
  common_tags     = var.common_tags
}

module "github_deployment_tfstate" {
  source = "../../generated/modules/policies/github_deployment_tfstate"
  
  environment      = var.environment
  abac_conditions  = var.abac_conditions
  common_tags     = var.common_tags
}

module "github_deployment_network" {
  source = "../../generated/modules/policies/github_deployment_network"
  
  environment      = var.environment
  abac_conditions  = var.abac_conditions
  common_tags     = var.common_tags
}

module "github_deployment_compute" {
  source = "../../generated/modules/policies/github_deployment_compute"
  
  environment      = var.environment
  abac_conditions  = var.abac_conditions
  common_tags     = var.common_tags
}

module "github_deployment_database" {
  source = "../../generated/modules/policies/github_deployment_database"
  
  environment      = var.environment
  abac_conditions  = var.abac_conditions
  common_tags     = var.common_tags
}

module "github_deployment_storage" {
  source = "../../generated/modules/policies/github_deployment_storage"
  
  environment      = var.environment
  abac_conditions  = var.abac_conditions
  common_tags     = var.common_tags
}

module "github_deployment_monitoring" {
  source = "../../generated/modules/policies/github_deployment_monitoring"
  
  environment      = var.environment
  abac_conditions  = var.abac_conditions
  common_tags     = var.common_tags
}

module "github_deployment_application" {
  source = "../../generated/modules/policies/github_deployment_application"
  
  environment      = var.environment
  abac_conditions  = var.abac_conditions
  common_tags     = var.common_tags
}

module "github_deployment_cloudformation" {
  source = "../../generated/modules/policies/github_deployment_cloudformation"
  
  environment      = var.environment
  abac_conditions  = var.abac_conditions
  common_tags     = var.common_tags
}

module "github_deployment_cloudwatch" {
  source = "../../generated/modules/policies/github_deployment_cloudwatch"
  
  environment      = var.environment
  abac_conditions  = var.abac_conditions
  common_tags     = var.common_tags
}

module "github_deployment_glue" {
  source = "../../generated/modules/policies/github_deployment_glue"
  
  environment      = var.environment
  abac_conditions  = var.abac_conditions
  common_tags     = var.common_tags
}

# ==============================================================================
# POLICY ATTACHMENTS
# ==============================================================================
# Commented out - using existing role with existing permissions for this deployment
# resource "aws_iam_role_policy_attachment" "github_deployment_policies" {
#   for_each = {
#     iam            = module.github_deployment_iam.policy_arn
#     sts            = module.github_deployment_sts.policy_arn
#     tfstate        = module.github_deployment_tfstate.policy_arn
#     network        = module.github_deployment_network.policy_arn
#     compute        = module.github_deployment_compute.policy_arn
#     database       = module.github_deployment_database.policy_arn
#     storage        = module.github_deployment_storage.policy_arn
#     monitoring     = module.github_deployment_monitoring.policy_arn
#     application    = module.github_deployment_application.policy_arn
#     cloudformation = module.github_deployment_cloudformation.policy_arn
#     cloudwatch     = module.github_deployment_cloudwatch.policy_arn
#     glue           = module.github_deployment_glue.policy_arn
#   }
#
#   role       = data.aws_iam_role.github_actions_deployment_role.name
#   policy_arn = each.value
# }

# ==============================================================================
# DATA SOURCES
# ==============================================================================
data "aws_caller_identity" "current" {}
data "aws_region" "current" {}