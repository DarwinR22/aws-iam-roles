terraform {
  required_version = ">= 1.0"
  
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }

  backend "s3" {
    bucket = "mci-terraform-state-bucket"
    key    = "environments/dev/terraform.tfstate"
    region = "us-east-1"
    
    # DynamoDB table for state locking
    dynamodb_table = "mci-terraform-state-lock"
    encrypt        = true
  }
}

provider "aws" {
  region = var.aws_region
  
  # Default tags para todos los recursos
  default_tags {
    tags = {
      Environment   = "DEV"
      ManagedBy     = "Terraform"
      Repository    = "mci-aws-iam"
      StateLocation = "s3://mci-terraform-state-bucket/environments/dev/"
      pais          = "Guatemala"
      direccion     = "CENAM"
      gerencia      = "IT"
      proveedor     = "Claro"
      creado_por    = "DarwinLopez"
    }
  }
}
