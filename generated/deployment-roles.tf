# ==============================================================================
# Deployment and Infrastructure Roles
# ==============================================================================
# CI/CD, GitHub Actions, and infrastructure automation roles
# 
# This file is auto-generated from YAML definitions.
# DO NOT EDIT MANUALLY - Changes will be overwritten.
# 
# Generated: 2025-09-26T08:50:16.202791
# Source: Multiple role definitions in definitions/roles/
# ==============================================================================


# Role from: github-deployment-role.yaml
# Auto-generated role: github-actions-iam-deployment-role
# Generated from: definitions/roles/github-deployment-role.yaml
# DO NOT EDIT MANUALLY - Changes will be overwritten

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
      values   = [
        "sts.amazonaws.com"
      ]
    }
    condition {
      test     = "StringLike"
      variable = "token.actions.githubusercontent.com:sub"
      values   = [
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
    "Pais" = "rg"
    "Gerencia" = "MCI"
    "Area" = "DevOps"
    "Ambiente" = "dev"
    "Direccion" = "TIRegional"
    "Modulo" = "IAM"
    "Alcance SOX" = "No"
    "Propietario" = "DarwinLopez"
    "Proveedor" = "InHouse"
    "Layer" = "Devops"
    "Dominio" = "BusinessIntelligence"
    "Subdominio" = "Analytics"
    "Aplicacion" = "CICD"
    "Name" = "github-actions-iam-deployment-role"
    "Tipo de Recurso" = "IAMRole"
    "Soporte" = "darwin.lopez@claro.com.gt"
    "Contacto" = "darwin.lopez@claro.com.gt"
    "Creado Por" = "DarwinLopez"
    "Ciclo de Vida" = "Creacion"
    "Versión" = "v1.0.3"
    "Fecha de Creacion" = "2025-09-16"
    "Última Actualización" = "2025-09-25"
    # Auto-generated tags
    "ManagedBy" = "terraform"
    "Source"    = "definitions/roles/github-deployment-role.yaml"
    "Generated" = "2025-09-26T08:50:16.202372"
  }
}

# Create policies as independent modules (not attached to role)
module "githubactions_basepermissions" {
  source = "./modules/policies/mci_githubactions_basepermissions"
  
  environment = "dev"
  
  # ABAC conditions for policy restrictions
  abac_conditions = {
    "aws:PrincipalTag/Gerencia" = ["MCI"]
    "aws:PrincipalTag/Area"     = ["DevOps"]
    "aws:PrincipalTag/Ambiente" = ["dev"]
  }
  
  # AWS Configuration
  aws_region            = "us-east-1"
  role_prefix          = "MCI-"
  policy_prefix        = "MCI-"
  s3_bucket_name       = "mci-terraform-state"
  dynamodb_table_name  = "mci-terraform-locks"
  kms_key_id          = "*"
  
  common_tags = {
    "Gerencia" = "MCI"
    "Area" = "DevOps"  
    "Ambiente" = "dev"
  }
}
module "githubactions_terraformbackend" {
  source = "./modules/policies/mci_githubactions_terraformbackend"
  
  environment = "dev"
  
  # ABAC conditions for policy restrictions
  abac_conditions = {
    "aws:PrincipalTag/Gerencia" = ["MCI"]
    "aws:PrincipalTag/Area"     = ["DevOps"]
    "aws:PrincipalTag/Ambiente" = ["dev"]
  }
  
  # AWS Configuration
  aws_region            = "us-east-1"
  role_prefix          = "MCI-"
  policy_prefix        = "MCI-"
  s3_bucket_name       = "mci-terraform-state"
  dynamodb_table_name  = "mci-terraform-locks"
  kms_key_id          = "*"
  
  common_tags = {
    "Gerencia" = "MCI"
    "Area" = "DevOps"  
    "Ambiente" = "dev"
  }
}
module "githubactions_iammanagement" {
  source = "./modules/policies/mci_githubactions_iammanagement"
  
  environment = "dev"
  
  # ABAC conditions for policy restrictions
  abac_conditions = {
    "aws:PrincipalTag/Gerencia" = ["MCI"]
    "aws:PrincipalTag/Area"     = ["DevOps"]
    "aws:PrincipalTag/Ambiente" = ["dev"]
  }
  
  # AWS Configuration
  aws_region            = "us-east-1"
  role_prefix          = "MCI-"
  policy_prefix        = "MCI-"
  s3_bucket_name       = "mci-terraform-state"
  dynamodb_table_name  = "mci-terraform-locks"
  kms_key_id          = "*"
  
  common_tags = {
    "Gerencia" = "MCI"
    "Area" = "DevOps"  
    "Ambiente" = "dev"
  }
}

# To attach policies to role later, manually add:
# resource "aws_iam_role_policy_attachment" "role_policy" {
#   role       = aws_iam_role.github_actions_iam_deployment_role.name  
#   policy_arn = module.POLICY_MODULE.policy_arn
# }

# Output role ARN
output "github_actions_iam_deployment_role_arn" {
  description = "ARN of github-actions-iam-deployment-role role"
  value       = aws_iam_role.github_actions_iam_deployment_role.arn
}

