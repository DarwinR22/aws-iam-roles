# ==============================================================================
# Plantilla para Role IAM - Data Analytics & ETL
# Convención: rol-[servicio]-[layer]-[ambiente]-[nombre]
# Ejemplo: rol-glue-data-analytics-dev-transformadorVentas
# ==============================================================================

terraform {
  required_version = ">= 1.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

# Configuración del backend (será configurado por cada ambiente)
terraform {
  backend "s3" {
    # El backend será configurado dinámicamente
  }
}

# ==============================================================================
# Variables locales
# ==============================================================================

locals {
  # Configuración específica del rol
  role_name = "rol-${var.servicio}-${var.layer}-${var.ambiente}-${var.nombre}"

  # Política de confianza para Glue
  glue_assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "glue.amazonaws.com"
        }
      }
    ]
  })

  # Política de confianza para Lambda
  lambda_assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "lambda.amazonaws.com"
        }
      }
    ]
  })

  # Política de confianza para EC2
  ec2_assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      }
    ]
  })

  # Seleccionar política de confianza según el servicio
  assume_role_policy = var.servicio == "glue" ? local.glue_assume_role_policy : (
    var.servicio == "lambda" ? local.lambda_assume_role_policy : (
      var.servicio == "ec2" ? local.ec2_assume_role_policy : var.custom_assume_role_policy
    )
  )
}

# ==============================================================================
# Módulo IAM Role
# ==============================================================================

module "iam_role" {
  source = "../../modules/iam-role"

  role_name            = local.role_name
  assume_role_policy   = local.assume_role_policy
  description          = var.description
  max_session_duration = var.max_session_duration
  policy_arns          = var.policy_arns
  inline_policy        = var.inline_policy

  tags = {
    ambiente    = var.ambiente
    pais        = var.pais
    direccion   = var.direccion
    gerencia    = var.gerencia
    cuenta      = var.cuenta
    modulo      = var.modulo
    alcance_sox = var.alcance_sox
    propietario = var.propietario
    proveedor   = var.proveedor
    layer       = var.layer
    dominio     = var.dominio
    subdominio  = var.subdominio
    aplicacion  = var.aplicacion
    soporte     = var.soporte
    contacto    = var.contacto
    proyecto    = var.proyecto
    creado_por  = var.creado_por
    ciclo_vida  = var.ciclo_vida
    version     = var.version
  }
}

# ==============================================================================
# Políticas adicionales comunes por servicio
# ==============================================================================

# Política personalizada para S3 (ejemplo)
module "s3_policy" {
  count  = var.servicio == "s3" && var.create_s3_policy ? 1 : 0
  source = "../../modules/iam-policy"

  policy_name = "${local.role_name}-s3-access"
  description = "Política de acceso a S3 para ${local.role_name}"

  policy_document = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "s3:GetObject",
          "s3:PutObject",
          "s3:DeleteObject"
        ]
        Resource = var.s3_bucket_arns
      },
      {
        Effect = "Allow"
        Action = [
          "s3:ListBucket"
        ]
        Resource = var.s3_bucket_arns
      }
    ]
  })

  tags = {
    ambiente    = var.ambiente
    pais        = var.pais
    direccion   = var.direccion
    gerencia    = var.gerencia
    cuenta      = var.cuenta
    modulo      = var.modulo
    alcance_sox = var.alcance_sox
    propietario = var.propietario
    proveedor   = var.proveedor
    layer       = var.layer
    dominio     = var.dominio
    subdominio  = var.subdominio
    aplicacion  = var.aplicacion
    soporte     = var.soporte
    contacto    = var.contacto
    proyecto    = var.proyecto
    creado_por  = var.creado_por
    ciclo_vida  = var.ciclo_vida
    version     = var.version
  }
}

# Adjuntar política S3 al rol si se crea
resource "aws_iam_role_policy_attachment" "s3_policy" {
  count      = var.servicio == "s3" && var.create_s3_policy ? 1 : 0
  role       = module.iam_role.role_name
  policy_arn = module.s3_policy[0].policy_arn
}
