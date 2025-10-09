# Data source for current AWS caller identity
data "aws_caller_identity" "current" {}

# mci-s3-deployment-abac Policy Module - Following ABAC Pattern
# Converted from definitions/policies/deployment\s3-deployment-abac.yaml
resource "aws_iam_policy" "main" {
  name        = "mci-mci-s3-deployment-abac"
  path        = "/policies/"
  description = var.policy_description

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
Sid    = "S3BucketManagement"
Effect = "Allow"
        Action = ["s3:CreateBucket", "s3:DeleteBucket", "s3:ListBucket", "s3:GetBucketLocation", "s3:GetBucketVersioning", "s3:PutBucketVersioning", "s3:GetBucketPolicy", "s3:PutBucketPolicy", "s3:DeleteBucketPolicy", "s3:GetBucketTagging", "s3:PutBucketTagging", "s3:GetBucketEncryption", "s3:PutBucketEncryption", "s3:GetBucketPublicAccessBlock", "s3:PutBucketPublicAccessBlock", "s3:GetBucketLifecycleConfiguration", "s3:PutBucketLifecycleConfiguration", "s3:GetBucketCors", "s3:PutBucketCors", "s3:DeleteBucketCors"]
        Resource = [          "arn:aws:s3:::*"        ]
        Condition = {
          StringEquals = {            "aws:RequestTag/gerencia" = ["${aws:PrincipalTag/gerencia}"]          }        }
      },      {
Sid    = "S3ObjectManagement"
Effect = "Allow"
        Action = ["s3:GetObject", "s3:PutObject", "s3:DeleteObject", "s3:GetObjectVersion", "s3:DeleteObjectVersion", "s3:GetObjectTagging", "s3:PutObjectTagging", "s3:GetObjectAcl", "s3:PutObjectAcl", "s3:ListMultipartUploadParts", "s3:AbortMultipartUpload"]
        Resource = [          "arn:aws:s3:::*/*"        ]
        Condition = {
          StringEquals = {            "s3:ExistingObjectTag/gerencia" = ["${aws:PrincipalTag/gerencia}"]          }        }
      },      {
Sid    = "S3ListAllBuckets"
Effect = "Allow"
        Action = ["s3:ListAllMyBuckets", "s3:GetBucketLocation"]
        Resource = [          "*"        ]
      }    ]
  })

  tags = merge(var.common_tags, {
    Name = "mci-s3-deployment-abac-${var.environment}"
    Type = "Policy"
  })
}