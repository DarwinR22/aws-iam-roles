# ==============================================================================
# LAYER 1: FOUNDATION - OUTPUTS
# ==============================================================================

# IAM Role Outputs (using existing role)
output "github_deployment_role_arn" {
  description = "ARN of the GitHub Actions deployment role"
  value       = data.aws_iam_role.github_actions_deployment_role.arn
  sensitive   = false
}

output "github_deployment_role_name" {
  description = "Name of the GitHub Actions deployment role"
  value       = data.aws_iam_role.github_actions_deployment_role.name
}

output "github_deployment_role_unique_id" {
  description = "Unique ID of the GitHub Actions deployment role"
  value       = data.aws_iam_role.github_actions_deployment_role.unique_id
}

# Policy ARNs (10 Optimized Policies - Exactly at AWS Limit!)
output "policy_arns" {
  description = "ARNs of all attached optimized policies"
  value = {
    iam         = module.github_deployment_iam.policy_arn         # IAM + STS consolidated
    network     = module.github_deployment_network.policy_arn     # VPC infrastructure
    compute     = module.github_deployment_compute.policy_arn     # EC2, ALB, Auto Scaling
    cloudwatch  = module.github_deployment_cloudwatch.policy_arn  # Logs, metrics, SNS
    monitoring  = module.github_deployment_monitoring.policy_arn  # Security monitoring
    deployment  = module.github_deployment_deployment.policy_arn  # CloudFormation + tfstate
    application = module.github_deployment_application.policy_arn
    database    = module.github_deployment_database.policy_arn
    storage     = module.github_deployment_storage.policy_arn
    glue        = module.github_deployment_glue.policy_arn
  }
}

# Account Information
output "aws_account_id" {
  description = "AWS Account ID"
  value       = data.aws_caller_identity.current.account_id
}

output "aws_region" {
  description = "AWS Region"
  value       = data.aws_region.current.name
}

# Environment Information
output "environment" {
  description = "Environment name"
  value       = var.environment
}

output "layer_info" {
  description = "Layer information for downstream layers"
  value = {
    layer_name    = "foundation"
    layer_number  = "01"
    state_key     = "sgsi/layer1-foundation/terraform.tfstate"
    deployed_at   = timestamp()
  }
}