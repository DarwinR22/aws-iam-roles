# modules/iam-role/variables.tf
# ==========================================
# VARIABLES FOR ENTERPRISE IAM ROLE MODULE
# ==========================================

variable "role_name" {
  description = "Name of the IAM role (must follow naming conventions)"
  type        = string
  validation {
    condition = can(regex("^[a-zA-Z][a-zA-Z0-9_-]{1,63}$", var.role_name))
    error_message = "Role name must start with letter, be 2-64 chars, alphanumeric plus _ and - only."
  }
}

variable "description" {
  description = "Description of the IAM role"
  type        = string
  default     = ""
}

variable "trust_policy_document" {
  description = "Trust policy document (JSON) for the role"
  type        = string
}

variable "permission_boundary_arn" {
  description = "ARN of permission boundary policy (defaults to App-StandardBoundary)"
  type        = string
  default     = ""
}

variable "managed_policy_arns" {
  description = "List of managed policy ARNs to attach"
  type        = list(string)
  default     = []
}

variable "inline_policies" {
  description = "Map of inline policy names to JSON documents"
  type        = map(string)
  default     = {}
}

variable "max_session_duration" {
  description = "Maximum session duration in seconds (1-12 hours)"
  type        = number
  default     = 3600
  validation {
    condition     = var.max_session_duration >= 3600 && var.max_session_duration <= 43200
    error_message = "Max session duration must be between 3600 and 43200 seconds (1-12 hours)."
  }
}

variable "force_detach_policies" {
  description = "Whether to force detach policies on role deletion"
  type        = bool
  default     = false
}

variable "tags" {
  description = "Additional tags for the role (will be merged with canonical tags)"
  type        = map(string)
  default     = {}
}

# CANONICAL TAGS VALIDATION
variable "canonical_tags" {
  description = "Canonical tags that must be present on all roles"
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
    error_message = "All 23 canonical tags must be present: Ambiente, País, Dirección, Gerencia, Cuenta, Módulo, Alcance SOX, Propietario, Proveedor, Layer, Dominio, Subdominio, Aplicación, Name, Soporte, Contacto, Proyecto, Fechas de Creación, Creado Por, Tipo de Recurso, Ciclo de Vida, Versión, Map-migrated"
  }
  
  validation {
    condition = can(regex("^(GT|SV|HN|NI|CR|RG)$", var.canonical_tags["País"]))
    error_message = "País must be one of: GT, SV, HN, NI, CR, RG"
  }
  
  validation {
    condition = alltrue([
      for key, value in var.canonical_tags : 
      key == "Name" ? true : can(regex("^[A-Z][a-zA-Z0-9-]*$", value))
    ])
    error_message = "All canonical tag values must be CamelCase (except 'Name')"
  }
}

variable "auto_tags" {
  description = "Tags to be auto-populated if not provided"
  type        = map(string)
  default     = {}
}

# LOCALS FOR VALIDATION AND PROCESSING
locals {
  # Auto-complete missing auto tags
  current_timestamp = formatdate("YYYY-MM-DD'T'hh:mm:ss'Z'", timestamp())
  
  auto_completed_tags = merge(
    var.canonical_tags,
    {
      "Fechas de Creación" = lookup(var.canonical_tags, "Fechas de Creación", local.current_timestamp)
      "Creado Por"         = lookup(var.canonical_tags, "Creado Por", "terraform-iac")
      "Tipo de Recurso"    = lookup(var.canonical_tags, "Tipo de Recurso", "IAM-Role")
    },
    var.auto_tags
  )
  
  # Merge with additional tags, ensuring no case-insensitive duplicates
  all_tag_keys = concat(
    keys(local.auto_completed_tags),
    keys(var.tags)
  )
  
  # Check for case-insensitive duplicates
  lower_case_keys = [for k in local.all_tag_keys : lower(k)]
  has_duplicates = length(local.lower_case_keys) != length(distinct(local.lower_case_keys))
  
  final_tags = local.has_duplicates ? {} : merge(
    local.auto_completed_tags,
    var.tags
  )
  
  # Validate no unauthorized additional tags
  unauthorized_keys = [
    for k in keys(var.tags) : k
    if !contains([
      "Ambiente", "País", "Dirección", "Gerencia", "Cuenta", "Módulo",
      "Alcance SOX", "Propietario", "Proveedor", "Layer", "Dominio", "Subdominio",
      "Aplicación", "Name", "Soporte", "Contacto", "Proyecto", "Fechas de Creación",
      "Creado Por", "Tipo de Recurso", "Ciclo de Vida", "Versión", "Map-migrated"
    ], k)
  ]
  
  # Permission boundary ARN (defaults to App-StandardBoundary)
  effective_boundary_arn = var.permission_boundary_arn != "" ? var.permission_boundary_arn : "arn:aws:iam::393209814297:policy/App-StandardBoundary"
}
