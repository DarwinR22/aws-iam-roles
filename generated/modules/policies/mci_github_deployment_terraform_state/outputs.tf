# Outputs for github-deployment-terraform-state Policy Module

output "policy_arn" {
  description = "The ARN of the created github-deployment-terraform-state policy"
  value       = aws_iam_policy.main.arn
}

output "policy_name" {
  description = "The name of the created github-deployment-terraform-state policy"
  value       = aws_iam_policy.main.name
}

output "policy_id" {
  description = "The ID of the created github-deployment-terraform-state policy"
  value       = aws_iam_policy.main.id
}