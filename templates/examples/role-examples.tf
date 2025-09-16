# ==============================================================================
# Ejemplo de uso de la plantilla IAM Role
# ==============================================================================

# Configuración del proveedor AWS
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

# Ejemplo 1: Rol para Glue ETL
module "glue_etl_role" {
  source = "../../templates/iam-role-template"

  # Configuración del rol
  servicio  = "glue"
  layer     = "data-analytics"
  ambiente  = "dev"
  nombre    = "transformadorVentas"
  
  description = "Rol para job de Glue que transforma datos de ventas"
  
  # Políticas AWS gestionadas
  policy_arns = [
    "arn:aws:iam::aws:policy/service-role/AWSGlueServiceRole",
    "arn:aws:iam::aws:policy/AmazonS3ReadOnlyAccess"
  ]

  # Tags obligatorios
  pais         = "GT"
  direccion    = "Gerencia de TI"
  gerencia     = "Data Analytics"
  cuenta       = "prod-analytics-account"
  modulo       = "Aplicación"
  alcance_sox  = "No"
  propietario  = "Juan Pérez"
  proveedor    = "Inhouse"
  dominio      = "Analytics"
  subdominio   = "ETL"
  aplicacion   = "DATA-TRANSFORM-001"
  soporte      = "Equipo Data Engineering"
  contacto     = "data-engineering@empresa.com"
  proyecto     = "PROJ-2024-ANALYTICS"
  creado_por   = "juan.perez@empresa.com"
  ciclo_vida   = "Implementación"
  version      = "1.0.0"
}

# Ejemplo 2: Rol para Lambda API
module "lambda_api_role" {
  source = "../../templates/iam-role-template"

  # Configuración del rol
  servicio  = "lambda"
  layer     = "api"
  ambiente  = "prod"
  nombre    = "jobProcessor"
  
  description = "Rol para función Lambda que procesa trabajos"
  
  # Políticas AWS gestionadas
  policy_arns = [
    "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole",
    "arn:aws:iam::aws:policy/AmazonDynamoDBReadOnlyAccess"
  ]

  # Tags obligatorios
  pais         = "CR"
  direccion    = "Gerencia de Aplicaciones"
  gerencia     = "Backend Services"
  cuenta       = "prod-applications-account"
  modulo       = "Aplicación"
  alcance_sox  = "Sí"
  propietario  = "María García"
  proveedor    = "Inhouse"
  dominio      = "Applications"
  subdominio   = "Microservices"
  aplicacion   = "JOB-PROCESSOR-API"
  soporte      = "Equipo Backend"
  contacto     = "backend-team@empresa.com"
  proyecto     = "PROJ-2024-MICROSERVICES"
  creado_por   = "maria.garcia@empresa.com"
  ciclo_vida   = "MonitoreoYMantenimiento"
  version      = "2.1.0"
}

# Ejemplo 3: Rol para S3 con política personalizada
module "s3_data_role" {
  source = "../../templates/iam-role-template"

  # Configuración del rol
  servicio  = "s3"
  layer     = "data-analytics"
  ambiente  = "dev"
  nombre    = "bitacora"
  
  description = "Rol para acceso a bucket S3 de bitácoras"
  
  # Crear política personalizada para S3
  create_s3_policy = true
  s3_bucket_arns = [
    "arn:aws:s3:::empresa-bitacoras-dev",
    "arn:aws:s3:::empresa-bitacoras-dev/*"
  ]

  # Tags obligatorios
  pais         = "SV"
  direccion    = "Gerencia de TI"
  gerencia     = "Data Analytics"
  cuenta       = "dev-analytics-account"
  modulo       = "DB"
  alcance_sox  = "No"
  propietario  = "Carlos López"
  proveedor    = "Inhouse"
  dominio      = "Analytics"
  subdominio   = "Storage"
  aplicacion   = "BITACORA-SYSTEM"
  soporte      = "Equipo Infraestructura"
  contacto     = "infraestructura@empresa.com"
  proyecto     = "PROJ-2024-LOGGING"
  creado_por   = "carlos.lopez@empresa.com"
  ciclo_vida   = "Creación"
  version      = "1.0.0"
}
