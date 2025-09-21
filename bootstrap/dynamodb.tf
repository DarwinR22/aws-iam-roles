# KMS Key para encriptación de DynamoDB
resource "aws_kms_key" "dynamodb_cmk" {
  description             = "KMS Customer Managed Key para encriptación de DynamoDB Terraform Lock"
  deletion_window_in_days = 7
  enable_key_rotation     = true

  tags = {
    Name        = "DynamoDB-TerraformLock-CMK"
    Environment = "dev"
    ManagedBy   = "Terraform"
    Purpose     = "DynamoDB Encryption"
    Ambiente    = "dev"
    Pais        = "RG"
    Direccion   = "Tecnologia"
    Gerencia    = "MCI"
  }
}

# Alias para la clave KMS
resource "aws_kms_alias" "dynamodb_cmk_alias" {
  name          = "alias/dynamodb-terraform-lock-dev"
  target_key_id = aws_kms_key.dynamodb_cmk.key_id
}

# Bootstrap: Crear tabla DynamoDB para Terraform state
resource "aws_dynamodb_table" "terraform_lock" {
  name           = "dynamodb-db-dev-terraform-lock"
  billing_mode   = "PAY_PER_REQUEST"
  hash_key       = "LockID"

  attribute {
    name = "LockID"
    type = "S"
  }

  # Encriptación usando KMS Customer Managed Key
  server_side_encryption {
    enabled     = true
    kms_key_arn = aws_kms_key.dynamodb_cmk.arn
  }

  # Habilitar Point-in-Time Recovery
  point_in_time_recovery {
    enabled = true
  }

  tags = {
    Name        = "Terraform State Lock Table"
    Environment = "dev"
    ManagedBy   = "Terraform"
    Purpose     = "State Lock"
    Ambiente    = "dev"
    Pais        = "RG"
    Direccion   = "Tecnologia"
    Gerencia    = "MCI"
  }

  lifecycle {
    prevent_destroy = true
  }
}

# Verificar que el bucket S3 existe
data "aws_s3_bucket" "tfstate" {
  bucket = "s3-data-analytics-raw-dev-tfstate"
}

output "dynamodb_table_name" {
  description = "Name of the DynamoDB table for Terraform state locking"
  value       = aws_dynamodb_table.terraform_lock.name
}

output "dynamodb_kms_key_id" {
  description = "ID of the KMS key used for DynamoDB encryption"
  value       = aws_kms_key.dynamodb_cmk.key_id
}

output "dynamodb_kms_key_arn" {
  description = "ARN of the KMS key used for DynamoDB encryption"
  value       = aws_kms_key.dynamodb_cmk.arn
}

output "s3_bucket_name" {
  description = "Name of the S3 bucket for Terraform state"
  value       = data.aws_s3_bucket.tfstate.bucket
}
