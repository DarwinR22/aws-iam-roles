# ==============================================================================
# LAYER 2: NETWORK - TERRAFORM VARIABLES
# Environment: Development
# ==============================================================================

# AWS Configuration
aws_region = "us-east-1"

# Environment Configuration
environment = "dev"

# VPC Configuration
vpc_cidr = "10.0.0.0/16"

# NAT Gateway (disabled to save costs)
enable_nat_gateway = false
enable_vpn_gateway = false

# Admin IP (change in production)
admin_ip = "0.0.0.0/0"

# Subnet Configuration
subnet_config = {
  dmz_cidr_blocks  = ["10.0.1.0/24", "10.0.2.0/24"]
  app_cidr_blocks  = ["10.0.16.0/24", "10.0.17.0/24"]
  db_cidr_blocks   = ["10.0.32.0/24", "10.0.33.0/24"]
  mgmt_cidr_blocks = ["10.0.48.0/24", "10.0.49.0/24"]
}

# Security Configuration
security_config = {
  enable_flow_logs     = true
  enable_dns_logging   = true
  enable_vpc_endpoints = true
}

# Common Tags
common_tags = {
  Project             = "SGSI-Implementation"
  Layer               = "Network"
  Environment         = "Development"
  SecurityLevel       = "High"
  ComplianceScope     = "ISO27001+NIST-CSF+ZeroTrust"
  CreatedBy           = "GitHub-Actions"
  MaintenanceWindow   = "Sunday-2AM-6AM"
  BackupRequired      = "No"
  MonitoringEnabled   = "Yes"
  LoggingEnabled      = "Yes"
  ChangeManagement    = "ITIL-v4"
  BusinessOwner       = "SGSI-Team"
  TechnicalContact    = "darwin.lopez@example.com"
  SecurityContact     = "security@example.com"
  CostCenter          = "Security-Infrastructure"
  DataClassification  = "Internal"
  AssetType           = "Network-Infrastructure"
  ZeroTrustLayer      = "Network-Segmentation"
}