# ==============================================================================
# OUTPUTS - RDS MODULE
# ==============================================================================

output "db_instance_id" {
  description = "ID de la instancia RDS"
  value       = aws_db_instance.main.id
}

output "db_instance_arn" {
  description = "ARN de la instancia RDS"
  value       = aws_db_instance.main.arn
}

output "db_instance_endpoint" {
  description = "Endpoint de conexión de la base de datos"
  value       = aws_db_instance.main.endpoint
}

output "db_instance_address" {
  description = "Dirección DNS de la instancia RDS"
  value       = aws_db_instance.main.address
}

output "db_instance_port" {
  description = "Puerto de la base de datos"
  value       = aws_db_instance.main.port
}

output "db_instance_name" {
  description = "Nombre de la base de datos"
  value       = aws_db_instance.main.db_name
}

output "db_subnet_group_name" {
  description = "Nombre del DB Subnet Group"
  value       = aws_db_subnet_group.main.name
}

output "db_subnet_group_arn" {
  description = "ARN del DB Subnet Group"
  value       = aws_db_subnet_group.main.arn
}

output "db_parameter_group_name" {
  description = "Nombre del Parameter Group"
  value       = aws_db_parameter_group.main.name
}

output "db_parameter_group_arn" {
  description = "ARN del Parameter Group"
  value       = aws_db_parameter_group.main.arn
}

output "monitoring_role_arn" {
  description = "ARN del rol de monitoreo (si está habilitado)"
  value       = var.monitoring_interval > 0 ? aws_iam_role.rds_monitoring[0].arn : ""
}

output "cloudwatch_alarm_arns" {
  description = "ARNs de las alarmas de CloudWatch"
  value = {
    cpu_high         = aws_cloudwatch_metric_alarm.cpu_high.arn
    storage_low      = aws_cloudwatch_metric_alarm.storage_low.arn
    connections_high = aws_cloudwatch_metric_alarm.connections_high.arn
  }
}

output "db_connection_string" {
  description = "String de conexión para la aplicación (sin password)"
  value       = "postgresql://${var.master_username}@${aws_db_instance.main.endpoint}/${aws_db_instance.main.db_name}"
  sensitive   = true
}

output "compliance_summary" {
  description = "Resumen de compliance del módulo RDS"
  value = {
    iso27001_controls = ["A.12.3.1", "A.10.1.1", "A.10.1.2", "A.17.2.1", "A.12.4.1", "A.9.4.2"]
    nist_controls     = ["PR.DS-1", "PR.IP-1", "DE.CM-1"]
    features = {
      multi_az                  = var.multi_az
      encrypted_at_rest         = true
      automated_backups         = var.backup_retention_period > 0
      backup_retention_days     = var.backup_retention_period
      performance_insights      = var.performance_insights_enabled
      enhanced_monitoring       = var.monitoring_interval > 0
      cloudwatch_logs_exports   = length(var.enabled_cloudwatch_logs_exports) > 0
      deletion_protection       = var.deletion_protection
      auto_minor_version_upgrade = var.auto_minor_version_upgrade
    }
  }
}
