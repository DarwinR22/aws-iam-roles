# policy_lib/deployment/variables.tf
# =============================================
# DEPLOYMENT POLICY VARIABLES
# =============================================

variable "department" {
  description = "Gerencia tag for ABAC policies (MCI, sistemas, data-analytics)" 
  type        = string
  validation {
    condition = contains([
      "MCI",
      "sistemas", 
      "data-analytics"
    ], var.department)
    error_message = "Department must be one of: MCI, sistemas, data-analytics."
  }
}

variable "environment" {
  description = "Environment tag for ABAC policies (dev, qa, prod)"
  type        = string
  validation {
    condition = contains([
      "dev",
      "qa",
      "prod"
    ], var.environment)
    error_message = "Environment must be one of: dev, qa, prod."
  }
}

variable "policy_prefix" {
  description = "Prefix for policy names"
  type        = string
  default     = "MCI-Deployment"
}

variable "tags" {
  description = "Common tags for all deployment policies"
  type        = map(string)
  default = {
    "PolicyType"   = "Deployment"
    "Governance"   = "ABAC"
    "ManagedBy"    = "Terraform"
    "Architecture" = "Enterprise"
  }
}