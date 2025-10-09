# ==============================================================================
# Deployment and Infrastructure Roles
# ==============================================================================
# CI/CD, GitHub Actions, and infrastructure automation roles
# 
# This file is auto-generated from YAML definitions.
# DO NOT EDIT MANUALLY - Changes will be overwritten.
# 
# Generated: 2025-10-09T23:41:00.756605
# Source: Multiple role definitions in definitions/roles/
# ==============================================================================


# Role from: github-deployment-role.yaml
# Auto-generated role: github-actions-iam-deployment-role
# Generated from: definitions/roles/github-deployment-role.yaml
# DO NOT EDIT MANUALLY - Changes will be overwritten
# Last update: 2025-10-09 - Added complete tags for SCP compliance

# Get current AWS account ID
data "aws_caller_identity" "current" {}

# Trust policy for the role
data "aws_iam_policy_document" "github_actions_iam_deployment_role_trust" {
  # OIDC Trust Policy for GitHub Actions
  statement {
    effect = "Allow"

    principals {
      type        = "Federated"
      identifiers = ["arn:aws:iam::${data.aws_caller_identity.current.account_id}:oidc-provider/token.actions.githubusercontent.com"]
    }

    actions = ["sts:AssumeRoleWithWebIdentity"]

    condition {
      test     = "StringEquals"
      variable = "token.actions.githubusercontent.com:aud"
      values = [
        "sts.amazonaws.com"
      ]
    }
    condition {
      test     = "StringLike"
      variable = "token.actions.githubusercontent.com:sub"
      values = [
        "repo:ClaroCENAM/*"
      ]
    }
  }
}

# IAM Role
resource "aws_iam_role" "github_actions_iam_deployment_role" {
  name               = "github-actions-iam-deployment-role"
  description        = "Rol IAM para despliegues automaticos desde GitHub Actions (repositorio: ClaroCENAM/mci-aws-iam) utilizando OIDC. Permite unicamente la creacion y administracion de recursos IAM a traves de la canalizacion (pipeline) de Terraform"
  assume_role_policy = data.aws_iam_policy_document.github_actions_iam_deployment_role_trust.json

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
    "Versión"              = "v2.0.0"
    "Fecha de Creacion"    = "2025-09-16"
    "Última Actualización" = "2025-10-09"
    # Auto-generated tags
    "ManagedBy" = "terraform"
    "Source"    = "definitions/roles/github-deployment-role.yaml"
    "Generated" = "2025-10-09T23:41:00.756605"
  }
}

# Create policies as independent modules (not attached to role)
module "mci_terraform_statemanagement" {
  source = "./modules/policies/mci_terraform_statemanagement"

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
module "mci_lambda_deploymentabac" {
  source = "./modules/policies/mci_lambda_deploymentabac"

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
module "mci_s3_deploymentabac" {
  source = "./modules/policies/mci_s3_deploymentabac"

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
module "mci_dynamodb_deploymentabac" {
  source = "./modules/policies/mci_dynamodb_deploymentabac"

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
module "mci_eventbridge_deploymentabac" {
  source = "./modules/policies/mci_eventbridge_deploymentabac"

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
module "mci_cloudwatch_deploymentabac" {
  source = "./modules/policies/mci_cloudwatch_deploymentabac"

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
module "mci_glue_deploymentabac" {
  source = "./modules/policies/mci_glue_deploymentabac"

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
module "mci_iam_deployment" {
  source = "./modules/policies/mci_iam_deployment"

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
module "mci_cloudformation_deployment" {
  source = "./modules/policies/mci_cloudformation_deployment"

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
resource "aws_iam_role_policy_attachment" "github_actions_iam_deployment_role_mci_terraform_statemanagement" {
  role       = aws_iam_role.github_actions_iam_deployment_role.name
  policy_arn = module.mci_terraform_statemanagement.policy_arn
}
resource "aws_iam_role_policy_attachment" "github_actions_iam_deployment_role_mci_lambda_deploymentabac" {
  role       = aws_iam_role.github_actions_iam_deployment_role.name
  policy_arn = module.mci_lambda_deploymentabac.policy_arn
}
resource "aws_iam_role_policy_attachment" "github_actions_iam_deployment_role_mci_s3_deploymentabac" {
  role       = aws_iam_role.github_actions_iam_deployment_role.name
  policy_arn = module.mci_s3_deploymentabac.policy_arn
}
resource "aws_iam_role_policy_attachment" "github_actions_iam_deployment_role_mci_dynamodb_deploymentabac" {
  role       = aws_iam_role.github_actions_iam_deployment_role.name
  policy_arn = module.mci_dynamodb_deploymentabac.policy_arn
}
resource "aws_iam_role_policy_attachment" "github_actions_iam_deployment_role_mci_eventbridge_deploymentabac" {
  role       = aws_iam_role.github_actions_iam_deployment_role.name
  policy_arn = module.mci_eventbridge_deploymentabac.policy_arn
}
resource "aws_iam_role_policy_attachment" "github_actions_iam_deployment_role_mci_cloudwatch_deploymentabac" {
  role       = aws_iam_role.github_actions_iam_deployment_role.name
  policy_arn = module.mci_cloudwatch_deploymentabac.policy_arn
}
resource "aws_iam_role_policy_attachment" "github_actions_iam_deployment_role_mci_glue_deploymentabac" {
  role       = aws_iam_role.github_actions_iam_deployment_role.name
  policy_arn = module.mci_glue_deploymentabac.policy_arn
}
resource "aws_iam_role_policy_attachment" "github_actions_iam_deployment_role_mci_iam_deployment" {
  role       = aws_iam_role.github_actions_iam_deployment_role.name
  policy_arn = module.mci_iam_deployment.policy_arn
}
resource "aws_iam_role_policy_attachment" "github_actions_iam_deployment_role_mci_cloudformation_deployment" {
  role       = aws_iam_role.github_actions_iam_deployment_role.name
  policy_arn = module.mci_cloudformation_deployment.policy_arn
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

