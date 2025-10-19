# ==============================================================================
# MODULE VARIABLES
# ==============================================================================

variable "identifier" {
  description = "DB instance identifier"
  type        = string
}

variable "engine" {
  description = "Database engine"
  type        = string
}

variable "engine_version" {
  description = "Engine version"
  type        = string
}

variable "instance_class" {
  description = "Description for instance_class"
  type        = string
  default     = "db.t3.micro"
}

variable "allocated_storage" {
  description = "Description for allocated_storage"
  type        = number
  default     = 20
}

variable "storage_encrypted" {
  description = "Description for storage_encrypted"
  type        = bool
  default     = true
}

variable "db_name" {
  description = "Database name"
  type        = string
}

variable "username" {
  description = "Master username"
  type        = string
}

variable "manage_master_user_password" {
  description = "Description for manage_master_user_password"
  type        = bool
  default     = true
}

variable "vpc_security_group_ids" {
  description = "Security group IDs"
  type        = list(string)
}

variable "db_subnet_group_name" {
  description = "DB subnet group name"
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
