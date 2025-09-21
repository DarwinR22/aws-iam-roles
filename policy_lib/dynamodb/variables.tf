# policy_lib/dynamodb/variables.tf
# ================================
# DYNAMODB POLICY BLOCK VARIABLES
# ================================

variable "dynamodb_read_table_arns" {
  description = "List of DynamoDB table ARNs for explicit read access (fallback)"
  type        = list(string)
  default     = []
}

variable "dynamodb_write_table_arns" {
  description = "List of DynamoDB table ARNs for explicit write access (fallback)"
  type        = list(string)
  default     = []
}

variable "enable_tag_based_access" {
  description = "Enable ABAC tag-based access (preferred)"
  type        = bool
  default     = true
}

variable "enable_leading_keys_restriction" {
  description = "Enable DynamoDB leading keys restriction based on principal tags"
  type        = bool
  default     = false
}

variable "enable_explicit_access" {
  description = "Enable explicit table ARN access (fallback)"
  type        = bool
  default     = false
}