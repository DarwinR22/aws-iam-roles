output "policy_arn" {
  description = "ARN of the generated IAM policy"
  value       = aws_iam_policy.github_deployment_infrastructure.arn
}

output "policy_name" {
  description = "Name of the generated IAM policy"
  value       = aws_iam_policy.github_deployment_infrastructure.name
}

output "policy_id" {
  description = "ID of the generated IAM policy"
  value       = aws_iam_policy.github_deployment_infrastructure.id
}
