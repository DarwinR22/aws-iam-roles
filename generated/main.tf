# Main Terraform configuration for MCI AWS IAM
# Nueva arquitectura modular siguiendo mejores prácticas de Terraform, Git y AWS
# Mantiene solo el rol de GitHub Actions y estructura modular con ABAC

terraform {
  required_version = ">= 1.0"
  
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
  
  # Backend configuration will be loaded from config/backend.hcl
  backend "s3" {}
}

# Provider configuration
provider "aws" {
  region = var.aws_region
  
  default_tags {
    tags = {
      Project     = "MCI-IAM"
      ManagedBy   = "Terraform"
      Repository  = "ClaroCENAM/mci-aws-iam"
      Environment = var.environment
    }
  }
}

# Data sources
data "aws_caller_identity" "current" {}
data "aws_region" "current" {}

# Local variables
locals {
  account_id = data.aws_caller_identity.current.account_id
  region     = data.aws_region.current.name
  
  common_tags = {
    Pais      = "rg"
    Gerencia  = "MCI"
    Ambiente  = var.environment
    ManagedBy = "Terraform"
  }
}