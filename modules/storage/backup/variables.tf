# ==============================================================================
# STORAGE MODULE: AWS BACKUP - VARIABLES
# ==============================================================================

variable "vault_name" {
  description = "Nombre del backup vault"
  type        = string
}

variable "plan_name" {
  description = "Nombre del backup plan"
  type        = string
}

variable "common_tags" {
  description = "Tags comunes para todos los recursos"
  type        = map(string)
  default     = {}
}

# ------------------------------------------------------------------------------
# ENCRYPTION
# ------------------------------------------------------------------------------
variable "kms_key_arn" {
  description = "ARN de KMS key para encriptar backups (null = AWS managed key)"
  type        = string
  default     = null
}

# ------------------------------------------------------------------------------
# VAULT LOCK (WORM)
# ------------------------------------------------------------------------------
variable "enable_vault_lock" {
  description = "Habilitar Vault Lock para inmutabilidad (WORM)"
  type        = bool
  default     = false
}

variable "vault_lock_changeable_days" {
  description = "Días durante los cuales el lock es modificable (72 horas mínimo en producción)"
  type        = number
  default     = 3
}

variable "vault_lock_min_retention_days" {
  description = "Mínimo de días de retención forzada"
  type        = number
  default     = 30
}

variable "vault_lock_max_retention_days" {
  description = "Máximo de días de retención permitida"
  type        = number
  default     = 365
}

# ------------------------------------------------------------------------------
# VAULT POLICY
# ------------------------------------------------------------------------------
variable "vault_policy_json" {
  description = "JSON policy para control de acceso al vault"
  type        = string
  default     = null
}

# ------------------------------------------------------------------------------
# BACKUP SCHEDULES (CRON FORMAT)
# ------------------------------------------------------------------------------
variable "daily_backup_schedule" {
  description = "Schedule para backups diarios (CRON format UTC)"
  type        = string
  default     = "cron(0 2 * * ? *)" # 02:00 AM UTC diario
}

variable "weekly_backup_schedule" {
  description = "Schedule para backups semanales (CRON format UTC)"
  type        = string
  default     = "cron(0 3 ? * SUN *)" # 03:00 AM UTC domingos
}

variable "monthly_backup_schedule" {
  description = "Schedule para backups mensuales (CRON format UTC)"
  type        = string
  default     = "cron(0 4 1 * ? *)" # 04:00 AM UTC primer día del mes
}

# ------------------------------------------------------------------------------
# BACKUP WINDOWS
# ------------------------------------------------------------------------------
variable "backup_start_window" {
  description = "Minutos desde el schedule para iniciar backup"
  type        = number
  default     = 60
}

variable "backup_completion_window" {
  description = "Minutos para completar backup después de iniciar"
  type        = number
  default     = 120
}

# ------------------------------------------------------------------------------
# RETENTION
# ------------------------------------------------------------------------------
variable "daily_retention_days" {
  description = "Días de retención para backups diarios"
  type        = number
  default     = 7
}

variable "weekly_retention_days" {
  description = "Días de retención para backups semanales"
  type        = number
  default     = 30
}

variable "monthly_retention_days" {
  description = "Días de retención para backups mensuales"
  type        = number
  default     = 365
}

# ------------------------------------------------------------------------------
# CROSS-REGION BACKUP
# ------------------------------------------------------------------------------
variable "enable_cross_region_backup" {
  description = "Habilitar copia de backups a otra región"
  type        = bool
  default     = false
}

variable "destination_vault_arn" {
  description = "ARN del vault destino en otra región"
  type        = string
  default     = null
}

# ------------------------------------------------------------------------------
# RESOURCE SELECTION
# ------------------------------------------------------------------------------
variable "backup_role_arn" {
  description = "ARN del IAM role para AWS Backup"
  type        = string
}

variable "backup_tag_key" {
  description = "Tag key para identificar recursos a respaldar"
  type        = string
  default     = "Backup"
}

variable "backup_tag_value" {
  description = "Tag value para identificar recursos a respaldar"
  type        = string
  default     = "true"
}

variable "resource_arns" {
  description = "Lista de ARNs específicos para respaldar (opcional)"
  type        = list(string)
  default     = null
}

variable "backup_selection_conditions" {
  description = "Condiciones avanzadas para selección de recursos"
  type = object({
    string_equals = optional(object({
      key   = string
      value = string
    }))
    string_not_equals = optional(object({
      key   = string
      value = string
    }))
  })
  default = null
}

# ------------------------------------------------------------------------------
# NOTIFICATIONS
# ------------------------------------------------------------------------------
variable "create_sns_topic" {
  description = "Crear SNS topic para notificaciones de backup"
  type        = bool
  default     = true
}

variable "backup_vault_events" {
  description = "Eventos de backup que generan notificaciones"
  type        = list(string)
  default = [
    "BACKUP_JOB_STARTED",
    "BACKUP_JOB_COMPLETED",
    "BACKUP_JOB_FAILED",
    "RESTORE_JOB_STARTED",
    "RESTORE_JOB_COMPLETED",
    "RESTORE_JOB_FAILED"
  ]
}

# ------------------------------------------------------------------------------
# MONITORING
# ------------------------------------------------------------------------------
variable "enable_cloudwatch_alarms" {
  description = "Crear CloudWatch alarms para monitoreo de backups"
  type        = bool
  default     = true
}
