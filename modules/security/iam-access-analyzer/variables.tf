# ==============================================================================
# IAM ACCESS ANALYZER MODULE - VARIABLES
# ==============================================================================

variable "environment" {
  description = "Environment name (dev, staging, production)"
  type        = string
  default     = "dev"

  validation {
    condition     = can(regex("^(dev|staging|production)$", var.environment))
    error_message = "Environment must be dev, staging, or production."
  }
}

variable "analyzer_type" {
  description = "Type of analyzer (ACCOUNT or ORGANIZATION)"
  type        = string
  default     = "ACCOUNT"

  validation {
    condition     = can(regex("^(ACCOUNT|ORGANIZATION)$", var.analyzer_type))
    error_message = "Analyzer type must be ACCOUNT or ORGANIZATION."
  }
}

variable "common_tags" {
  description = "Common tags to apply to all resources"
  type        = map(string)
  default     = {}
}

variable "archive_rules" {
  description = "List of archive rules to suppress expected findings"
  type = list(object({
    name = string
    filters = list(object({
      criteria = string
      contains = optional(list(string))
      eq       = optional(list(string))
      exists   = optional(bool)
      neq      = optional(list(string))
    }))
  }))
  default = []
}

variable "create_cloudwatch_alarm" {
  description = "Whether to create CloudWatch alarm for new findings"
  type        = bool
  default     = true
}

variable "alarm_threshold" {
  description = "Threshold for new findings alarm"
  type        = number
  default     = 0
}

variable "alarm_actions" {
  description = "List of ARNs to notify when alarm triggers"
  type        = list(string)
  default     = []
}

variable "create_eventbridge_rule" {
  description = "Whether to create EventBridge rule for findings"
  type        = bool
  default     = true
}

variable "event_targets" {
  description = "List of ARNs to send events to (SNS topics, Lambda, etc.)"
  type        = list(string)
  default     = []
}
