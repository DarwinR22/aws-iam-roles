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

# Provider configuration will be inherited from parent module
provider "aws" {
  # Configuration will be inherited from the calling module
  # No explicit configuration needed here
}