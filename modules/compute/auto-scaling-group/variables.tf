# ==============================================================================
# MODULE VARIABLES
# ==============================================================================

variable "name" {
  description = "Name of the Auto Scaling Group"
  type        = string
}

variable "min_size" {
  description = "Description for min_size"
  type        = number
  default     = 1
}

variable "max_size" {
  description = "Description for max_size"
  type        = number
  default     = 3
}

variable "desired_capacity" {
  description = "Description for desired_capacity"
  type        = number
  default     = 2
}

variable "vpc_zone_identifier" {
  description = "List of subnet IDs"
  type        = list(string)
}

variable "target_group_arns" {
  description = "Description for target_group_arns"
  type        = list(string)
  default     = []
}

variable "health_check_type" {
  description = "Description for health_check_type"
  type        = string
  default     = "EC2"
}

variable "instance_type" {
  description = "Description for instance_type"
  type        = string
  default     = "t3.medium"
}

variable "ami_id" {
  description = "AMI ID for launch template"
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
