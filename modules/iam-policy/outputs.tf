# ==============================================================================
# Outputs del módulo IAM Policy
# ==============================================================================

output "policy_arn" {
  description = "ARN de la política IAM creada"
  value       = aws_iam_policy.this.arn
}

output "policy_name" {
  description = "Nombre de la política IAM creada"
  value       = aws_iam_policy.this.name
}

output "policy_id" {
  description = "ID de la política IAM creada"
  value       = aws_iam_policy.this.id
}

output "policy_path" {
  description = "Ruta de la política IAM creada"
  value       = aws_iam_policy.this.path
}

output "policy_tags" {
  description = "Tags aplicados a la política IAM"
  value       = aws_iam_policy.this.tags
}

output "policy_description" {
  description = "Descripción de la política IAM creada"
  value       = aws_iam_policy.this.description
}
