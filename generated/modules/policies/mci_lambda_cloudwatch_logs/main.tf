# Data source for current AWS caller identity
data "aws_caller_identity" "current" {}

# mci-lambda-cloudwatch-logs Policy Module - Following ABAC Pattern
# Converted from definitions/policies/execution\mci-lambda-cloudwatch-logs.yaml
resource "aws_iam_policy" "main" {
  name        = "mci-lambda-cloudwatch-logs"
  path        = "/"
  description = var.policy_description

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
Sid    = "CreateLogGroupWithABAC"
Effect = "Allow"
        Action = ["logs:CreateLogGroup"]
        Resource = [          "arn:aws:logs:*:*:*"        ]
        Condition = {
          StringEquals = {            "aws:PrincipalTag/Gerencia" = var.abac_conditions["aws:PrincipalTag/Gerencia"],            "aws:PrincipalTag/Ambiente" = ["$${aws:ResourceTag/Ambiente}"]          }        }
      },      {
Sid    = "WriteLogsWithABAC"
Effect = "Allow"
        Action = ["logs:CreateLogStream", "logs:PutLogEvents"]
        Resource = [          "arn:aws:logs:*:*:log-group:/aws/lambda/*:*"        ]
        Condition = {
          StringEquals = {            "aws:PrincipalTag/Gerencia" = var.abac_conditions["aws:PrincipalTag/Gerencia"],            "aws:PrincipalTag/Ambiente" = ["$${aws:ResourceTag/Ambiente}"]          }        }
      }    ]
  })

  tags = merge(var.common_tags, {
    Name = "mci-lambda-cloudwatch-logs-${var.environment}"
    Type = "Policy"
  })
}