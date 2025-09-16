# ==============================================================================
# Configuración Global del Repositorio
# Variables compartidas entre todos los ambientes
# ==============================================================================

# Información de la organización
organization = "MCI - América Móvil"
company_code = "AMX"

# Configuración de Terraform
terraform_version    = "~> 1.6.0"
aws_provider_version = "~> 5.0"

# Configuración de buckets de estado por ambiente
terraform_state_buckets = {
  dev  = "mci-terraform-state-dev"
  qa   = "mci-terraform-state-qa"
  prod = "mci-terraform-state-prod"
}

# Configuración de regiones por ambiente
aws_regions = {
  dev  = "us-east-1"
  qa   = "us-east-1"
  prod = "us-east-1"
}

# Cuentas AWS por ambiente
aws_accounts = {
  dev  = "123456789012" # Reemplazar con IDs reales
  qa   = "234567890123"
  prod = "345678901234"
}

# Políticas AWS gestionadas comunes
common_aws_policies = {
  basic_lambda    = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
  glue_service    = "arn:aws:iam::aws:policy/service-role/AWSGlueServiceRole"
  s3_read_only    = "arn:aws:iam::aws:policy/AmazonS3ReadOnlyAccess"
  s3_full         = "arn:aws:iam::aws:policy/AmazonS3FullAccess"
  cloudwatch_logs = "arn:aws:iam::aws:policy/CloudWatchLogsFullAccess"
}

# Configuración de retención por ambiente
retention_policies = {
  dev = {
    logs_days    = 7
    backups_days = 7
  }
  qa = {
    logs_days    = 30
    backups_days = 14
  }
  prod = {
    logs_days    = 90
    backups_days = 365
  }
}

# Configuración de monitoreo por ambiente
monitoring_config = {
  dev = {
    enable_detailed_monitoring = false
    enable_cost_alerts         = false
    cost_threshold             = 100
  }
  qa = {
    enable_detailed_monitoring = true
    enable_cost_alerts         = true
    cost_threshold             = 500
  }
  prod = {
    enable_detailed_monitoring = true
    enable_cost_alerts         = true
    cost_threshold             = 2000
    enable_compliance_checks   = true
  }
}

# Tags corporativos obligatorios
corporate_tags = {
  Organization = "MCI"
  Company      = "América Móvil"
  ManagedBy    = "Terraform"
  Repository   = "mci-aws-iam"
}

# Configuración de nomenclatura
naming_standards = {
  max_role_name_length = 64
  allowed_services = [
    "s3", "lambda", "glue", "ec2", "ecs", "rds",
    "dynamodb", "sns", "sqs", "kinesis", "redshift",
    "emr", "apigateway"
  ]
  allowed_environments = ["dev", "qa", "prod", "poc"]
  allowed_countries    = ["GT", "SV", "NI", "HN", "CR", "RG"]
}

# Configuración de seguridad
security_config = {
  dev = {
    require_mfa                = false
    max_session_duration_hours = 2
    allow_experimental_perms   = true
  }
  qa = {
    require_mfa                = false
    max_session_duration_hours = 4
    allow_experimental_perms   = false
  }
  prod = {
    require_mfa                = true
    max_session_duration_hours = 8
    allow_experimental_perms   = false
    require_sox_compliance     = true
  }
}
