# modules/iam-policy-cleanup/variables.tf
# Variables para el módulo de cleanup de políticas obsoletas

variable "aws_region" {
  description = "AWS region for operations"
  type        = string
  default     = "us-east-1"
}

variable "environment" {
  description = "Environment (dev, qa, prod)"
  type        = string
  default     = "dev"
}

variable "cleanup_enabled" {
  description = "Enable cleanup of obsolete policies"
  type        = bool
  default     = true
}