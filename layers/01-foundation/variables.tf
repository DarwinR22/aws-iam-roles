# ==============================================================================
# LAYER 1: FOUNDATION - VARIABLES
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

variable "account_id" {
  description = "AWS Account ID"
  type        = string
  default     = "051963532279"
}

variable "common_tags" {
  description = "Common tags to be applied to all resources"
  type        = map(string)
  default     = {
    Project              = "SGSI_Implementation"
    Layer                = "Foundation"
    SecurityLevel        = "Critical"
    ComplianceScope      = "ISO27001_NIST_CSF"
    CreatedBy            = "GitHub_Actions"
    MaintenanceWindow    = "Sunday_2AM_6AM"
    BackupRequired       = "Yes"
    MonitoringEnabled    = "Yes"
    LoggingEnabled       = "Yes"
    ChangeManagement     = "ITIL_v4"
  }
}

variable "github_repository" {
  description = "GitHub repository for OIDC trust policy"
  type        = string
  default     = "DarwinR22/aws-iam-roles"
}

variable "role_session_duration" {
  description = "Maximum session duration for IAM roles (in seconds)"
  type        = number
  default     = 3600
  
  validation {
    condition     = var.role_session_duration >= 3600 && var.role_session_duration <= 43200
    error_message = "Role session duration must be between 3600 (1 hour) and 43200 (12 hours)."
  }
}

# ABAC Configuration
variable "abac_conditions" {
  description = "ABAC conditions for policy enforcement"
  type        = map(list(string))
  default     = {
    "Area"       = ["DevOps", "Security", "Network", "Database"]
    "Team"       = ["Infrastructure", "Platform", "Security"]
    "Project"    = ["SGSI-Implementation"]
    "Environment" = ["Development", "QA", "Production"]
  }
}