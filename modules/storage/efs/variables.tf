# ==============================================================================
# STORAGE MODULE: EFS - VARIABLES
# ==============================================================================

variable "efs_name" {
  description = "Nombre del EFS file system"
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
variable "enable_encryption" {
  description = "Habilitar encriptación en reposo"
  type        = bool
  default     = true
}

variable "kms_key_arn" {
  description = "ARN de KMS key para encriptar (null = AWS managed key)"
  type        = string
  default     = null
}

# ------------------------------------------------------------------------------
# PERFORMANCE
# ------------------------------------------------------------------------------
variable "performance_mode" {
  description = "Performance mode: generalPurpose o maxIO"
  type        = string
  default     = "generalPurpose"
  
  validation {
    condition     = contains(["generalPurpose", "maxIO"], var.performance_mode)
    error_message = "performance_mode debe ser: generalPurpose o maxIO"
  }
}

variable "throughput_mode" {
  description = "Throughput mode: bursting o provisioned"
  type        = string
  default     = "bursting"
  
  validation {
    condition     = contains(["bursting", "provisioned", "elastic"], var.throughput_mode)
    error_message = "throughput_mode debe ser: bursting, provisioned, o elastic"
  }
}

variable "provisioned_throughput" {
  description = "Throughput provisionado en MiB/s (solo si throughput_mode = provisioned)"
  type        = number
  default     = null
}

# ------------------------------------------------------------------------------
# LIFECYCLE
# ------------------------------------------------------------------------------
variable "lifecycle_policy_transition_to_ia" {
  description = "Días para mover archivos inactivos a IA: AFTER_7_DAYS, AFTER_14_DAYS, AFTER_30_DAYS, AFTER_60_DAYS, AFTER_90_DAYS"
  type        = string
  default     = "AFTER_30_DAYS"
  
  validation {
    condition = contains([
      "AFTER_7_DAYS",
      "AFTER_14_DAYS",
      "AFTER_30_DAYS",
      "AFTER_60_DAYS",
      "AFTER_90_DAYS"
    ], var.lifecycle_policy_transition_to_ia)
    error_message = "lifecycle_policy_transition_to_ia debe ser: AFTER_X_DAYS donde X es 7, 14, 30, 60, o 90"
  }
}

variable "lifecycle_policy_transition_to_primary" {
  description = "Política para regresar archivos a Standard: AFTER_1_ACCESS (null = deshabilitar)"
  type        = string
  default     = null
  
  validation {
    condition     = var.lifecycle_policy_transition_to_primary == null || var.lifecycle_policy_transition_to_primary == "AFTER_1_ACCESS"
    error_message = "lifecycle_policy_transition_to_primary debe ser: null o AFTER_1_ACCESS"
  }
}

# ------------------------------------------------------------------------------
# NETWORK
# ------------------------------------------------------------------------------
variable "subnet_ids" {
  description = "IDs de subnets para mount targets (Multi-AZ recomendado)"
  type        = list(string)
}

variable "security_group_ids" {
  description = "IDs de security groups para EFS mount targets"
  type        = list(string)
}

# ------------------------------------------------------------------------------
# BACKUP
# ------------------------------------------------------------------------------
variable "enable_backup" {
  description = "Habilitar backup automático vía AWS Backup"
  type        = bool
  default     = true
}

# ------------------------------------------------------------------------------
# POLICY
# ------------------------------------------------------------------------------
variable "file_system_policy_json" {
  description = "JSON policy para control de acceso al file system"
  type        = string
  default     = null
}

# ------------------------------------------------------------------------------
# ACCESS POINTS
# ------------------------------------------------------------------------------
variable "create_access_points" {
  description = "Crear access points para /app y /data"
  type        = bool
  default     = true
}

# ------------------------------------------------------------------------------
# MONITORING
# ------------------------------------------------------------------------------
variable "enable_cloudwatch_alarms" {
  description = "Crear CloudWatch alarms para EFS"
  type        = bool
  default     = true
}

variable "sns_topic_arn" {
  description = "ARN del SNS topic para notificaciones de alarmas"
  type        = string
  default     = null
}

variable "max_client_connections" {
  description = "Umbral máximo de conexiones de clientes"
  type        = number
  default     = 50
}
