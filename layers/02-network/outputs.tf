# ==============================================================================
# LAYER 2: NETWORK - OUTPUTS
# ==============================================================================

# VPC Outputs
output "vpc_id" {
  description = "ID of the VPC"
  value       = aws_vpc.sgsi_vpc_main.id
}

output "vpc_cidr_block" {
  description = "CIDR block of the VPC"
  value       = aws_vpc.sgsi_vpc_main.cidr_block
}

output "vpc_arn" {
  description = "ARN of the VPC"
  value       = aws_vpc.sgsi_vpc_main.arn
}

# Internet Gateway Outputs
output "internet_gateway_id" {
  description = "ID of the Internet Gateway"
  value       = aws_internet_gateway.sgsi_igw.id
}

# Public Subnet Outputs
output "public_subnet_ids" {
  description = "IDs of the public subnets"
  value       = [aws_subnet.dmz_public_1a.id, aws_subnet.dmz_public_1b.id]
}

output "public_subnet_cidrs" {
  description = "CIDR blocks of the public subnets"
  value       = [aws_subnet.dmz_public_1a.cidr_block, aws_subnet.dmz_public_1b.cidr_block]
}

# Private Application Subnet Outputs
output "app_private_subnet_ids" {
  description = "IDs of the private application subnets"
  value       = [aws_subnet.app_private_1a.id, aws_subnet.app_private_1b.id]
}

output "app_private_subnet_cidrs" {
  description = "CIDR blocks of the private application subnets"
  value       = [aws_subnet.app_private_1a.cidr_block, aws_subnet.app_private_1b.cidr_block]
}

# Private Database Subnet Outputs
output "db_private_subnet_ids" {
  description = "IDs of the private database subnets"
  value       = [aws_subnet.db_private_1a.id, aws_subnet.db_private_1b.id]
}

output "db_private_subnet_cidrs" {
  description = "CIDR blocks of the private database subnets"
  value       = [aws_subnet.db_private_1a.cidr_block, aws_subnet.db_private_1b.cidr_block]
}

# Route Table Outputs
output "public_route_table_id" {
  description = "ID of the public route table"
  value       = aws_route_table.public.id
}

output "private_route_table_id" {
  description = "ID of the private route table"
  value       = aws_route_table.private.id
}

# Security Groups (will be defined in security-groups.tf)
output "security_group_ids" {
  description = "Map of security group names to IDs"
  value = {
    alb  = aws_security_group.sgsi_alb_sg.id
    web  = aws_security_group.sgsi_web_sg.id
    app  = aws_security_group.sgsi_app_sg.id
    db   = aws_security_group.sgsi_db_sg.id
    mgmt = aws_security_group.sgsi_mgmt_sg.id
  }
}

# Availability Zones
output "availability_zones" {
  description = "Availability zones used"
  value       = ["us-east-1a", "us-east-1b"]
}

# Layer Information
output "layer_info" {
  description = "Layer information for downstream layers"
  value = {
    layer_name    = "network"
    layer_number  = "02"
    state_key     = "sgsi/layer2-network/terraform.tfstate"
    deployed_at   = timestamp()
  }
}

# For use by other layers
output "network_config" {
  description = "Network configuration for other layers"
  value = {
    vpc_id                    = aws_vpc.sgsi_vpc_main.id
    vpc_cidr                  = aws_vpc.sgsi_vpc_main.cidr_block
    public_subnet_ids         = [aws_subnet.dmz_public_1a.id, aws_subnet.dmz_public_1b.id]
    app_private_subnet_ids    = [aws_subnet.app_private_1a.id, aws_subnet.app_private_1b.id]
    db_private_subnet_ids     = [aws_subnet.db_private_1a.id, aws_subnet.db_private_1b.id]
    internet_gateway_id       = aws_internet_gateway.sgsi_igw.id
    public_route_table_id     = aws_route_table.public.id
    private_route_table_id    = aws_route_table.private.id
  }
}