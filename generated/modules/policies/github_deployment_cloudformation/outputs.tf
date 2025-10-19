output "policy_arn" {
  description = "ARN of the generated IAM policy"
  value       = aws_iam_policy.github_deployment_cloudformation.arn
}

output "policy_name" {
  description = "Name of the generated IAM policy"
  value       = aws_iam_policy.github_deployment_cloudformation.name
}

output "policy_id" {
  description = "ID of the generated IAM policy"
  value       = aws_iam_policy.github_deployment_cloudformation.id
}
