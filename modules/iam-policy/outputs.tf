# ==============================================================================
# Outputs del modulo IAM Policy
# ==============================================================================

output "policy_arn" {
  description = "ARN de la politica IAM creada"
  value       = aws_iam_policy.this.arn
}

output "policy_name" {
  description = "Nombre de la politica IAM creada"
  value       = aws_iam_policy.this.name
}

output "policy_id" {
  description = "ID de la politica IAM creada"
  value       = aws_iam_policy.this.id
}

output "policy_path" {
  description = "Ruta de la politica IAM creada"
  value       = aws_iam_policy.this.path
}

output "policy_tags" {
  description = "Tags aplicados a la politica IAM"
  value       = aws_iam_policy.this.tags
}

output "policy_description" {
  description = "Descripcion de la politica IAM creada"
  value       = aws_iam_policy.this.description
}
