# ==============================================================================
# MODULE: VPC Endpoints - Variables
# ==============================================================================

variable "vpc_id" {
  description = "ID of the VPC"
  type        = string
}

variable "vpc_cidr" {
  description = "CIDR block of the VPC"
  type        = string
}

variable "region" {
  description = "AWS region"
  type        = string
}

variable "name_prefix" {
  description = "Prefix for resource names"
  type        = string
}

variable "route_table_ids" {
  description = "List of route table IDs to associate with Gateway endpoints"
  type        = list(string)
}

variable "private_subnet_ids" {
  description = "List of private subnet IDs for Interface endpoints"
  type        = list(string)
  default     = []
}

variable "allowed_s3_buckets" {
  description = "List of S3 bucket names to allow access through the endpoint (empty = all buckets)"
  type        = list(string)
  default     = []
}

variable "allowed_dynamodb_tables" {
  description = "List of DynamoDB table names to allow access through the endpoint (empty = all tables)"
  type        = list(string)
  default     = []
}

variable "enable_secrets_manager_endpoint" {
  description = "Enable Secrets Manager Interface endpoint"
  type        = bool
  default     = false
}

variable "enable_kms_endpoint" {
  description = "Enable KMS Interface endpoint"
  type        = bool
  default     = false
}

variable "tags" {
  description = "Common tags to apply to all resources"
  type        = map(string)
  default     = {}
}
