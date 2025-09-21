# modules/iam-attachments/outputs.tf
# ===================================
# OUTPUTS FOR IAM ATTACHMENTS MODULE
# ===================================

output "attached_policy_arns" {
  description = "List of all attached policy ARNs"
  value       = local.unique_policy_arns
}

output "attachment_count" {
  description = "Number of policies attached"
  value       = local.policy_count
}

output "aws_managed_policies" {
  description = "List of attached AWS managed policies"
  value       = local.aws_managed_arns
}

output "customer_managed_policies" {
  description = "List of attached customer managed policies"
  value       = local.customer_managed_arns
}

output "role_name" {
  description = "Name of the role with attached policies"
  value       = var.role_name
}

output "role_arn" {
  description = "ARN of the role with attached policies"
  value       = data.aws_iam_role.target_role.arn
}