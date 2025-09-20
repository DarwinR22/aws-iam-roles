# ============================================================================
# CONFIGURACION TAG-BASED POLICIES - Nueva Arquitectura MCI
# ============================================================================
# Esta configuracion reemplaza el enfoque granular con politicas inteligentes
# basadas en tags que escalan automaticamente.

# ============================================================================
# TEAM-BASED TAG POLICIES: Acceso automatico por equipos
# ============================================================================

team_tag_policies = {
  # -------------------------------------------------------------------------
  # EQUIPO BI/ANALYTICS - Acceso a datos de analisis
  # -------------------------------------------------------------------------
  "bi-team-dynamodb-read" = {
    policy_template = "MCI-DynamoDB-TagBased-ReadOnly"
    team_name      = "BI-Team"
    environment    = "dev"
    project_name   = "DataAnalytics"
    description    = "Acceso de lectura DynamoDB para equipo BI a tablas etiquetadas"
  }

  "bi-team-s3-read" = {
    policy_template = "MCI-S3-TagBased-ReadOnly"
    team_name      = "BI-Team"
    environment    = "dev"
    project_name   = "DataAnalytics"
    description    = "Acceso de lectura S3 para equipo BI a buckets etiquetados"
  }

  # -------------------------------------------------------------------------
  # EQUIPO DEVELOPMENT - Acceso completo en DEV
  # -------------------------------------------------------------------------
  "dev-team-dynamodb-write" = {
    policy_template = "MCI-DynamoDB-TagBased-Write"
    team_name      = "Development-Team"
    environment    = "dev"
    project_name   = "WebApps"
    description    = "Acceso completo DynamoDB para desarrollo a tablas etiquetadas"
  }

  "dev-team-s3-write" = {
    policy_template = "MCI-S3-TagBased-Write"
    team_name      = "Development-Team"
    environment    = "dev"
    project_name   = "WebApps"
    description    = "Acceso completo S3 para desarrollo a buckets etiquetados"
  }

  # -------------------------------------------------------------------------
  # EQUIPO DATABASE - Solo lectura en PROD
  # -------------------------------------------------------------------------
  "db-team-prod-readonly" = {
    policy_template = "MCI-DynamoDB-TagBased-ReadOnly"
    team_name      = "Database-Team"
    environment    = "prod"
    project_name   = "AllProjects"  # Acceso a todos los proyectos
    description    = "Acceso de solo lectura para equipo DB en produccion"
  }

  # -------------------------------------------------------------------------
  # EQUIPO FINANCE - Auditoria especifica
  # -------------------------------------------------------------------------
  "finance-audit-readonly" = {
    policy_template = "MCI-DynamoDB-TagBased-ReadOnly"
    team_name      = "Finance-Team"
    environment    = "prod"
    project_name   = "FinancialReporting"
    description    = "Acceso de auditoria para equipo financiero"
  }

  "finance-s3-readonly" = {
    policy_template = "MCI-S3-TagBased-ReadOnly"
    team_name      = "Finance-Team"
    environment    = "prod"
    project_name   = "FinancialReporting"
    description    = "Acceso S3 de auditoria para reportes financieros"
  }
}

# ============================================================================
# REQUIRED TAGS GOVERNANCE
# Tags obligatorios para recursos - Compliance automatico
# ============================================================================

required_resource_tags = {
  # DynamoDB tables DEBEN tener estos tags
  dynamodb_required_tags = [
    "Equipo",           # Que equipo es dueno?
    "Ambiente",         # dev/qa/prod
    "Proyecto",         # A que proyecto pertenece?
    "CentroCosto",      # Para billing
    "Propietario",      # Email del responsable
    "DataClassification" # public/internal/confidential
  ]

  # S3 buckets DEBEN tener estos tags
  s3_required_tags = [
    "Equipo",
    "Ambiente", 
    "Proyecto",
    "CentroCosto",
    "Propietario",
    "DataRetention",    # Politica de retencion
    "Encryption"        # Tipo de encriptacion
  ]
}

# ============================================================================
# TAG VALIDATION RULES
# Reglas de validación para valores de tags
# ============================================================================

tag_validation_rules = {
  # Valores validos para tag "Equipo"
  valid_teams = [
    "BI-Team",
    "Development-Team", 
    "Database-Team",
    "Finance-Team",
    "Operations-Team",
    "Security-Team",
    "Infrastructure-Team"
  ]

  # Valores validos para tag "Ambiente"
  valid_environments = ["dev", "qa", "staging", "prod"]

  # Patrones validos para "Proyecto"
  valid_project_patterns = [
    "DataAnalytics",
    "WebApps", 
    "MobileApps",
    "FinancialReporting",
    "CustomerPortal",
    "InternalTools"
  ]

  # Valores validos para "DataClassification"
  valid_data_classifications = ["public", "internal", "confidential", "restricted"]
}
