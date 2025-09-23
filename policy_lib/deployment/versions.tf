# policy_lib/deployment/versions.tf
# =============================================
# TERRAFORM PROVIDER CONFIGURATION
# =============================================

terraform {
  required_version = ">= 1.0"
  
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

# Provider configuration is inherited from parent module
# No explicit provider block needed - using required_providers above