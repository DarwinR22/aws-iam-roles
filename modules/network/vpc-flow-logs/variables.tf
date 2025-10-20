# ==============================================================================
# MODULE: VPC Flow Logs - Variables
# ==============================================================================

variable "vpc_id" {
  description = "ID of the VPC to enable flow logs for"
  type        = string
}

variable "vpc_name" {
  description = "Name of the VPC (used for naming resources)"
  type        = string
}

variable "traffic_type" {
  description = "Type of traffic to log (ACCEPT, REJECT, or ALL)"
  type        = string
  default     = "ALL"

  validation {
    condition     = contains(["ACCEPT", "REJECT", "ALL"], var.traffic_type)
    error_message = "Traffic type must be ACCEPT, REJECT, or ALL."
  }
}

variable "log_retention_days" {
  description = "Number of days to retain flow logs in CloudWatch"
  type        = number
  default     = 90

  validation {
    condition     = contains([1, 3, 5, 7, 14, 30, 60, 90, 120, 150, 180, 365, 400, 545, 731, 1827, 3653], var.log_retention_days)
    error_message = "Log retention must be a valid CloudWatch Logs retention period."
  }
}

variable "custom_log_format" {
  description = "Custom log format for flow logs (leave empty for default)"
  type        = string
  default     = ""
}

variable "enable_rejected_traffic_alarm" {
  description = "Enable CloudWatch alarm for high rejected traffic"
  type        = bool
  default     = true
}

variable "rejected_traffic_threshold" {
  description = "Threshold for rejected traffic alarm (number of rejected connections)"
  type        = number
  default     = 100
}

variable "enable_ssh_monitoring" {
  description = "Enable monitoring and alerting for SSH traffic from internet"
  type        = bool
  default     = true
}

variable "alarm_actions" {
  description = "List of ARNs to notify when alarms trigger (SNS topics)"
  type        = list(string)
  default     = []
}

variable "tags" {
  description = "Common tags to apply to all resources"
  type        = map(string)
  default     = {}
}
