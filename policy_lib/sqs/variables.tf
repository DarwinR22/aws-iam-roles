# policy_lib/sqs/variables.tf
# ===========================
# SQS POLICY BLOCK VARIABLES
# ===========================

variable "sqs_produce_queue_arns" {
  description = "List of SQS queue ARNs for explicit produce access (fallback)"
  type        = list(string)
  default     = []
}

variable "sqs_consume_queue_arns" {
  description = "List of SQS queue ARNs for explicit consume access (fallback)"
  type        = list(string)
  default     = []
}

variable "enable_tag_based_access" {
  description = "Enable ABAC tag-based SQS access (preferred)"
  type        = bool
  default     = true
}

variable "enable_explicit_access" {
  description = "Enable explicit queue ARN access (fallback)"
  type        = bool
  default     = false
}