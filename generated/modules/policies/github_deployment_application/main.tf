# Auto-generated policy module: github_deployment_application

resource "aws_iam_policy" "github_deployment_application" {
  name        = "${var.environment}-github-deployment-application"
  description = "Política consolidada de servicios de aplicación (Lambda, S3, DynamoDB, EventBridge) para GitHub Actions deployment con control ABAC basado en tags"
  path        = "/"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
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
      "Sid": "LambdaManagementWithABAC",
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
      "Sid": "S3BucketManagementWithABAC",
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
      "Sid": "S3ObjectManagementWithABAC",
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
      "Sid": "DynamoDBManagementWithABAC",
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
        "elasticloadbalancing:CreateLoadBalancer",
        "elasticloadbalancing:DeleteLoadBalancer",
        "elasticloadbalancing:DescribeLoadBalancers",
        "elasticloadbalancing:DescribeLoadBalancerAttributes",
        "elasticloadbalancing:ModifyLoadBalancerAttributes",
        "elasticloadbalancing:SetLoadBalancerPoliciesOfListener",
        "elasticloadbalancing:CreateTargetGroup",
        "elasticloadbalancing:DeleteTargetGroup",
        "elasticloadbalancing:DescribeTargetGroups",
        "elasticloadbalancing:DescribeTargetGroupAttributes",
        "elasticloadbalancing:ModifyTargetGroup",
        "elasticloadbalancing:ModifyTargetGroupAttributes",
        "elasticloadbalancing:DescribeTargetHealth",
        "elasticloadbalancing:RegisterTargets",
        "elasticloadbalancing:DeregisterTargets",
        "elasticloadbalancing:CreateListener",
        "elasticloadbalancing:DeleteListener",
        "elasticloadbalancing:DescribeListeners",
        "elasticloadbalancing:ModifyListener",
        "elasticloadbalancing:DescribeListenerCertificates",
        "elasticloadbalancing:AddListenerCertificates",
        "elasticloadbalancing:RemoveListenerCertificates",
        "elasticloadbalancing:CreateRule",
        "elasticloadbalancing:DeleteRule",
        "elasticloadbalancing:DescribeRules",
        "elasticloadbalancing:ModifyRule",
        "elasticloadbalancing:SetRulePriorities",
        "elasticloadbalancing:DescribeSSLPolicies",
        "elasticloadbalancing:AddTags",
        "elasticloadbalancing:RemoveTags",
        "elasticloadbalancing:DescribeTags"
      ],
      "Sid": "ELBManagementWithABAC",
      "Resource": [
        "*"
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
        "autoscaling:CreateAutoScalingGroup",
        "autoscaling:UpdateAutoScalingGroup",
        "autoscaling:DeleteAutoScalingGroup",
        "autoscaling:DescribeAutoScalingGroups",
        "autoscaling:DescribeAutoScalingInstances",
        "autoscaling:CreateLaunchConfiguration",
        "autoscaling:DeleteLaunchConfiguration",
        "autoscaling:DescribeLaunchConfigurations",
        "autoscaling:PutScalingPolicy",
        "autoscaling:DeletePolicy",
        "autoscaling:DescribePolicies",
        "autoscaling:ExecutePolicy",
        "autoscaling:PutScheduledUpdateGroupAction",
        "autoscaling:DeleteScheduledAction",
        "autoscaling:DescribeScheduledActions",
        "autoscaling:PutLifecycleHook",
        "autoscaling:DeleteLifecycleHook",
        "autoscaling:DescribeLifecycleHooks",
        "autoscaling:CompleteLifecycleAction",
        "autoscaling:AttachInstances",
        "autoscaling:DetachInstances",
        "autoscaling:SetDesiredCapacity",
        "autoscaling:SetInstanceHealth",
        "autoscaling:TerminateInstanceInAutoScalingGroup",
        "autoscaling:AttachLoadBalancers",
        "autoscaling:DetachLoadBalancers",
        "autoscaling:AttachLoadBalancerTargetGroups",
        "autoscaling:DetachLoadBalancerTargetGroups",
        "autoscaling:DescribeLoadBalancers",
        "autoscaling:DescribeLoadBalancerTargetGroups",
        "autoscaling:CreateOrUpdateTags",
        "autoscaling:DeleteTags",
        "autoscaling:DescribeTags",
        "autoscaling:PutNotificationConfiguration",
        "autoscaling:DeleteNotificationConfiguration",
        "autoscaling:DescribeNotificationConfigurations",
        "autoscaling:EnableMetricsCollection",
        "autoscaling:DisableMetricsCollection",
        "autoscaling:DescribeMetricCollectionTypes",
        "autoscaling:StartInstanceRefresh",
        "autoscaling:CancelInstanceRefresh",
        "autoscaling:DescribeInstanceRefreshes"
      ],
      "Sid": "AutoScalingWithABAC",
      "Resource": [
        "*"
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
        "ec2:CreateLaunchTemplate",
        "ec2:CreateLaunchTemplateVersion",
        "ec2:DeleteLaunchTemplate",
        "ec2:DeleteLaunchTemplateVersions",
        "ec2:DescribeLaunchTemplates",
        "ec2:DescribeLaunchTemplateVersions",
        "ec2:GetLaunchTemplateData",
        "ec2:ModifyLaunchTemplate",
        "ec2:DescribeImages",
        "ec2:DescribeInstanceTypes",
        "ec2:DescribeInstanceAttribute",
        "ec2:DescribeInstances",
        "ec2:DescribeSecurityGroups",
        "ec2:DescribeSubnets",
        "ec2:DescribeVpcs",
        "ec2:DescribeKeyPairs",
        "ec2:CreateTags",
        "ec2:DeleteTags",
        "ec2:DescribeTags"
      ],
      "Sid": "EC2LaunchTemplateManagement",
      "Resource": [
        "*"
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
        "iam:PassRole"
      ],
      "Sid": "IAMPassRoleForEC2AndASG",
      "Resource": [
        "arn:aws:iam::*:role/sgsi-*",
        "arn:aws:iam::*:role/mci-*",
        "arn:aws:iam::*:role/github-*"
      ],
      "Condition": {
        "StringEquals": {
          "iam:PassedToService": [
            "ec2.amazonaws.com",
            "autoscaling.amazonaws.com"
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
      "Sid": "EventBridgeManagementWithABAC",
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
      "Sid": "StepFunctionsManagementWithABAC",
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
}
EOF

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
