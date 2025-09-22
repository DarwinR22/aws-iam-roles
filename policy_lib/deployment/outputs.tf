# policy_lib/deployment/outputs.tf
# =============================================
# DEPLOYMENT POLICY OUTPUTS
# =============================================

# INDIVIDUAL POLICY DOCUMENTS
output "terraform_core_deployment_policy" {
  description = "Terraform core deployment policy document"
  value       = data.aws_iam_policy_document.terraform_core_deployment.json
}

output "s3_analytics_deployment_policy" {
  description = "S3 analytics deployment policy document"
  value       = data.aws_iam_policy_document.s3_analytics_deployment.json
}

output "cloudformation_deployment_policy" {
  description = "CloudFormation deployment policy document"
  value       = data.aws_iam_policy_document.cloudformation_deployment.json
}

output "lambda_deployment_policy" {
  description = "Lambda deployment policy document"
  value       = data.aws_iam_policy_document.lambda_deployment.json
}

output "logs_deployment_policy" {
  description = "Logs deployment policy document"
  value       = data.aws_iam_policy_document.logs_deployment.json
}

# COMBINED POLICY DOCUMENTS
output "full_deployment_policy" {
  description = "Full deployment access policy (all services)"
  value       = data.aws_iam_policy_document.full_deployment_access.json
}

output "basic_deployment_policy" {
  description = "Basic deployment access policy (CloudFormation + Lambda + Logs)"
  value       = data.aws_iam_policy_document.basic_deployment_access.json
}

# POLICY NAMES FOR REFERENCE
output "policy_names" {
  description = "Map of policy types to standardized names"
  value = {
    terraform_core   = "${var.policy_prefix}-TerraformCore"
    s3_analytics     = "${var.policy_prefix}-S3Analytics"
    cloudformation   = "${var.policy_prefix}-CloudFormation"
    lambda           = "${var.policy_prefix}-Lambda"
    logs             = "${var.policy_prefix}-Logs"
    full_deployment  = "${var.policy_prefix}-FullAccess"
    basic_deployment = "${var.policy_prefix}-BasicAccess"
  }
}

# RESOURCE ARNS FOR AUTOMATION
output "resource_patterns" {
  description = "Resource ARN patterns for each service"
  value = {
    s3_buckets            = "arn:aws:s3:::${var.department}-${var.environment}-*"
    lambda_functions      = "arn:aws:lambda:*:*:function:${var.department}-${var.environment}-*"
    cloudformation_stacks = "arn:aws:cloudformation:*:*:stack/${var.department}-${var.environment}-*/*"
    log_groups = [
      "arn:aws:logs:*:*:log-group:/aws/lambda/${var.department}-${var.environment}-*",
      "arn:aws:logs:*:*:log-group:/aws/apigateway/${var.department}-${var.environment}-*"
    ]
  }
}