# ==============================================================================
# STORAGE MODULE: S3 - OUTPUTS
# ==============================================================================

output "bucket_id" {
  description = "ID del bucket S3"
  value       = aws_s3_bucket.primary.id
}

output "bucket_arn" {
  description = "ARN del bucket S3"
  value       = aws_s3_bucket.primary.arn
}

output "bucket_domain_name" {
  description = "Domain name del bucket"
  value       = aws_s3_bucket.primary.bucket_domain_name
}

output "bucket_regional_domain_name" {
  description = "Regional domain name del bucket"
  value       = aws_s3_bucket.primary.bucket_regional_domain_name
}

output "versioning_enabled" {
  description = "Estado del versionado"
  value       = var.enable_versioning
}

output "encryption_algorithm" {
  description = "Algoritmo de encriptación configurado"
  value       = var.kms_key_arn != null ? "aws:kms" : "AES256"
}

output "lifecycle_enabled" {
  description = "Estado de lifecycle policies"
  value       = var.enable_lifecycle
}

output "replication_enabled" {
  description = "Estado de replicación"
  value       = var.enable_replication
}

output "compliance_summary" {
  description = "Resumen de compliance y configuración"
  value = {
    versioning            = var.enable_versioning
    encryption            = true
    public_access_blocked = true
    mfa_delete            = var.enable_mfa_delete
    logging               = var.enable_logging
    object_lock           = var.enable_object_lock
    replication           = var.enable_replication
    iso27001_controls     = ["A.12.3.1", "A.18.1.3", "A.12.4.1"]
    nist_csf_functions    = ["PR.DS-1", "PR.DS-6", "PR.IP-1"]
  }
}
