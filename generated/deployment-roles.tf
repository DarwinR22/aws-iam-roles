# ==============================================================================
# Deployment and Infrastructure Roles
# ==============================================================================
# CI/CD, GitHub Actions, and infrastructure automation roles
# 
# This file is auto-generated from YAML definitions.
# DO NOT EDIT MANUALLY - Changes will be overwritten.
# 
# Generated: 2025-10-14T21:42:43.626096
# Source: Multiple role definitions in definitions/roles/
# ==============================================================================


# Role from: github-deployment-role.yaml
# Auto-generated role: github-actions-iam-deployment-role
# Generated from: definitions/roles/github-deployment-role.yaml
# DO NOT EDIT MANUALLY - Changes will be overwritten
# Last update: 2025-10-09 - Added complete tags for SCP compliance

# Get current AWS account ID
data "aws_caller_identity" "current" {}

# Trust policy for the role (using jsonencode to preserve array format)
locals {
  github_actions_iam_deployment_role_trust_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Principal = {
        Federated = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:oidc-provider/token.actions.githubusercontent.com"
      }
      Action = "sts:AssumeRoleWithWebIdentity"
      Condition = {
        StringEquals = {
          "token.actions.githubusercontent.com:aud" = [
            "sts.amazonaws.com"
          ]
        },
        StringLike = {
          "token.actions.githubusercontent.com:sub" = [
            "repo:ClaroCENAM/mci-aws-iam:ref:refs/heads/dev",
            "repo:ClaroCENAM/mci-aws-iam:pull_request"
          ]
        }
      }
    }]
  })
}

# IAM Role
resource "aws_iam_role" "github_actions_iam_deployment_role" {
  name               = "github-actions-iam-deployment-role"
  description        = "Rol IAM para despliegues automaticos desde GitHub Actions (repositorio: ClaroCENAM/mci-aws-iam) utilizando OIDC. Permite unicamente la creacion y administracion de recursos IAM a traves de la canalizacion (pipeline) de Terraform"
  assume_role_policy = local.github_actions_iam_deployment_role_trust_policy

  max_session_duration = 3600

  tags = {
    "Pais"                 = "RG"
    "Gerencia"             = "MCI"
    "Area"                 = "DevOps"
    "Ambiente"             = "DEV"
    "Direccion"            = "TIRegional"
    "Modulo"               = "IAM"
    "Alcance SOX"          = "No"
    "Propietario"          = "DarwinLopez"
    "Proveedor"            = "InHouse"
    "Layer"                = "Devops"
    "Dominio"              = "BusinessIntelligence"
    "Subdominio"           = "Analytics"
    "Aplicacion"           = "CICD"
    "Name"                 = "github-actions-iam-deployment-role"
    "Tipo de Recurso"      = "IAMRole"
    "Soporte"              = "darwin.lopez@claro.com.gt"
    "Contacto"             = "darwin.lopez@claro.com.gt"
    "Creado Por"           = "DarwinLopez"
    "Ciclo de Vida"        = "Actualizacion"
    "Versión"              = "v2.1.0"
    "Fecha de Creacion"    = "2025-09-16"
    "Última Actualización" = "2025-10-09"
    # Auto-generated tags
    "ManagedBy" = "terraform"
    "Source"    = "definitions/roles/github-deployment-role.yaml"
    "Generated" = "2025-10-14T21:42:43.626096"
  }
}

# Create policies as independent modules (not attached to role)
module "github_deployment_tfstate" {
  source = "./modules/policies/github_deployment_tfstate"

  environment = "DEV"

  # ABAC conditions for policy restrictions
  abac_conditions = {
    "aws:PrincipalTag/Gerencia" = ["MCI"]
    "aws:PrincipalTag/Area"     = ["DevOps"]
    "aws:PrincipalTag/Ambiente" = ["DEV"]
  }

  # AWS Configuration
  aws_region          = "us-east-1"
  role_prefix         = "MCI-"
  policy_prefix       = "MCI-"
  s3_bucket_name      = "mci-terraform-state"
  dynamodb_table_name = "mci-terraform-locks"
  kms_key_id          = "*"

  common_tags = {
    "Pais"            = "RG"
    "Gerencia"        = "MCI"
    "Area"            = "DevOps"
    "Ambiente"        = "DEV"
    "Direccion"       = "TIRegional"
    "Modulo"          = "IAM"
    "Alcance SOX"     = "No"
    "Propietario"     = "DarwinLopez"
    "Proveedor"       = "InHouse"
    "Layer"           = "Devops"
    "Dominio"         = "BusinessIntelligence"
    "Subdominio"      = "Analytics"
    "Aplicacion"      = "CICD"
    "Tipo de Recurso" = "IAMPolicy"
    "Soporte"         = "darwin.lopez@claro.com.gt"
    "Contacto"        = "darwin.lopez@claro.com.gt"
    "Creado Por"      = "DarwinLopez"
    "Ciclo de Vida"   = "Creacion"
    "ManagedBy"       = "terraform"
  }
}
module "github_deployment_lambda" {
  source = "./modules/policies/github_deployment_lambda"

  environment = "DEV"

  # ABAC conditions for policy restrictions
  abac_conditions = {
    "aws:PrincipalTag/Gerencia" = ["MCI"]
    "aws:PrincipalTag/Area"     = ["DevOps"]
    "aws:PrincipalTag/Ambiente" = ["DEV"]
  }

  # AWS Configuration
  aws_region          = "us-east-1"
  role_prefix         = "MCI-"
  policy_prefix       = "MCI-"
  s3_bucket_name      = "mci-terraform-state"
  dynamodb_table_name = "mci-terraform-locks"
  kms_key_id          = "*"

  common_tags = {
    "Pais"            = "RG"
    "Gerencia"        = "MCI"
    "Area"            = "DevOps"
    "Ambiente"        = "DEV"
    "Direccion"       = "TIRegional"
    "Modulo"          = "IAM"
    "Alcance SOX"     = "No"
    "Propietario"     = "DarwinLopez"
    "Proveedor"       = "InHouse"
    "Layer"           = "Devops"
    "Dominio"         = "BusinessIntelligence"
    "Subdominio"      = "Analytics"
    "Aplicacion"      = "CICD"
    "Tipo de Recurso" = "IAMPolicy"
    "Soporte"         = "darwin.lopez@claro.com.gt"
    "Contacto"        = "darwin.lopez@claro.com.gt"
    "Creado Por"      = "DarwinLopez"
    "Ciclo de Vida"   = "Creacion"
    "ManagedBy"       = "terraform"
  }
}
module "github_deployment_s3" {
  source = "./modules/policies/github_deployment_s3"

  environment = "DEV"

  # ABAC conditions for policy restrictions
  abac_conditions = {
    "aws:PrincipalTag/Gerencia" = ["MCI"]
    "aws:PrincipalTag/Area"     = ["DevOps"]
    "aws:PrincipalTag/Ambiente" = ["DEV"]
  }

  # AWS Configuration
  aws_region          = "us-east-1"
  role_prefix         = "MCI-"
  policy_prefix       = "MCI-"
  s3_bucket_name      = "mci-terraform-state"
  dynamodb_table_name = "mci-terraform-locks"
  kms_key_id          = "*"

  common_tags = {
    "Pais"            = "RG"
    "Gerencia"        = "MCI"
    "Area"            = "DevOps"
    "Ambiente"        = "DEV"
    "Direccion"       = "TIRegional"
    "Modulo"          = "IAM"
    "Alcance SOX"     = "No"
    "Propietario"     = "DarwinLopez"
    "Proveedor"       = "InHouse"
    "Layer"           = "Devops"
    "Dominio"         = "BusinessIntelligence"
    "Subdominio"      = "Analytics"
    "Aplicacion"      = "CICD"
    "Tipo de Recurso" = "IAMPolicy"
    "Soporte"         = "darwin.lopez@claro.com.gt"
    "Contacto"        = "darwin.lopez@claro.com.gt"
    "Creado Por"      = "DarwinLopez"
    "Ciclo de Vida"   = "Creacion"
    "ManagedBy"       = "terraform"
  }
}
module "github_deployment_dynamodb" {
  source = "./modules/policies/github_deployment_dynamodb"

  environment = "DEV"

  # ABAC conditions for policy restrictions
  abac_conditions = {
    "aws:PrincipalTag/Gerencia" = ["MCI"]
    "aws:PrincipalTag/Area"     = ["DevOps"]
    "aws:PrincipalTag/Ambiente" = ["DEV"]
  }

  # AWS Configuration
  aws_region          = "us-east-1"
  role_prefix         = "MCI-"
  policy_prefix       = "MCI-"
  s3_bucket_name      = "mci-terraform-state"
  dynamodb_table_name = "mci-terraform-locks"
  kms_key_id          = "*"

  common_tags = {
    "Pais"            = "RG"
    "Gerencia"        = "MCI"
    "Area"            = "DevOps"
    "Ambiente"        = "DEV"
    "Direccion"       = "TIRegional"
    "Modulo"          = "IAM"
    "Alcance SOX"     = "No"
    "Propietario"     = "DarwinLopez"
    "Proveedor"       = "InHouse"
    "Layer"           = "Devops"
    "Dominio"         = "BusinessIntelligence"
    "Subdominio"      = "Analytics"
    "Aplicacion"      = "CICD"
    "Tipo de Recurso" = "IAMPolicy"
    "Soporte"         = "darwin.lopez@claro.com.gt"
    "Contacto"        = "darwin.lopez@claro.com.gt"
    "Creado Por"      = "DarwinLopez"
    "Ciclo de Vida"   = "Creacion"
    "ManagedBy"       = "terraform"
  }
}
module "github_deployment_eventbridge" {
  source = "./modules/policies/github_deployment_eventbridge"

  environment = "DEV"

  # ABAC conditions for policy restrictions
  abac_conditions = {
    "aws:PrincipalTag/Gerencia" = ["MCI"]
    "aws:PrincipalTag/Area"     = ["DevOps"]
    "aws:PrincipalTag/Ambiente" = ["DEV"]
  }

  # AWS Configuration
  aws_region          = "us-east-1"
  role_prefix         = "MCI-"
  policy_prefix       = "MCI-"
  s3_bucket_name      = "mci-terraform-state"
  dynamodb_table_name = "mci-terraform-locks"
  kms_key_id          = "*"

  common_tags = {
    "Pais"            = "RG"
    "Gerencia"        = "MCI"
    "Area"            = "DevOps"
    "Ambiente"        = "DEV"
    "Direccion"       = "TIRegional"
    "Modulo"          = "IAM"
    "Alcance SOX"     = "No"
    "Propietario"     = "DarwinLopez"
    "Proveedor"       = "InHouse"
    "Layer"           = "Devops"
    "Dominio"         = "BusinessIntelligence"
    "Subdominio"      = "Analytics"
    "Aplicacion"      = "CICD"
    "Tipo de Recurso" = "IAMPolicy"
    "Soporte"         = "darwin.lopez@claro.com.gt"
    "Contacto"        = "darwin.lopez@claro.com.gt"
    "Creado Por"      = "DarwinLopez"
    "Ciclo de Vida"   = "Creacion"
    "ManagedBy"       = "terraform"
  }
}
module "github_deployment_cloudwatch" {
  source = "./modules/policies/github_deployment_cloudwatch"

  environment = "DEV"

  # ABAC conditions for policy restrictions
  abac_conditions = {
    "aws:PrincipalTag/Gerencia" = ["MCI"]
    "aws:PrincipalTag/Area"     = ["DevOps"]
    "aws:PrincipalTag/Ambiente" = ["DEV"]
  }

  # AWS Configuration
  aws_region          = "us-east-1"
  role_prefix         = "MCI-"
  policy_prefix       = "MCI-"
  s3_bucket_name      = "mci-terraform-state"
  dynamodb_table_name = "mci-terraform-locks"
  kms_key_id          = "*"

  common_tags = {
    "Pais"            = "RG"
    "Gerencia"        = "MCI"
    "Area"            = "DevOps"
    "Ambiente"        = "DEV"
    "Direccion"       = "TIRegional"
    "Modulo"          = "IAM"
    "Alcance SOX"     = "No"
    "Propietario"     = "DarwinLopez"
    "Proveedor"       = "InHouse"
    "Layer"           = "Devops"
    "Dominio"         = "BusinessIntelligence"
    "Subdominio"      = "Analytics"
    "Aplicacion"      = "CICD"
    "Tipo de Recurso" = "IAMPolicy"
    "Soporte"         = "darwin.lopez@claro.com.gt"
    "Contacto"        = "darwin.lopez@claro.com.gt"
    "Creado Por"      = "DarwinLopez"
    "Ciclo de Vida"   = "Creacion"
    "ManagedBy"       = "terraform"
  }
}
module "github_deployment_glue" {
  source = "./modules/policies/github_deployment_glue"

  environment = "DEV"

  # ABAC conditions for policy restrictions
  abac_conditions = {
    "aws:PrincipalTag/Gerencia" = ["MCI"]
    "aws:PrincipalTag/Area"     = ["DevOps"]
    "aws:PrincipalTag/Ambiente" = ["DEV"]
  }

  # AWS Configuration
  aws_region          = "us-east-1"
  role_prefix         = "MCI-"
  policy_prefix       = "MCI-"
  s3_bucket_name      = "mci-terraform-state"
  dynamodb_table_name = "mci-terraform-locks"
  kms_key_id          = "*"

  common_tags = {
    "Pais"            = "RG"
    "Gerencia"        = "MCI"
    "Area"            = "DevOps"
    "Ambiente"        = "DEV"
    "Direccion"       = "TIRegional"
    "Modulo"          = "IAM"
    "Alcance SOX"     = "No"
    "Propietario"     = "DarwinLopez"
    "Proveedor"       = "InHouse"
    "Layer"           = "Devops"
    "Dominio"         = "BusinessIntelligence"
    "Subdominio"      = "Analytics"
    "Aplicacion"      = "CICD"
    "Tipo de Recurso" = "IAMPolicy"
    "Soporte"         = "darwin.lopez@claro.com.gt"
    "Contacto"        = "darwin.lopez@claro.com.gt"
    "Creado Por"      = "DarwinLopez"
    "Ciclo de Vida"   = "Creacion"
    "ManagedBy"       = "terraform"
  }
}
module "github_deployment_iam" {
  source = "./modules/policies/github_deployment_iam"

  environment = "DEV"

  # ABAC conditions for policy restrictions
  abac_conditions = {
    "aws:PrincipalTag/Gerencia" = ["MCI"]
    "aws:PrincipalTag/Area"     = ["DevOps"]
    "aws:PrincipalTag/Ambiente" = ["DEV"]
  }

  # AWS Configuration
  aws_region          = "us-east-1"
  role_prefix         = "MCI-"
  policy_prefix       = "MCI-"
  s3_bucket_name      = "mci-terraform-state"
  dynamodb_table_name = "mci-terraform-locks"
  kms_key_id          = "*"

  common_tags = {
    "Pais"            = "RG"
    "Gerencia"        = "MCI"
    "Area"            = "DevOps"
    "Ambiente"        = "DEV"
    "Direccion"       = "TIRegional"
    "Modulo"          = "IAM"
    "Alcance SOX"     = "No"
    "Propietario"     = "DarwinLopez"
    "Proveedor"       = "InHouse"
    "Layer"           = "Devops"
    "Dominio"         = "BusinessIntelligence"
    "Subdominio"      = "Analytics"
    "Aplicacion"      = "CICD"
    "Tipo de Recurso" = "IAMPolicy"
    "Soporte"         = "darwin.lopez@claro.com.gt"
    "Contacto"        = "darwin.lopez@claro.com.gt"
    "Creado Por"      = "DarwinLopez"
    "Ciclo de Vida"   = "Creacion"
    "ManagedBy"       = "terraform"
  }
}
module "github_deployment_cloudformation" {
  source = "./modules/policies/github_deployment_cloudformation"

  environment = "DEV"

  # ABAC conditions for policy restrictions
  abac_conditions = {
    "aws:PrincipalTag/Gerencia" = ["MCI"]
    "aws:PrincipalTag/Area"     = ["DevOps"]
    "aws:PrincipalTag/Ambiente" = ["DEV"]
  }

  # AWS Configuration
  aws_region          = "us-east-1"
  role_prefix         = "MCI-"
  policy_prefix       = "MCI-"
  s3_bucket_name      = "mci-terraform-state"
  dynamodb_table_name = "mci-terraform-locks"
  kms_key_id          = "*"

  common_tags = {
    "Pais"            = "RG"
    "Gerencia"        = "MCI"
    "Area"            = "DevOps"
    "Ambiente"        = "DEV"
    "Direccion"       = "TIRegional"
    "Modulo"          = "IAM"
    "Alcance SOX"     = "No"
    "Propietario"     = "DarwinLopez"
    "Proveedor"       = "InHouse"
    "Layer"           = "Devops"
    "Dominio"         = "BusinessIntelligence"
    "Subdominio"      = "Analytics"
    "Aplicacion"      = "CICD"
    "Tipo de Recurso" = "IAMPolicy"
    "Soporte"         = "darwin.lopez@claro.com.gt"
    "Contacto"        = "darwin.lopez@claro.com.gt"
    "Creado Por"      = "DarwinLopez"
    "Ciclo de Vida"   = "Creacion"
    "ManagedBy"       = "terraform"
  }
}

# Attach policies to role
resource "aws_iam_role_policy_attachment" "github_actions_iam_deployment_role_github_deployment_tfstate" {
  role       = aws_iam_role.github_actions_iam_deployment_role.name
  policy_arn = module.github_deployment_tfstate.policy_arn
}
resource "aws_iam_role_policy_attachment" "github_actions_iam_deployment_role_github_deployment_lambda" {
  role       = aws_iam_role.github_actions_iam_deployment_role.name
  policy_arn = module.github_deployment_lambda.policy_arn
}
resource "aws_iam_role_policy_attachment" "github_actions_iam_deployment_role_github_deployment_s3" {
  role       = aws_iam_role.github_actions_iam_deployment_role.name
  policy_arn = module.github_deployment_s3.policy_arn
}
resource "aws_iam_role_policy_attachment" "github_actions_iam_deployment_role_github_deployment_dynamodb" {
  role       = aws_iam_role.github_actions_iam_deployment_role.name
  policy_arn = module.github_deployment_dynamodb.policy_arn
}
resource "aws_iam_role_policy_attachment" "github_actions_iam_deployment_role_github_deployment_eventbridge" {
  role       = aws_iam_role.github_actions_iam_deployment_role.name
  policy_arn = module.github_deployment_eventbridge.policy_arn
}
resource "aws_iam_role_policy_attachment" "github_actions_iam_deployment_role_github_deployment_cloudwatch" {
  role       = aws_iam_role.github_actions_iam_deployment_role.name
  policy_arn = module.github_deployment_cloudwatch.policy_arn
}
resource "aws_iam_role_policy_attachment" "github_actions_iam_deployment_role_github_deployment_glue" {
  role       = aws_iam_role.github_actions_iam_deployment_role.name
  policy_arn = module.github_deployment_glue.policy_arn
}
resource "aws_iam_role_policy_attachment" "github_actions_iam_deployment_role_github_deployment_iam" {
  role       = aws_iam_role.github_actions_iam_deployment_role.name
  policy_arn = module.github_deployment_iam.policy_arn
}
resource "aws_iam_role_policy_attachment" "github_actions_iam_deployment_role_github_deployment_cloudformation" {
  role       = aws_iam_role.github_actions_iam_deployment_role.name
  policy_arn = module.github_deployment_cloudformation.policy_arn
}

# Cleanup module for obsolete policies (TEMPORARILY DISABLED - performance issue)
# TODO: Re-enable after optimizing the external data source performance
# module "cleanup_obsolete_policies" {
#   source = "../modules/iam-policy-cleanup"
#   
#   aws_region       = "us-east-1"
#   environment      = "DEV"
#   cleanup_enabled  = true
# }

# Output role ARN
output "github_actions_iam_deployment_role_arn" {
  description = "ARN of github-actions-iam-deployment-role role"
  value       = aws_iam_role.github_actions_iam_deployment_role.arn
}

# Output cleanup summary (DISABLED)
# output "cleanup_summary" {
#   description = "Summary of obsolete policy cleanup"  
#   value       = module.cleanup_obsolete_policies.cleanup_summary
# }

