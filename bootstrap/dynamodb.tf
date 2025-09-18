# Bootstrap: Crear tabla DynamoDB para Terraform state
resource "aws_dynamodb_table" "terraform_lock" {
  name           = "dynamodb-db-dev-terraform-lock"
  billing_mode   = "PAY_PER_REQUEST"
  hash_key       = "LockID"

  attribute {
    name = "LockID"
    type = "S"
  }

  tags = {
    Name        = "Terraform State Lock Table"
    Environment = "dev"
    ManagedBy   = "Terraform"
    Purpose     = "State Lock"
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

output "s3_bucket_name" {
  description = "Name of the S3 bucket for Terraform state"
  value       = data.aws_s3_bucket.tfstate.bucket
}
