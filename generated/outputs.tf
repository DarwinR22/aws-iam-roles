# Outputs for MCI IAM Infrastructure

output "github_deployment_role_arn" {
  description = "ARN of the GitHub Actions deployment role"
  value       = aws_iam_role.github_deployment.arn
}

output "github_deployment_role_name" {
  description = "Name of the GitHub Actions deployment role"
  value       = aws_iam_role.github_deployment.name
}

output "account_id" {
  description = "Current AWS Account ID"
  value       = local.account_id
}

output "region" {
  description = "Current AWS Region"
  value       = local.region
}