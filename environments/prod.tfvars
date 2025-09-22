# ==============================================================================
# Configuracion de ambiente PROD
# Este archivo contiene configuraciones especificas para el ambiente de produccion
# ==============================================================================

# Configuracion AWS
aws_region = "us-east-1"
account_id = "345678901234" # Reemplazar con ID real de cuenta PROD

# Configuracion de red
vpc_id     = "vpc-prod12345"
subnet_ids = ["subnet-prod123", "subnet-prod456", "subnet-prod789"] # Mas subnets para HA

# Configuracion de buckets S3 para PROD
data_buckets = {
  raw_data  = "empresa-data-raw-prod"
  processed = "empresa-data-processed-prod"
  logs      = "empresa-logs-prod"
  backups   = "empresa-backups-prod"
  archive   = "empresa-archive-prod" # Bucket adicional para archivos
}

# Configuracion de bases de datos
database_endpoints = {
  postgres_main = "postgres-prod.cluster-xyz.us-east-1.rds.amazonaws.com"
  postgres_read = "postgres-prod-ro.cluster-xyz.us-east-1.rds.amazonaws.com"
  redis_cache   = "redis-prod.abc123.cache.amazonaws.com"
}

# Configuracion de servicios externos
external_services = {
  monitoring_url = "https://monitoring.empresa.com"
  logging_url    = "https://logs.empresa.com"
  alerting_url   = "https://alerts.empresa.com"
}

# Configuracion de politicas especificas para PROD
allow_experimental_permissions = false # Muy restrictivo en PROD
enable_debug_logging           = false # Sin debug en PROD
session_duration_hours         = 8     # Sesiones mas largas para operaciones

# Configuracion de tags especificos para PROD
default_cost_center = "PROD-OPERATIONS"
environment_tier    = "production"

# Configuracion de retention (mas conservadora)
log_retention_days    = 90  # 3 meses
backup_retention_days = 365 # 1 año

# Configuracion de alarmas (muy estrictas)
enable_cost_alerts       = true
enable_security_alerts   = true
cost_threshold_usd       = 2000
enable_compliance_checks = true
require_sox_compliance   = true

# Configuracion de seguridad adicional para PROD
enable_enhanced_monitoring   = true
require_mfa_for_roles        = true
enable_access_logging        = true
enable_encryption_at_rest    = true
enable_encryption_in_transit = true

# Configuracion de disponibilidad
multi_az_deployment       = true
cross_region_backup       = true
disaster_recovery_enabled = true
