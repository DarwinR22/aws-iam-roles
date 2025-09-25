# Variables for S3 Analytics Read Policy Module

variable "policy_description" {
  description = "Description for the S3 analytics read policy"
  type        = string
  default     = "Policy for S3 analytics read access with ABAC controls"
}

variable "bucket_name" {
  description = "Name of the S3 bucket to grant access to"
  type        = string
}

variable "abac_conditions" {
  description = "ABAC conditions for the policy (e.g., aws:PrincipalTag/Area, aws:PrincipalTag/Team)"
  type        = map(list(string))
}

variable "environment" {
  description = "Environment name (dev, qa, prod)"
  type        = string
}

variable "common_tags" {
  description = "Common tags to apply to the policy"
  type        = map(string)
  default     = {}
}