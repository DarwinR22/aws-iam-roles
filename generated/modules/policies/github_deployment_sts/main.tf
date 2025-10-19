# Auto-generated policy module: github_deployment_sts

resource "aws_iam_policy" "github_deployment_sts" {
  name        = "${var.environment}-github-deployment-sts"
  description = "Permisos STS necesarios para GitHub Actions OIDC"
  path        = "/"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "sts:AssumeRoleWithWebIdentity",
        "sts:GetCallerIdentity",
        "sts:TagSession"
      ],
      "Sid": "STSAssumeRoleWithWebIdentity",
      "Resource": [
        "*"
      ]
    },
    {
      "Effect": "Allow",
      "Action": [
        "sts:AssumeRole"
      ],
      "Sid": "AssumeOtherRoles",
      "Resource": [
        "arn:aws:iam::*:role/*"
      ],
      "Condition": {
        "StringEquals": {
          "aws:RequestedRegion": [
            "us-east-1"
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
      Name                = "${var.environment}-github-deployment-sts"
      PolicyType         = "Custom"
      Scope              = "Service"
      GeneratedFrom      = "github_deployment_sts.yaml"
    }
  )
}
