# Data source for current AWS caller identity
data "aws_caller_identity" "current" {}

# mci-lambda-sns-publish Policy Module - Following ABAC Pattern
# Converted from definitions/policies/execution\mci-lambda-sns-publish.yaml
resource "aws_iam_policy" "main" {
  name        = "mci-lambda-sns-publish"
  path        = "/"
  description = var.policy_description

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
Sid    = "PublishToSNSWithABAC"
Effect = "Allow"
        Action = ["sns:Publish"]
        Resource = [          "arn:aws:sns:*:*:*"        ]
        Condition = {
          StringEquals = {            "aws:PrincipalTag/Gerencia" = var.abac_conditions["aws:PrincipalTag/Gerencia"],            "aws:PrincipalTag/Ambiente" = ["$${aws:ResourceTag/Ambiente}"]          }        }
      }    ]
  })

  tags = merge(var.common_tags, {
    Name = "mci-lambda-sns-publish-${var.environment}"
    Type = "Policy"
  })
}