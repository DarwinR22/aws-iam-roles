# modules/iam-managed-policy/outputs.tf
# ====================================
# OUTPUTS FOR IAM POLICY MODULE
# ====================================

output "policy_arn" {
  description = "ARN of the IAM policy"
  value       = aws_iam_policy.this.arn
}

output "policy_name" {
  description = "Name of the IAM policy"
  value       = aws_iam_policy.this.name
}

output "policy_id" {
  description = "ID of the IAM policy"
  value       = aws_iam_policy.this.id
}

output "policy_tags" {
  description = "Applied tags on the IAM policy"
  value       = aws_iam_policy.this.tags
}

output "policy_path" {
  description = "Path of the IAM policy"
  value       = aws_iam_policy.this.path
}

output "policy_document" {
  description = "The policy document"
  value       = var.policy_document_json
  sensitive   = true
}