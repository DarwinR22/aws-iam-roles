# ==============================================================================
# MODULE VARIABLES
# ==============================================================================

variable "name" {
  description = "Name of the ALB"
  type        = string
}

variable "internal" {
  description = "Description for internal"
  type        = bool
  default     = false
}

variable "subnets" {
  description = "List of subnet IDs"
  type        = list(string)
}

variable "vpc_id" {
  description = "VPC ID"
  type        = string
}

variable "certificate_arn" {
  description = "Description for certificate_arn"
  type        = string
}

variable "enable_deletion_protection" {
  description = "Description for enable_deletion_protection"
  type        = bool
  default     = true
}

variable "idle_timeout" {
  description = "Description for idle_timeout"
  type        = number
  default     = 60
}

# Standard variables
variable "environment" {
  description = "Environment name"
  type        = string
  default     = "production"
}

variable "common_tags" {
  description = "Common tags to apply to all resources"
  type        = map(string)
  default = {
    Project     = "SGSI-Implementation"
    ManagedBy   = "Terraform"
  }
}

variable "additional_tags" {
  description = "Additional tags to apply to resources"
  type        = map(string)
  default     = {}
}
