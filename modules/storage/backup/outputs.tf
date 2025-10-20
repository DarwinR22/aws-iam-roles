# ==============================================================================
# STORAGE MODULE: AWS BACKUP - OUTPUTS
# ==============================================================================

output "vault_id" {
  description = "ID del backup vault"
  value       = aws_backup_vault.main.id
}

output "vault_arn" {
  description = "ARN del backup vault"
  value       = aws_backup_vault.main.arn
}

output "vault_recovery_points" {
  description = "Número de recovery points en el vault"
  value       = aws_backup_vault.main.recovery_points
}

output "plan_id" {
  description = "ID del backup plan"
  value       = aws_backup_plan.main.id
}

output "plan_arn" {
  description = "ARN del backup plan"
  value       = aws_backup_plan.main.arn
}

output "plan_version" {
  description = "Versión del backup plan"
  value       = aws_backup_plan.main.version
}

output "selection_id" {
  description = "ID de la backup selection"
  value       = aws_backup_selection.main.id
}

output "sns_topic_arn" {
  description = "ARN del SNS topic para notificaciones"
  value       = var.create_sns_topic ? aws_sns_topic.backup_notifications[0].arn : null
}

output "backup_schedule_summary" {
  description = "Resumen de schedules configurados"
  value = {
    daily_schedule   = var.daily_backup_schedule
    weekly_schedule  = var.weekly_backup_schedule
    monthly_schedule = var.monthly_backup_schedule
  }
}

output "retention_summary" {
  description = "Resumen de políticas de retención"
  value = {
    daily_retention_days   = var.daily_retention_days
    weekly_retention_days  = var.weekly_retention_days
    monthly_retention_days = var.monthly_retention_days
  }
}

output "compliance_summary" {
  description = "Resumen de compliance y configuración"
  value = {
    vault_encrypted         = var.kms_key_arn != null
    vault_lock_enabled      = var.enable_vault_lock
    cross_region_enabled    = var.enable_cross_region_backup
    notifications_enabled   = var.create_sns_topic
    cloudwatch_alarms       = var.enable_cloudwatch_alarms
    backup_frequencies      = ["Daily", "Weekly", "Monthly"]
    iso27001_controls       = ["A.12.3.1", "A.17.1.2", "A.18.1.3"]
    nist_csf_functions      = ["PR.IP-4", "RC.RP-1", "PR.DS-1"]
  }
}
