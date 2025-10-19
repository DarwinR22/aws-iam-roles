# ==============================================================================
# MODULE OUTPUTS
# ==============================================================================

output "backup_vault_id" {
  description = "Backup Vault Id"
  value       = aws_backup_vault.main.id
}

output "backup_vault_arn" {
  description = "Backup Vault Arn"
  value       = aws_backup_vault.main.arn
}

output "backup_plan_id" {
  description = "Backup Plan Id"
  value       = aws_backup_plan.main.id
}

output "module_info" {
  description = "Information about this module"
  value = {
    module_name = "backup-vault"
    status      = "implemented"
  }
}
