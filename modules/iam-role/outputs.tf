# ==============================================================================
# Outputs del modulo IAM Role
# ==============================================================================

output "role_arn" {
  description = "ARN del rol IAM creado"
  value       = aws_iam_role.this.arn
}

output "role_name" {
  description = "Nombre del rol IAM creado"
  value       = aws_iam_role.this.name
}

output "role_id" {
  description = "ID del rol IAM creado"
  value       = aws_iam_role.this.id
}

output "role_unique_id" {
  description = "ID unico del rol IAM creado"
  value       = aws_iam_role.this.unique_id
}

output "role_create_date" {
  description = "Fecha de creacion del rol IAM"
  value       = aws_iam_role.this.create_date
}

output "role_tags" {
  description = "Applied tags on the IAM role"
  value       = aws_iam_role.this.tags
}

output "attached_managed_policies" {
  description = "List of managed policies attached to the role"
  value       = var.managed_policy_arns
}

output "inline_policies" {
  description = "Map of inline policies attached to the role"
  value       = var.inline_policies
}

output "permission_boundary_arn" {
  description = "ARN of the permission boundary attached to the role"
  value       = local.effective_boundary_arn
}

output "canonical_tags" {
  description = "Canonical tags applied to the role"
  value       = local.auto_completed_tags
}
