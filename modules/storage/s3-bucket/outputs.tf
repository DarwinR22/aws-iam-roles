# ==============================================================================
# MODULE OUTPUTS
# ==============================================================================

output "bucket_id" {
  description = "Bucket Id"
  value       = aws_s3_bucket.main.id
}

output "bucket_arn" {
  description = "Bucket Arn"
  value       = aws_s3_bucket.main.arn
}

output "bucket_domain_name" {
  description = "Bucket Domain Name"
  value       = aws_s3_bucket.main.bucket_domain_name
}

output "module_info" {
  description = "Information about this module"
  value = {
    module_name = "s3-bucket"
    status      = "implemented"
  }
}
