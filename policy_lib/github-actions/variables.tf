# Variables for GitHub Actions policies
# ====================================

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
    "Project"      = "github-actions-iam"
    "Owner"        = "MCI-DevOps"
    "CostCenter"   = "MCI-IT"
    "ManagedBy"    = "Terraform"
  }
}