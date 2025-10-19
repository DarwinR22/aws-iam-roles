# ==============================================================================
# LAMBDA FUNCTION MODULE - VARIABLES
# ==============================================================================

variable "name" {
  description = "Name for the lambda function"
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
    AssetType   = "Compute-Lambda-Function"
  }
}

# TODO: Add specific variables for lambda-function
