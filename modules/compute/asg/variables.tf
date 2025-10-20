# ==============================================================================
# VARIABLES - ASG MODULE
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

variable "subnet_ids" {
  description = "Lista de subnets para el ASG (Multi-AZ)"
  type        = list(string)
}

variable "security_group_ids" {
  description = "Lista de Security Groups para las instancias EC2"
  type        = list(string)
}

variable "target_group_arns" {
  description = "Lista de ARNs de Target Groups para el ASG"
  type        = list(string)
  default     = []
}

# ------------------------------------------------------------------------------
# INSTANCE CONFIGURATION
# ------------------------------------------------------------------------------

variable "ami_id" {
  description = "ID de la AMI (vacío para usar Amazon Linux 2 más reciente)"
  type        = string
  default     = ""
}

variable "instance_type" {
  description = "Tipo de instancia EC2"
  type        = string
  default     = "t3.micro"
}

variable "root_volume_size" {
  description = "Tamaño del volumen raíz en GB"
  type        = number
  default     = 20
}

variable "detailed_monitoring" {
  description = "Habilitar monitoreo detallado (CloudWatch)"
  type        = bool
  default     = true
}

variable "enable_cloudwatch_agent" {
  description = "Habilitar CloudWatch Agent en instancias"
  type        = bool
  default     = true
}

# ------------------------------------------------------------------------------
# AUTO SCALING CONFIGURATION
# ------------------------------------------------------------------------------

variable "min_size" {
  description = "Número mínimo de instancias"
  type        = number
  default     = 2
}

variable "max_size" {
  description = "Número máximo de instancias"
  type        = number
  default     = 6
}

variable "desired_capacity" {
  description = "Capacidad deseada de instancias"
  type        = number
  default     = 2
}

variable "health_check_type" {
  description = "Tipo de health check (EC2 o ELB)"
  type        = string
  default     = "ELB"
  validation {
    condition     = contains(["EC2", "ELB"], var.health_check_type)
    error_message = "Health check type debe ser EC2 o ELB."
  }
}

variable "health_check_grace_period" {
  description = "Tiempo de gracia para health check (segundos)"
  type        = number
  default     = 300
}

# ------------------------------------------------------------------------------
# SCALING POLICIES
# ------------------------------------------------------------------------------

variable "scale_up_adjustment" {
  description = "Número de instancias a agregar al escalar hacia arriba"
  type        = number
  default     = 1
}

variable "scale_up_cooldown" {
  description = "Tiempo de espera después de scale up (segundos)"
  type        = number
  default     = 300
}

variable "scale_down_adjustment" {
  description = "Número de instancias a remover al escalar hacia abajo (negativo)"
  type        = number
  default     = -1
}

variable "scale_down_cooldown" {
  description = "Tiempo de espera después de scale down (segundos)"
  type        = number
  default     = 300
}

# ------------------------------------------------------------------------------
# CLOUDWATCH ALARM THRESHOLDS
# ------------------------------------------------------------------------------

variable "cpu_high_threshold" {
  description = "Threshold de CPU para scale up (%)"
  type        = number
  default     = 70
}

variable "cpu_low_threshold" {
  description = "Threshold de CPU para scale down (%)"
  type        = number
  default     = 30
}

# ------------------------------------------------------------------------------
# TAGS
# ------------------------------------------------------------------------------

variable "common_tags" {
  description = "Tags comunes para todos los recursos"
  type        = map(string)
  default     = {}
}
