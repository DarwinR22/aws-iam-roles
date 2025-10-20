# ==============================================================================
# MODULE: NAT Gateway High Availability - Variables
# ==============================================================================

variable "vpc_id" {
  description = "ID of the VPC"
  type        = string
}

variable "name_prefix" {
  description = "Prefix for resource names"
  type        = string
}

variable "internet_gateway_id" {
  description = "ID of the Internet Gateway (for dependency management)"
  type        = string
}

variable "availability_zones" {
  description = "List of availability zones (must be exactly 2)"
  type        = list(string)

  validation {
    condition     = length(var.availability_zones) == 2
    error_message = "Must provide exactly 2 availability zones for HA."
  }
}

variable "public_subnet_ids" {
  description = "List of public subnet IDs for NAT Gateways (one per AZ)"
  type        = list(string)

  validation {
    condition     = length(var.public_subnet_ids) == 2
    error_message = "Must provide exactly 2 public subnet IDs."
  }
}

variable "app_subnet_ids_az1" {
  description = "List of application subnet IDs in AZ1 to associate with NAT Gateway AZ1"
  type        = list(string)
  default     = []
}

variable "app_subnet_ids_az2" {
  description = "List of application subnet IDs in AZ2 to associate with NAT Gateway AZ2"
  type        = list(string)
  default     = []
}

variable "db_subnet_ids_az1" {
  description = "List of database subnet IDs in AZ1 to associate with NAT Gateway AZ1"
  type        = list(string)
  default     = []
}

variable "db_subnet_ids_az2" {
  description = "List of database subnet IDs in AZ2 to associate with NAT Gateway AZ2"
  type        = list(string)
  default     = []
}

variable "enable_monitoring" {
  description = "Enable CloudWatch monitoring and alarms for NAT Gateways"
  type        = bool
  default     = true
}

variable "min_bytes_threshold" {
  description = "Minimum bytes threshold for NAT Gateway monitoring (triggers alarm if below)"
  type        = number
  default     = 1000
}

variable "alarm_actions" {
  description = "List of ARNs to notify when alarms trigger (SNS topics)"
  type        = list(string)
  default     = []
}

variable "tags" {
  description = "Common tags to apply to all resources"
  type        = map(string)
  default     = {}
}
