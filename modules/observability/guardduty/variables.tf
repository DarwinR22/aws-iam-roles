# ==============================================================================
# GUARDDUTY MODULE - VARIABLES
# ==============================================================================

variable "detector_name" {
  description = "Nombre del detector de GuardDuty"
  type        = string
}

variable "enable_guardduty" {
  description = "Habilitar GuardDuty detector"
  type        = bool
  default     = true
}

variable "finding_publishing_frequency" {
  description = "Frecuencia de publicación de findings (FIFTEEN_MINUTES, ONE_HOUR, SIX_HOURS)"
  type        = string
  default     = "FIFTEEN_MINUTES"
  
  validation {
    condition     = contains(["FIFTEEN_MINUTES", "ONE_HOUR", "SIX_HOURS"], var.finding_publishing_frequency)
    error_message = "Must be FIFTEEN_MINUTES, ONE_HOUR, or SIX_HOURS."
  }
}

variable "enable_s3_protection" {
  description = "Habilitar protección de S3 (detectar acceso no autorizado)"
  type        = bool
  default     = true
}

variable "enable_kubernetes_protection" {
  description = "Habilitar protección de Kubernetes (EKS audit logs)"
  type        = bool
  default     = false # false en dev si no hay EKS
}

variable "enable_malware_protection" {
  description = "Habilitar escaneo de malware en EBS volumes"
  type        = bool
  default     = true
}

variable "enable_sns_notifications" {
  description = "Habilitar notificaciones SNS para findings"
  type        = bool
  default     = true
}

variable "notification_emails" {
  description = "Lista de emails para recibir alertas de GuardDuty"
  type        = list(string)
  default     = []
}

variable "enable_eventbridge_integration" {
  description = "Habilitar integración con EventBridge para automatización"
  type        = bool
  default     = true
}

variable "enable_cloudwatch_logs" {
  description = "Habilitar almacenamiento de findings en CloudWatch Logs"
  type        = bool
  default     = true
}

variable "log_retention_days" {
  description = "Días de retención de logs en CloudWatch"
  type        = number
  default     = 90
}

variable "common_tags" {
  description = "Tags comunes para todos los recursos"
  type        = map(string)
  default     = {}
}
