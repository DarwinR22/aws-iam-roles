terraform {
  backend "s3" {
    bucket         = "s3-data-analytics-raw-dev-tfstate"
    key            = "environments/dev/iam-roles/terraform.tfstate"
    region         = "us-east-1"
    dynamodb_table = "dynamodb-db-dev-terraform-lock"
    encrypt        = true
    
    # Estructura organizada por gerencia y área
    workspace_key_prefix = "workspaces"
  }
  
  required_version = ">= 1.6.0"
  
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

# Provider configuration
provider "aws" {
  region = var.aws_region
  
  default_tags {
    tags = {
      Environment   = "dev"
      ManagedBy     = "Terraform"
      Repository    = "mci-aws-iam"
      StateLocation = "s3-data-analytics-raw-dev-tfstate"
    }
  }
}
