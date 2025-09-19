variable "aws_region" {
  description = "AWS region for resources"
  type        = string
  default     = "us-east-1"
}

variable "aws_account_id" {
  description = "AWS Account ID"
  type        = string
  default     = "393209814297" # Tu cuenta AWS
}

variable "environment" {
  description = "Environment name"
  type        = string
  default     = "dev"
}

variable "project_name" {
  description = "Project name for resource naming"
  type        = string
  default     = "mci-aws-iam"
}

variable "policy_tags" {
  description = "Standard tags for IAM policies"
  type        = map(string)
  default     = {}
}

variable "policy_custom_tags" {
  description = "Custom tags per policy name (fallback for specific overrides)"
  type        = map(map(string))
  default     = {}
}

variable "service_owners" {
  description = "Owner per AWS service type"
  type        = map(string)
  default     = {}
}

variable "service_teams" {
  description = "Team per AWS service type"
  type        = map(string)
  default     = {}
}

variable "service_cost_centers" {
  description = "Cost center per AWS service type"
  type        = map(string)
  default     = {}
}
