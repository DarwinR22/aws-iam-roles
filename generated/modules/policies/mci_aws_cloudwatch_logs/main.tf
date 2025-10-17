# Data source for current AWS caller identity
data "aws_caller_identity" "current" {}

# mci-aws-cloudwatch-logs Policy Module - Following ABAC Pattern
# Converted from definitions/policies/execution/mci-aws-cloudwatch-logs.yaml
resource "aws_iam_policy" "main" {
  name        = "mci-aws-cloudwatch-logs"
  path        = "/"
  description = var.policy_description

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid      = "CreateLogGroupWithABAC"
        Effect   = "Allow"
        Action   = ["logs:CreateLogGroup"]
        Resource = ["arn:aws:logs:*:*:*"]
        Condition = {
        StringEquals = { "aws:PrincipalTag/Cuenta" = ["$${aws:ResourceTag/Cuenta}"] } }
        }, {
        Sid      = "WriteLogsWithABAC"
        Effect   = "Allow"
        Action   = ["logs:CreateLogStream", "logs:PutLogEvents", "logs:DescribeLogStreams"]
        Resource = ["arn:aws:logs:*:*:log-group:/aws/glue/*:*", "arn:aws:logs:*:*:log-group:/aws/lambda/*:*", "arn:aws:logs:*:*:log-group:/aws/ecs/*:*", "arn:aws:logs:*:*:log-group:/aws/batch/*:*"]
        Condition = {
        StringEquals = { "aws:PrincipalTag/Cuenta" = ["$${aws:ResourceTag/Cuenta}"] } }
    }]
  })

  tags = merge(var.common_tags, {
    Name = "mci-aws-cloudwatch-logs-${var.environment}"
    Type = "Policy"
  })
}