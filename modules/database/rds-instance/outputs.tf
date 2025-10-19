# ==============================================================================
# MODULE OUTPUTS
# ==============================================================================

output "db_instance_address" {
  description = "Db Instance Address"
  value       = aws_db_instance.main.address
}

output "db_instance_arn" {
  description = "Db Instance Arn"
  value       = aws_db_instance.main.arn
}

output "db_instance_endpoint" {
  description = "Db Instance Endpoint"
  value       = aws_db_instance.main.endpoint
}

output "db_instance_id" {
  description = "Db Instance Id"
  value       = aws_db_instance.main.identifier
}

output "module_info" {
  description = "Information about this module"
  value = {
    module_name = "rds-instance"
    status      = "implemented"
  }
}
