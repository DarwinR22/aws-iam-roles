variable "environment" {
  description = "Environment name"
  type        = string
}

variable "abac_conditions" {
  description = "ABAC conditions for policies"
  type        = map(any)
  default     = {}
}

variable "common_tags" {
  description = "Common tags to apply to resources"
  type        = map(string)
  default     = {}
}
