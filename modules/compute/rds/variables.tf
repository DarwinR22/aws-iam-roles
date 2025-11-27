# ==============================================================================
# VARIABLES - RDS MODULE
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
  description = "Lista de subnets para el DB Subnet Group (mínimo 2 AZs)"
  type        = list(string)
}

variable "security_group_ids" {
  description = "Lista de Security Groups para RDS"
  type        = list(string)
}

# ------------------------------------------------------------------------------
# DATABASE ENGINE CONFIGURATION
# ------------------------------------------------------------------------------

variable "engine" {
  description = "Motor de base de datos (postgres, mysql, mariadb)"
  type        = string
  default     = "postgres"
  validation {
    condition     = contains(["postgres", "mysql", "mariadb"], var.engine)
    error_message = "Engine debe ser postgres, mysql, o mariadb."
  }
}

variable "engine_version" {
  description = "Versión del motor de base de datos"
  type        = string
  default     = "14.9"
}

variable "instance_class" {
  description = "Tipo de instancia RDS"
  type        = string
  default     = "db.t3.micro"
}

variable "parameter_group_family" {
  description = "Familia del parameter group"
  type        = string
  default     = "postgres14"
}

variable "db_name" {
  description = "Nombre de la base de datos inicial"
  type        = string
  default     = "sgsi_db"
}

variable "db_port" {
  description = "Puerto de la base de datos"
  type        = number
  default     = 5432
}

variable "master_username" {
  description = "Usuario maestro de la base de datos"
  type        = string
  default     = "dbadmin"
  sensitive   = true
}

variable "master_password" {
  description = "Contraseña del usuario maestro"
  type        = string
  sensitive   = true
}

# ------------------------------------------------------------------------------
# STORAGE CONFIGURATION
# ------------------------------------------------------------------------------

variable "allocated_storage" {
  description = "Almacenamiento inicial en GB"
  type        = number
  default     = 20
}

variable "max_allocated_storage" {
  description = "Almacenamiento máximo para autoscaling (GB)"
  type        = number
  default     = 100
}

variable "storage_type" {
  description = "Tipo de almacenamiento (gp3, gp2, io1)"
  type        = string
  default     = "gp3"
  validation {
    condition     = contains(["gp3", "gp2", "io1"], var.storage_type)
    error_message = "Storage type debe ser gp3, gp2, o io1."
  }
}

variable "iops" {
  description = "IOPS provisionados (solo para io1)"
  type        = number
  default     = null
}

variable "kms_key_id" {
  description = "ARN de la KMS key para encriptación (opcional)"
  type        = string
  default     = ""
}

# ------------------------------------------------------------------------------
# HIGH AVAILABILITY CONFIGURATION
# ------------------------------------------------------------------------------

variable "multi_az" {
  description = "Habilitar despliegue Multi-AZ (false para free tier)"
  type        = bool
  default     = false  # Multi-AZ not available in free tier
}

variable "availability_zone" {
  description = "Availability Zone específica (solo para single-AZ)"
  type        = string
  default     = ""
}

# ------------------------------------------------------------------------------
# BACKUP CONFIGURATION
# ------------------------------------------------------------------------------

variable "backup_retention_period" {
  description = "Días de retención de backups automáticos (max 7 para free tier)"
  type        = number
  default     = 7  # AWS Free Tier limit
}

variable "backup_window" {
  description = "Ventana de backup preferida (UTC)"
  type        = string
  default     = "03:00-04:00"
}

variable "skip_final_snapshot" {
  description = "Omitir snapshot final al eliminar (solo para dev/test)"
  type        = bool
  default     = false
}

# ------------------------------------------------------------------------------
# MAINTENANCE CONFIGURATION
# ------------------------------------------------------------------------------

variable "maintenance_window" {
  description = "Ventana de mantenimiento preferida (UTC)"
  type        = string
  default     = "sun:04:00-sun:05:00"
}

variable "auto_minor_version_upgrade" {
  description = "Habilitar upgrades automáticos de versiones menores"
  type        = bool
  default     = true
}

variable "apply_immediately" {
  description = "Aplicar cambios inmediatamente (en lugar de ventana de mantenimiento)"
  type        = bool
  default     = false
}

# ------------------------------------------------------------------------------
# MONITORING CONFIGURATION
# ------------------------------------------------------------------------------

variable "enabled_cloudwatch_logs_exports" {
  description = "Tipos de logs a exportar a CloudWatch"
  type        = list(string)
  default     = ["postgresql"]
}

variable "monitoring_interval" {
  description = "Intervalo de monitoreo mejorado (0, 1, 5, 10, 15, 30, 60)"
  type        = number
  default     = 60
  validation {
    condition     = contains([0, 1, 5, 10, 15, 30, 60], var.monitoring_interval)
    error_message = "Monitoring interval debe ser 0, 1, 5, 10, 15, 30, o 60."
  }
}

variable "performance_insights_enabled" {
  description = "Habilitar Performance Insights"
  type        = bool
  default     = true
}

variable "performance_insights_retention" {
  description = "Días de retención de Performance Insights (7 o 731)"
  type        = number
  default     = 7
  validation {
    condition     = contains([7, 731], var.performance_insights_retention)
    error_message = "Performance Insights retention debe ser 7 o 731 días."
  }
}

# ------------------------------------------------------------------------------
# PROTECTION CONFIGURATION
# ------------------------------------------------------------------------------

variable "deletion_protection" {
  description = "Habilitar protección contra eliminación"
  type        = bool
  default     = true
}

# ------------------------------------------------------------------------------
# CLOUDWATCH ALARM THRESHOLDS
# ------------------------------------------------------------------------------

variable "cpu_threshold" {
  description = "Threshold de CPU para alarma (%)"
  type        = number
  default     = 80
}

variable "storage_threshold_bytes" {
  description = "Threshold de almacenamiento libre para alarma (bytes)"
  type        = number
  default     = 10737418240  # 10 GB
}

variable "connections_threshold" {
  description = "Threshold de conexiones para alarma"
  type        = number
  default     = 80
}

# ------------------------------------------------------------------------------
# TAGS
# ------------------------------------------------------------------------------

variable "common_tags" {
  description = "Tags comunes para todos los recursos"
  type        = map(string)
  default     = {}
}
