# Data source for current AWS caller identity
data "aws_caller_identity" "current" {}

# github-deployment-cloudformation Policy Module - Following ABAC Pattern
# Converted from definitions/policies/deployment\github-deployment-cloudformation.yaml
resource "aws_iam_policy" "main" {
  name        = "github-deployment-cloudformation"
  path        = "/"
  description = var.policy_description

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
Sid    = "CloudFormationFullAccess"
Effect = "Allow"
        Action = ["cloudformation:CreateStack", "cloudformation:UpdateStack", "cloudformation:DeleteStack", "cloudformation:DescribeStacks", "cloudformation:DescribeStackEvents", "cloudformation:DescribeStackResources", "cloudformation:GetTemplate", "cloudformation:ListStacks", "cloudformation:ValidateTemplate", "cloudformation:CreateChangeSet", "cloudformation:DeleteChangeSet", "cloudformation:DescribeChangeSet", "cloudformation:ExecuteChangeSet", "cloudformation:ListChangeSets", "cloudformation:TagResource", "cloudformation:UntagResource", "cloudformation:ListStackResources"]
        Resource = [          "arn:aws:cloudformation:*:*:stack/*",          "arn:aws:cloudformation:*:*:changeSet/*"        ]
      },      {
Sid    = "CloudFormationListOperations"
Effect = "Allow"
        Action = ["cloudformation:ListStacks", "cloudformation:ListExports", "cloudformation:ListImports", "cloudformation:DescribeAccountLimits"]
        Resource = [          "*"        ]
      },      {
Sid    = "KMSEncryptionForServices"
Effect = "Allow"
        Action = ["kms:Decrypt", "kms:Encrypt", "kms:GenerateDataKey", "kms:GenerateDataKeyWithoutPlaintext", "kms:ReEncrypt*", "kms:DescribeKey", "kms:CreateGrant", "kms:ListGrants", "kms:RevokeGrant"]
        Resource = [          "arn:aws:kms:*:*:key/*"        ]
      },      {
Sid    = "KMSListKeys"
Effect = "Allow"
        Action = ["kms:ListKeys", "kms:ListAliases"]
        Resource = [          "*"        ]
      },      {
Sid    = "STSGetCallerIdentity"
Effect = "Allow"
        Action = ["sts:GetCallerIdentity"]
        Resource = [          "*"        ]
      }    ]
  })

  tags = merge(var.common_tags, {
    Name = "github-deployment-cloudformation-${var.environment}"
    Type = "Policy"
  })
}