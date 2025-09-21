terraform {
  backend "s3" {
    bucket         = "s3-data-analytics-raw-dev-tfstate"
    key            = "environments/dev/iam-roles/terraform.tfstate"
    region         = "us-east-1"
    dynamodb_table = "dynamodb-db-dev-terraform-lock"
    encrypt        = true
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

# ENTERPRISE AWS PROVIDER WITH CANONICAL TAGS
provider "aws" {
  region = var.aws_region

  default_tags {
    tags = {
      # ALL 23 CANONICAL TAGS (MANDATORY FOR ALL RESOURCES)
      Ambiente        = "Dev"
      País            = "GT"
      Dirección       = "Tecnología"
      Gerencia        = "MCI"
      Cuenta          = "393209814297"
      Módulo          = "IAM-Management"
      "Alcance SOX"   = "Sí"
      Propietario     = "Security-Team"
      Proveedor       = "Claro"
      Layer           = "Security"
      Dominio         = "IdentityAccessManagement"
      Subdominio      = "Roles"
      Aplicación      = "iam-terraform"
      Name            = "MCI-IAM-Enterprise"
      Soporte         = "Security-Team"
      Contacto        = "security@claro.com"
      Proyecto        = "IAM-ABAC-Enterprise"
      "Fechas de Creación" = "2024-01-15T10:00:00Z"
      "Creado Por"    = "terraform-iac"
      "Tipo de Recurso" = "IAM-Infrastructure"
      "Ciclo de Vida" = "Active"
      Versión         = "2.0"
      "Map-migrated"  = "mig_iam_enterprise_001"
      
      # Additional management tags
      ManagedBy       = "Terraform"
      Repository      = "mci-aws-iam"
      StateLocation   = "s3://s3-data-analytics-raw-dev-tfstate"
      TerraformVersion = "1.6.0"
    }
  }
}
