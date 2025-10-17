# Data source for current AWS caller identity
data "aws_caller_identity" "current" {}

# github-deployment-glue Policy Module - Following ABAC Pattern
# Converted from definitions/policies/deployment\github-deployment-glue.yaml
resource "aws_iam_policy" "main" {
  name        = "github-deployment-glue"
  path        = "/"
  description = var.policy_description

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
Sid    = "GlueFullManagement"
Effect = "Allow"
        Action = ["glue:CreateDatabase", "glue:DeleteDatabase", "glue:GetDatabase", "glue:GetDatabases", "glue:UpdateDatabase", "glue:CreateTable", "glue:DeleteTable", "glue:GetTable", "glue:GetTables", "glue:UpdateTable", "glue:CreatePartition", "glue:DeletePartition", "glue:GetPartition", "glue:GetPartitions", "glue:UpdatePartition", "glue:BatchCreatePartition", "glue:BatchDeletePartition", "glue:BatchGetPartition", "glue:BatchUpdatePartition", "glue:CreateJob", "glue:DeleteJob", "glue:GetJob", "glue:GetJobs", "glue:UpdateJob", "glue:StartJobRun", "glue:StopJobRun", "glue:GetJobRun", "glue:GetJobRuns", "glue:GetJobBookmark", "glue:ResetJobBookmark", "glue:CreateCrawler", "glue:DeleteCrawler", "glue:GetCrawler", "glue:GetCrawlers", "glue:UpdateCrawler", "glue:StartCrawler", "glue:StopCrawler", "glue:GetCrawlerMetrics", "glue:CreateTrigger", "glue:DeleteTrigger", "glue:GetTrigger", "glue:GetTriggers", "glue:UpdateTrigger", "glue:StartTrigger", "glue:StopTrigger", "glue:CreateWorkflow", "glue:DeleteWorkflow", "glue:GetWorkflow", "glue:UpdateWorkflow", "glue:TagResource", "glue:UntagResource", "glue:GetTags"]
        Resource = [          "arn:aws:glue:*:*:catalog",          "arn:aws:glue:*:*:database/*",          "arn:aws:glue:*:*:table/*",          "arn:aws:glue:*:*:job/*",          "arn:aws:glue:*:*:crawler/*",          "arn:aws:glue:*:*:trigger/*",          "arn:aws:glue:*:*:workflow/*"        ]
        Condition = {
          StringEquals = {            "aws:RequestTag/Gerencia" = ["$${aws:PrincipalTag/Gerencia}"]          }        }
      },      {
Sid    = "IAMPassRoleForServices"
Effect = "Allow"
        Action = ["iam:PassRole"]
        Resource = [          "arn:aws:iam::*:role/*"        ]
      },      {
Sid    = "IAMReadOnlyForInfra"
Effect = "Allow"
        Action = ["iam:GetRole", "iam:GetRolePolicy", "iam:GetPolicy", "iam:GetPolicyVersion", "iam:ListAttachedRolePolicies", "iam:ListRolePolicies", "iam:ListPolicyVersions"]
        Resource = [          "arn:aws:iam::*:role/*",          "arn:aws:iam::*:policy/*"        ]
      },      {
Sid    = "KMSFullAccess"
Effect = "Allow"
        Action = ["kms:Decrypt", "kms:Encrypt", "kms:DescribeKey", "kms:GenerateDataKey", "kms:GenerateDataKeyWithoutPlaintext", "kms:CreateGrant", "kms:ListGrants", "kms:ListKeys", "kms:ListAliases", "kms:ReEncrypt"]
        Resource = [          "*"        ]
      },      {
Sid    = "STSAssumeRole"
Effect = "Allow"
        Action = ["sts:AssumeRole", "sts:GetCallerIdentity"]
        Resource = [          "*"        ]
      }    ]
  })

  tags = merge(var.common_tags, {
    Name = "github-deployment-glue-${var.environment}"
    Type = "Policy"
  })
}