# ==============================================================================
# MODULE VARIABLES
# ==============================================================================

variable "vpc_name" {
  description = "Name of the VPC"
  type        = string
}

variable "vpc_cidr_block" {
  description = "CIDR block for the VPC"
  type        = string
}

variable "public_subnet_cidrs" {
  description = "Description for public_subnet_cidrs"
  type        = list(string)
  default     = []
}

variable "private_subnet_cidrs" {
  description = "Description for private_subnet_cidrs"
  type        = list(string)
  default     = []
}

variable "create_nat_gateway" {
  description = "Description for create_nat_gateway"
  type        = bool
  default     = true
}

variable "enable_flow_logs" {
  description = "Description for enable_flow_logs"
  type        = bool
  default     = true
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
