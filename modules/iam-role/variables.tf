# ==============================================================================
# Variables para el módulo IAM Role
# ==============================================================================

variable "role_name" {
  description = "Nombre del rol IAM siguiendo la convención: rol-[servicio]-[layer]-[ambiente]-[nombre]"
  type        = string

  validation {
    condition     = can(regex("^rol-[a-z0-9]+-[a-z0-9-]+-[a-z]+-[a-z0-9-]+$", var.role_name))
    error_message = "El nombre debe seguir la convención: rol-[servicio]-[layer]-[ambiente]-[nombre]"
  }
}

variable "assume_role_policy" {
  description = "Política de confianza para el rol (assume role policy)"
  type        = string
}

variable "description" {
  description = "Descripción del rol IAM"
  type        = string
  default     = ""
}

variable "max_session_duration" {
  description = "Duración máxima de la sesión en segundos"
  type        = number
  default     = 3600

  validation {
    condition     = var.max_session_duration >= 3600 && var.max_session_duration <= 43200
    error_message = "La duración debe estar entre 3600 (1 hora) y 43200 (12 horas) segundos."
  }
}

variable "policy_arns" {
  description = "Lista de ARNs de políticas a adjuntar al rol"
  type        = list(string)
  default     = []
}

variable "inline_policy" {
  description = "Política inline en formato JSON (opcional)"
  type        = string
  default     = null
}

# ==============================================================================
# Variables de Tags Obligatorios
# ==============================================================================

variable "tags" {
  description = "Tags obligatorios para el recurso IAM"
  type = object({
    ambiente     = string # dev, qa, prod, poc
    pais         = string # GT, SV, NI, HN, CR, RG
    direccion    = string # Dirección solicitante
    gerencia     = string # Gerencia TI responsable
    cuenta       = string # Nombre de la cuenta organizacional
    modulo       = string # Aplicación, DB, POC
    alcance_sox  = string # Sí/No
    propietario  = string # Persona responsable
    proveedor    = string # Inhouse o tercero
    layer        = string # Ej. Data Analytics & AI
    dominio      = string # Dominio AMX
    subdominio   = string # Subdominio AMX
    aplicacion   = string # Identificador de aplicación
    soporte      = string # Equipo/persona responsable del soporte
    contacto     = string # Correo de soporte
    proyecto     = string # Código o nombre del proyecto
    creado_por   = string # Nombre o ID del creador
    ciclo_vida   = string # Creación, Implementación, MonitoreoYMantenimiento, etc.
    version      = string # Versión del recurso
  })

  validation {
    condition = contains(["dev", "qa", "prod", "poc"], var.tags.ambiente)
    error_message = "El ambiente debe ser: dev, qa, prod o poc"
  }

  validation {
    condition = contains(["GT", "SV", "NI", "HN", "CR", "RG"], var.tags.pais)
    error_message = "El país debe ser: GT, SV, NI, HN, CR o RG"
  }

  validation {
    condition = contains(["Sí", "No"], var.tags.alcance_sox)
    error_message = "Alcance SOX debe ser 'Sí' o 'No'"
  }

  validation {
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
    error_message = "Todos los campos de tags son obligatorios y no pueden estar vacíos"
  }
}
