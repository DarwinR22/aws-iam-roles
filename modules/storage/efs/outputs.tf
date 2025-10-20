# ==============================================================================
# STORAGE MODULE: EFS - OUTPUTS
# ==============================================================================

output "file_system_id" {
  description = "ID del EFS file system"
  value       = aws_efs_file_system.main.id
}

output "file_system_arn" {
  description = "ARN del EFS file system"
  value       = aws_efs_file_system.main.arn
}

output "file_system_dns_name" {
  description = "DNS name para montar el file system"
  value       = aws_efs_file_system.main.dns_name
}

output "mount_target_ids" {
  description = "IDs de los mount targets"
  value       = aws_efs_mount_target.main[*].id
}

output "mount_target_ips" {
  description = "IPs privadas de los mount targets"
  value       = aws_efs_mount_target.main[*].ip_address
}

output "access_point_app_id" {
  description = "ID del access point para /app"
  value       = var.create_access_points ? aws_efs_access_point.app[0].id : null
}

output "access_point_data_id" {
  description = "ID del access point para /data"
  value       = var.create_access_points ? aws_efs_access_point.data[0].id : null
}

output "size_in_bytes" {
  description = "Tamaño del file system en bytes"
  value       = aws_efs_file_system.main.size_in_bytes
}

output "mount_command" {
  description = "Comando para montar el EFS en EC2"
  value       = "sudo mount -t nfs4 -o nfsvers=4.1,rsize=1048576,wsize=1048576,hard,timeo=600,retrans=2,noresvport ${aws_efs_file_system.main.dns_name}:/ /mnt/efs"
}

output "compliance_summary" {
  description = "Resumen de compliance y configuración"
  value = {
    encrypted             = var.enable_encryption
    performance_mode      = var.performance_mode
    throughput_mode       = var.throughput_mode
    backup_enabled        = var.enable_backup
    lifecycle_ia_enabled  = true
    access_points_created = var.create_access_points
    multi_az              = length(var.subnet_ids) > 1
    iso27001_controls     = ["A.12.3.1", "A.12.6.1"]
    nist_csf_functions    = ["PR.DS-1", "PR.IP-12"]
  }
}
