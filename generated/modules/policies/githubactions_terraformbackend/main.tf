# Data source for current AWS caller identity
data "aws_caller_identity" "current" {}

# GithubActions-TerraformBackend Policy Module - Following ABAC Pattern
# Converted from definitions/policies/deployment\terraform-backend.yaml
resource "aws_iam_policy" "main" {
  name_prefix = "githubactions-terraformbackend-"
  path        = "/policies/"
  description = var.policy_description

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid      = "TerraformS3StateAccess"
        Effect   = "Allow"
        Action   = ["s3:GetObject", "s3:PutObject", "s3:DeleteObject", "s3:ListBucket", "s3:GetBucketVersioning", "s3:GetBucketLocation"]
        Resource = ["arn:aws:s3:::${s3_bucket_name}", "arn:aws:s3:::${s3_bucket_name}/*"]
        }, {
        Sid      = "TerraformDynamoDBLockAccess"
        Effect   = "Allow"
        Action   = ["dynamodb:GetItem", "dynamodb:PutItem", "dynamodb:DeleteItem", "dynamodb:DescribeTable"]
        Resource = ["arn:aws:dynamodb:${aws_region}:${account_id}:table/${dynamodb_table_name}"]
        }, {
        Sid      = "TerraformKMSAccess"
        Effect   = "Allow"
        Action   = ["kms:Decrypt", "kms:DescribeKey", "kms:Encrypt", "kms:GenerateDataKey*", "kms:ReEncrypt*", "kms:CreateGrant"]
        Resource = ["arn:aws:kms:${aws_region}:${account_id}:key/${kms_key_id}"]
    }]
  })

  tags = merge(var.common_tags, {
    Name = "githubactions-terraformbackend-${var.environment}"
    Type = "Policy"
  })
}