# Data source for current AWS caller identity
data "aws_caller_identity" "current" {}

# MCI-S3-AnalyticsRead Policy Module - Following ABAC Pattern
# Converted from definitions/policies/s3-analytics-read.yaml
resource "aws_iam_policy" "main" {
  name_prefix = "mci-s3-analyticsread-"
  path        = "/policies/"
  description = var.policy_description

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid      = "S3AnalyticsRead"
        Effect   = "Allow"
        Action   = ["s3:GetObject", "s3:GetObjectVersion", "s3:ListBucket", "s3:ListBucketVersions", "s3:GetBucketLocation"]
        Resource = ["arn:aws:s3:::mci-${environment}-analytics/*", "arn:aws:s3:::mci-${environment}-datalake/*", "arn:aws:s3:::shared-${environment}-reports/*"]
        Condition = {
        StringEquals = { "aws:PrincipalTag/Gerencia" = var.abac_conditions["aws:PrincipalTag/Gerencia"], "aws:PrincipalTag/Ambiente" = ["${environment}"] }, StringLike = { "s3:prefix" = ["${area}/*", "shared/*", "public/*"] } }
    }]
  })

  tags = merge(var.common_tags, {
    Name = "mci-s3-analyticsread-${var.environment}"
    Type = "Policy"
  })
}