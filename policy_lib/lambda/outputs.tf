# policy_lib/lambda/outputs.tf
# ============================
# LAMBDA POLICY BLOCK OUTPUTS
# ============================

output "lambda_invoke_by_prefix_policy_json" {
  description = "Lambda invoke by prefix policy document (JSON)"
  value       = data.aws_iam_policy_document.lambda_invoke_by_prefix.json
}

output "lambda_tag_based_invoke_policy_json" {
  description = "Lambda tag-based invoke policy document (JSON)"
  value       = data.aws_iam_policy_document.lambda_tag_based_invoke.json
}

output "lambda_execution_basic_policy_json" {
  description = "Lambda basic execution policy document (JSON)"
  value       = data.aws_iam_policy_document.lambda_execution_basic.json
}

output "lambda_explicit_invoke_policy_json" {
  description = "Lambda explicit invoke policy document (JSON)"
  value       = length(var.lambda_function_arns) > 0 ? data.aws_iam_policy_document.lambda_explicit_invoke[0].json : ""
}