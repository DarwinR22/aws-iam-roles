# policy_lib/commons/outputs.tf
# ============================
# COMMON POLICY BLOCK OUTPUTS
# ============================

output "lambda_service_trust_policy_json" {
  description = "Lambda service trust policy document (JSON)"
  value       = data.aws_iam_policy_document.lambda_service_trust.json
}

output "ecs_service_trust_policy_json" {
  description = "ECS service trust policy document (JSON)"
  value       = data.aws_iam_policy_document.ecs_service_trust.json
}

output "glue_service_trust_policy_json" {
  description = "Glue service trust policy document (JSON)"
  value       = data.aws_iam_policy_document.glue_service_trust.json
}

output "step_functions_service_trust_policy_json" {
  description = "Step Functions service trust policy document (JSON)"
  value       = data.aws_iam_policy_document.step_functions_service_trust.json
}

output "cross_account_trust_policy_json" {
  description = "Cross-account trust policy document (JSON)"
  value       = var.external_account_id != "" ? data.aws_iam_policy_document.cross_account_trust[0].json : ""
}

output "app_standard_boundary_policy_json" {
  description = "App standard permission boundary policy document (JSON)"
  value       = data.aws_iam_policy_document.app_standard_boundary.json
}

output "platform_boundary_policy_json" {
  description = "Platform permission boundary policy document (JSON)"
  value       = data.aws_iam_policy_document.platform_boundary.json
}