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
  Project             = "SGSI_Implementation"
  Layer               = "Foundation"
  Environment         = "Development"
  SecurityLevel       = "Critical"
  ComplianceScope     = "ISO27001_NIST_CSF"
  CreatedBy           = "GitHub_Actions"
  MaintenanceWindow   = "Sunday_2AM_6AM"
  BackupRequired      = "Yes"
  MonitoringEnabled   = "Yes"
  LoggingEnabled      = "Yes"
  ChangeManagement    = "ITIL_v4"
  BusinessOwner       = "SGSI_Team"
  TechnicalContact    = "darwin.lopez"
  SecurityContact     = "security"
  CostCenter          = "Security_Infrastructure"
  DataClassification  = "Internal"
}