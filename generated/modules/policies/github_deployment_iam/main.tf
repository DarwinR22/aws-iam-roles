# Auto-generated policy module: github_deployment_iam

resource "aws_iam_policy" "github_deployment_iam" {
  name        = "${var.environment}-github-deployment-iam"
  description = "Gestión completa de IAM y STS para despliegues del SGSI - Consolidación de iam + sts"
  path        = "/"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "iam:CreateRole",
        "iam:DeleteRole",
        "iam:UpdateRole",
        "iam:UpdateRoleDescription",
        "iam:GetRole",
        "iam:ListRoles",
        "iam:ListRoleTags",
        "iam:TagRole",
        "iam:UntagRole",
        "iam:UpdateAssumeRolePolicy"
      ],
      "Sid": "IAMRoleFullManagement",
      "Resource": [
        "arn:aws:iam::*:role/*"
      ]
    },
    {
      "Effect": "Allow",
      "Action": [
        "iam:CreatePolicy",
        "iam:DeletePolicy",
        "iam:GetPolicy",
        "iam:GetPolicyVersion",
        "iam:ListPolicies",
        "iam:ListPolicyVersions",
        "iam:CreatePolicyVersion",
        "iam:DeletePolicyVersion",
        "iam:SetDefaultPolicyVersion",
        "iam:TagPolicy",
        "iam:UntagPolicy",
        "iam:ListPolicyTags"
      ],
      "Sid": "IAMPolicyFullManagement",
      "Resource": [
        "arn:aws:iam::*:policy/*"
      ]
    },
    {
      "Effect": "Allow",
      "Action": [
        "iam:AttachRolePolicy",
        "iam:DetachRolePolicy",
        "iam:ListAttachedRolePolicies",
        "iam:PutRolePolicy",
        "iam:DeleteRolePolicy",
        "iam:GetRolePolicy",
        "iam:ListRolePolicies"
      ],
      "Sid": "IAMRolePolicyAttachment",
      "Resource": [
        "arn:aws:iam::*:role/*"
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
      ]
    },
    {
      "Effect": "Allow",
      "Action": [
        "iam:ListInstanceProfiles",
        "iam:ListInstanceProfilesForRole",
        "iam:GetAccountSummary",
        "iam:GetAccountPasswordPolicy",
        "iam:ListUsers",
        "iam:ListGroups",
        "iam:ListAccountAliases"
      ],
      "Sid": "IAMReadOnlyAccess",
      "Resource": [
        "*"
      ]
    },
    {
      "Effect": "Allow",
      "Action": [
        "iam:CreateOpenIDConnectProvider",
        "iam:DeleteOpenIDConnectProvider",
        "iam:GetOpenIDConnectProvider",
        "iam:ListOpenIDConnectProviders",
        "iam:UpdateOpenIDConnectProviderThumbprint",
        "iam:TagOpenIDConnectProvider",
        "iam:UntagOpenIDConnectProvider",
        "iam:ListOpenIDConnectProviderTags"
      ],
      "Sid": "IAMOIDCProviderManagement",
      "Resource": [
        "arn:aws:iam::*:oidc-provider/*"
      ]
    },
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
      Name                = "${var.environment}-github-deployment-iam"
      PolicyType         = "Custom"
      Scope              = "Service"
      GeneratedFrom      = "github_deployment_iam.yaml"
    }
  )
}
