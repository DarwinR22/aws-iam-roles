# ==============================================================================
# LAYER 4: STORAGE - CONFIGURATION (DEV ENVIRONMENT)
# ==============================================================================

aws_region   = "us-east-1"
environment  = "dev"
project_name = "sgsi"
owner        = "SGSI-Team"

# ------------------------------------------------------------------------------
# S3 CONFIGURATION
# ------------------------------------------------------------------------------
enable_s3_replication    = false # Habilitar en producción para DR
enable_s3_backup_bucket  = true  # Bucket adicional para archivos de backup

# ------------------------------------------------------------------------------
# EFS CONFIGURATION
# ------------------------------------------------------------------------------
efs_performance_mode             = "generalPurpose" # O "maxIO" para alta concurrencia
efs_throughput_mode              = "bursting"       # O "provisioned" o "elastic"
efs_provisioned_throughput       = null             # Solo si throughput_mode = "provisioned"
efs_lifecycle_transition_to_ia   = "AFTER_30_DAYS"  # Transición a IA después de 30 días
efs_lifecycle_transition_to_primary = null          # null = no regresar automáticamente

# ------------------------------------------------------------------------------
# AWS BACKUP CONFIGURATION
# ------------------------------------------------------------------------------
enable_backup_vault_lock     = false # true en producción para WORM compliance
backup_daily_retention_days  = 7     # 1 semana para backups diarios
backup_weekly_retention_days = 30    # 1 mes para backups semanales
backup_monthly_retention_days = 365  # 1 año para backups mensuales

# Cross-region backup (DR)
enable_cross_region_backup    = false # Habilitar en producción
backup_destination_vault_arn  = null  # ARN del vault en región secundaria

# ------------------------------------------------------------------------------
# COMMON TAGS
# ------------------------------------------------------------------------------
common_tags = {
  Project           = "SGSI-Implementation"
  Layer             = "Storage"
  Environment       = "Development"
  SecurityLevel     = "High"
  ComplianceScope   = "ISO27001+NIST-CSF"
  CreatedBy         = "GitHub-Actions"
  MaintenanceWindow = "Sunday-2AM-6AM"
  BackupRequired    = "Yes"
  MonitoringEnabled = "Yes"
  LoggingEnabled    = "Yes"
}