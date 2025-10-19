# ==============================================================================
# MODULE VARIABLES
# ==============================================================================

variable "bucket_name" {
  description = "Name of the S3 bucket"
  type        = string
}

variable "versioning_enabled" {
  description = "Description for versioning_enabled"
  type        = bool
  default     = true
}

variable "sse_algorithm" {
  description = "Description for sse_algorithm"
  type        = string
  default     = "AES256"
}

variable "block_public_acls" {
  description = "Description for block_public_acls"
  type        = bool
  default     = true
}

variable "lifecycle_rules" {
  description = "Description for lifecycle_rules"
  type        = list(object)
  default     = []
}

variable "logging_enabled" {
  description = "Description for logging_enabled"
  type        = bool
  default     = false
}

variable "create_cloudwatch_alarms" {
  description = "Description for create_cloudwatch_alarms"
  type        = bool
  default     = true
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
