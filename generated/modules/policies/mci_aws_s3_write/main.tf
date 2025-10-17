# Data source for current AWS caller identity
data "aws_caller_identity" "current" {}

# mci-aws-s3-write Policy Module - Following ABAC Pattern
# Converted from definitions/policies/execution/mci-aws-s3-write.yaml
resource "aws_iam_policy" "main" {
  name        = "mci-aws-s3-write"
  path        = "/"
  description = var.policy_description

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid      = "WriteObjectsWithABAC"
        Effect   = "Allow"
        Action   = ["s3:PutObject", "s3:PutObjectAcl", "s3:DeleteObject", "s3:AbortMultipartUpload", "s3:ListMultipartUploadParts"]
        Resource = ["arn:aws:s3:::*/*"]
        Condition = {
        StringEquals = { "aws:PrincipalTag/Cuenta" = ["$${aws:ResourceTag/Cuenta}"], "aws:PrincipalTag/Proposito" = ["$${aws:ResourceTag/Proposito}"] } }
        }, {
        Sid      = "ManageMultipartUploadsWithABAC"
        Effect   = "Allow"
        Action   = ["s3:ListBucketMultipartUploads"]
        Resource = ["arn:aws:s3:::*"]
        Condition = {
        StringEquals = { "aws:PrincipalTag/Cuenta" = ["$${aws:ResourceTag/Cuenta}"], "aws:PrincipalTag/Proposito" = ["$${aws:ResourceTag/Proposito}"] } }
    }]
  })

  tags = merge(var.common_tags, {
    Name = "mci-aws-s3-write-${var.environment}"
    Type = "Policy"
  })
}