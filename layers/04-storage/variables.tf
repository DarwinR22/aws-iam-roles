# ==============================================================================
# LAYER 4: STORAGE - VARIABLES
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
}

variable "project_name" {
  description = "Project name prefix"
  type        = string
  default     = "sgsi"
}

variable "owner" {
  description = "Owner of the resources"
  type        = string
  default     = "SGSI-Team"
}

variable "common_tags" {
  description = "Common tags to be applied to all resources"
  type        = map(string)
  default     = {}
}

# ------------------------------------------------------------------------------
# S3 CONFIGURATION
# ------------------------------------------------------------------------------
variable "enable_s3_replication" {
  description = "Enable S3 cross-region replication"
  type        = bool
  default     = false
}

variable "enable_s3_backup_bucket" {
  description = "Create additional S3 bucket for backups"
  type        = bool
  default     = true
}

# ------------------------------------------------------------------------------
# EFS CONFIGURATION
# ------------------------------------------------------------------------------
variable "efs_performance_mode" {
  description = "EFS performance mode: generalPurpose or maxIO"
  type        = string
  default     = "generalPurpose"
}

variable "efs_throughput_mode" {
  description = "EFS throughput mode: bursting, provisioned, or elastic"
  type        = string
  default     = "bursting"
}

variable "efs_provisioned_throughput" {
  description = "Provisioned throughput in MiB/s (only if throughput_mode = provisioned)"
  type        = number
  default     = null
}

variable "efs_lifecycle_transition_to_ia" {
  description = "Days to transition files to IA storage"
  type        = string
  default     = "AFTER_30_DAYS"
}

variable "efs_lifecycle_transition_to_primary" {
  description = "Transition files back to primary storage after access"
  type        = string
  default     = null
}

# ------------------------------------------------------------------------------
# AWS BACKUP CONFIGURATION
# ------------------------------------------------------------------------------
variable "enable_backup_vault_lock" {
  description = "Enable Backup Vault Lock for WORM compliance"
  type        = bool
  default     = false
}

variable "backup_daily_retention_days" {
  description = "Retention period for daily backups (days)"
  type        = number
  default     = 7
}

variable "backup_weekly_retention_days" {
  description = "Retention period for weekly backups (days)"
  type        = number
  default     = 30
}

variable "backup_monthly_retention_days" {
  description = "Retention period for monthly backups (days)"
  type        = number
  default     = 365
}

variable "enable_cross_region_backup" {
  description = "Enable cross-region backup copy"
  type        = bool
  default     = false
}

variable "backup_destination_vault_arn" {
  description = "ARN of destination vault for cross-region backup"
  type        = string
  default     = null
}