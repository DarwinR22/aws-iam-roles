# Data source for current AWS caller identity
data "aws_caller_identity" "current" {}

# github-deployment-lambda-abac Policy Module - Following ABAC Pattern
# Converted from definitions/policies/deployment/github-deployment-lambda-abac.yaml
resource "aws_iam_policy" "main" {
  name        = "mci-github-deployment-lambda-abac"
  path        = "/policies/"
  description = var.policy_description

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid      = "LambdaFullDeployment"
        Effect   = "Allow"
        Action   = ["lambda:CreateFunction", "lambda:UpdateFunctionCode", "lambda:UpdateFunctionConfiguration", "lambda:DeleteFunction", "lambda:GetFunction", "lambda:GetFunctionConfiguration", "lambda:ListFunctions", "lambda:PublishVersion", "lambda:CreateAlias", "lambda:UpdateAlias", "lambda:DeleteAlias", "lambda:GetAlias", "lambda:ListAliases", "lambda:AddPermission", "lambda:RemovePermission", "lambda:GetPolicy", "lambda:TagResource", "lambda:UntagResource", "lambda:ListTags", "lambda:InvokeFunction"]
        Resource = ["arn:aws:lambda:*:*:function:*"]
        Condition = {
        StringEquals = { "aws:RequestTag/gerencia" = ["$${aws:PrincipalTag/gerencia}"], "aws:ResourceTag/gerencia" = ["$${aws:PrincipalTag/gerencia}"] } }
        }, {
        Sid      = "LambdaLayersManagement"
        Effect   = "Allow"
        Action   = ["lambda:PublishLayerVersion", "lambda:DeleteLayerVersion", "lambda:GetLayerVersion", "lambda:ListLayers", "lambda:ListLayerVersions"]
        Resource = ["arn:aws:lambda:*:*:layer:*"]
        }, {
        Sid      = "LambdaEventSourceMapping"
        Effect   = "Allow"
        Action   = ["lambda:CreateEventSourceMapping", "lambda:DeleteEventSourceMapping", "lambda:UpdateEventSourceMapping", "lambda:GetEventSourceMapping", "lambda:ListEventSourceMappings"]
        Resource = ["*"]
    }]
  })

  tags = merge(var.common_tags, {
    Name = "github-deployment-lambda-abac-${var.environment}"
    Type = "Policy"
  })
}