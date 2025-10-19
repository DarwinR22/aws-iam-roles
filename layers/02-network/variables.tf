# ==============================================================================
# LAYER 2: NETWORK - VARIABLES
# ==============================================================================

variable "aws_region" {
  description = "AWS region for deployment"
  type        = string
  default     = "us-east-1"
}

variable "environment" {
  description = "Environment name (dev, qa, prod)"
  type        = string
  default     = "dev"
  
  validation {
    condition     = contains(["dev", "qa", "prod"], var.environment)
    error_message = "Environment must be one of: dev, qa, prod."
  }
}

variable "vpc_cidr" {
  description = "CIDR block for the VPC"
  type        = string
  default     = "10.0.0.0/16"
  
  validation {
    condition     = can(cidrhost(var.vpc_cidr, 0))
    error_message = "VPC CIDR must be a valid IPv4 CIDR block."
  }
}

variable "common_tags" {
  description = "Common tags to be applied to all resources"
  type        = map(string)
  default     = {
    Project              = "SGSI-Implementation"
    Layer                = "Network"
    SecurityLevel        = "High"
    ComplianceScope      = "ISO27001,NIST-CSF"
    CreatedBy            = "GitHub-Actions"
    MaintenanceWindow    = "Sunday-2AM-6AM"
    BackupRequired       = "No"
    MonitoringEnabled    = "Yes"
    LoggingEnabled       = "Yes"
    ChangeManagement     = "ITIL-v4"
  }
}

variable "enable_nat_gateway" {
  description = "Whether to create NAT Gateway for private subnets"
  type        = bool
  default     = false  # Disabled to save costs (~$90/month)
}

variable "enable_vpn_gateway" {
  description = "Whether to create VPN Gateway"
  type        = bool
  default     = false
}

variable "admin_ip" {
  description = "Administrator IP address for management access"
  type        = string
  default     = "0.0.0.0/0"  # Change in production
  
  validation {
    condition     = can(cidrhost(var.admin_ip, 0))
    error_message = "Admin IP must be a valid IPv4 CIDR block."
  }
}

# Subnet Configuration
variable "subnet_config" {
  description = "Subnet configuration for different tiers"
  type = object({
    dmz_cidr_blocks = list(string)
    app_cidr_blocks = list(string)
    db_cidr_blocks  = list(string)
    mgmt_cidr_blocks = list(string)
  })
  default = {
    dmz_cidr_blocks  = ["10.0.1.0/24", "10.0.2.0/24"]
    app_cidr_blocks  = ["10.0.16.0/24", "10.0.17.0/24"]
    db_cidr_blocks   = ["10.0.32.0/24", "10.0.33.0/24"]
    mgmt_cidr_blocks = ["10.0.48.0/24", "10.0.49.0/24"]
  }
}

# Security Configuration
variable "security_config" {
  description = "Security configuration for the network"
  type = object({
    enable_flow_logs     = bool
    enable_dns_logging   = bool
    enable_vpc_endpoints = bool
  })
  default = {
    enable_flow_logs     = true
    enable_dns_logging   = true
    enable_vpc_endpoints = true
  }
}