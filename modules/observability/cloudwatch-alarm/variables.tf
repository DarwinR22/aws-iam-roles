# ==============================================================================
# CLOUDWATCH ALARM MODULE - VARIABLES
# ==============================================================================

variable "name" {
  description = "Name for the cloudwatch alarm"
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
    AssetType   = "Observability-Cloudwatch-Alarm"
  }
}

# TODO: Add specific variables for cloudwatch-alarm
