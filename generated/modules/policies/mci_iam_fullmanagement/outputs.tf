# Outputs for MCI-IAM-FullManagement Policy Module

output "policy_arn" {
  description = "The ARN of the created MCI-IAM-FullManagement policy"
  value       = aws_iam_policy.main.arn
}

output "policy_name" {
  description = "The name of the created MCI-IAM-FullManagement policy"
  value       = aws_iam_policy.main.name
}

output "policy_id" {
  description = "The ID of the created MCI-IAM-FullManagement policy"
  value       = aws_iam_policy.main.id
}