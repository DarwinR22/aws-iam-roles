# ==============================================================================
# INTERNET GATEWAY MODULE - VARIABLES
# ==============================================================================

variable "name" {
  description = "Name for the internet gateway"
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
    AssetType   = "Network-Internet-Gateway"
  }
}

# TODO: Add specific variables for internet-gateway
