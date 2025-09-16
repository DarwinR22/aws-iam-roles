# ==============================================================================
# Variables para el módulo IAM Policy
# ==============================================================================

variable "policy_name" {
  description = "Nombre de la política IAM"
  type        = string

  validation {
    condition     = length(var.policy_name) > 0 && length(var.policy_name) <= 128
    error_message = "El nombre de la política debe tener entre 1 y 128 caracteres."
  }
}

variable "policy_document" {
  description = "Documento de política IAM en formato JSON"
  type        = string

  validation {
    condition     = can(jsondecode(var.policy_document))
    error_message = "El documento de política debe ser un JSON válido."
  }
}

variable "description" {
  description = "Descripción de la política IAM"
  type        = string
  default     = ""
}

variable "path" {
  description = "Ruta para la política IAM"
  type        = string
  default     = "/"

  validation {
    condition     = can(regex("^/.*/$", var.path)) || var.path == "/"
    error_message = "La ruta debe comenzar y terminar con '/' o ser igual a '/'."
  }
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
