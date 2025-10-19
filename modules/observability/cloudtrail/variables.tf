# ==============================================================================
# MODULE VARIABLES
# ==============================================================================

variable "trail_name" {
  description = "Name of the CloudTrail"
  type        = string
}

variable "s3_bucket_name" {
  description = "S3 bucket for CloudTrail logs"
  type        = string
}

variable "include_global_service_events" {
  description = "Description for include_global_service_events"
  type        = bool
  default     = true
}

variable "is_multi_region_trail" {
  description = "Description for is_multi_region_trail"
  type        = bool
  default     = true
}

variable "enable_log_file_validation" {
  description = "Description for enable_log_file_validation"
  type        = bool
  default     = true
}

variable "kms_key_id" {
  description = "Description for kms_key_id"
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
