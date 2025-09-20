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
  # Limpieza automática de tags con valores seguros por defecto
  clean_propietario = replace(replace(lookup(var.tags, "Propietario", lookup(var.tags, "propietario", "admin")), " ", ""), "-", "")
  clean_creado_por  = replace(replace(lookup(var.tags, "CreadoPor", lookup(var.tags, "creado_por", "terraform")), " ", ""), "-", "")
  clean_contacto    = replace(replace(lookup(var.tags, "Contacto", lookup(var.tags, "contacto", "admin")), " ", ""), "-", "")
  clean_proyecto    = replace(replace(lookup(var.tags, "Proyecto", lookup(var.tags, "proyecto", "default")), " ", ""), "-", "")
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

  # Tags flexibles - usar valores proporcionados o valores por defecto
  flexible_tags = merge(
    {
      # Tags mínimos garantizados
      Name                = var.role_name
      "Tipo de Recurso"   = "IAM Role"
      "Fecha de Creacion" = formatdate("YYYY-MM-DD", timestamp())
      "Creado Por"        = local.clean_creado_por
      Propietario         = local.clean_propietario
      Contacto            = local.clean_contacto
      Proyecto            = local.clean_proyecto
    },
    # Filtrar tags proporcionados para evitar duplicados
    { for k, v in var.tags : k => v if !contains([
      "Name",
      "Tipo de Recurso", 
      "Fecha de Creacion",
      "Creado Por",
      "Propietario",
      "Contacto", 
      "Proyecto",
      # También excluir variaciones de case comunes
      "name",
      "propietario",
      "contacto",
      "proyecto",
      "CreadoPor",
      "creado_por"
    ], k) }
  )

  # Validar ambientes permitidos (usar tags flexibles)
  valid_environments = ["dev", "qa", "prod", "poc"]
  ambiente_tag = lookup(var.tags, "ambiente", lookup(var.tags, "Ambiente", "dev"))
  environment_valid  = contains(local.valid_environments, local.ambiente_tag)

  # Validar países permitidos (opcional)
  valid_countries = ["GT", "SV", "NI", "HN", "CR", "RG"]
  pais_tag = lookup(var.tags, "pais", lookup(var.tags, "Pais", "GT"))
  country_valid   = contains(local.valid_countries, local.pais_tag)

  # Validar SOX (opcional)
  valid_sox = ["Sí", "No", "Si", "No", "YES", "NO"]
  sox_tag = lookup(var.tags, "alcance_sox", lookup(var.tags, "SOX", "No"))
  sox_valid = contains(local.valid_sox, local.sox_tag)
}

# Validaciones con preconditions
resource "aws_iam_role" "this" {
  name                 = var.role_name
  assume_role_policy   = var.assume_role_policy
  description          = var.description
  max_session_duration = var.max_session_duration

  tags = local.flexible_tags

  lifecycle {
    precondition {
      condition     = local.name_validation
      error_message = "El nombre del rol debe seguir la convención: rol-[servicio]-[layer]-[ambiente]-[nombre]. Ejemplo: rol-s3-data-analytics-dev-bitacora"
    }

    precondition {
      condition     = local.environment_valid
      error_message = "El ambiente debe ser uno de: ${join(", ", local.valid_environments)}"
    }
  }
}

# Adjuntar políticas al rol
resource "aws_iam_role_policy_attachment" "custom_policies" {
  for_each = toset(var.policy_arns)

  role       = aws_iam_role.this.name
  policy_arn = each.value
}

# Política inline si se proporciona
resource "aws_iam_role_policy" "inline_policy" {
  count = var.inline_policy != null ? 1 : 0

  name   = "${var.role_name}-inline-policy"
  role   = aws_iam_role.this.id
  policy = var.inline_policy
}
