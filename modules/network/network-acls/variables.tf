# ==============================================================================
# MODULE: Network ACLs - Variables
# ==============================================================================

variable "vpc_id" {
  description = "ID of the VPC"
  type        = string
}

variable "vpc_cidr" {
  description = "CIDR block of the VPC"
  type        = string
}

variable "name_prefix" {
  description = "Prefix for resource names"
  type        = string
}

variable "dmz_subnet_ids" {
  description = "List of DMZ (public) subnet IDs"
  type        = list(string)
}

variable "app_subnet_ids" {
  description = "List of application (private) subnet IDs"
  type        = list(string)
}

variable "db_subnet_ids" {
  description = "List of database (private) subnet IDs"
  type        = list(string)
}

variable "tags" {
  description = "Common tags to apply to all resources"
  type        = map(string)
  default     = {}
}
