# GitHub Actions Role - Terraform Managed
# ======================================
# Rol para GitHub Actions con políticas managed granulares

# Importar las políticas desde policy_lib
module "github_actions_policies" {
  source = "../policy_lib/github-actions"
  
  environment   = var.environment
  common_tags   = var.common_tags
}

# Trust policy para GitHub Actions OIDC
data "aws_iam_policy_document" "github_actions_trust_policy" {
  statement {
    effect = "Allow"
    
    principals {
      type        = "Federated"
      identifiers = ["arn:aws:iam::393209814297:oidc-provider/token.actions.githubusercontent.com"]
    }
    
    actions = ["sts:AssumeRoleWithWebIdentity"]
    
    condition {
      test     = "StringLike"
      variable = "token.actions.githubusercontent.com:sub"
      values   = ["repo:MCI-GITOPS/mci-aws-iam:*"]
    }
    
    condition {
      test     = "StringEquals"
      variable = "token.actions.githubusercontent.com:aud"
      values   = ["sts.amazonaws.com"]
    }
  }
}

# Crear el rol de GitHub Actions  
resource "aws_iam_role" "github_actions_role" {
  name               = "GitHubActions-MCI-IAM-Role"
  path               = "/GitHubActions/"
  description        = "Rol para GitHub Actions CI/CD con políticas granulares managed"
  assume_role_policy = data.aws_iam_policy_document.github_actions_trust_policy.json
  
  # Tags obligatorios
  tags = merge(var.common_tags, {
    "Name"        = "GitHubActions-MCI-IAM-Role"
    "Purpose"     = "CICD" 
    "Service"     = "GitHubActions"
    "Repository"  = "mci-aws-iam"
  })
}

# Adjuntar política de Terraform Backend
resource "aws_iam_role_policy_attachment" "github_actions_terraform_backend" {
  role       = aws_iam_role.github_actions_role.name
  policy_arn = module.github_actions_policies.terraform_backend_policy_arn
}

# Adjuntar política de IAM Management
resource "aws_iam_role_policy_attachment" "github_actions_iam_management" {
  role       = aws_iam_role.github_actions_role.name
  policy_arn = module.github_actions_policies.iam_management_policy_arn
}

# Outputs
output "github_actions_role_arn" {
  description = "ARN del rol de GitHub Actions"
  value       = aws_iam_role.github_actions_role.arn
}

output "github_actions_role_name" {
  description = "Nombre del rol de GitHub Actions"
  value       = aws_iam_role.github_actions_role.name
}