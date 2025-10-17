# Data source for current AWS caller identity
data "aws_caller_identity" "current" {}

# mci-aws-dynamodb-read Policy Module - Following ABAC Pattern
# Converted from definitions/policies/execution/mci-aws-dynamodb-read.yaml
resource "aws_iam_policy" "main" {
  name        = "mci-aws-dynamodb-read"
  path        = "/"
  description = var.policy_description

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid      = "ReadDynamoDBWithABAC"
        Effect   = "Allow"
        Action   = ["dynamodb:GetItem", "dynamodb:BatchGetItem", "dynamodb:Query", "dynamodb:Scan", "dynamodb:DescribeTable"]
        Resource = ["arn:aws:dynamodb:*:*:table/*"]
        Condition = {
        StringEquals = { "aws:PrincipalTag/Cuenta" = ["$${aws:ResourceTag/Cuenta}"] } }
    }]
  })

  tags = merge(var.common_tags, {
    Name = "mci-aws-dynamodb-read-${var.environment}"
    Type = "Policy"
  })
}