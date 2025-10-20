# ==============================================================================
# MODULE: VPC Endpoints - Outputs
# ==============================================================================

output "s3_endpoint_id" {
  description = "ID of the S3 VPC endpoint"
  value       = aws_vpc_endpoint.s3.id
}

output "dynamodb_endpoint_id" {
  description = "ID of the DynamoDB VPC endpoint"
  value       = aws_vpc_endpoint.dynamodb.id
}

output "secrets_manager_endpoint_id" {
  description = "ID of the Secrets Manager VPC endpoint"
  value       = var.enable_secrets_manager_endpoint ? aws_vpc_endpoint.secrets_manager[0].id : null
}

output "kms_endpoint_id" {
  description = "ID of the KMS VPC endpoint"
  value       = var.enable_kms_endpoint ? aws_vpc_endpoint.kms[0].id : null
}

output "endpoint_info" {
  description = "Information about deployed VPC endpoints"
  value = {
    gateway_endpoints = {
      s3       = aws_vpc_endpoint.s3.id
      dynamodb = aws_vpc_endpoint.dynamodb.id
    }
    interface_endpoints = {
      secrets_manager = var.enable_secrets_manager_endpoint ? aws_vpc_endpoint.secrets_manager[0].id : "not-enabled"
      kms             = var.enable_kms_endpoint ? aws_vpc_endpoint.kms[0].id : "not-enabled"
    }
    cost_optimization = "Enabled"
    security_benefit  = "No Internet Exposure for AWS Services"
  }
}
