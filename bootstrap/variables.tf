# Variables para Bootstrap de MCI IAM
variable "aws_region" {
  description = "AWS region para los recursos de bootstrap"
  type        = string
  default     = "us-east-1"
}

variable "environment" {
  description = "Environment (dev, qa, prod)"
  type        = string
  default     = "dev"
}

variable "project_name" {
  description = "Nombre del proyecto"
  type        = string
  default     = "mci-iam"
}