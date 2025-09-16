# ==============================================================================
# Configuración de ambiente QA
# Este archivo contiene configuraciones específicas para el ambiente de QA
# ==============================================================================

# Configuración AWS
aws_region = "us-east-1"
account_id = "234567890123" # Reemplazar con ID real de cuenta QA

# Configuración de red
vpc_id     = "vpc-qa12345"
subnet_ids = ["subnet-qa123", "subnet-qa456"]

# Configuración de buckets S3 para QA
data_buckets = {
  raw_data  = "empresa-data-raw-qa"
  processed = "empresa-data-processed-qa"
  logs      = "empresa-logs-qa"
  backups   = "empresa-backups-qa"
}

# Configuración de bases de datos
database_endpoints = {
  postgres_main = "postgres-qa.cluster-xyz.us-east-1.rds.amazonaws.com"
  redis_cache   = "redis-qa.abc123.cache.amazonaws.com"
}

# Configuración de servicios externos
external_services = {
  monitoring_url = "https://monitoring-qa.empresa.com"
  logging_url    = "https://logs-qa.empresa.com"
}

# Configuración de políticas específicas para QA
allow_experimental_permissions = false # Más restrictivo que DEV
enable_debug_logging           = true
session_duration_hours         = 4 # Un poco más de tiempo para testing

# Configuración de tags específicos para QA
default_cost_center = "QA-OPERATIONS"
environment_tier    = "quality-assurance"

# Configuración de retention (más que DEV)
log_retention_days    = 30
backup_retention_days = 14

# Configuración de alarmas
enable_cost_alerts     = true
enable_security_alerts = true
cost_threshold_usd     = 500
