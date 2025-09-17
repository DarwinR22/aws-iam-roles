# ==============================================================================
# Módulo IAM Role con validación estricta de tags y convención de nombres
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

# Función para limpiar nombres (quitar espacios y caracteres especiales)
locals {
  # Limpieza automática de tags con espacios
  clean_propietario = replace(replace(var.tags.propietario, " ", ""), "-", "")
  clean_creado_por  = replace(replace(var.tags.creado_por, " ", ""), "-", "")
  clean_contacto    = replace(replace(var.tags.contacto, " ", ""), "-", "")
  clean_proyecto    = replace(replace(var.tags.proyecto, " ", ""), "-", "")
}

# Validación de convención de nombres
locals {
  # Patrón: rol-[servicio]-[layer]-[ambiente]-[nombre]
  name_pattern = "^rol-[a-z0-9]+-[a-z0-9-]+-[a-z]+-[a-z0-9-]+$"

  # Validar que el nombre sigue la convención
  name_validation = can(regex(local.name_pattern, var.role_name)) ? true : false

  # Extraer componentes del nombre
  name_parts = split("-", var.role_name)
  servicio   = length(local.name_parts) >= 2 ? local.name_parts[1] : ""
  layer      = length(local.name_parts) >= 3 ? join("-", slice(local.name_parts, 2, length(local.name_parts) - 2)) : ""
  ambiente   = length(local.name_parts) >= 2 ? local.name_parts[length(local.name_parts) - 2] : ""
  nombre     = length(local.name_parts) >= 1 ? local.name_parts[length(local.name_parts) - 1] : ""

  # Tags obligatorios con validación
  required_tags = {
    Ambiente            = var.tags.ambiente
    Pais                = var.tags.pais
    Direccion           = var.tags.direccion
    Gerencia            = var.tags.gerencia
    Cuenta              = var.tags.cuenta
    Modulo              = var.tags.modulo
    "Alcance SOX"       = var.tags.alcance_sox
    Propietario         = local.clean_propietario
    Proveedor           = var.tags.proveedor
    Layer               = var.tags.layer
    Dominio             = var.tags.dominio
    Subdominio          = var.tags.subdominio
    Aplicacion          = var.tags.aplicacion
    Name                = var.role_name
    Soporte             = var.tags.soporte
    Contacto            = local.clean_contacto
    Proyecto            = local.clean_proyecto
    "Fecha de Creacion" = formatdate("YYYY-MM-DD", timestamp())
    "Creado Por"        = local.clean_creado_por
    "Tipo de Recurso"   = "IAM Role"
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

# Validaciones con preconditions
resource "aws_iam_role" "this" {
  name                 = var.role_name
  assume_role_policy   = var.assume_role_policy
  description          = var.description
  max_session_duration = var.max_session_duration

  tags = local.required_tags

  lifecycle {
    precondition {
      condition     = local.name_validation
      error_message = "El nombre del rol debe seguir la convención: rol-[servicio]-[layer]-[ambiente]-[nombre]. Ejemplo: rol-s3-data-analytics-dev-bitacora"
    }

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
  }
}

# Adjuntar políticas al rol
resource "aws_iam_role_policy_attachment" "custom_policies" {
  count = length(var.policy_arns)

  role       = aws_iam_role.this.name
  policy_arn = var.policy_arns[count.index]
}

# Política inline si se proporciona
resource "aws_iam_role_policy" "inline_policy" {
  count = var.inline_policy != null ? 1 : 0

  name   = "${var.role_name}-inline-policy"
  role   = aws_iam_role.this.id
  policy = var.inline_policy
}
