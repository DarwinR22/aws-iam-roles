# Data source for current AWS caller identity
data "aws_caller_identity" "current" {}

# S3 Analytics Read Policy Module - Following ABAC Pattern
# Converted from definitions/policies/other/s3-analytics-read.yaml
resource "aws_iam_policy" "main" {
  name_prefix = "mci_s3_analyticsread-"
  path        = "/policies/"
  description = var.policy_description

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "S3BucketListAccess"
        Effect = "Allow"
        Action = [
          "s3:ListBucket"
        ]
        Resource = "arn:aws:s3:::${var.bucket_name}"
        Condition = {
          StringEquals = {
            for condition_key, condition_values in var.abac_conditions : condition_key => condition_values
          }
        }
      },
      {
        Sid    = "S3ObjectReadAccess"
        Effect = "Allow"
        Action = [
          "s3:GetObject"
        ]
        Resource = "arn:aws:s3:::${var.bucket_name}/*"
        Condition = {
          StringEquals = {
            for condition_key, condition_values in var.abac_conditions : condition_key => condition_values
          }
        }
      }
    ]
  })

  tags = merge(var.common_tags, {
    Name = "mci_s3_analyticsread-${var.environment}"
    Type = "Policy"
  })
}