# Data source for current AWS caller identity
data "aws_caller_identity" "current" {}

# mci-aws-kms-decrypt Policy Module - Following ABAC Pattern
# Converted from definitions/policies/execution\mci-aws-kms-decrypt.yaml
resource "aws_iam_policy" "main" {
  name        = "mci-aws-kms-decrypt"
  path        = "/"
  description = var.policy_description

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
Sid    = "DecryptWithKMSAndABAC"
Effect = "Allow"
        Action = ["kms:Decrypt", "kms:DescribeKey", "kms:GenerateDataKey"]
        Resource = [          "arn:aws:kms:*:*:key/*"        ]
        Condition = {
          StringEquals = {            "aws:PrincipalTag/Cuenta" = ["$${aws:ResourceTag/Cuenta}"]          }        }
      }    ]
  })

  tags = merge(var.common_tags, {
    Name = "mci-aws-kms-decrypt-${var.environment}"
    Type = "Policy"
  })
}