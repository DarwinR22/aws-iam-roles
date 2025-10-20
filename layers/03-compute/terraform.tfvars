# ==============================================================================
# LAYER 3: COMPUTE - TERRAFORM VARIABLES
# Environment: Development
# ==============================================================================

# AWS Configuration
aws_region   = "us-east-1"
project_name = "sgsi"
environment  = "dev"

# ==============================================================================
# ALB CONFIGURATION
# ==============================================================================
alb_enable_deletion_protection = false
alb_access_logs_bucket         = ""  # Bucket S3 para logs (vacío = deshabilitado)
alb_enable_https               = false
alb_certificate_arn            = ""  # ARN del certificado ACM (requerido si HTTPS)

# ==============================================================================
# ASG CONFIGURATION
# ==============================================================================
asg_ami_id           = ""  # Vacío para usar Amazon Linux 2 latest
asg_instance_type    = "t3.micro"
asg_min_size         = 2
asg_max_size         = 6
asg_desired_capacity = 2

# ==============================================================================
# RDS CONFIGURATION
# ==============================================================================
rds_engine                  = "postgres"
rds_engine_version          = "14.9"
rds_instance_class          = "db.t3.micro"
rds_parameter_group_family  = "postgres14"
rds_db_name                 = "sgsi_db"
rds_db_port                 = 5432
rds_master_username         = "dbadmin"
rds_master_password         = "Changeme123!SecurePassword"  # ⚠️ CAMBIAR EN PRODUCCIÓN
rds_allocated_storage       = 20
rds_max_allocated_storage   = 100
rds_multi_az                = true   # Alta disponibilidad Multi-AZ
rds_backup_retention_period = 30     # 30 días de retención de backups
rds_skip_final_snapshot     = false  # Crear snapshot final
rds_deletion_protection     = true   # Protección contra eliminación

# ==============================================================================
# SNS ALARMS CONFIGURATION (Optional)
# ==============================================================================
enable_sns_alarms = false
sns_alarm_email   = ""  # Email para recibir alarmas

# ==============================================================================
# COMMON TAGS (ACTUALIZADO - SIN COMAS)
# ==============================================================================
common_tags = {
  Project             = "SGSI-Implementation"
  Layer               = "Compute"
  Environment         = "Development"
  SecurityLevel       = "High"
  ComplianceScope     = "ISO27001+NIST-CSF+ZeroTrust"
  CreatedBy           = "GitHub-Actions"
  MaintenanceWindow   = "Sunday-2AM-6AM"
  BackupRequired      = "Yes"
  MonitoringEnabled   = "Yes"
  LoggingEnabled      = "Yes"
  ChangeManagement    = "ITIL-v4"
  BusinessOwner       = "SGSI-Team"
  TechnicalContact    = "darwin.lopez@university.edu"
  SecurityContact     = "security@university.edu"
  CostCenter          = "Security-Infrastructure"
  DataClassification  = "Internal"
  ISO27001Control     = "A.17.2.1+A.12.3.1+A.13.1.3"
  NISTControl         = "PR.IP-1+PR.DS-1"
  Proposito           = "Capa-Compute-SGSI"
}
