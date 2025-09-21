# modules/iam-attachments/variables.tf
# =====================================
# VARIABLES FOR IAM ATTACHMENTS MODULE
# =====================================

variable "role_name" {
  description = "Name of the IAM role to attach policies to"
  type        = string
}

variable "managed_policy_arns" {
  description = "List of managed policy ARNs to attach"
  type        = list(string)
  default     = []
}

variable "aws_managed_policies" {
  description = "List of AWS managed policy names to attach"
  type        = list(string)
  default     = []
}

variable "customer_managed_policies" {
  description = "List of customer managed policy names to attach"
  type        = list(string)
  default     = []
}

variable "max_attached_policies" {
  description = "Maximum number of policies that can be attached (AWS limit is 20)"
  type        = number
  default     = 20
  validation {
    condition     = var.max_attached_policies > 0 && var.max_attached_policies <= 20
    error_message = "Maximum attached policies must be between 1 and 20."
  }
}

# LOCALS FOR PROCESSING
locals {
  # Build complete list of policy ARNs
  aws_managed_arns = [
    for policy_name in var.aws_managed_policies :
    "arn:aws:iam::aws:policy/${policy_name}"
  ]
  
  customer_managed_arns = [
    for policy_name in var.customer_managed_policies :
    "arn:aws:iam::393209814297:policy/${policy_name}"
  ]
  
  all_policy_arns = concat(
    var.managed_policy_arns,
    local.aws_managed_arns,
    local.customer_managed_arns
  )
  
  # Remove duplicates
  unique_policy_arns = distinct(local.all_policy_arns)
  
  # Validate policy count
  policy_count = length(local.unique_policy_arns)
  exceeds_limit = local.policy_count > var.max_attached_policies
}