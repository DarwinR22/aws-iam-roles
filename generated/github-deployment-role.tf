# GitHub Actions Deployment Role - IMPORTED from existing AWS resource
# This resource was created in AWS Console and imported to Terraform
# Role ARN: arn:aws:iam::393209814297:role/github-actions-iam-deployment-role

# OIDC Provider trust policy for GitHub Actions
data "aws_iam_policy_document" "github_actions_trust" {
  statement {
    effect = "Allow"
    
    principals {
      type        = "Federated"
      identifiers = ["arn:aws:iam::393209814297:oidc-provider/token.actions.githubusercontent.com"]
    }
    
    actions = ["sts:AssumeRoleWithWebIdentity"]
    
    condition {
      test     = "StringEquals"
      variable = "token.actions.githubusercontent.com:aud"
      values   = ["sts.amazonaws.com"]
    }
    
    condition {
      test     = "StringLike"
      variable = "token.actions.githubusercontent.com:sub" 
      values   = ["repo:ClaroCENAM/*"]
    }
  }
}

# IAM Role for GitHub Actions deployment
resource "aws_iam_role" "github_deployment" {
  name                 = "github-actions-iam-deployment-role"
  path                 = "/"
  description          = "Rol IAM para despliegues automaticos desde GitHub Actions (repositorio: ClaroCENAM/mci-aws-iam) utilizando OIDC. Permite unicamente la creacion y administracion de recursos IAM a traves de la canalizacion (pipeline) de Terraform"
  max_session_duration = 3600
  
  assume_role_policy = data.aws_iam_policy_document.github_actions_trust.json
  
  tags = {
    "Pais"              = "rg"
    "Gerencia"          = "MCI"
    "Ambiente"          = "dev"
    "Direccion"         = "TIRegional"
    "Modulo"            = "IAM"
    "Alcance SOX"       = "No"
    "Propietario"       = "DarwinLopez"
    "Proveedor"         = "InHouse"
    "Layer"             = "Devops"
    "Dominio"           = "BusinessIntelligence"
    "Subdominio"        = "Analytics"
    "Aplicacion"        = "CICD"
    "Name"              = "github-actions-iam-deployment-role"
    "Soporte"           = "darwin.lopez@claro.com.gt"
    "Contacto"          = "darwin.lopez@claro.com.gt"
    "Creado Por"        = "DarwinLopez"
    "Tipo de Recurso"   = "IAMRole"
    "Ciclo de Vida"     = "Creacion"
    "Versión"           = "v1.0.0"
    "Fecha de Creacion" = "2025-09-16"
  }
}

# Inline policy for GitHub Actions deployment permissions
data "aws_iam_policy_document" "github_actions_deployment" {
  # IAM permissions for role and policy management
  statement {
    effect = "Allow"
    actions = [
      "iam:CreateRole",
      "iam:DeleteRole", 
      "iam:GetRole",
      "iam:ListRoles",
      "iam:UpdateRole",
      "iam:AttachRolePolicy",
      "iam:DetachRolePolicy",
      "iam:ListAttachedRolePolicies",
      "iam:CreatePolicy",
      "iam:DeletePolicy",
      "iam:GetPolicy",
      "iam:ListPolicies",
      "iam:CreatePolicyVersion",
      "iam:DeletePolicyVersion",
      "iam:ListPolicyVersions",
      "iam:PutRolePolicy",
      "iam:DeleteRolePolicy",
      "iam:GetRolePolicy",
      "iam:ListRolePolicies",
      "iam:TagRole",
      "iam:UntagRole",
      "iam:ListRoleTags",
      "iam:PassRole"
    ]
    resources = ["*"]
  }
  
  # S3 permissions for Terraform state
  statement {
    effect = "Allow"
    actions = [
      "s3:GetObject",
      "s3:PutObject", 
      "s3:DeleteObject",
      "s3:ListBucket",
      "s3:GetBucketVersioning",
      "s3:GetBucketLocation"
    ]
    resources = [
      "arn:aws:s3:::s3-data-analytics-dev-tfstate-datalake",
      "arn:aws:s3:::s3-data-analytics-dev-tfstate-datalake/*"
    ]
  }
  
  # DynamoDB permissions for Terraform locks
  statement {
    effect = "Allow"
    actions = [
      "dynamodb:GetItem",
      "dynamodb:PutItem",
      "dynamodb:DeleteItem", 
      "dynamodb:DescribeTable"
    ]
    resources = [
      "arn:aws:dynamodb:us-east-1:393209814297:table/dynamodb-db-dev-terraform-lock"
    ]
  }
  
  # STS permissions
  statement {
    effect = "Allow"
    actions = [
      "sts:GetCallerIdentity"
    ]
    resources = ["*"]
  }
  
  # KMS permissions for S3/DynamoDB encryption
  statement {
    effect = "Allow"
    actions = [
      "kms:Decrypt",
      "kms:DescribeKey",
      "kms:Encrypt", 
      "kms:GenerateDataKey*",
      "kms:ReEncrypt*",
      "kms:CreateGrant"
    ]
    resources = [
      "arn:aws:kms:us-east-1:393209814297:key/fe44eac8-0501-4620-bba9-b0155ed1b1a1"
    ]
    
    condition {
      test     = "StringEquals"
      variable = "kms:ViaService"
      values = [
        "s3.us-east-1.amazonaws.com",
        "dynamodb.us-east-1.amazonaws.com"
      ]
    }
  }
}

# Attach inline policy to role
resource "aws_iam_role_policy" "github_actions_deployment" {
  name   = "github-actions-iam-policy"
  role   = aws_iam_role.github_deployment.id
  policy = data.aws_iam_policy_document.github_actions_deployment.json
}