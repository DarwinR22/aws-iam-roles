# Variables for AWS Setup
# ======================

variable "environment" {
  description = "Entorno de despliegue (dev, qa, prod)"
  type        = string
  default     = "dev"
}

variable "common_tags" {
  description = "Tags comunes para todos los recursos"
  type        = map(string)
  default = {
    "BusinessUnit" = "MCI"
    "Environment"  = "dev"
    "Project"      = "github-actions-setup"
    "Owner"        = "MCI-DevOps"
    "CostCenter"   = "MCI-IT"
    "ManagedBy"    = "Terraform"
  }
}