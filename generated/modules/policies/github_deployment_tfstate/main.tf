# Auto-generated policy module: github_deployment_tfstate

resource "aws_iam_policy" "github_deployment_tfstate" {
  name        = "${var.environment}-github-deployment-tfstate"
  description = "Gestión de estado de Terraform en S3 y locks en DynamoDB (sin ABAC - requerido para CI/CD)"
  path        = "/"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
            "Effect": "Allow",
            "Action": [
                  "s3:GetObject",
                  "s3:PutObject",
                  "s3:DeleteObject",
                  "s3:ListBucket",
                  "s3:GetBucketVersioning",
                  "s3:GetBucketLocation",
                  "s3:ListBucketVersions"
            ],
            "Resource": [
                  "arn:aws:s3:::*-tfstate-*",
                  "arn:aws:s3:::*-tfstate-*/*"
            ]
      },
      {
            "Effect": "Allow",
            "Action": [
                  "dynamodb:GetItem",
                  "dynamodb:PutItem",
                  "dynamodb:DeleteItem",
                  "dynamodb:DescribeTable",
                  "dynamodb:DescribeContinuousBackups"
            ],
            "Resource": [
                  "arn:aws:dynamodb:*:*:table/*-terraform-lock*",
                  "arn:aws:dynamodb:*:*:table/*-tfstate-lock*"
            ]
      }
]
  })

  tags = merge(
    var.common_tags,
    {
      Name                = "${var.environment}-github-deployment-tfstate"
      PolicyType         = "Custom"
      Scope              = "Service"
      GeneratedFrom      = "github_deployment_tfstate.yaml"
    }
  )
}
