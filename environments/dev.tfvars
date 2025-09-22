# ==============================================================================
# Configuracion de ambiente DEV
# Este archivo contiene configuraciones especificas para el ambiente de desarrollo
# ==============================================================================

# Configuracion AWS
aws_region = "us-east-1"
account_id = "123456789012" # Reemplazar con ID real de cuenta DEV

# Configuracion de red
vpc_id     = "vpc-dev12345"
subnet_ids = ["subnet-dev123", "subnet-dev456"]

# Configuracion de buckets S3 para DEV
data_buckets = {
  raw_data  = "empresa-data-raw-dev"
  processed = "empresa-data-processed-dev"
  logs      = "empresa-logs-dev"
  backups   = "empresa-backups-dev"
}

# Configuracion de bases de datos
database_endpoints = {
  postgres_main = "postgres-dev.cluster-xyz.us-east-1.rds.amazonaws.com"
  redis_cache   = "redis-dev.abc123.cache.amazonaws.com"
}

# Configuracion de servicios externos
external_services = {
  monitoring_url = "https://monitoring-dev.empresa.com"
  logging_url    = "https://logs-dev.empresa.com"
}

# Configuracion de politicas especificas para DEV
allow_experimental_permissions = true
enable_debug_logging           = true
session_duration_hours         = 2

# Configuracion de tags especificos para DEV
default_cost_center = "DEV-OPERATIONS"
environment_tier    = "development"

# Configuracion de retention
log_retention_days    = 7
backup_retention_days = 7

# Configuracion de alarmas (mas relajadas en DEV)
enable_cost_alerts     = false
enable_security_alerts = true
cost_threshold_usd     = 100
