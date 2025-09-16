# ==============================================================================
# Outputs del módulo IAM Role
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
  description = "ID único del rol IAM creado"
  value       = aws_iam_role.this.unique_id
}

output "role_create_date" {
  description = "Fecha de creación del rol IAM"
  value       = aws_iam_role.this.create_date
}

output "role_tags" {
  description = "Tags aplicados al rol IAM"
  value       = aws_iam_role.this.tags
}

output "attached_policies" {
  description = "Lista de políticas adjuntadas al rol"
  value       = var.policy_arns
}

output "role_components" {
  description = "Componentes extraídos del nombre del rol"
  value = {
    servicio = local.servicio
    layer    = local.layer
    ambiente = local.ambiente
    nombre   = local.nombre
  }
}
