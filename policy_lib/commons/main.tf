# policy_lib/commons/main.tf
# ================================
# COMMON POLICY BUILDING BLOCKS
# ================================

# SECURE SERVICE TRUST POLICIES
data "aws_iam_policy_document" "lambda_service_trust" {
  statement {
    sid    = "LambdaServiceTrust"
    effect = "Allow"
    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }
    actions = ["sts:AssumeRole"]
    
    condition {
      test     = "StringEquals"
      variable = "aws:SourceAccount"
      values   = ["393209814297"]
    }
    
    condition {
      test     = "ArnLike"
      variable = "aws:SourceArn"
      values   = ["arn:aws:lambda:us-east-1:393209814297:function:*"]
    }
  }
}

data "aws_iam_policy_document" "ecs_service_trust" {
  statement {
    sid    = "ECSServiceTrust"
    effect = "Allow"
    principals {
      type        = "Service"
      identifiers = ["ecs-tasks.amazonaws.com"]
    }
    actions = ["sts:AssumeRole"]
    
    condition {
      test     = "StringEquals"
      variable = "aws:SourceAccount"
      values   = ["393209814297"]
    }
    
    condition {
      test     = "ArnLike"
      variable = "aws:SourceArn"
      values   = ["arn:aws:ecs:us-east-1:393209814297:*"]
    }
  }
}

data "aws_iam_policy_document" "glue_service_trust" {
  statement {
    sid    = "GlueServiceTrust"
    effect = "Allow"
    principals {
      type        = "Service"
      identifiers = ["glue.amazonaws.com"]
    }
    actions = ["sts:AssumeRole"]
    
    condition {
      test     = "StringEquals"
      variable = "aws:SourceAccount"
      values   = ["393209814297"]
    }
  }
}

data "aws_iam_policy_document" "step_functions_service_trust" {
  statement {
    sid    = "StepFunctionsServiceTrust"
    effect = "Allow"
    principals {
      type        = "Service"
      identifiers = ["states.amazonaws.com"]
    }
    actions = ["sts:AssumeRole"]
    
    condition {
      test     = "StringEquals"
      variable = "aws:SourceAccount"
      values   = ["393209814297"]
    }
  }
}

# CROSS-ACCOUNT TRUST WITH EXTERNAL ID
data "aws_iam_policy_document" "cross_account_trust" {
  count = var.external_account_id != "" ? 1 : 0
  
  statement {
    sid    = "CrossAccountTrust"
    effect = "Allow"
    principals {
      type        = "AWS"
      identifiers = ["arn:aws:iam::${var.external_account_id}:root"]
    }
    actions = ["sts:AssumeRole"]
    
    condition {
      test     = "StringEquals"
      variable = "sts:ExternalId"
      values   = [var.external_id]
    }
    
    condition {
      test     = "StringEquals"
      variable = "aws:RequestedRegion"
      values   = ["us-east-1"]
    }
  }
}

# PERMISSION BOUNDARIES
data "aws_iam_policy_document" "app_standard_boundary" {
  # Deny dangerous IAM actions
  statement {
    sid    = "DenyDangerousIAMActions"
    effect = "Deny"
    actions = [
      "iam:CreateRole",
      "iam:DeleteRole",
      "iam:CreateUser",
      "iam:DeleteUser",
      "iam:AttachUserPolicy",
      "iam:DetachUserPolicy",
      "iam:PutUserPermissionsBoundary",
      "iam:DeleteUserPermissionsBoundary",
      "iam:CreateAccessKey",
      "iam:DeleteAccessKey",
      "iam:UpdateAccessKey"
    ]
    resources = ["*"]
  }
  
  # Deny Organizations actions
  statement {
    sid    = "DenyOrganizationsActions"
    effect = "Deny"
    actions = [
      "organizations:*"
    ]
    resources = ["*"]
  }
  
  # Require conditions for wildcard actions
  statement {
    sid    = "RequireConditionForWildcardActions"
    effect = "Deny"
    not_actions = [
      "iam:GetAccountSummary",
      "iam:ListRoles",
      "iam:ListUsers",
      "iam:ListPolicies",
      "s3:ListAllMyBuckets",
      "ec2:Describe*",
      "logs:Describe*"
    ]
    resources = ["*"]
    
    condition {
      test     = "Bool"
      variable = "aws:ViaAWSService"
      values   = ["false"]
    }
    
    condition {
      test     = "Null"
      variable = "aws:RequestTag/Ambiente"
      values   = ["true"]
    }
  }
}

data "aws_iam_policy_document" "platform_boundary" {
  # Platform boundary allows more permissions but still restricts critical actions
  statement {
    sid    = "DenyDangerousActions"
    effect = "Deny"
    actions = [
      "iam:CreateUser",
      "iam:DeleteUser",
      "iam:CreateAccessKey",
      "iam:DeleteAccessKey",
      "organizations:LeaveOrganization",
      "organizations:CloseAccount"
    ]
    resources = ["*"]
  }
}