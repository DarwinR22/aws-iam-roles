# ==============================================================================
# CREDENTIAL ROTATION POLICY MODULE - OUTPUTS
# ==============================================================================

output "password_policy_expire_passwords" {
  description = "Whether passwords expire"
  value       = aws_iam_account_password_policy.main.expire_passwords
}

output "password_policy_max_age" {
  description = "Maximum password age configured"
  value       = aws_iam_account_password_policy.main.max_password_age
}

output "access_key_checker_function_arn" {
  description = "ARN of the Lambda function that checks aged access keys"
  value       = var.enable_access_key_monitoring ? aws_lambda_function.check_access_keys[0].arn : null
}

output "access_key_checker_function_name" {
  description = "Name of the Lambda function that checks aged access keys"
  value       = var.enable_access_key_monitoring ? aws_lambda_function.check_access_keys[0].function_name : null
}

output "cloudwatch_rule_arn" {
  description = "ARN of the CloudWatch Event rule for aged access keys"
  value       = var.enable_access_key_monitoring ? aws_cloudwatch_event_rule.aged_access_keys[0].arn : null
}
