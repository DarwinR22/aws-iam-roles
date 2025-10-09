# Data source for current AWS caller identity
data "aws_caller_identity" "current" {}

# mci-terraform-state-management Policy Module - Following ABAC Pattern
# Converted from definitions/policies/deployment\terraform-state-management.yaml
resource "aws_iam_policy" "main" {
  name        = "mci-mci-terraform-state-management"
  path        = "/policies/"
  description = var.policy_description

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
Sid    = "TerraformS3StateAccess"
Effect = "Allow"
        Action = ["s3:GetObject", "s3:PutObject", "s3:DeleteObject", "s3:ListBucket", "s3:GetBucketVersioning", "s3:GetBucketLocation", "s3:ListBucketVersions"]
        Resource = [          "arn:aws:s3:::*-tfstate-*",          "arn:aws:s3:::*-tfstate-*/*"        ]
      },      {
Sid    = "TerraformDynamoDBLockAccess"
Effect = "Allow"
        Action = ["dynamodb:GetItem", "dynamodb:PutItem", "dynamodb:DeleteItem", "dynamodb:DescribeTable", "dynamodb:DescribeContinuousBackups"]
        Resource = [          "arn:aws:dynamodb:*:*:table/*-terraform-lock*",          "arn:aws:dynamodb:*:*:table/*-tfstate-lock*"        ]
      }    ]
  })

  tags = merge(var.common_tags, {
    Name = "mci-terraform-state-management-${var.environment}"
    Type = "Policy"
  })
}