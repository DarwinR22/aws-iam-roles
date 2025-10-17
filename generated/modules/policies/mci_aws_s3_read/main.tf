# Data source for current AWS caller identity
data "aws_caller_identity" "current" {}

# mci-aws-s3-read Policy Module - Following ABAC Pattern
# Converted from definitions/policies/execution\mci-aws-s3-read.yaml
resource "aws_iam_policy" "main" {
  name        = "mci-aws-s3-read"
  path        = "/"
  description = var.policy_description

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
Sid    = "ListBucketsWithABAC"
Effect = "Allow"
        Action = ["s3:ListBucket", "s3:GetBucketLocation", "s3:GetBucketVersioning"]
        Resource = [          "arn:aws:s3:::*"        ]
        Condition = {
          StringEquals = {            "aws:PrincipalTag/Cuenta" = ["$${aws:ResourceTag/Cuenta}"],            "aws:PrincipalTag/Proposito" = ["$${aws:ResourceTag/Proposito}"]          }        }
      },      {
Sid    = "ReadObjectsWithABAC"
Effect = "Allow"
        Action = ["s3:GetObject", "s3:GetObjectVersion", "s3:GetObjectMetadata", "s3:GetObjectAttributes"]
        Resource = [          "arn:aws:s3:::*/*"        ]
        Condition = {
          StringEquals = {            "aws:PrincipalTag/Cuenta" = ["$${aws:ResourceTag/Cuenta}"],            "aws:PrincipalTag/Proposito" = ["$${aws:ResourceTag/Proposito}"]          }        }
      }    ]
  })

  tags = merge(var.common_tags, {
    Name = "mci-aws-s3-read-${var.environment}"
    Type = "Policy"
  })
}