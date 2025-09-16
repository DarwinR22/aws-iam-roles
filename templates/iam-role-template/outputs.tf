# ==============================================================================
# Outputs de la plantilla de rol IAM
# ==============================================================================

output "role_arn" {
  description = "ARN del rol IAM creado"
  value       = module.iam_role.role_arn
}

output "role_name" {
  description = "Nombre del rol IAM creado"
  value       = module.iam_role.role_name
}

output "role_id" {
  description = "ID del rol IAM creado"
  value       = module.iam_role.role_id
}

output "role_components" {
  description = "Componentes del nombre del rol"
  value       = module.iam_role.role_components
}

output "custom_policy_arn" {
  description = "ARN de la política personalizada S3 (si se crea)"
  value       = var.create_s3_policy ? module.s3_policy[0].policy_arn : null
}

output "full_role_name" {
  description = "Nombre completo del rol generado"
  value       = "rol-${var.servicio}-${var.layer}-${var.ambiente}-${var.nombre}"
}

output "role_tags" {
  description = "Tags aplicados al rol"
  value       = module.iam_role.role_tags
}
