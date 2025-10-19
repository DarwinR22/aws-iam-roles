# Auto-generated policy module: github_deployment_glue

resource "aws_iam_policy" "github_deployment_glue" {
  name        = "${var.environment}-github-deployment-glue"
  description = "Gestión de Glue, IAM PassRole y KMS para despliegue de infraestructura con ABAC"
  path        = "/"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "glue:CreateDatabase",
        "glue:DeleteDatabase",
        "glue:GetDatabase",
        "glue:GetDatabases",
        "glue:UpdateDatabase",
        "glue:CreateTable",
        "glue:DeleteTable",
        "glue:GetTable",
        "glue:GetTables",
        "glue:UpdateTable",
        "glue:CreatePartition",
        "glue:DeletePartition",
        "glue:GetPartition",
        "glue:GetPartitions",
        "glue:UpdatePartition",
        "glue:BatchCreatePartition",
        "glue:BatchDeletePartition",
        "glue:BatchGetPartition",
        "glue:BatchUpdatePartition",
        "glue:CreateJob",
        "glue:DeleteJob",
        "glue:GetJob",
        "glue:GetJobs",
        "glue:UpdateJob",
        "glue:StartJobRun",
        "glue:StopJobRun",
        "glue:GetJobRun",
        "glue:GetJobRuns",
        "glue:GetJobBookmark",
        "glue:ResetJobBookmark",
        "glue:CreateCrawler",
        "glue:DeleteCrawler",
        "glue:GetCrawler",
        "glue:GetCrawlers",
        "glue:UpdateCrawler",
        "glue:StartCrawler",
        "glue:StopCrawler",
        "glue:GetCrawlerMetrics",
        "glue:CreateTrigger",
        "glue:DeleteTrigger",
        "glue:GetTrigger",
        "glue:GetTriggers",
        "glue:UpdateTrigger",
        "glue:StartTrigger",
        "glue:StopTrigger",
        "glue:CreateWorkflow",
        "glue:DeleteWorkflow",
        "glue:GetWorkflow",
        "glue:UpdateWorkflow",
        "glue:TagResource",
        "glue:UntagResource",
        "glue:GetTags"
      ],
      "Sid": "GlueFullManagement",
      "Resource": [
        "arn:aws:glue:*:*:catalog",
        "arn:aws:glue:*:*:database/*",
        "arn:aws:glue:*:*:table/*",
        "arn:aws:glue:*:*:job/*",
        "arn:aws:glue:*:*:crawler/*",
        "arn:aws:glue:*:*:trigger/*",
        "arn:aws:glue:*:*:workflow/*"
      ]
    },
    {
      "Effect": "Allow",
      "Action": [
        "iam:PassRole"
      ],
      "Sid": "IAMPassRoleForServices",
      "Resource": [
        "arn:aws:iam::*:role/*"
      ],
      "Condition": {
        "StringEquals": {
          "iam:PassedToService": [
            "lambda.amazonaws.com",
            "glue.amazonaws.com",
            "states.amazonaws.com",
            "events.amazonaws.com"
          ]
        }
      }
    },
    {
      "Effect": "Allow",
      "Action": [
        "iam:GetRole",
        "iam:GetRolePolicy",
        "iam:GetPolicy",
        "iam:GetPolicyVersion",
        "iam:ListAttachedRolePolicies",
        "iam:ListRolePolicies",
        "iam:ListPolicyVersions"
      ],
      "Sid": "IAMReadOnlyForInfra",
      "Resource": [
        "arn:aws:iam::*:role/*",
        "arn:aws:iam::*:policy/*"
      ]
    },
    {
      "Effect": "Allow",
      "Action": [
        "kms:Decrypt",
        "kms:Encrypt",
        "kms:DescribeKey",
        "kms:GenerateDataKey",
        "kms:GenerateDataKeyWithoutPlaintext",
        "kms:CreateGrant",
        "kms:ListGrants",
        "kms:ListKeys",
        "kms:ListAliases",
        "kms:ReEncrypt"
      ],
      "Sid": "KMSFullAccess",
      "Resource": [
        "*"
      ]
    },
    {
      "Effect": "Allow",
      "Action": [
        "sts:AssumeRole",
        "sts:GetCallerIdentity"
      ],
      "Sid": "STSAssumeRole",
      "Resource": [
        "*"
      ]
    }
  ]
}
EOF

  tags = merge(
    var.common_tags,
    {
      Name                = "${var.environment}-github-deployment-glue"
      PolicyType         = "Custom"
      Scope              = "Service"
      GeneratedFrom      = "github_deployment_glue.yaml"
    }
  )
}
