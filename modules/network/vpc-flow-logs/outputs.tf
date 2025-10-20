# ==============================================================================
# MODULE: VPC Flow Logs - Outputs
# ==============================================================================

output "flow_log_id" {
  description = "ID of the VPC Flow Log"
  value       = aws_flow_log.vpc_flow_log.id
}

output "log_group_name" {
  description = "Name of the CloudWatch Log Group"
  value       = aws_cloudwatch_log_group.vpc_flow_logs.name
}

output "log_group_arn" {
  description = "ARN of the CloudWatch Log Group"
  value       = aws_cloudwatch_log_group.vpc_flow_logs.arn
}

output "iam_role_arn" {
  description = "ARN of the IAM role used by Flow Logs"
  value       = aws_iam_role.vpc_flow_logs_role.arn
}

output "rejected_traffic_alarm_arn" {
  description = "ARN of the rejected traffic CloudWatch alarm"
  value       = var.enable_rejected_traffic_alarm ? aws_cloudwatch_metric_alarm.high_rejected_traffic[0].arn : null
}

output "ssh_monitoring_alarm_arn" {
  description = "ARN of the SSH from internet CloudWatch alarm"
  value       = var.enable_ssh_monitoring ? aws_cloudwatch_metric_alarm.ssh_from_internet[0].arn : null
}

output "compliance_info" {
  description = "Compliance information for the VPC Flow Logs"
  value = {
    iso_27001_controls = ["A.13.1.1", "A.16.1.2"]
    nist_csf_controls  = ["DE.AE-3", "DE.CM-1"]
    traffic_type       = var.traffic_type
    retention_days     = var.log_retention_days
    monitoring_enabled = {
      rejected_traffic = var.enable_rejected_traffic_alarm
      ssh_monitoring   = var.enable_ssh_monitoring
    }
  }
}
