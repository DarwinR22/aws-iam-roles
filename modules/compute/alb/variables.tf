# ==============================================================================
# VARIABLES - ALB MODULE
# ==============================================================================

variable "project_name" {
  description = "Nombre del proyecto"
  type        = string
  default     = "sgsi"
}

variable "environment" {
  description = "Ambiente de despliegue (dev, staging, prod)"
  type        = string
  validation {
    condition     = contains(["dev", "staging", "prod"], var.environment)
    error_message = "Environment debe ser dev, staging, o prod."
  }
}

variable "vpc_id" {
  description = "ID de la VPC donde se desplegará el ALB"
  type        = string
}

variable "subnet_ids" {
  description = "Lista de subnets para el ALB (mínimo 2 AZs)"
  type        = list(string)
}

variable "security_group_ids" {
  description = "Lista de Security Groups para el ALB"
  type        = list(string)
}

variable "internal" {
  description = "Si el ALB es interno (true) o público (false)"
  type        = bool
  default     = false
}

variable "enable_deletion_protection" {
  description = "Habilitar protección contra eliminación"
  type        = bool
  default     = false
}

variable "idle_timeout" {
  description = "Tiempo de espera de conexiones inactivas (segundos)"
  type        = number
  default     = 60
}

variable "access_logs_bucket" {
  description = "Bucket S3 para almacenar logs de acceso del ALB"
  type        = string
  default     = ""
}

# ------------------------------------------------------------------------------
# TARGET GROUP CONFIGURATION
# ------------------------------------------------------------------------------

variable "target_port" {
  description = "Puerto del target group"
  type        = number
  default     = 8080
}

variable "target_protocol" {
  description = "Protocolo del target group (HTTP, HTTPS)"
  type        = string
  default     = "HTTP"
  validation {
    condition     = contains(["HTTP", "HTTPS"], var.target_protocol)
    error_message = "Protocol debe ser HTTP o HTTPS."
  }
}

# ------------------------------------------------------------------------------
# HEALTH CHECK CONFIGURATION
# ------------------------------------------------------------------------------

variable "health_check_path" {
  description = "Path para health check"
  type        = string
  default     = "/"
}

variable "health_check_matcher" {
  description = "Códigos HTTP esperados para health check"
  type        = string
  default     = "200"
}

variable "health_check_interval" {
  description = "Intervalo entre health checks (segundos)"
  type        = number
  default     = 30
}

variable "health_check_timeout" {
  description = "Timeout para health check (segundos)"
  type        = number
  default     = 5
}

variable "health_check_healthy_threshold" {
  description = "Número de health checks exitosos para marcar como healthy"
  type        = number
  default     = 2
}

variable "health_check_unhealthy_threshold" {
  description = "Número de health checks fallidos para marcar como unhealthy"
  type        = number
  default     = 2
}

variable "enable_stickiness" {
  description = "Habilitar session stickiness"
  type        = bool
  default     = false
}

# ------------------------------------------------------------------------------
# HTTPS/SSL CONFIGURATION
# ------------------------------------------------------------------------------

variable "enable_https" {
  description = "Habilitar HTTPS listener"
  type        = bool
  default     = false
}

variable "certificate_arn" {
  description = "ARN del certificado SSL/TLS en ACM"
  type        = string
  default     = ""
}

variable "ssl_policy" {
  description = "Política SSL para el listener HTTPS"
  type        = string
  default     = "ELBSecurityPolicy-TLS-1-2-2017-01"
}

# ------------------------------------------------------------------------------
# CLOUDWATCH ALARMS THRESHOLDS
# ------------------------------------------------------------------------------

variable "response_time_threshold" {
  description = "Threshold para alarma de tiempo de respuesta (segundos)"
  type        = number
  default     = 1.0
}

variable "error_5xx_threshold" {
  description = "Threshold para alarma de errores 5XX"
  type        = number
  default     = 10
}

# ------------------------------------------------------------------------------
# TAGS
# ------------------------------------------------------------------------------

variable "common_tags" {
  description = "Tags comunes para todos los recursos"
  type        = map(string)
  default     = {}
}
