# ==============================================================================
# MODULE OUTPUTS
# ==============================================================================

output "topic_arn" {
  description = "Topic Arn"
  value       = aws_sns_topic.main.arn
}

output "topic_id" {
  description = "Topic Id"
  value       = aws_sns_topic.main.id
}

output "module_info" {
  description = "Information about this module"
  value = {
    module_name = "sns-topic"
    status      = "implemented"
  }
}
