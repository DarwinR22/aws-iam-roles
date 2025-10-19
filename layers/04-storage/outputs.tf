output "s3_buckets" {
  description = "S3 bucket information"
  value = {
    app_data = aws_s3_bucket.sgsi_app_data.id
    logs     = aws_s3_bucket.sgsi_logs.id
    backups  = aws_s3_bucket.sgsi_backups.id
  }
}

output "efs_file_system_id" {
  description = "EFS file system ID"
  value       = aws_efs_file_system.sgsi_shared.id
}

output "backup_vault_arn" {
  description = "Backup vault ARN"
  value       = aws_backup_vault.sgsi_vault.arn
}

output "layer_info" {
  description = "Layer information"
  value = {
    layer_name   = "storage"
    layer_number = "04"
    state_key    = "sgsi/layer4-storage/terraform.tfstate"
    deployed_at  = timestamp()
  }
}