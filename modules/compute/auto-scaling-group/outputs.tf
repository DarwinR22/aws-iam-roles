# ==============================================================================
# MODULE OUTPUTS
# ==============================================================================

output "auto_scaling_group_id" {
  description = "Auto Scaling Group Id"
  value       = aws_autoscaling_group.main.id
}

output "auto_scaling_group_arn" {
  description = "Auto Scaling Group Arn"
  value       = aws_autoscaling_group.main.arn
}

output "launch_template_id" {
  description = "Launch Template Id"
  value       = aws_launch_template.main.id
}

output "module_info" {
  description = "Information about this module"
  value = {
    module_name = "auto-scaling-group"
    status      = "implemented"
  }
}
