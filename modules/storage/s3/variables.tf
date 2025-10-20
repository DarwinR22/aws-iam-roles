# ==============================================================================
# STORAGE MODULE: S3 - VARIABLES
# ==============================================================================

variable "bucket_name" {
  description = "Nombre del bucket S3"
  type        = string
}

variable "common_tags" {
  description = "Tags comunes para todos los recursos"
  type        = map(string)
  default     = {}
}

variable "data_classification" {
  description = "Clasificación de datos: Public, Internal, Confidential, Restricted"
  type        = string
  default     = "Internal"
  
  validation {
    condition     = contains(["Public", "Internal", "Confidential", "Restricted"], var.data_classification)
    error_message = "data_classification debe ser: Public, Internal, Confidential, o Restricted"
  }
}

# ------------------------------------------------------------------------------
# VERSIONING
# ------------------------------------------------------------------------------
variable "enable_versioning" {
  description = "Habilitar versionado de objetos"
  type        = bool
  default     = true
}

variable "enable_mfa_delete" {
  description = "Requiere MFA para eliminar versiones (solo funciona con root account)"
  type        = bool
  default     = false
}

# ------------------------------------------------------------------------------
# ENCRYPTION
# ------------------------------------------------------------------------------
variable "kms_key_arn" {
  description = "ARN de la KMS key para encriptar (null = AES256)"
  type        = string
  default     = null
}

# ------------------------------------------------------------------------------
# LIFECYCLE
# ------------------------------------------------------------------------------
variable "enable_lifecycle" {
  description = "Habilitar políticas de ciclo de vida"
  type        = bool
  default     = true
}

variable "lifecycle_prefix" {
  description = "Prefijo para aplicar lifecycle rules"
  type        = string
  default     = ""
}

variable "lifecycle_ia_days" {
  description = "Días antes de transición a STANDARD_IA"
  type        = number
  default     = 30
  
  validation {
    condition     = var.lifecycle_ia_days >= 30
    error_message = "lifecycle_ia_days debe ser >= 30 días (requisito AWS)"
  }
}

variable "lifecycle_glacier_days" {
  description = "Días antes de transición a GLACIER"
  type        = number
  default     = 90
  
  validation {
    condition     = var.lifecycle_glacier_days >= 90
    error_message = "lifecycle_glacier_days debe ser >= 90 días"
  }
}

variable "version_expiration_days" {
  description = "Días para expirar versiones no actuales"
  type        = number
  default     = 365
}

# ------------------------------------------------------------------------------
# LOGGING
# ------------------------------------------------------------------------------
variable "enable_logging" {
  description = "Habilitar access logging"
  type        = bool
  default     = true
}

variable "logging_bucket_name" {
  description = "Bucket destino para logs (null = mismo bucket)"
  type        = string
  default     = null
}

# ------------------------------------------------------------------------------
# OBJECT LOCK (WORM)
# ------------------------------------------------------------------------------
variable "enable_object_lock" {
  description = "Habilitar Object Lock para inmutabilidad (WORM)"
  type        = bool
  default     = false
}

variable "object_lock_retention_days" {
  description = "Días de retención para Object Lock"
  type        = number
  default     = 90
}

# ------------------------------------------------------------------------------
# REPLICATION
# ------------------------------------------------------------------------------
variable "enable_replication" {
  description = "Habilitar replicación cross-region"
  type        = bool
  default     = false
}

variable "replication_bucket_arn" {
  description = "ARN del bucket destino para replicación"
  type        = string
  default     = null
}

variable "replication_role_arn" {
  description = "ARN del IAM role para replicación"
  type        = string
  default     = null
}

variable "replication_kms_key_arn" {
  description = "ARN de KMS key en región destino"
  type        = string
  default     = null
}

# ------------------------------------------------------------------------------
# BUCKET POLICY
# ------------------------------------------------------------------------------
variable "bucket_policy_json" {
  description = "JSON policy para el bucket (null = no aplicar)"
  type        = string
  default     = null
}

# ------------------------------------------------------------------------------
# ADVANCED FEATURES
# ------------------------------------------------------------------------------
variable "enable_intelligent_tiering" {
  description = "Habilitar S3 Intelligent-Tiering automático"
  type        = bool
  default     = false
}

variable "enable_metrics" {
  description = "Habilitar CloudWatch metrics para el bucket"
  type        = bool
  default     = true
}

variable "enable_inventory" {
  description = "Habilitar S3 Inventory para auditoría"
  type        = bool
  default     = false
}
