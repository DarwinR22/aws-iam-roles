# ==============================================================================
# MODULE VARIABLES
# ==============================================================================

variable "vault_name" {
  description = "Name of the backup vault"
  type        = string
}

variable "kms_key_arn" {
  description = "Description for kms_key_arn"
  type        = string
}

variable "backup_plan_name" {
  description = "Name of the backup plan"
  type        = string
}

variable "schedule" {
  description = "Description for schedule"
  type        = string
  default     = "cron(0 5 ? * * *)"
}

variable "retention_days" {
  description = "Description for retention_days"
  type        = number
  default     = 30
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
