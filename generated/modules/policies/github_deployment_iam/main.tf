# Data source for current AWS caller identity
data "aws_caller_identity" "current" {}

# github-deployment-iam Policy Module - Following ABAC Pattern
# Converted from definitions/policies/deployment\github-deployment-iam.yaml
resource "aws_iam_policy" "main" {
  name        = "github-deployment-iam"
  path        = "/"
  description = var.policy_description

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
Sid    = "IAMRoleFullManagement"
Effect = "Allow"
        Action = ["iam:CreateRole", "iam:DeleteRole", "iam:UpdateRole", "iam:UpdateRoleDescription", "iam:GetRole", "iam:ListRoles", "iam:ListRoleTags", "iam:TagRole", "iam:UntagRole", "iam:UpdateAssumeRolePolicy"]
        Resource = [          "arn:aws:iam::*:role/*"        ]
      },      {
Sid    = "IAMPolicyFullManagement"
Effect = "Allow"
        Action = ["iam:CreatePolicy", "iam:DeletePolicy", "iam:GetPolicy", "iam:GetPolicyVersion", "iam:ListPolicies", "iam:ListPolicyVersions", "iam:CreatePolicyVersion", "iam:DeletePolicyVersion", "iam:SetDefaultPolicyVersion", "iam:TagPolicy", "iam:UntagPolicy", "iam:ListPolicyTags"]
        Resource = [          "arn:aws:iam::*:policy/*"        ]
      },      {
Sid    = "IAMRolePolicyAttachment"
Effect = "Allow"
        Action = ["iam:AttachRolePolicy", "iam:DetachRolePolicy", "iam:ListAttachedRolePolicies", "iam:PutRolePolicy", "iam:DeleteRolePolicy", "iam:GetRolePolicy", "iam:ListRolePolicies"]
        Resource = [          "arn:aws:iam::*:role/*"        ]
      },      {
Sid    = "IAMPassRoleForServices"
Effect = "Allow"
        Action = ["iam:PassRole"]
        Resource = [          "arn:aws:iam::*:role/*"        ]
      },      {
Sid    = "IAMReadOnlyAccess"
Effect = "Allow"
        Action = ["iam:ListInstanceProfiles", "iam:GetAccountSummary", "iam:GetAccountPasswordPolicy", "iam:ListUsers", "iam:ListGroups", "iam:ListAccountAliases"]
        Resource = [          "*"        ]
      }    ]
  })

  tags = merge(var.common_tags, {
    Name = "github-deployment-iam-${var.environment}"
    Type = "Policy"
  })
}