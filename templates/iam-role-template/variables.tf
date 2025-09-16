# ==============================================================================
# Variables para la plantilla de rol IAM
# ==============================================================================

# Variables principales del rol
variable "servicio" {
  description = "Tipo de servicio AWS (s3, lambda, glue, ec2, etc.)"
  type        = string

  validation {
    condition = contains([
      "s3", "lambda", "glue", "ec2", "ecs", "rds", "dynamodb",
      "sns", "sqs", "kinesis", "redshift", "emr", "apigateway"
    ], var.servicio)
    error_message = "El servicio debe ser uno de los servicios AWS soportados."
  }
}

variable "layer" {
  description = "Capa o layer del sistema (data-analytics, api, frontend, etc.)"
  type        = string
}

variable "ambiente" {
  description = "Ambiente de despliegue"
  type        = string

  validation {
    condition     = contains(["dev", "qa", "prod", "poc"], var.ambiente)
    error_message = "El ambiente debe ser: dev, qa, prod o poc"
  }
}

variable "nombre" {
  description = "Nombre específico del rol"
  type        = string

  validation {
    condition     = can(regex("^[a-z0-9-]+$", var.nombre))
    error_message = "El nombre solo puede contener letras minúsculas, números y guiones."
  }
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
}

variable "policy_arns" {
  description = "Lista de ARNs de políticas AWS gestionadas a adjuntar"
  type        = list(string)
  default     = []
}

variable "inline_policy" {
  description = "Política inline en formato JSON (opcional)"
  type        = string
  default     = null
}

variable "custom_assume_role_policy" {
  description = "Política de confianza personalizada en formato JSON (opcional)"
  type        = string
  default     = null
}

# Variables para políticas específicas
variable "create_s3_policy" {
  description = "Crear política personalizada para S3"
  type        = bool
  default     = false
}

variable "s3_bucket_arns" {
  description = "Lista de ARNs de buckets S3 para acceso"
  type        = list(string)
  default     = []
}

# ==============================================================================
# Variables de Tags Obligatorios
# ==============================================================================

variable "pais" {
  description = "País donde se despliega el recurso"
  type        = string

  validation {
    condition     = contains(["GT", "SV", "NI", "HN", "CR", "RG"], var.pais)
    error_message = "El país debe ser: GT, SV, NI, HN, CR o RG"
  }
}

variable "direccion" {
  description = "Dirección solicitante del recurso"
  type        = string
}

variable "gerencia" {
  description = "Gerencia TI responsable"
  type        = string
}

variable "cuenta" {
  description = "Nombre de la cuenta organizacional AWS"
  type        = string
}

variable "modulo" {
  description = "Tipo de módulo (Aplicación, DB, POC)"
  type        = string

  validation {
    condition     = contains(["Aplicación", "DB", "POC"], var.modulo)
    error_message = "El módulo debe ser: Aplicación, DB o POC"
  }
}

variable "alcance_sox" {
  description = "Indica si el recurso está bajo alcance SOX"
  type        = string

  validation {
    condition     = contains(["Sí", "No"], var.alcance_sox)
    error_message = "Alcance SOX debe ser 'Sí' o 'No'"
  }
}

variable "propietario" {
  description = "Persona responsable del recurso"
  type        = string
}

variable "proveedor" {
  description = "Proveedor del recurso (Inhouse o tercero)"
  type        = string

  validation {
    condition     = contains(["Inhouse", "Tercero"], var.proveedor)
    error_message = "El proveedor debe ser 'Inhouse' o 'Tercero'"
  }
}

variable "dominio" {
  description = "Dominio AMX"
  type        = string
}

variable "subdominio" {
  description = "Subdominio AMX"
  type        = string
}

variable "aplicacion" {
  description = "Identificador de aplicación"
  type        = string
}

variable "soporte" {
  description = "Equipo o persona responsable del soporte"
  type        = string
}

variable "contacto" {
  description = "Correo electrónico de contacto para soporte"
  type        = string

  validation {
    condition     = can(regex("^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\\.[a-zA-Z]{2,}$", var.contacto))
    error_message = "Debe proporcionar un correo electrónico válido."
  }
}

variable "proyecto" {
  description = "Código o nombre del proyecto"
  type        = string
}

variable "creado_por" {
  description = "Nombre o ID del creador del recurso"
  type        = string
}

variable "ciclo_vida" {
  description = "Etapa del ciclo de vida del recurso"
  type        = string

  validation {
    condition = contains([
      "Creación",
      "Implementación",
      "MonitoreoYMantenimiento",
      "Optimización",
      "Decommission"
    ], var.ciclo_vida)
    error_message = "El ciclo de vida debe ser: Creación, Implementación, MonitoreoYMantenimiento, Optimización o Decommission"
  }
}

variable "module_version" {
  description = "Versión del recurso"
  type        = string
  default     = "1.0.0"

  validation {
    condition     = can(regex("^[0-9]+\\.[0-9]+\\.[0-9]+$", var.module_version))
    error_message = "La versión debe seguir el formato semántico (ej: 1.0.0)."
  }
}
