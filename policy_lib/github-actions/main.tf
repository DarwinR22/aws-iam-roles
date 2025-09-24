# MCI GitHub Actions Managed Policies
# ==================================
# Políticas granulares para GitHub Actions CI/CD

# 1. Terraform Backend Access
module "github_actions_terraform_backend_policy" {
  source = "../iam-managed-policy"
  
  name        = "MCI-GitHubActions-TerraformBackend"
  path        = "/MCI/GitHubActions/"
  description = "Política para acceso al backend de Terraform desde GitHub Actions (S3, DynamoDB, KMS)"
  
  policy = data.aws_iam_policy_document.github_actions_terraform_backend.json
  tags   = var.common_tags
}

# 2. IAM Management  
module "github_actions_iam_management_policy" {
  source = "../iam-managed-policy"
  
  name        = "MCI-GitHubActions-IAMManagement"
  path        = "/MCI/GitHubActions/"
  description = "Política para gestión de roles y políticas IAM desde GitHub Actions"
  
  policy = data.aws_iam_policy_document.github_actions_iam_management.json
  tags   = var.common_tags
}

# Output ARNs for role attachment
output "terraform_backend_policy_arn" {
  description = "ARN de la política de backend de Terraform"
  value       = module.github_actions_terraform_backend_policy.arn
}

output "iam_management_policy_arn" {
  description = "ARN de la política de gestión IAM"  
  value       = module.github_actions_iam_management_policy.arn
}