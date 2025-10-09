# Data source for current AWS caller identity
data "aws_caller_identity" "current" {}

# MCI-DynamoDB-DeploymentABAC Policy Module - Following ABAC Pattern
# Converted from definitions/policies/deployment/MCI-DynamoDB-DeploymentABAC.yaml
resource "aws_iam_policy" "main" {
  name        = "mci-dynamodb-deploymentabac"
  path        = "/"
  description = var.policy_description

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid      = "DynamoDBTableManagement"
        Effect   = "Allow"
        Action   = ["dynamodb:CreateTable", "dynamodb:DeleteTable", "dynamodb:DescribeTable", "dynamodb:UpdateTable", "dynamodb:ListTables", "dynamodb:DescribeTimeToLive", "dynamodb:UpdateTimeToLive", "dynamodb:ListTagsOfResource", "dynamodb:TagResource", "dynamodb:UntagResource", "dynamodb:DescribeContinuousBackups", "dynamodb:UpdateContinuousBackups", "dynamodb:DescribeKinesisStreamingDestination"]
        Resource = ["arn:aws:dynamodb:*:*:table/*"]
        }, {
        Sid      = "DynamoDBDataAccess"
        Effect   = "Allow"
        Action   = ["dynamodb:GetItem", "dynamodb:PutItem", "dynamodb:DeleteItem", "dynamodb:UpdateItem", "dynamodb:Query", "dynamodb:Scan", "dynamodb:BatchGetItem", "dynamodb:BatchWriteItem"]
        Resource = ["arn:aws:dynamodb:*:*:table/*"]
        }, {
        Sid      = "DynamoDBBackupManagement"
        Effect   = "Allow"
        Action   = ["dynamodb:CreateBackup", "dynamodb:DeleteBackup", "dynamodb:DescribeBackup", "dynamodb:ListBackups", "dynamodb:RestoreTableFromBackup", "dynamodb:RestoreTableToPointInTime"]
        Resource = ["arn:aws:dynamodb:*:*:table/*/backup/*"]
        }, {
        Sid      = "DynamoDBStreamAccess"
        Effect   = "Allow"
        Action   = ["dynamodb:DescribeStream", "dynamodb:GetRecords", "dynamodb:GetShardIterator", "dynamodb:ListStreams"]
        Resource = ["arn:aws:dynamodb:*:*:table/*/stream/*"]
    }]
  })

  tags = merge(var.common_tags, {
    Name = "mci-dynamodb-deploymentabac-${var.environment}"
    Type = "Policy"
  })
}