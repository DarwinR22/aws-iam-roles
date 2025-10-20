# ==============================================================================
# LAYER 3: COMPUTE - VARIABLES
# ==============================================================================

variable "aws_region" {
  description = "AWS region for deployment"
  type        = string
  default     = "us-east-1"
}

variable "project_name" {
  description = "Nombre del proyecto"
  type        = string
  default     = "sgsi"
}

variable "environment" {
  description = "Environment name (dev, staging, prod)"
  type        = string
  default     = "dev"
}

variable "common_tags" {
  description = "Common tags to be applied to all resources"
  type        = map(string)
  default     = {}
}

# ==============================================================================
# ALB (Application Load Balancer) CONFIGURATION
# ==============================================================================

variable "alb_enable_deletion_protection" {
  description = "Habilitar protección contra eliminación del ALB"
  type        = bool
  default     = false
}

variable "alb_access_logs_bucket" {
  description = "Bucket S3 para logs de acceso del ALB (vacío para desabilitar)"
  type        = string
  default     = ""
}

variable "alb_enable_https" {
  description = "Habilitar HTTPS listener en el ALB"
  type        = bool
  default     = false
}

variable "alb_certificate_arn" {
  description = "ARN del certificado SSL/TLS en ACM (requerido si HTTPS está habilitado)"
  type        = string
  default     = ""
}

# ==============================================================================
# ASG (Auto Scaling Group) CONFIGURATION
# ==============================================================================

variable "asg_ami_id" {
  description = "ID de la AMI para instancias EC2 (vacío para usar Amazon Linux 2 latest)"
  type        = string
  default     = ""
}

variable "asg_instance_type" {
  description = "Tipo de instancia EC2 para web servers"
  type        = string
  default     = "t3.micro"
}

variable "asg_min_size" {
  description = "Número mínimo de instancias en ASG"
  type        = number
  default     = 2
}

variable "asg_max_size" {
  description = "Número máximo de instancias en ASG"
  type        = number
  default     = 6
}

variable "asg_desired_capacity" {
  description = "Capacidad deseada de instancias en ASG"
  type        = number
  default     = 2
}

# ==============================================================================
# RDS (Database) CONFIGURATION
# ==============================================================================

variable "rds_engine" {
  description = "Motor de base de datos (postgres, mysql, mariadb)"
  type        = string
  default     = "postgres"
}

variable "rds_engine_version" {
  description = "Versión del motor de base de datos"
  type        = string
  default     = "14.9"
}

variable "rds_instance_class" {
  description = "Tipo de instancia RDS"
  type        = string
  default     = "db.t3.micro"
}

variable "rds_parameter_group_family" {
  description = "Familia del parameter group"
  type        = string
  default     = "postgres14"
}

variable "rds_db_name" {
  description = "Nombre de la base de datos inicial"
  type        = string
  default     = "sgsi_db"
}

variable "rds_db_port" {
  description = "Puerto de la base de datos"
  type        = number
  default     = 5432
}

variable "rds_master_username" {
  description = "Usuario maestro de la base de datos"
  type        = string
  default     = "dbadmin"
  sensitive   = true
}

variable "rds_master_password" {
  description = "Contraseña del usuario maestro (cambiar en producción)"
  type        = string
  sensitive   = true
}

variable "rds_allocated_storage" {
  description = "Almacenamiento inicial en GB"
  type        = number
  default     = 20
}

variable "rds_max_allocated_storage" {
  description = "Almacenamiento máximo para autoscaling (GB)"
  type        = number
  default     = 100
}

variable "rds_multi_az" {
  description = "Habilitar despliegue Multi-AZ para alta disponibilidad"
  type        = bool
  default     = true
}

variable "rds_backup_retention_period" {
  description = "Días de retención de backups automáticos"
  type        = number
  default     = 30
}

variable "rds_skip_final_snapshot" {
  description = "Omitir snapshot final al eliminar (solo para dev/test)"
  type        = bool
  default     = false
}

variable "rds_deletion_protection" {
  description = "Habilitar protección contra eliminación de RDS"
  type        = bool
  default     = true
}

# ==============================================================================
# SNS ALARMS CONFIGURATION (Optional)
# ==============================================================================

variable "enable_sns_alarms" {
  description = "Habilitar topic SNS para alarmas de CloudWatch"
  type        = bool
  default     = false
}

variable "sns_alarm_email" {
  description = "Email para recibir notificaciones de alarmas"
  type        = string
  default     = ""
}
