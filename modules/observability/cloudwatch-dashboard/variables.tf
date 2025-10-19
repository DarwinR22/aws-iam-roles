# ==============================================================================
# MODULE VARIABLES
# ==============================================================================

variable "dashboard_name" {
  description = "Name of the dashboard"
  type        = string
}

variable "dashboard_body" {
  description = "JSON body of the dashboard"
  type        = string
}

variable "metric_widgets" {
  description = "Description for metric_widgets"
  type        = list(object)
  default     = []
}

# Standard variables
variable "environment" {
  description = "Environment name"
  type        = string
  default     = "production"
}

variable "common_tags" {
  description = "Common tags to apply to all resources"
  type        = map(string)
  default = {
    Project     = "SGSI-Implementation"
    ManagedBy   = "Terraform"
  }
}

variable "additional_tags" {
  description = "Additional tags to apply to resources"
  type        = map(string)
  default     = {}
}
