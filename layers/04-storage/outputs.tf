# ==============================================================================
# LAYER 4: STORAGE - OUTPUTS
# ==============================================================================

# ------------------------------------------------------------------------------
# S3 OUTPUTS
# ------------------------------------------------------------------------------
output "s3_app_data_bucket_id" {
  description = "ID del bucket S3 para datos de aplicación"
  value       = module.s3_app_data.bucket_id
}

output "s3_app_data_bucket_arn" {
  description = "ARN del bucket S3 para datos de aplicación"
  value       = module.s3_app_data.bucket_arn
}

output "s3_logs_bucket_id" {
  description = "ID del bucket S3 para logs"
  value       = module.s3_logs.bucket_id
}

output "s3_logs_bucket_arn" {
  description = "ARN del bucket S3 para logs"
  value       = module.s3_logs.bucket_arn
}

output "s3_backup_bucket_id" {
  description = "ID del bucket S3 para backups (si está habilitado)"
  value       = var.enable_s3_backup_bucket ? module.s3_backup[0].bucket_id : null
}

output "s3_backup_bucket_arn" {
  description = "ARN del bucket S3 para backups (si está habilitado)"
  value       = var.enable_s3_backup_bucket ? module.s3_backup[0].bucket_arn : null
}

# ------------------------------------------------------------------------------
# EFS OUTPUTS
# ------------------------------------------------------------------------------
output "efs_file_system_id" {
  description = "ID del EFS file system"
  value       = module.efs.file_system_id
}

output "efs_file_system_arn" {
  description = "ARN del EFS file system"
  value       = module.efs.file_system_arn
}

output "efs_dns_name" {
  description = "DNS name para montar EFS"
  value       = module.efs.file_system_dns_name
}

output "efs_mount_command" {
  description = "Comando para montar EFS en EC2"
  value       = module.efs.mount_command
}

output "efs_access_point_app_id" {
  description = "ID del access point /app"
  value       = module.efs.access_point_app_id
}

output "efs_access_point_data_id" {
  description = "ID del access point /data"
  value       = module.efs.access_point_data_id
}

# ------------------------------------------------------------------------------
# AWS BACKUP OUTPUTS
# ------------------------------------------------------------------------------
output "backup_vault_id" {
  description = "ID del backup vault"
  value       = module.backup.vault_id
}

output "backup_vault_arn" {
  description = "ARN del backup vault"
  value       = module.backup.vault_arn
}

output "backup_plan_id" {
  description = "ID del backup plan"
  value       = module.backup.plan_id
}

output "backup_plan_arn" {
  description = "ARN del backup plan"
  value       = module.backup.plan_arn
}

output "backup_sns_topic_arn" {
  description = "ARN del SNS topic para notificaciones de backup"
  value       = module.backup.sns_topic_arn
}

output "backup_schedule_summary" {
  description = "Resumen de schedules de backup"
  value       = module.backup.backup_schedule_summary
}

output "backup_retention_summary" {
  description = "Resumen de políticas de retención"
  value       = module.backup.retention_summary
}

# ------------------------------------------------------------------------------
# COMPLIANCE SUMMARY
# ------------------------------------------------------------------------------
output "compliance_summary" {
  description = "Resumen de compliance ISO 27001 y NIST CSF"
  value = {
    layer = "Storage"
    modules = {
      s3_app_data = module.s3_app_data.compliance_summary
      s3_logs     = module.s3_logs.compliance_summary
      efs         = module.efs.compliance_summary
      backup      = module.backup.compliance_summary
    }
    iso27001_controls = [
      "A.12.3.1 - Information backup",
      "A.18.1.3 - Protection of records",
      "A.17.1.2 - Implementing information security continuity",
      "A.12.4.1 - Event logging"
    ]
    nist_csf_functions = [
      "PR.DS-1 - Data-at-rest is protected",
      "PR.DS-6 - Integrity checking mechanisms",
      "PR.IP-4 - Backups of information are conducted",
      "RC.RP-1 - Recovery plan is executed"
    ]
  }
}

# ------------------------------------------------------------------------------
# LAYER INFO
# ------------------------------------------------------------------------------
output "layer_info" {
  description = "Información de Layer 4"
  value = {
    layer_name   = "Storage"
    layer_number = "04"
    state_key    = "sgsi/layer4-storage/terraform.tfstate"
    modules_deployed = {
      s3_buckets = var.enable_s3_backup_bucket ? 3 : 2
      efs        = 1
      backup     = 1
    }
    features = {
      s3_versioning          = true
      s3_lifecycle           = true
      s3_object_lock         = true
      efs_encrypted          = true
      efs_multi_az           = true
      backup_daily           = true
      backup_weekly          = true
      backup_monthly         = true
      cross_region_backup    = var.enable_cross_region_backup
    }
  }
}