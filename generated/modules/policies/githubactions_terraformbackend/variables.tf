# Variables for GithubActions-TerraformBackend Policy Module

variable "policy_description" {
  description = "Description for the GithubActions-TerraformBackend policy"
  type        = string
  default     = "Terraform state backend access for S3, DynamoDB and KMS"
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