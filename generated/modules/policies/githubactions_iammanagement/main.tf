# Data source for current AWS caller identity
data "aws_caller_identity" "current" {}

# GithubActions-IAMManagement Policy Module - Following ABAC Pattern
# Converted from definitions/policies/deployment\iam-management.yaml
resource "aws_iam_policy" "main" {
  name_prefix = "githubactions-iammanagement-"
  path        = "/policies/"
  description = var.policy_description

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
Sid    = "IAMReadPermissions"
Effect = "Allow"
        Action = ["iam:GetRole", "iam:GetRolePolicy", "iam:GetPolicy", "iam:GetPolicyVersion", "iam:ListRoles", "iam:ListPolicies", "iam:ListPolicyVersions", "iam:ListAttachedRolePolicies", "iam:ListRolePolicies", "iam:ListInstanceProfilesForRole", "iam:ListRoleTags"]
        Resource = ["*"]
      },      {
Sid    = "IAMRoleManagement"
Effect = "Allow"
        Action = ["iam:CreateRole", "iam:DeleteRole", "iam:UpdateRole", "iam:TagRole", "iam:UntagRole", "iam:PutRolePolicy", "iam:DeleteRolePolicy"]
        Resource = ["arn:aws:iam::${account_id}:role/${role_prefix}*"]
      },      {
Sid    = "IAMPolicyManagement"
Effect = "Allow"
        Action = ["iam:CreatePolicy", "iam:DeletePolicy", "iam:CreatePolicyVersion", "iam:DeletePolicyVersion", "iam:SetDefaultPolicyVersion"]
        Resource = ["arn:aws:iam::${account_id}:policy/${policy_prefix}*"]
      },      {
Sid    = "IAMAttachmentManagement"
Effect = "Allow"
        Action = ["iam:AttachRolePolicy", "iam:DetachRolePolicy", "iam:PassRole"]
        Resource = ["arn:aws:iam::${account_id}:role/${role_prefix}*", "arn:aws:iam::${account_id}:policy/${policy_prefix}*", "arn:aws:iam::aws:policy/*"]
      }    ]
  })

  tags = merge(var.common_tags, {
    Name = "githubactions-iammanagement-${var.environment}"
    Type = "Policy"
  })
}