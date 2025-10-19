# ==============================================================================
# KMS KEY MODULE - VARIABLES
# ==============================================================================

variable "name" {
  description = "Name for the kms key"
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
    AssetType   = "Storage-Kms-Key"
  }
}

# TODO: Add specific variables for kms-key
