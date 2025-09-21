# policy_lib/lambda/variables.tf
# =============================
# LAMBDA POLICY BLOCK VARIABLES
# =============================

variable "lambda_function_arns" {
  description = "List of Lambda function ARNs for explicit invoke access (fallback)"
  type        = list(string)
  default     = []
}

variable "lambda_function_prefixes" {
  description = "List of Lambda function name prefixes for prefix-based access"
  type        = list(string)
  default     = []
}

variable "enable_tag_based_invoke" {
  description = "Enable ABAC tag-based Lambda invoke (preferred)"
  type        = bool
  default     = true
}

variable "enable_prefix_based_invoke" {
  description = "Enable prefix-based Lambda invoke"
  type        = bool
  default     = true
}

variable "enable_explicit_invoke" {
  description = "Enable explicit function ARN invoke (fallback)"
  type        = bool
  default     = false
}

variable "include_execution_permissions" {
  description = "Include basic Lambda execution permissions (CloudWatch Logs)"
  type        = bool
  default     = false
}