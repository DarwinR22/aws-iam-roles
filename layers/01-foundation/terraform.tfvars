# ==============================================================================
# LAYER 1: FOUNDATION - TERRAFORM VARIABLES
# Environment: Development
# ==============================================================================

# AWS Configuration
aws_region = "us-east-1"
account_id = "051963532279"

# Environment Configuration
environment = "dev"

# GitHub Repository Configuration
github_repository = "DarwinR22/aws-iam-roles"

# IAM Role Configuration
role_session_duration = 3600

# ABAC Conditions
abac_conditions = {
  "Area"        = ["DevOps", "Security", "Network", "Database", "Application"]
  "Team"        = ["Infrastructure", "Platform", "Security", "DevOps"]
  "Project"     = ["SGSI-Implementation"]
  "Environment" = ["Development", "QA", "Production"]
  "Layer"       = ["Foundation", "Network", "Compute", "Storage", "Observability"]
}

# Common Tags
common_tags = {
  Project             = "SGSI-Implementation"
  Layer               = "Foundation"
  Environment         = "Development"
  SecurityLevel       = "Critical"
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