terraform {
  # State local temporal para bootstrap
  # Una vez creada la tabla DynamoDB, migrar a S3 backend
  
  required_version = ">= 1.6.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region  = var.aws_region
  profile = "darkhn"
  
  default_tags {
    tags = {
      Project     = "MCI-IAM"
      ManagedBy   = "Terraform"
      Environment = "bootstrap"
    }
  }
}
