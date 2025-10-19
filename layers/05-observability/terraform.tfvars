# ==============================================================================
# LAYER 5: OBSERVABILITY TERRAFORM VARIABLES
# ==============================================================================

aws_region  = "us-east-1"
environment = "dev"

common_tags = {
  Project              = "SGSI-Implementation"
  Layer                = "Observability"
  Environment          = "dev"
  ManagedBy           = "Terraform"
  SecurityLevel       = "Critical"
  ComplianceScope     = "ISO27001,NIST-CSF,SOX"
  CreatedBy           = "GitHub-Actions"
  MaintenanceWindow   = "Sunday-2AM-6AM"
  CostCenter          = "IT-Security"
  DataClassification  = "Confidential"
}

# Observability Configuration
enable_guardduty_malware_protection = true
cloudwatch_log_retention_days       = 30
security_alert_email                = "security-team@company.com"
enable_detailed_monitoring          = true
config_delivery_frequency           = "TwentyFour_Hours"
guardduty_findings_frequency        = "FIFTEEN_MINUTES"