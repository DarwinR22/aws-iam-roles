# ==============================================================================
# MODULE VARIABLES
# ==============================================================================

variable "name" {
  description = "Name of the EFS file system"
  type        = string
}

variable "performance_mode" {
  description = "Description for performance_mode"
  type        = string
  default     = "generalPurpose"
}

variable "throughput_mode" {
  description = "Description for throughput_mode"
  type        = string
  default     = "provisioned"
}

variable "encrypted" {
  description = "Description for encrypted"
  type        = bool
  default     = true
}

variable "subnet_ids" {
  description = "Subnet IDs for mount targets"
  type        = list(string)
}

variable "vpc_id" {
  description = "VPC ID for security groups"
  type        = string
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
