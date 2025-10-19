# Auto-generated policy module: github_deployment_deployment

resource "aws_iam_policy" "github_deployment_deployment" {
  name        = "${var.environment}-github-deployment-deployment"
  description = "Política consolidada para herramientas de deployment (CloudFormation + Terraform State) del SGSI - Consolidación de cloudformation + tfstate"
  path        = "/"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "cloudformation:CreateStack",
        "cloudformation:UpdateStack",
        "cloudformation:DeleteStack",
        "cloudformation:DescribeStacks",
        "cloudformation:DescribeStackEvents",
        "cloudformation:DescribeStackResources",
        "cloudformation:DescribeStackResource",
        "cloudformation:GetTemplate",
        "cloudformation:GetStackPolicy",
        "cloudformation:SetStackPolicy",
        "cloudformation:ValidateTemplate",
        "cloudformation:EstimateTemplateCost",
        "cloudformation:ListStacks",
        "cloudformation:ListStackResources",
        "cloudformation:CancelUpdateStack",
        "cloudformation:ContinueUpdateRollback",
        "cloudformation:CreateChangeSet",
        "cloudformation:DeleteChangeSet",
        "cloudformation:DescribeChangeSet",
        "cloudformation:ExecuteChangeSet",
        "cloudformation:ListChangeSets",
        "cloudformation:SignalResource",
        "cloudformation:DetectStackDrift",
        "cloudformation:DetectStackResourceDrift",
        "cloudformation:DescribeStackDriftDetectionStatus",
        "cloudformation:DescribeStackResourceDrifts"
      ],
      "Sid": "CloudFormationFullAccess",
      "Resource": [
        "arn:aws:cloudformation:*:*:stack/sgsi-*/*",
        "arn:aws:cloudformation:*:*:stack/mci-*/*",
        "arn:aws:cloudformation:*:*:changeSet/*"
      ],
      "Condition": {
        "StringEquals": {
          "aws:RequestedRegion": [
            "us-east-1"
          ]
        }
      }
    },
    {
      "Effect": "Allow",
      "Action": [
        "cloudformation:TagResource",
        "cloudformation:UntagResource",
        "cloudformation:ListTagsForResource"
      ],
      "Sid": "CloudFormationTagging",
      "Resource": [
        "arn:aws:cloudformation:*:*:stack/sgsi-*/*",
        "arn:aws:cloudformation:*:*:stack/mci-*/*"
      ]
    },
    {
      "Effect": "Allow",
      "Action": [
        "s3:GetObject",
        "s3:PutObject",
        "s3:DeleteObject",
        "s3:ListBucket",
        "s3:GetBucketVersioning",
        "s3:GetBucketLocation",
        "s3:GetBucketLogging",
        "s3:GetBucketPolicy",
        "s3:GetBucketTagging",
        "s3:GetBucketAcl",
        "s3:GetBucketCors",
        "s3:GetBucketWebsite",
        "s3:GetBucketNotification",
        "s3:GetEncryptionConfiguration",
        "s3:GetObjectVersion",
        "s3:GetObjectVersionAcl",
        "s3:DeleteObjectVersion",
        "s3:ListBucketVersions",
        "s3:ListBucketMultipartUploads",
        "s3:GetObjectRetention",
        "s3:GetObjectLegalHold",
        "s3:ListMultipartUploadParts",
        "s3:AbortMultipartUpload"
      ],
      "Sid": "TerraformS3StateBackend",
      "Resource": [
        "arn:aws:s3:::terraform-state-bucket-*",
        "arn:aws:s3:::terraform-state-bucket-*/*",
        "arn:aws:s3:::sgsi-terraform-state-*",
        "arn:aws:s3:::sgsi-terraform-state-*/*",
        "arn:aws:s3:::mci-terraform-state-*",
        "arn:aws:s3:::mci-terraform-state-*/*"
      ],
      "Condition": {
        "StringEquals": {
          "aws:RequestedRegion": [
            "us-east-1"
          ]
        }
      }
    },
    {
      "Effect": "Allow",
      "Action": [
        "dynamodb:GetItem",
        "dynamodb:PutItem",
        "dynamodb:DeleteItem",
        "dynamodb:DescribeTable",
        "dynamodb:Query",
        "dynamodb:Scan",
        "dynamodb:UpdateItem",
        "dynamodb:CreateTable",
        "dynamodb:UpdateTable",
        "dynamodb:DeleteTable",
        "dynamodb:DescribeTimeToLive",
        "dynamodb:UpdateTimeToLive",
        "dynamodb:ListTagsOfResource",
        "dynamodb:TagResource",
        "dynamodb:UntagResource"
      ],
      "Sid": "TerraformDynamoDBStateLocking",
      "Resource": [
        "arn:aws:dynamodb:*:*:table/terraform-locks",
        "arn:aws:dynamodb:*:*:table/terraform-state-locks",
        "arn:aws:dynamodb:*:*:table/sgsi-terraform-locks",
        "arn:aws:dynamodb:*:*:table/mci-terraform-locks",
        "arn:aws:dynamodb:*:*:table/terraform-locks/index/*",
        "arn:aws:dynamodb:*:*:table/terraform-state-locks/index/*",
        "arn:aws:dynamodb:*:*:table/sgsi-terraform-locks/index/*",
        "arn:aws:dynamodb:*:*:table/mci-terraform-locks/index/*"
      ],
      "Condition": {
        "StringEquals": {
          "aws:RequestedRegion": [
            "us-east-1"
          ]
        }
      }
    },
    {
      "Effect": "Allow",
      "Action": [
        "s3:ListAllMyBuckets",
        "s3:GetBucketLocation",
        "s3:HeadBucket"
      ],
      "Sid": "TerraformStateBucketReadOnlyAccess",
      "Resource": [
        "*"
      ]
    },
    {
      "Effect": "Allow",
      "Action": [
        "dynamodb:ListTables",
        "dynamodb:DescribeTable"
      ],
      "Sid": "TerraformDynamoDBReadAccess",
      "Resource": [
        "*"
      ]
    },
    {
      "Effect": "Allow",
      "Action": [
        "kms:Decrypt",
        "kms:Encrypt",
        "kms:ReEncrypt*",
        "kms:GenerateDataKey*",
        "kms:DescribeKey",
        "kms:CreateGrant",
        "kms:ListAliases",
        "kms:ListKeys"
      ],
      "Sid": "TerraformStateKMSAccess",
      "Resource": [
        "arn:aws:kms:*:*:key/*",
        "arn:aws:kms:*:*:alias/terraform-state-*",
        "arn:aws:kms:*:*:alias/sgsi-*"
      ],
      "Condition": {
        "StringEquals": {
          "aws:RequestedRegion": [
            "us-east-1"
          ]
        },
        "StringLike": {
          "kms:ViaService": [
            "s3.*.amazonaws.com",
            "dynamodb.*.amazonaws.com"
          ]
        }
      }
    },
    {
      "Effect": "Allow",
      "Action": [
        "sts:GetCallerIdentity",
        "sts:AssumeRole",
        "iam:GetRole",
        "iam:ListRoles",
        "iam:PassRole",
        "logs:CreateLogGroup",
        "logs:CreateLogStream",
        "logs:PutLogEvents",
        "logs:DescribeLogGroups",
        "logs:DescribeLogStreams"
      ],
      "Sid": "DeploymentCoordination",
      "Resource": [
        "arn:aws:iam::*:role/github-*",
        "arn:aws:iam::*:role/terraform-*",
        "arn:aws:iam::*:role/sgsi-*",
        "arn:aws:logs:*:*:log-group:/aws/cloudformation/*",
        "arn:aws:logs:*:*:log-group:/aws/terraform/*",
        "arn:aws:logs:*:*:log-group:/aws/deployment/*"
      ]
    }
  ]
}
EOF

  tags = merge(
    var.common_tags,
    {
      Name          = "${var.environment}-github-deployment-deployment"
      PolicyType    = "Custom"
      Scope         = "Service"
      GeneratedFrom = "github_deployment_deployment.yaml"
    }
  )
}
