# modules/iam-managed-policy/variables.tf
# ============================================
# VARIABLES FOR IAM MANAGED POLICY MODULE
# ============================================

variable "policy_name" {
  description = "Name of the IAM managed policy"
  type        = string
  validation {
    condition = can(regex("^[a-zA-Z][a-zA-Z0-9_-]{1,127}$", var.policy_name))
    error_message = "Policy name must start with letter, be 2-128 chars, alphanumeric plus _ and - only."
  }
}

variable "description" {
  description = "Description of the IAM policy"
  type        = string
  default     = ""
}

variable "path" {
  description = "Path for the IAM policy"
  type        = string
  default     = "/"
  validation {
    condition = can(regex("^/.*/$", var.path)) || var.path == "/"
    error_message = "Path must start and end with /"
  }
}

variable "policy_document_json" {
  description = "IAM policy document in JSON format"
  type        = string
}

variable "tags" {
  description = "Additional tags for the policy (will be merged with canonical tags)"
  type        = map(string)
  default     = {}
}

variable "canonical_tags" {
  description = "Canonical tags that must be present on all policies"
  type        = map(string)
  validation {
    condition = alltrue([
      for required_key in [
        "Ambiente", "País", "Dirección", "Gerencia", "Cuenta", "Módulo",
        "Alcance SOX", "Propietario", "Proveedor", "Layer", "Dominio", "Subdominio",
        "Aplicación", "Name", "Soporte", "Contacto", "Proyecto", "Fechas de Creación",
        "Creado Por", "Tipo de Recurso", "Ciclo de Vida", "Versión", "Map-migrated"
      ] : contains(keys(var.canonical_tags), required_key)
    ])
    error_message = "All 23 canonical tags must be present"
  }
}

# LOCALS FOR PROCESSING
locals {
  # Auto-complete missing auto tags
  current_timestamp = formatdate("YYYY-MM-DD'T'hh:mm:ss'Z'", timestamp())
  
  auto_completed_tags = merge(
    var.canonical_tags,
    {
      "Fechas de Creación" = lookup(var.canonical_tags, "Fechas de Creación", local.current_timestamp)
      "Creado Por"         = lookup(var.canonical_tags, "Creado Por", "terraform-iac")
      "Tipo de Recurso"    = lookup(var.canonical_tags, "Tipo de Recurso", "IAM-Policy")
    }
  )
  
  # Check for case-insensitive duplicates
  all_tag_keys = concat(
    keys(local.auto_completed_tags),
    keys(var.tags)
  )
  lower_case_keys = [for k in local.all_tag_keys : lower(k)]
  has_duplicates = length(local.lower_case_keys) != length(distinct(local.lower_case_keys))
  
  final_tags = local.has_duplicates ? {} : merge(
    local.auto_completed_tags,
    var.tags
  )
}