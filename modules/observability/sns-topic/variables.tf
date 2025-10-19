# ==============================================================================
# MODULE VARIABLES
# ==============================================================================

variable "topic_name" {
  description = "Name of the SNS topic"
  type        = string
}

variable "display_name" {
  description = "Description for display_name"
  type        = string
}

variable "subscriptions" {
  description = "Description for subscriptions"
  type        = list(object)
  default     = []
}

variable "kms_master_key_id" {
  description = "Description for kms_master_key_id"
  type        = string
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
