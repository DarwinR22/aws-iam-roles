# ==============================================================================
# IAM ACCESS ANALYZER MODULE - OUTPUTS
# ==============================================================================

output "analyzer_id" {
  description = "ID of the Access Analyzer"
  value       = aws_accessanalyzer_analyzer.main.id
}

output "analyzer_arn" {
  description = "ARN of the Access Analyzer"
  value       = aws_accessanalyzer_analyzer.main.arn
}

output "analyzer_name" {
  description = "Name of the Access Analyzer"
  value       = aws_accessanalyzer_analyzer.main.analyzer_name
}

output "cloudwatch_alarm_arn" {
  description = "ARN of the CloudWatch alarm for new findings"
  value       = var.create_cloudwatch_alarm ? aws_cloudwatch_metric_alarm.new_findings[0].arn : null
}

output "eventbridge_rule_arn" {
  description = "ARN of the EventBridge rule for findings"
  value       = var.create_eventbridge_rule ? aws_cloudwatch_event_rule.access_analyzer_findings[0].arn : null
}
