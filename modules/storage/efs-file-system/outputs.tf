# ==============================================================================
# MODULE OUTPUTS
# ==============================================================================

output "file_system_id" {
  description = "File System Id"
  value       = aws_efs_file_system.main.id
}

output "file_system_arn" {
  description = "File System Arn"
  value       = aws_efs_file_system.main.arn
}

output "dns_name" {
  description = "Dns Name"
  value       = aws_efs_file_system.main.dns_name
}

output "module_info" {
  description = "Information about this module"
  value = {
    module_name = "efs-file-system"
    status      = "implemented"
  }
}
