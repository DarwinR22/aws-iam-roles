# Auto-generated policy module: github_deployment_application

resource "aws_iam_policy" "github_deployment_application" {
  name        = "${var.environment}-github-deployment-application"
  description = "Política consolidada de servicios de aplicación (Lambda, S3, DynamoDB, EventBridge) para GitHub Actions deployment con control ABAC basado en tags"
  path        = "/"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
            "Effect": "Allow",
            "Action": [
                  "lambda:CreateFunction",
                  "lambda:UpdateFunctionCode",
                  "lambda:UpdateFunctionConfiguration",
                  "lambda:DeleteFunction",
                  "lambda:GetFunction",
                  "lambda:GetFunctionConfiguration",
                  "lambda:ListFunctions",
                  "lambda:ListVersionsByFunction",
                  "lambda:PublishVersion",
                  "lambda:CreateAlias",
                  "lambda:UpdateAlias",
                  "lambda:DeleteAlias",
                  "lambda:GetAlias",
                  "lambda:ListAliases",
                  "lambda:CreateEventSourceMapping",
                  "lambda:UpdateEventSourceMapping",
                  "lambda:DeleteEventSourceMapping",
                  "lambda:GetEventSourceMapping",
                  "lambda:ListEventSourceMappings",
                  "lambda:AddPermission",
                  "lambda:RemovePermission",
                  "lambda:GetPolicy",
                  "lambda:TagResource",
                  "lambda:UntagResource",
                  "lambda:ListTags"
            ],
            "Resource": [
                  "*"
            ]
      },
      {
            "Effect": "Allow",
            "Action": [
                  "s3:CreateBucket",
                  "s3:DeleteBucket",
                  "s3:ListBucket",
                  "s3:ListAllMyBuckets",
                  "s3:GetBucketLocation",
                  "s3:GetBucketVersioning",
                  "s3:PutBucketVersioning",
                  "s3:GetBucketEncryption",
                  "s3:PutBucketEncryption",
                  "s3:GetBucketPublicAccessBlock",
                  "s3:PutBucketPublicAccessBlock",
                  "s3:GetBucketNotification",
                  "s3:PutBucketNotification",
                  "s3:GetBucketPolicy",
                  "s3:PutBucketPolicy",
                  "s3:DeleteBucketPolicy",
                  "s3:GetBucketAcl",
                  "s3:PutBucketAcl",
                  "s3:GetBucketTagging",
                  "s3:PutBucketTagging"
            ],
            "Resource": [
                  "arn:aws:s3:::mci-*",
                  "arn:aws:s3:::github-*",
                  "arn:aws:s3:::sgsi-*"
            ],
            "Condition": {
                  "StringEquals": {
                        "aws:RequestedRegion": "us-east-1"
                  }
            }
      },
      {
            "Effect": "Allow",
            "Action": [
                  "s3:GetObject",
                  "s3:PutObject",
                  "s3:DeleteObject",
                  "s3:GetObjectVersion",
                  "s3:DeleteObjectVersion",
                  "s3:GetObjectAttributes",
                  "s3:GetObjectAcl",
                  "s3:PutObjectAcl",
                  "s3:GetObjectTagging",
                  "s3:PutObjectTagging",
                  "s3:DeleteObjectTagging"
            ],
            "Resource": [
                  "arn:aws:s3:::mci-*/*",
                  "arn:aws:s3:::github-*/*",
                  "arn:aws:s3:::sgsi-*/*"
            ],
            "Condition": {
                  "StringEquals": {
                        "aws:RequestedRegion": "us-east-1"
                  }
            }
      },
      {
            "Effect": "Allow",
            "Action": [
                  "dynamodb:CreateTable",
                  "dynamodb:DeleteTable",
                  "dynamodb:DescribeTable",
                  "dynamodb:ListTables",
                  "dynamodb:UpdateTable",
                  "dynamodb:DescribeTimeToLive",
                  "dynamodb:UpdateTimeToLive",
                  "dynamodb:DescribeBackup",
                  "dynamodb:CreateBackup",
                  "dynamodb:DeleteBackup",
                  "dynamodb:ListBackups",
                  "dynamodb:RestoreTableFromBackup",
                  "dynamodb:DescribeContinuousBackups",
                  "dynamodb:UpdateContinuousBackups",
                  "dynamodb:TagResource",
                  "dynamodb:UntagResource",
                  "dynamodb:ListTagsOfResource",
                  "dynamodb:CreateGlobalTable",
                  "dynamodb:UpdateGlobalTable",
                  "dynamodb:DescribeGlobalTable",
                  "dynamodb:ListGlobalTables"
            ],
            "Resource": [
                  "*"
            ],
            "Condition": {
                  "StringEquals": {
                        "aws:RequestedRegion": "us-east-1"
                  },
                  "StringLike": {
                        "dynamodb:TableName": [
                              "mci-*",
                              "github-*",
                              "sgsi-*"
                        ]
                  }
            }
      },
      {
            "Effect": "Allow",
            "Action": [
                  "events:PutRule",
                  "events:DeleteRule",
                  "events:DescribeRule",
                  "events:ListRules",
                  "events:PutTargets",
                  "events:RemoveTargets",
                  "events:ListTargetsByRule",
                  "events:CreateEventBus",
                  "events:DeleteEventBus",
                  "events:DescribeEventBus",
                  "events:ListEventBuses",
                  "events:CreateConnection",
                  "events:UpdateConnection",
                  "events:DeleteConnection",
                  "events:DescribeConnection",
                  "events:ListConnections",
                  "events:PutPermission",
                  "events:RemovePermission",
                  "events:DescribeEventSource",
                  "events:ListEventSources",
                  "events:TagResource",
                  "events:UntagResource",
                  "events:ListTagsForResource"
            ],
            "Resource": [
                  "*"
            ],
            "Condition": {
                  "StringEquals": {
                        "aws:RequestedRegion": "us-east-1"
                  },
                  "StringLike": {
                        "events:RuleName": [
                              "mci-*",
                              "github-*",
                              "sgsi-*"
                        ]
                  }
            }
      },
      {
            "Effect": "Allow",
            "Action": [
                  "states:CreateStateMachine",
                  "states:UpdateStateMachine",
                  "states:DeleteStateMachine",
                  "states:DescribeStateMachine",
                  "states:ListStateMachines",
                  "states:StartExecution",
                  "states:StopExecution",
                  "states:DescribeExecution",
                  "states:ListExecutions",
                  "states:GetExecutionHistory",
                  "states:TagResource",
                  "states:UntagResource",
                  "states:ListTagsForResource"
            ],
            "Resource": [
                  "*"
            ],
            "Condition": {
                  "StringEquals": {
                        "aws:RequestedRegion": "us-east-1"
                  },
                  "StringLike": {
                        "states:StateMachineName": [
                              "mci-*",
                              "github-*",
                              "sgsi-*"
                        ]
                  }
            }
      }
]
  })

  tags = merge(
    var.common_tags,
    {
      Name                = "${var.environment}-github-deployment-application"
      PolicyType         = "Custom"
      Scope              = "Service"
      GeneratedFrom      = "github_deployment_application.yaml"
    }
  )
}
