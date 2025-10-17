# Data source for current AWS caller identity
data "aws_caller_identity" "current" {}

# mci-aws-glue-catalog-write Policy Module - Following ABAC Pattern
# Converted from definitions/policies/execution/mci-aws-glue-catalog-write.yaml
resource "aws_iam_policy" "main" {
  name        = "mci-aws-glue-catalog-write"
  path        = "/"
  description = var.policy_description

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid      = "WriteGlueCatalogWithABAC"
        Effect   = "Allow"
        Action   = ["glue:CreateDatabase", "glue:UpdateDatabase", "glue:DeleteDatabase", "glue:CreateTable", "glue:UpdateTable", "glue:DeleteTable", "glue:BatchCreatePartition", "glue:CreatePartition", "glue:UpdatePartition", "glue:DeletePartition", "glue:BatchDeletePartition", "glue:BatchUpdatePartition"]
        Resource = ["arn:aws:glue:*:*:catalog", "arn:aws:glue:*:*:database/*", "arn:aws:glue:*:*:table/*/*"]
        Condition = {
        StringEquals = { "aws:PrincipalTag/Cuenta" = ["$${aws:ResourceTag/Cuenta}"] } }
    }]
  })

  tags = merge(var.common_tags, {
    Name = "mci-aws-glue-catalog-write-${var.environment}"
    Type = "Policy"
  })
}