# policy_lib/commons/variables.tf
# ===============================
# COMMON POLICY BLOCK VARIABLES
# ===============================

variable "external_account_id" {
  description = "External AWS account ID for cross-account trust"
  type        = string
  default     = ""
}

variable "external_id" {
  description = "External ID for cross-account trust (required if external_account_id is set)"
  type        = string
  default     = ""
}

variable "allowed_regions" {
  description = "List of allowed AWS regions"
  type        = list(string)
  default     = ["us-east-1"]
}

variable "account_id" {
  description = "AWS account ID"
  type        = string
  default     = "393209814297"
}