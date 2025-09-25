# Variables for MCI-S3-AnalyticsRead Policy Module

variable "policy_description" {
  description = "Description for the MCI-S3-AnalyticsRead policy"
  type        = string
  default     = "Read-only access to analytics S3 buckets for BI team"
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