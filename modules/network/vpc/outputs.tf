# ==============================================================================
# MODULE OUTPUTS
# ==============================================================================

output "vpc_id" {
  description = "Vpc Id"
  value       = aws_vpc.main.id
}

output "vpc_cidr_block" {
  description = "Vpc Cidr Block"
  value       = aws_vpc.main.cidr_block
}

output "public_subnet_ids" {
  description = "Public Subnet Ids"
  value       = aws_subnet.public[*].id
}

output "private_subnet_ids" {
  description = "Private Subnet Ids"
  value       = aws_subnet.private[*].id
}

output "module_info" {
  description = "Information about this module"
  value = {
    module_name = "vpc"
    status      = "implemented"
  }
}
