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
  description = "Tags para el recurso IAM"
  type        = map(string)
  default     = {}

  validation {
    condition = alltrue([
      length(var.tags) > 0,
      contains(keys(var.tags), "Team"),
      contains(keys(var.tags), "Environment"), 
      contains(keys(var.tags), "Project")
    ])
    error_message = <<-EOT
    ❌ FALTAN ETIQUETAS OBLIGATORIAS:
    
    Los siguientes tags son OBLIGATORIOS para todos los roles IAM:
    - Team: Nombre del equipo responsable (ej: "BI-Team", "Development-Team")
    - Environment: Entorno de despliegue (ej: "dev", "qa", "prod") 
    - Project: Nombre del proyecto (ej: "DataAnalytics", "WebPortal")
    
    Ejemplo correcto:
    "tags": {
      "Team": "BI-Team",
      "Environment": "dev", 
      "Project": "DataAnalytics"
    }
    
    🛡️ Estos tags son necesarios para:
    - Governance automática de acceso a recursos
    - Separación por equipos y ambientes
    - Facturación y costos por proyecto
    EOT
  }

  validation {
    condition     = var.tags["Environment"] != null ? contains(["dev", "qa", "prod"], var.tags["Environment"]) : true
    error_message = "❌ Tag 'Environment' debe ser: 'dev', 'qa' o 'prod'"
  }
}
