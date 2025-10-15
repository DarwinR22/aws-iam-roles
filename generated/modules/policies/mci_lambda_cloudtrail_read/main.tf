# Data source for current AWS caller identity
data "aws_caller_identity" "current" {}

# mci-lambda-cloudtrail-read Policy Module - Following ABAC Pattern
# Converted from definitions/policies/execution/mci-lambda-cloudtrail-read.yaml
resource "aws_iam_policy" "main" {
  name        = "mci-lambda-cloudtrail-read"
  path        = "/"
  description = var.policy_description

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid      = "ReadCloudTrailWithABAC"
        Effect   = "Allow"
        Action   = ["cloudtrail:LookupEvents", "cloudtrail:GetEventSelectors"]
        Resource = ["*"]
        Condition = {
        StringEquals = { "aws:PrincipalTag/Gerencia" = var.abac_conditions["aws:PrincipalTag/Gerencia"], "aws:PrincipalTag/Dominio" = ["Security", "Serverless"] } }
    }]
  })

  tags = merge(var.common_tags, {
    Name = "mci-lambda-cloudtrail-read-${var.environment}"
    Type = "Policy"
  })
}