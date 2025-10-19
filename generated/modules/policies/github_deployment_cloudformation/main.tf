# Auto-generated policy module: github_deployment_cloudformation

resource "aws_iam_policy" "github_deployment_cloudformation" {
  name        = "${var.environment}-github-deployment-cloudformation"
  description = "Permisos para despliegues con CloudFormation, KMS encryption y servicios adicionales"
  path        = "/"

  policy = {
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Effect" : "Allow",
        "Action" : [
          "cloudformation:CreateStack",
          "cloudformation:UpdateStack",
          "cloudformation:DeleteStack",
          "cloudformation:DescribeStacks",
          "cloudformation:DescribeStackEvents",
          "cloudformation:DescribeStackResources",
          "cloudformation:GetTemplate",
          "cloudformation:ListStacks",
          "cloudformation:ValidateTemplate",
          "cloudformation:CreateChangeSet",
          "cloudformation:DeleteChangeSet",
          "cloudformation:DescribeChangeSet",
          "cloudformation:ExecuteChangeSet",
          "cloudformation:ListChangeSets",
          "cloudformation:TagResource",
          "cloudformation:UntagResource",
          "cloudformation:ListStackResources"
        ],
        "Sid" : "CloudFormationFullAccess",
        "Resource" : [
          "arn:aws:cloudformation:*:*:stack/*",
          "arn:aws:cloudformation:*:*:changeSet/*"
        ]
      },
      {
        "Effect" : "Allow",
        "Action" : [
          "cloudformation:ListStacks",
          "cloudformation:ListExports",
          "cloudformation:ListImports",
          "cloudformation:DescribeAccountLimits"
        ],
        "Sid" : "CloudFormationListOperations",
        "Resource" : [
          "*"
        ]
      },
      {
        "Effect" : "Allow",
        "Action" : [
          "kms:Decrypt",
          "kms:Encrypt",
          "kms:GenerateDataKey",
          "kms:GenerateDataKeyWithoutPlaintext",
          "kms:ReEncrypt*",
          "kms:DescribeKey",
          "kms:CreateGrant",
          "kms:ListGrants",
          "kms:RevokeGrant"
        ],
        "Sid" : "KMSEncryptionForServices",
        "Resource" : [
          "arn:aws:kms:*:*:key/*"
        ],
        "Condition" : [
          {
            "test" : "StringEquals",
            "variable" : "kms:ViaService",
            "values" : [
              "s3.us-east-1.amazonaws.com",
              "dynamodb.us-east-1.amazonaws.com"
            ]
          }
        ]
      },
      {
        "Effect" : "Allow",
        "Action" : [
          "kms:ListKeys",
          "kms:ListAliases"
        ],
        "Sid" : "KMSListKeys",
        "Resource" : [
          "*"
        ]
      },
      {
        "Effect" : "Allow",
        "Action" : [
          "sts:GetCallerIdentity"
        ],
        "Sid" : "STSGetCallerIdentity",
        "Resource" : [
          "*"
        ]
      }
    ]
  }

  tags = merge(
    var.common_tags,
    {
      Name          = "${var.environment}-github-deployment-cloudformation"
      PolicyType    = "Custom"
      Scope         = "Service"
      GeneratedFrom = "github_deployment_cloudformation.yaml"
    }
  )
}
