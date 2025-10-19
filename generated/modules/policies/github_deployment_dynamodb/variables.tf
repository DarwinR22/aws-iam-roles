# Variables for github-deployment-dynamodb Policy Module

variable "policy_description" {
  description = "Description for the github-deployment-dynamodb policy"
  type        = string
  default     = "Gestión completa de tablas DynamoDB sin restricciones ABAC para CI/CD deployment"
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

# AWS Configuration Variables
variable "aws_region" {
  description = "AWS region for resources"
  type        = string
  default     = "us-east-1"
}

variable "role_prefix" {
  description = "Prefix for IAM roles"
  type        = string
  default     = "APP-"
}

variable "policy_prefix" {
  description = "Prefix for IAM policies"
  type        = string
  default     = "APP-"
}

variable "s3_bucket_name" {
  description = "S3 bucket name for Terraform backend"
  type        = string
  default     = "terraform-state-bucket-051963532279"
}

variable "dynamodb_table_name" {
  description = "DynamoDB table name for Terraform state locking"
  type        = string
  default     = "terraform-locks"
}

variable "kms_key_id" {
  description = "KMS key ID for encryption"
  type        = string
  default     = "*"
}