# ==============================================================================
# LAYER 3: COMPUTE - TERRAFORM VARIABLES
# Environment: Development
# ==============================================================================

# AWS Configuration
aws_region = "us-east-1"
environment = "dev"

# EC2 Configuration
instance_type = "t3.micro"

# Auto Scaling Configuration
asg_min_size         = 1
asg_max_size         = 3
asg_desired_capacity = 2

# RDS Configuration
db_allocated_storage     = 20
db_max_allocated_storage = 100
db_instance_class        = "db.t3.micro"
db_name                  = "sgsidb"
db_username              = "admin"
db_password              = "changeme123!"  # Change in production

# Common Tags
common_tags = {
  Project             = "SGSI-Implementation"
  Layer               = "Compute"
  Environment         = "Development"
  SecurityLevel       = "High"
  ComplianceScope     = "ISO27001,NIST-CSF"
  CreatedBy           = "GitHub-Actions"
  MaintenanceWindow   = "Sunday-2AM-6AM"
  BackupRequired      = "Yes"
  MonitoringEnabled   = "Yes"
  LoggingEnabled      = "Yes"
  ChangeManagement    = "ITIL-v4"
  BusinessOwner       = "SGSI-Team"
  TechnicalContact    = "darwin.lopez@example.com"
  SecurityContact     = "security@example.com"
  CostCenter          = "Security-Infrastructure"
  DataClassification  = "Internal"
}