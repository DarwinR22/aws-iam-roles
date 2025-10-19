# ==============================================================================
# CREDENTIAL ROTATION POLICY MODULE - VARIABLES
# ==============================================================================

variable "environment" {
  description = "Environment name (dev, staging, production)"
  type        = string
  default     = "dev"
}

variable "common_tags" {
  description = "Common tags to apply to all resources"
  type        = map(string)
  default     = {}
}

# Password Policy Variables
variable "minimum_password_length" {
  description = "Minimum length of IAM user passwords"
  type        = number
  default     = 14
}

variable "require_lowercase" {
  description = "Require at least one lowercase character"
  type        = bool
  default     = true
}

variable "require_uppercase" {
  description = "Require at least one uppercase character"
  type        = bool
  default     = true
}

variable "require_numbers" {
  description = "Require at least one number"
  type        = bool
  default     = true
}

variable "require_symbols" {
  description = "Require at least one symbol"
  type        = bool
  default     = true
}

variable "allow_users_to_change_password" {
  description = "Allow IAM users to change their own password"
  type        = bool
  default     = true
}

variable "max_password_age" {
  description = "Maximum password age in days (0 = no expiration)"
  type        = number
  default     = 90
}

variable "password_reuse_prevention" {
  description = "Number of previous passwords to prevent reuse"
  type        = number
  default     = 12
}

variable "hard_expiry" {
  description = "Whether users are prevented from changing password after expiration"
  type        = bool
  default     = false
}

# Access Key Monitoring Variables
variable "enable_access_key_monitoring" {
  description = "Enable monitoring and alerting for aged access keys"
  type        = bool
  default     = true
}

variable "access_key_max_age" {
  description = "Maximum age of access keys in days before alerting"
  type        = number
  default     = 90
}

variable "notification_topic_arn" {
  description = "SNS topic ARN for notifications about aged credentials"
  type        = string
  default     = ""
}

variable "lambda_package_path" {
  description = "Path to Lambda deployment package (zip file)"
  type        = string
  default     = ""
}

variable "log_retention_days" {
  description = "CloudWatch Logs retention period in days"
  type        = number
  default     = 30
}
