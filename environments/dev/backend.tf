terraform {
  backend "s3" {
    bucket         = "s3-data-analytics-dev-tfstate-datalake"
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
      Pais            = "GT"
      Direccion       = "Tecnologia"
      Gerencia        = "MCI"
      Cuenta          = "393209814297"
      Modulo          = "IAM-Management"
      "Alcance SOX"   = "Si"
      Propietario     = "Security-Team"
      Proveedor       = "Claro"
      Layer           = "Security"
      Dominio         = "IdentityAccessManagement"
      Subdominio      = "Roles"
      Aplicacion      = "iam-terraform"
      Name            = "MCI-IAM-Enterprise"
      Soporte         = "Security-Team"
      Contacto        = "security@claro.com"
      Proyecto        = "IAM-ABAC-Enterprise"
      "Fechas de Creacion" = "2024-01-15T10:00:00Z"
      "Creado Por"    = "terraform-iac"
      "Tipo de Recurso" = "IAM-Infrastructure"
      "Ciclo de Vida" = "Active"
      Version         = "2.0"
      "Map-migrated"  = "mig_iam_enterprise_001"
      
      # Additional management tags
      ManagedBy       = "Terraform"
      Repository      = "mci-aws-iam"
      StateLocation   = "s3://s3-data-analytics-dev-tfstate-datalake"
      TerraformVersion = "1.6.0"
    }
  }
}
