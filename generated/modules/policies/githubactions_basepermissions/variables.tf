# Variables for GithubActions-BasePermissions Policy Module

variable "policy_description" {
  description = "Description for the GithubActions-BasePermissions policy"
  type        = string
  default     = "Base permissions for GitHub Actions deployment operations"
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