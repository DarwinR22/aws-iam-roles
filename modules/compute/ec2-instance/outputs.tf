# ==============================================================================
# MODULE OUTPUTS
# ==============================================================================

output "instance_id" {
  description = "Instance Id"
  value       = aws_instance.main.id
}

output "instance_arn" {
  description = "Instance Arn"
  value       = aws_instance.main.arn
}

output "instance_public_ip" {
  description = "Instance Public Ip"
  value       = aws_instance.main.public_ip
}

output "instance_private_ip" {
  description = "Instance Private Ip"
  value       = aws_instance.main.private_ip
}

output "security_group_id" {
  description = "Security Group Id"
  value       = aws_security_group.instance[0].id
}

output "module_info" {
  description = "Information about this module"
  value = {
    module_name = "ec2-instance"
    status      = "implemented"
  }
}
