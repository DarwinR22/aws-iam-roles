aws_region = "us-east-1"
environment = "dev"

common_tags = {
  Project             = "SGSI-Implementation"
  Layer               = "Storage"
  Environment         = "Development"
  SecurityLevel       = "High"
  ComplianceScope     = "ISO27001,NIST-CSF"
  CreatedBy           = "GitHub-Actions"
  MaintenanceWindow   = "Sunday-2AM-6AM"
  BackupRequired      = "Yes"
  MonitoringEnabled   = "Yes"
  LoggingEnabled      = "Yes"
}