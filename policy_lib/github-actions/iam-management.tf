# MCI-GitHubActions-IAMManagement Policy  
# ======================================
# Política para gestión de roles y políticas IAM desde GitHub Actions

data "aws_iam_policy_document" "github_actions_iam_management" {
  # Gestión de Roles IAM
  statement {
    sid    = "IAMRoleManagement"
    effect = "Allow"
    actions = [
      # Crear y gestionar roles
      "iam:CreateRole",
      "iam:UpdateRole", 
      "iam:DeleteRole",
      "iam:GetRole",
      "iam:ListRoles",
      
      # Gestión de assume role policies
      "iam:UpdateAssumeRolePolicy",
      
      # Tagging de roles
      "iam:TagRole",
      "iam:UntagRole",
      "iam:ListRoleTags"
    ]
    resources = [
      "arn:aws:iam::393209814297:role/MCI/*",
      "arn:aws:iam::393209814297:role/GitHubActions/*"
    ]
  }
  
  # Gestión de Políticas IAM
  statement {
    sid    = "IAMPolicyManagement"
    effect = "Allow" 
    actions = [
      # Crear y gestionar políticas managed
      "iam:CreatePolicy",
      "iam:DeletePolicy",
      "iam:GetPolicy",
      "iam:GetPolicyVersion", 
      "iam:ListPolicies",
      "iam:ListPolicyVersions",
      "iam:CreatePolicyVersion",
      "iam:DeletePolicyVersion",
      "iam:SetDefaultPolicyVersion",
      
      # Tagging de políticas
      "iam:TagPolicy",
      "iam:UntagPolicy",
      "iam:ListPolicyTags"
    ]
    resources = [
      "arn:aws:iam::393209814297:policy/MCI/*",
      "arn:aws:iam::393209814297:policy/Platform-*", 
      "arn:aws:iam::393209814297:policy/App-*"
    ]
  }
  
  # Adjuntar/Desadjuntar políticas a roles
  statement {
    sid    = "IAMPolicyAttachment"
    effect = "Allow"
    actions = [
      "iam:AttachRolePolicy", 
      "iam:DetachRolePolicy",
      "iam:ListAttachedRolePolicies"
    ]
    resources = [
      "arn:aws:iam::393209814297:role/MCI/*",
      "arn:aws:iam::393209814297:role/GitHubActions/*"
    ]
  }
  
  # Políticas inline (para migración gradual)
  statement {
    sid    = "IAMInlinePolicyManagement"
    effect = "Allow"
    actions = [
      "iam:PutRolePolicy",
      "iam:GetRolePolicy", 
      "iam:DeleteRolePolicy",
      "iam:ListRolePolicies"
    ]
    resources = [
      "arn:aws:iam::393209814297:role/GitHubActions/*"
    ]
  }
  
  # Simulación de políticas (testing) - Restringido a roles MCI
  statement {
    sid    = "IAMPolicySimulation"
    effect = "Allow"
    actions = [
      "iam:SimulatePrincipalPolicy",
      "iam:SimulateCustomPolicy"
    ]
    resources = [
      "arn:aws:iam::393209814297:role/MCI/*",
      "arn:aws:iam::393209814297:role/GitHubActions/*"
    ]
  }
  

}