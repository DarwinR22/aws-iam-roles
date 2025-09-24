# MCI-GitHubActions-TerraformBackend Policy
# ==========================================
# Política específica para acceso al backend de Terraform desde GitHub Actions
# Incluye: S3 tfstate, DynamoDB locks, KMS encryption

data "aws_iam_policy_document" "github_actions_terraform_backend" {
  # S3 Backend - Acceso completo al bucket de tfstate
  statement {
    sid    = "TerraformS3BackendAccess"
    effect = "Allow"
    actions = [
      # Operaciones básicas de tfstate
      "s3:GetObject",
      "s3:PutObject", 
      "s3:DeleteObject",
      "s3:ListBucket",
      
      # Configuración del bucket (requerido por Terraform)
      "s3:GetBucketVersioning",
      "s3:GetBucketLocation",
      "s3:GetBucketWebsite",
      "s3:PutBucketAcl",
      "s3:GetBucketAcl",
      "s3:PutBucketTagging",
      "s3:GetBucketTagging",
      
      # Encriptación (necesario para KMS)
      "s3:PutEncryptionConfiguration",
      "s3:GetEncryptionConfiguration", 
      "s3:GetBucketEncryption",
      
      # Permisos adicionales solicitados por Ricardo Brenes
      "s3:GetAccelerateConfiguration",
      "s3:GetBucketLogging",
      "s3:GetBucketRequestPayment",
      "s3:GetBucketLifecycle",
      "s3:GetBucketNotification",
      "s3:GetBucketObjectLockConfiguration",
      "s3:GetBucketIntelligentTieringConfiguration",
      
      # Multipart uploads para archivos grandes
      "s3:ListBucketMultipartUploads",
      "s3:AbortMultipartUpload"
    ]
    resources = [
      "arn:aws:s3:::s3-data-analytics-${var.environment}-tfstate-datalake",
      "arn:aws:s3:::s3-data-analytics-${var.environment}-tfstate-datalake/*"
    ]
  }
  
  # DynamoDB - State locking
  statement {
    sid    = "TerraformDynamoDBLocks"  
    effect = "Allow"
    actions = [
      "dynamodb:GetItem",
      "dynamodb:PutItem", 
      "dynamodb:DeleteItem",
      "dynamodb:DescribeTable"
    ]
    resources = [
      "arn:aws:dynamodb:us-east-1:393209814297:table/dynamodb-db-${var.environment}-terraform-lock"
    ]
  }
  
  # KMS - Customer Managed Key access
  statement {
    sid    = "TerraformKMSAccess"
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
      "arn:aws:kms:us-east-1:393209814297:key/*"
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