# Data source for current AWS caller identity
data "aws_caller_identity" "current" {}

# mci-aws-glue-catalog-read Policy Module - Following ABAC Pattern
# Converted from definitions/policies/execution/mci-aws-glue-catalog-read.yaml
resource "aws_iam_policy" "main" {
  name        = "mci-aws-glue-catalog-read"
  path        = "/"
  description = var.policy_description

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid      = "ReadGlueCatalogWithABAC"
        Effect   = "Allow"
        Action   = ["glue:GetDatabase", "glue:GetDatabases", "glue:GetTable", "glue:GetTables", "glue:GetPartition", "glue:GetPartitions", "glue:BatchGetPartition", "glue:GetTableVersion", "glue:GetTableVersions", "glue:SearchTables"]
        Resource = ["arn:aws:glue:*:*:catalog", "arn:aws:glue:*:*:database/*", "arn:aws:glue:*:*:table/*/*"]
        Condition = {
        StringEquals = { "aws:PrincipalTag/Cuenta" = ["$${aws:ResourceTag/Cuenta}"] } }
    }]
  })

  tags = merge(var.common_tags, {
    Name = "mci-aws-glue-catalog-read-${var.environment}"
    Type = "Policy"
  })
}