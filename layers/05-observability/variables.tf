# ==============================================================================
# LAYER 5: OBSERVABILITY VARIABLES
# ==============================================================================

variable "aws_region" {
  description = "AWS region for resources"
  type        = string
  default     = "us-east-1"
}

variable "environment" {
  description = "Environment name (dev, staging, prod)"
  type        = string
  default     = "dev"
}

variable "common_tags" {
  description = "Common tags to be applied to all resources"
  type        = map(string)
  default = {
    Project              = "SGSI-Implementation"
    CreatedBy           = "Terraform"
    MaintenanceWindow   = "Sunday-2AM-6AM"
  }
}

variable "enable_guardduty_malware_protection" {
  description = "Enable GuardDuty malware protection"
  type        = bool
  default     = true
}

variable "cloudwatch_log_retention_days" {
  description = "CloudWatch log retention period in days"
  type        = number
  default     = 30
}

variable "security_alert_email" {
  description = "Email address for security alerts"
  type        = string
  default     = "security@company.com"
}

variable "enable_detailed_monitoring" {
  description = "Enable detailed CloudWatch monitoring"
  type        = bool
  default     = true
}

variable "config_delivery_frequency" {
  description = "AWS Config delivery frequency"
  type        = string
  default     = "TwentyFour_Hours"
  
  validation {
    condition = contains([
      "One_Hour", "Three_Hours", "Six_Hours", 
      "Twelve_Hours", "TwentyFour_Hours"
    ], var.config_delivery_frequency)
    error_message = "Config delivery frequency must be a valid value."
  }
}

variable "guardduty_findings_frequency" {
  description = "GuardDuty findings publishing frequency"
  type        = string
  default     = "FIFTEEN_MINUTES"
  
  validation {
    condition = contains([
      "FIFTEEN_MINUTES", "ONE_HOUR", "SIX_HOURS"
    ], var.guardduty_findings_frequency)
    error_message = "GuardDuty findings frequency must be a valid value."
  }
}