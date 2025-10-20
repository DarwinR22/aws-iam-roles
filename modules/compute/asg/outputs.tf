# ==============================================================================
# OUTPUTS - ASG MODULE
# ==============================================================================

output "asg_id" {
  description = "ID del Auto Scaling Group"
  value       = aws_autoscaling_group.main.id
}

output "asg_name" {
  description = "Nombre del Auto Scaling Group"
  value       = aws_autoscaling_group.main.name
}

output "asg_arn" {
  description = "ARN del Auto Scaling Group"
  value       = aws_autoscaling_group.main.arn
}

output "launch_template_id" {
  description = "ID del Launch Template"
  value       = aws_launch_template.main.id
}

output "launch_template_latest_version" {
  description = "Última versión del Launch Template"
  value       = aws_launch_template.main.latest_version
}

output "iam_role_arn" {
  description = "ARN del IAM Role para instancias EC2"
  value       = aws_iam_role.ec2_instance_role.arn
}

output "iam_instance_profile_name" {
  description = "Nombre del IAM Instance Profile"
  value       = aws_iam_instance_profile.ec2_profile.name
}

output "scaling_policy_arns" {
  description = "ARNs de las políticas de scaling"
  value = {
    scale_up   = aws_autoscaling_policy.scale_up.arn
    scale_down = aws_autoscaling_policy.scale_down.arn
  }
}

output "cloudwatch_alarm_arns" {
  description = "ARNs de las alarmas de CloudWatch"
  value = {
    cpu_high = aws_cloudwatch_metric_alarm.cpu_high.arn
    cpu_low  = aws_cloudwatch_metric_alarm.cpu_low.arn
  }
}

output "capacity_info" {
  description = "Información de capacidad del ASG"
  value = {
    min_size         = var.min_size
    max_size         = var.max_size
    desired_capacity = var.desired_capacity
  }
}

output "compliance_summary" {
  description = "Resumen de compliance del módulo ASG"
  value = {
    iso27001_controls = ["A.17.2.1", "A.12.6.1", "A.10.1.1", "A.12.4.1"]
    nist_controls     = ["PR.IP-12", "DE.CM-1"]
    features = {
      multi_az              = true
      auto_scaling          = true
      encrypted_ebs         = true
      imdsv2_enforced       = true
      cloudwatch_monitoring = var.detailed_monitoring
      ssm_enabled           = true
      instance_refresh      = true
    }
  }
}
