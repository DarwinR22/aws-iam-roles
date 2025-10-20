# ==============================================================================
# GUARDDUTY MODULE - OUTPUTS
# ==============================================================================

output "detector_id" {
  description = "ID del detector de GuardDuty"
  value       = aws_guardduty_detector.main.id
}

output "detector_arn" {
  description = "ARN del detector de GuardDuty"
  value       = aws_guardduty_detector.main.arn
}

output "sns_topic_arn" {
  description = "ARN del topic SNS para findings"
  value       = var.enable_sns_notifications ? aws_sns_topic.guardduty_findings[0].arn : null
}

output "eventbridge_rule_name" {
  description = "Nombre de la regla EventBridge para high severity findings"
  value       = var.enable_eventbridge_integration ? aws_cloudwatch_event_rule.guardduty_high_severity[0].name : null
}

output "log_group_name" {
  description = "Nombre del CloudWatch Log Group"
  value       = var.enable_cloudwatch_logs ? aws_cloudwatch_log_group.guardduty_findings[0].name : null
}

output "critical_alarm_arn" {
  description = "ARN de la alarma para findings críticos"
  value       = var.enable_sns_notifications ? aws_cloudwatch_metric_alarm.critical_findings_alarm[0].arn : null
}
