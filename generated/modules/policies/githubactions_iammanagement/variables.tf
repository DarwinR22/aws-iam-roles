# Variables for GithubActions-IAMManagement Policy Module

variable "policy_description" {
  description = "Description for the GithubActions-IAMManagement policy"
  type        = string
  default     = "Complete IAM management permissions for infrastructure deployment"
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