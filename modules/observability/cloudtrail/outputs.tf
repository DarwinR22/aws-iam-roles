# ==============================================================================
# MODULE OUTPUTS
# ==============================================================================

output "trail_id" {
  description = "Trail Id"
  value       = aws_cloudtrail.main.id
}

output "trail_arn" {
  description = "Trail Arn"
  value       = aws_cloudtrail.main.arn
}

output "s3_bucket_name" {
  description = "S3 Bucket Name"
  value       = aws_s3_bucket.cloudtrail.bucket
}

output "module_info" {
  description = "Information about this module"
  value = {
    module_name = "cloudtrail"
    status      = "implemented"
  }
}
