# Data source for current AWS caller identity
data "aws_caller_identity" "current" {}

# GithubActions-BasePermissions Policy Module - Following ABAC Pattern
# Converted from definitions/policies/deployment/base-permissions.yaml
resource "aws_iam_policy" "main" {
  name_prefix = "githubactions-basepermissions-"
  path        = "/policies/"
  description = var.policy_description

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid      = "STSGetCallerIdentity"
        Effect   = "Allow"
        Action   = ["sts:GetCallerIdentity"]
        Resource = ["*"]
        }, {
        Sid      = "BasicAWSAccess"
        Effect   = "Allow"
        Action   = ["sts:DecodeAuthorizationMessage"]
        Resource = ["*"]
    }]
  })

  tags = merge(var.common_tags, {
    Name = "githubactions-basepermissions-${var.environment}"
    Type = "Policy"
  })
}