# ==============================================================================
# LAYER 5: OBSERVABILITY OUTPUTS
# ==============================================================================

output "cloudtrail_arn" {
  description = "ARN of the CloudTrail"
  value       = aws_cloudtrail.sgsi_trail.arn
}

output "config_recorder_name" {
  description = "Name of the AWS Config recorder"
  value       = aws_config_configuration_recorder.sgsi_recorder.name
}

output "guardduty_detector_id" {
  description = "ID of the GuardDuty detector"
  value       = aws_guardduty_detector.sgsi_detector.id
}

output "security_hub_arn" {
  description = "ARN of the Security Hub"
  value       = aws_securityhub_account.sgsi_security_hub.arn
}

output "cloudwatch_dashboard_arn" {
  description = "ARN of the CloudWatch dashboard"
  value       = aws_cloudwatch_dashboard.sgsi_dashboard.dashboard_arn
}

output "sns_topic_arn" {
  description = "ARN of the SNS topic for alerts"
  value       = aws_sns_topic.alerts.arn
}

output "high_cpu_alarm_arn" {
  description = "ARN of the high CPU alarm"
  value       = aws_cloudwatch_metric_alarm.high_cpu.arn
}

# ==============================================================================
# SUMMARY OUTPUTS
# ==============================================================================
output "observability_summary" {
  description = "Summary of all observability components"
  value = {
    layer               = "05-observability"
    cloudtrail_enabled  = true
    config_enabled      = true
    guardduty_enabled   = true
    security_hub_enabled = true
    monitoring_enabled  = true
    alert_topic_created = true
    
    security_services = [
      "CloudTrail",
      "AWS Config", 
      "GuardDuty",
      "Security Hub",
      "CloudWatch"
    ]
    
    compliance_coverage = [
      "ISO27001 - A.12.6.1 (Management of technical vulnerabilities)",
      "NIST-CSF - DE.CM (Detection Continuous Monitoring)",
      "SOX - IT General Controls (Monitoring)"
    ]
  }
}