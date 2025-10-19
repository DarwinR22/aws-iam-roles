# ==============================================================================
# RDS INSTANCE MODULE - VARIABLES
# ==============================================================================

variable "name" {
  description = "Name for the rds instance"
  type        = string
}

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
    AssetType   = "Compute-Rds-Instance"
  }
}

# TODO: Add specific variables for rds-instance
