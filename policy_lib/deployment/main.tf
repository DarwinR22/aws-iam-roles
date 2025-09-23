# policy_lib/deployment/main.tf
# =============================================
# DEPLOYMENT ABAC POLICY BUILDING BLOCKS
# =============================================

# TERRAFORM CORE DEPLOYMENT - Política 1 original (SECURE)
data "aws_iam_policy_document" "terraform_core_deployment" {
  # IAM Read permissions (can be broader for discovery)
  statement {
    sid    = "TerraformIAMRead"
    effect = "Allow"
    actions = [
      "iam:GetRole",
      "iam:GetRolePolicy", 
      "iam:GetPolicy",
      "iam:GetPolicyVersion",
      "iam:ListRoles",
      "iam:ListPolicies",
      "iam:ListPolicyVersions",
      "iam:ListAttachedRolePolicies",
      "iam:ListRolePolicies",
      "iam:ListInstanceProfilesForRole",
      # Organizations (unchanged)
      "organizations:Describe*",
      "organizations:List*"
    ]
    resources = ["*"]
    
    condition {
      test     = "StringEquals"
      variable = "aws:PrincipalTag/Gerencia"
      values   = [var.department]
    }
    
    condition {
      test     = "StringEquals"
      variable = "aws:PrincipalTag/Ambiente"
      values   = [var.environment]
    }
  }
  
  # IAM Write permissions (restricted to specific patterns)
  statement {
    sid    = "TerraformIAMWrite"
    effect = "Allow"
    actions = [
      "iam:CreateRole",
      "iam:UpdateRole",
      "iam:UpdateRoleDescription",
      "iam:DeleteRole",
      "iam:CreatePolicy",
      "iam:CreatePolicyVersion",
      "iam:DeletePolicy",
      "iam:DeletePolicyVersion",
      "iam:AttachRolePolicy",
      "iam:DetachRolePolicy",
      "iam:PutRolePolicy",
      "iam:DeleteRolePolicy",
      "iam:TagRole",
      "iam:UntagRole",
      "iam:TagPolicy",
      "iam:UntagPolicy"
    ]
    resources = [
      # Roles managed by this framework
      "arn:aws:iam::*:role/${var.department}-${var.environment}-*",
      "arn:aws:iam::*:role/rol-mci-*",
      "arn:aws:iam::*:role/rol-*-*",
      # Policies managed by this framework  
      "arn:aws:iam::*:policy/MCI-*",
      "arn:aws:iam::*:policy/${var.department}-${var.environment}-*"
    ]
    
    condition {
      test     = "StringEquals"
      variable = "aws:PrincipalTag/Gerencia"
      values   = [var.department]
    }
    
    condition {
      test     = "StringEquals"
      variable = "aws:PrincipalTag/Ambiente"
      values   = [var.environment]
    }
  }
  
  # PassRole for service principals (restricted to managed roles)
  statement {
    sid    = "TerraformPassRole"
    effect = "Allow"
    actions = ["iam:PassRole"]
    resources = [
      "arn:aws:iam::*:role/${var.department}-${var.environment}-*",
      "arn:aws:iam::*:role/rol-${var.department}-*"
    ]
    
    condition {
      test     = "StringEquals"
      variable = "iam:PassedToService"
      values   = [
        "lambda.amazonaws.com",
        "ec2.amazonaws.com",
        "ecs-tasks.amazonaws.com",
        "glue.amazonaws.com",
        "states.amazonaws.com"
      ]
    }
    
    condition {
      test     = "StringEquals"
      variable = "aws:PrincipalTag/Gerencia"
      values   = [var.department]
    }
    
    condition {
      test     = "StringEquals"
      variable = "aws:PrincipalTag/Ambiente"
      values   = [var.environment]
    }
  }
}

# ORGANIZATIONS CONTEXT - Nueva Política para soporte de AWS Organizations
data "aws_iam_policy_document" "organizations_deployment" {
  statement {
    sid    = "OrganizationsReadAccess"
    effect = "Allow"
    actions = [
      "organizations:DescribeAccount",
      "organizations:DescribeOrganization",
      "organizations:DescribeOrganizationalUnit",
      "organizations:DescribePolicy",
      "organizations:ListChildren",
      "organizations:ListParents",
      "organizations:ListPoliciesForTarget",
      "organizations:ListRoots",
      "organizations:ListPolicies",
      "organizations:ListTargetsForPolicy"
    ]
    resources = ["*"]
    
    condition {
      test     = "StringEquals"
      variable = "aws:PrincipalTag/Gerencia"
      values   = [var.department]
    }

    condition {
      test     = "StringEquals"
      variable = "aws:PrincipalTag/Ambiente"
      values   = [var.environment]
    }
  }
}

# TERRAFORM STATE S3 BACKEND ACCESS - Política ampliada
data "aws_iam_policy_document" "terraform_state_backend" {
  statement {
    sid    = "TerraformStateBackend"
    effect = "Allow"
    actions = [
      "s3:ListBucket",
      "s3:GetObject",
      "s3:PutObject",
      "s3:DeleteObject",
      "s3:GetBucketVersioning",
      "s3:GetBucketLocation",
      "s3:GetBucketWebsite",
      "s3:PutBucketAcl",
      "s3:GetBucketAcl",
      "s3:PutBucketTagging",
      "s3:GetBucketTagging",
      "s3:PutEncryptionConfiguration",
      "s3:GetEncryptionConfiguration",
      "s3:GetAccelerateConfiguration",
      "s3:ListBucketMultipartUploads",
      "s3:AbortMultipartUpload"
    ]
    resources = [
      "arn:aws:s3:::s3-data-analytics-raw-${var.environment}-tfstate",
      "arn:aws:s3:::s3-data-analytics-raw-${var.environment}-tfstate/*"
    ]
    
    condition {
      test     = "StringEquals"
      variable = "aws:PrincipalTag/Gerencia"
      values   = [var.department]
    }
    
    condition {
      test     = "StringEquals"
      variable = "aws:PrincipalTag/Ambiente"
      values   = [var.environment]
    }
  }
}

# S3 ANALYTICS DEPLOYMENT - Política 2 original (ampliada)
data "aws_iam_policy_document" "s3_analytics_deployment" {
  statement {
    sid    = "S3AnalyticsFullDeployment"
    effect = "Allow"
    actions = [
      # Bucket management
      "s3:CreateBucket",
      "s3:DeleteBucket", 
      "s3:ListBucket",
      "s3:GetBucketLocation",
      "s3:GetBucketTagging",
      "s3:PutBucketTagging",
      "s3:GetBucketVersioning",
      "s3:PutBucketVersioning",
      "s3:GetBucketAcl",
      "s3:PutBucketAcl",
      "s3:GetBucketCors",
      "s3:PutBucketCors",
      "s3:GetBucketWebsite",
      "s3:PutBucketWebsite",
      "s3:PutEncryptionConfiguration",
      "s3:GetEncryptionConfiguration",
      "s3:GetAccelerateConfiguration",
      "s3:PutReplicationConfiguration",
      "s3:GetReplicationConfiguration",
      "s3:GetLifecycleConfiguration",
      "s3:PutLifecycleConfiguration",
      # Object operations
      "s3:PutObject",
      "s3:GetObject", 
      "s3:DeleteObject",
      "s3:ListBucketMultipartUploads",
      "s3:AbortMultipartUpload",
      # Analytics específico
      "s3:GetBucketAnalyticsConfiguration",
      "s3:PutBucketAnalyticsConfiguration",
      "s3:GetBucketInventoryConfiguration",
      "s3:PutBucketInventoryConfiguration",
      "s3:GetBucketMetricsConfiguration",
      "s3:PutBucketMetricsConfiguration",
      "s3:GetBucketPolicy",
      "s3:PutBucketPolicy"
    ]
    resources = [
      "arn:aws:s3:::s3-data-analytics-*",
      "arn:aws:s3:::s3-data-analytics-*/*",
      # ABAC pattern for other departments
      "arn:aws:s3:::${var.department}-${var.environment}-*",
      "arn:aws:s3:::${var.department}-${var.environment}-*/*"
    ]
    
    condition {
      test     = "StringEquals"
      variable = "aws:PrincipalTag/Gerencia"
      values   = [var.department]
    }

    condition {
      test     = "StringEquals"
      variable = "aws:PrincipalTag/Ambiente"
      values   = [var.environment]
    }
  }
}

# CLOUDFORMATION DEPLOYMENT - Política 3 original
data "aws_iam_policy_document" "cloudformation_deployment" {
  statement {
    sid    = "CloudFormationDeployment"
    effect = "Allow"
    actions = [
      "cloudformation:CreateStack",
      "cloudformation:UpdateStack",
      "cloudformation:DeleteStack",
      "cloudformation:DescribeStacks",
      "cloudformation:ListStacks",
      "cloudformation:GetStackPolicy",
      "cloudformation:SetStackPolicy",
      "cloudformation:ValidateTemplate"
    ]
    resources = ["*"]  # Original era "*" para CloudFormation
    
    condition {
      test     = "StringEquals"
      variable = "aws:PrincipalTag/Gerencia"
      values   = [var.department]
    }

    condition {
      test     = "StringEquals"
      variable = "aws:PrincipalTag/Ambiente"
      values   = [var.environment]
    }
  }
}

# LAMBDA DEPLOYMENT - Política 4 original
data "aws_iam_policy_document" "lambda_deployment" {
  statement {
    sid    = "LambdaCorePermissions"
    effect = "Allow"
    actions = [
      "lambda:CreateFunction",
      "lambda:UpdateFunctionCode",
      "lambda:UpdateFunctionConfiguration",
      "lambda:DeleteFunction",
      "lambda:GetFunction",
      "lambda:ListFunctions",
      # Additional for modern deployments
      "lambda:PublishVersion",
      "lambda:CreateAlias",
      "lambda:UpdateAlias",
      "lambda:GetFunctionConfiguration",
      "lambda:ListVersionsByFunction"
    ]
    resources = [
      "arn:aws:lambda:us-east-1:393209814297:function:*",  # Original pattern
      "arn:aws:lambda:*:*:function:${var.department}-${var.environment}-*"  # ABAC pattern
    ]
    
    condition {
      test     = "StringEquals"
      variable = "aws:PrincipalTag/Gerencia"
      values   = [var.department]
    }

    condition {
      test     = "StringEquals"
      variable = "aws:PrincipalTag/Ambiente"
      values   = [var.environment]
    }
  }
  
  statement {
    sid    = "IAMPassRoleForLambda"
    effect = "Allow"
    actions = ["iam:PassRole"]
    resources = [
      "arn:aws:iam::393209814297:role/lambda_exec_role",  # Original specific role
      "arn:aws:iam::*:role/${var.department}-${var.environment}-lambda-*"  # ABAC pattern
    ]
    
    condition {
      test     = "StringEquals"
      variable = "aws:PrincipalTag/Gerencia"
      values   = [var.department]
    }

    condition {
      test     = "StringEquals"
      variable = "aws:PrincipalTag/Ambiente"
      values   = [var.environment]
    }
  }
}

# LOGS DEPLOYMENT - Política 5 original
data "aws_iam_policy_document" "logs_deployment" {
  statement {
    sid    = "CloudWatchLogsForLambda"
    effect = "Allow"
    actions = [
      "logs:CreateLogGroup",
      "logs:CreateLogStream",
      "logs:PutLogEvents",
      # Additional modern permissions
      "logs:DescribeLogGroups",
      "logs:DescribeLogStreams",
      "logs:PutRetentionPolicy"
    ]
    resources = [
      "arn:aws:logs:us-east-1:393209814297:*",  # Original pattern
      "arn:aws:logs:*:*:log-group:/aws/lambda/${var.department}-${var.environment}-*",
      "arn:aws:logs:*:*:log-group:/aws/apigateway/${var.department}-${var.environment}-*"
    ]

    condition {
      test     = "StringEquals"
      variable = "aws:PrincipalTag/Gerencia"
      values   = [var.department]
    }

    condition {
      test     = "StringEquals"
      variable = "aws:PrincipalTag/Ambiente"
      values   = [var.environment]
    }
  }
}

# DYNAMODB TERRAFORM LOCK - Nueva Política
data "aws_iam_policy_document" "dynamodb_deployment" {
  statement {
    sid    = "DynamoDBTerraformLock"
    effect = "Allow"
    actions = [
      "dynamodb:ListTables",
      "dynamodb:CreateTable",
      "dynamodb:DescribeTable",
      "dynamodb:DeleteTable",
      "dynamodb:UpdateTable",
      "dynamodb:GetItem",
      "dynamodb:PutItem",
      "dynamodb:UpdateItem",
      "dynamodb:DeleteItem",
      "dynamodb:BatchWriteItem",
      "dynamodb:BatchGetItem",
      "dynamodb:TagResource",
      "dynamodb:UntagResource",
      "dynamodb:ListTagsOfResource"
    ]
    resources = [
      "arn:aws:dynamodb:us-east-1:393209814297:table/dynamodb-db-${var.environment}-terraform-lock"
    ]
    
    condition {
      test     = "StringEquals"
      variable = "aws:PrincipalTag/Gerencia"
      values   = [var.department]
    }
    
    condition {
      test     = "StringEquals"
      variable = "aws:PrincipalTag/Ambiente"
      values   = [var.environment]
    }
  }
}

# COMBINACIONES PARA ROLES COMPUESTOS
data "aws_iam_policy_document" "full_deployment_access" {
  source_policy_documents = [
    data.aws_iam_policy_document.terraform_core_deployment.json,
    data.aws_iam_policy_document.organizations_deployment.json,
    data.aws_iam_policy_document.terraform_state_backend.json,
    data.aws_iam_policy_document.s3_analytics_deployment.json,
    data.aws_iam_policy_document.cloudformation_deployment.json,
    data.aws_iam_policy_document.lambda_deployment.json,
    data.aws_iam_policy_document.logs_deployment.json,
    data.aws_iam_policy_document.dynamodb_deployment.json
  ]
}

data "aws_iam_policy_document" "basic_deployment_access" {
  source_policy_documents = [
    data.aws_iam_policy_document.cloudformation_deployment.json,
    data.aws_iam_policy_document.lambda_deployment.json,
    data.aws_iam_policy_document.logs_deployment.json
  ]
}