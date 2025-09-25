# Auto-generated provider configuration for MCI IAM
# DO NOT EDIT MANUALLY

terraform {
  required_version = ">= 1.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }

  backend "s3" {
    # Backend configuration is set dynamically via:
    # terraform init -backend-config=config/backend-dev.hcl
    # This allows dev/qa/prod environments with different buckets/tables
  }
}

provider "aws" {
  region  = var.aws_region
  profile = var.aws_profile

  default_tags {
    tags = {
      Environment = var.environment
      Department  = var.department  
      Area        = var.area
      ManagedBy   = "Terraform"
      Repository  = "mci-aws-iam"
      LastUpdated = timestamp()
    }
  }
}