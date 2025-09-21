# policy_lib/s3/variables.tf
# ==========================
# S3 POLICY BLOCK VARIABLES
# ==========================

variable "s3_read_paths" {
  description = "List of S3 object ARN patterns for path-based read access (fallback)"
  type        = list(string)
  default     = []
}

variable "s3_write_paths" {
  description = "List of S3 object ARN patterns for path-based write access (fallback)"
  type        = list(string)
  default     = []
}

variable "s3_bucket_arns" {
  description = "List of S3 bucket ARNs for ListBucket operations"
  type        = list(string)
  default     = []
}

variable "s3_read_prefixes" {
  description = "List of S3 prefixes for path-based read access"
  type        = list(string)
  default     = []
}

variable "enable_tag_based_access" {
  description = "Enable ABAC tag-based access (preferred)"
  type        = bool
  default     = true
}

variable "enable_path_based_access" {
  description = "Enable path-based access (fallback)"
  type        = bool
  default     = false
}