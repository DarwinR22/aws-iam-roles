# ==============================================================================
# MODULE OUTPUTS
# ==============================================================================

output "security_group_id" {
  description = "Security Group Id"
  value       = aws_security_group.main.id
}

output "security_group_arn" {
  description = "Security Group Arn"
  value       = aws_security_group.main.arn
}

output "module_info" {
  description = "Information about this module"
  value = {
    module_name = "security-group"
    status      = "implemented"
  }
}
