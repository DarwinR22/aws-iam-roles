# Data source for current AWS caller identity
data "aws_caller_identity" "current" {}

# github-deployment-sts Policy Module - Following ABAC Pattern
# Converted from definitions/policies/deployment/github-deployment-sts.yaml
resource "aws_iam_policy" "main" {
  name        = "github-deployment-sts"
  path        = "/"
  description = var.policy_description

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid      = "STSAssumeRoleWithWebIdentity"
        Effect   = "Allow"
        Action   = ["sts:AssumeRoleWithWebIdentity", "sts:GetCallerIdentity", "sts:TagSession"]
        Resource = ["*"]
        }, {
        Sid      = "AssumeOtherRoles"
        Effect   = "Allow"
        Action   = ["sts:AssumeRole"]
        Resource = ["arn:aws:iam::*:role/*"]
    }]
  })

  tags = merge(var.common_tags, {
    Name = "github-deployment-sts-${var.environment}"
    Type = "Policy"
  })
}