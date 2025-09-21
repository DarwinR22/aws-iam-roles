# ==============================================================================
# Módulo IAM Policy con validación estricta de tags
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

# Validaciones locales
locals {
  # Tags obligatorios con validación
  required_tags = {
    Ambiente            = var.tags.ambiente
    Pais                = var.tags.pais
    Direccion           = var.tags.direccion
    Gerencia            = var.tags.gerencia
    Cuenta              = var.tags.cuenta
    Modulo              = var.tags.modulo
    "Alcance SOX"       = var.tags.alcance_sox
    Propietario         = var.tags.propietario
    Proveedor           = var.tags.proveedor
    Layer               = var.tags.layer
    Dominio             = var.tags.dominio
    Subdominio          = var.tags.subdominio
    Aplicacion          = var.tags.aplicacion
    Name                = var.policy_name
    Soporte             = var.tags.soporte
    Contacto            = var.tags.contacto
    Proyecto            = var.tags.proyecto
    "Fecha de Creacion" = formatdate("YYYY-MM-DD", timestamp())
    "Creado Por"        = var.tags.creado_por
    "Tipo de Recurso"   = "IAM Policy"
    "Ciclo de Vida"     = var.tags.ciclo_vida
    Version             = var.tags.version
  }

  # Validar ambientes permitidos
  valid_environments = ["dev", "qa", "prod", "poc"]
  environment_valid  = contains(local.valid_environments, var.tags.ambiente)

  # Validar países permitidos
  valid_countries = ["GT", "SV", "NI", "HN", "CR", "RG"]
  country_valid   = contains(local.valid_countries, var.tags.pais)

  # Validar SOX
  valid_sox = ["Sí", "No"]
  sox_valid = contains(local.valid_sox, var.tags.alcance_sox)
}

# Recurso de política IAM
resource "aws_iam_policy" "this" {
  name        = var.policy_name
  path        = var.path
  description = var.description
  policy      = var.policy_document

  tags = local.required_tags

  lifecycle {
    precondition {
      condition     = local.environment_valid
      error_message = "El ambiente debe ser uno de: ${join(", ", local.valid_environments)}"
    }

    precondition {
      condition     = local.country_valid
      error_message = "El país debe ser uno de: ${join(", ", local.valid_countries)}"
    }

    precondition {
      condition     = local.sox_valid
      error_message = "Alcance SOX debe ser 'Sí' o 'No'"
    }

    precondition {
      condition = alltrue([
        var.tags.ambiente != "",
        var.tags.pais != "",
        var.tags.direccion != "",
        var.tags.gerencia != "",
        var.tags.cuenta != "",
        var.tags.modulo != "",
        var.tags.alcance_sox != "",
        var.tags.propietario != "",
        var.tags.proveedor != "",
        var.tags.layer != "",
        var.tags.dominio != "",
        var.tags.subdominio != "",
        var.tags.aplicacion != "",
        var.tags.soporte != "",
        var.tags.contacto != "",
        var.tags.proyecto != "",
        var.tags.creado_por != "",
        var.tags.ciclo_vida != "",
        var.tags.version != ""
      ])
      error_message = "Todos los tags obligatorios deben estar completos. Verifique que no haya campos vacíos."
    }

    precondition {
      condition     = can(jsondecode(var.policy_document))
      error_message = "El documento de política debe ser un JSON válido."
    }
  }
}
