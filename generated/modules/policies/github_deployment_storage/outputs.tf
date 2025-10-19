output "policy_arn" {
  description = "ARN of the generated IAM policy"
  value       = aws_iam_policy.github_deployment_storage.arn
}

output "policy_name" {
  description = "Name of the generated IAM policy"
  value       = aws_iam_policy.github_deployment_storage.name
}

output "policy_id" {
  description = "ID of the generated IAM policy"
  value       = aws_iam_policy.github_deployment_storage.id
}
