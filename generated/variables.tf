# Variables for MCI IAM Infrastructure

variable "aws_region" {
  description = "AWS region for resources"
  type        = string
  default     = "us-east-1"
}

variable "environment" {
  description = "Environment name (dev, qa, prod)"
  type        = string
  
  validation {
    condition = contains(["dev", "qa", "prod"], var.environment)
    error_message = "Environment must be one of: dev, qa, prod."
  }
}

# Variables for ABAC (Attribute-Based Access Control)
variable "gerencia" {
  description = "Gerencia for ABAC tagging"
  type        = string
  default     = "MCI"
}

variable "area" {
  description = "Area for ABAC tagging"  
  type        = string
  default     = "TI"
}