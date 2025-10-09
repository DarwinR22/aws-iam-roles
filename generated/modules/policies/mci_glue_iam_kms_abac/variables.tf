# Variables for mci-glue-iam-kms-abac Policy Module

variable "policy_description" {
  description = "Description for the mci-glue-iam-kms-abac policy"
  type        = string
  default     = "Gestión de Glue, IAM PassRole y KMS para despliegue de infraestructura con ABAC"
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
  default     = "MCI-"
}

variable "policy_prefix" {
  description = "Prefix for IAM policies"
  type        = string
  default     = "MCI-"
}

variable "s3_bucket_name" {
  description = "S3 bucket name for Terraform backend"
  type        = string
  default     = "mci-terraform-state"
}

variable "dynamodb_table_name" {
  description = "DynamoDB table name for Terraform state locking"
  type        = string
  default     = "mci-terraform-locks"
}

variable "kms_key_id" {
  description = "KMS key ID for encryption"
  type        = string
  default     = "*"
}