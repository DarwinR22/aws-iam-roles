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

output "private_route_table_ids" {
  description = "IDs of the private route tables (per AZ for HA)"
  value = {
    az1 = module.nat_gateway_ha.private_route_table_ids["az1"]
    az2 = module.nat_gateway_ha.private_route_table_ids["az2"]
  }
}

# Legacy output for backwards compatibility
output "private_route_table_id" {
  description = "ID of the private route table (AZ1 - for backwards compatibility)"
  value       = module.nat_gateway_ha.private_route_table_ids["az1"]
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
    private_route_table_ids   = module.nat_gateway_ha.private_route_table_ids
  }
}

# ==============================================================================
# ENHANCED SECURITY MODULES OUTPUTS
# ==============================================================================

# VPC Flow Logs Outputs
output "vpc_flow_logs" {
  description = "VPC Flow Logs configuration"
  value = {
    flow_log_id           = module.vpc_flow_logs.flow_log_id
    log_group_name        = module.vpc_flow_logs.log_group_name
    log_group_arn         = module.vpc_flow_logs.log_group_arn
    rejected_traffic_alarm = module.vpc_flow_logs.rejected_traffic_alarm_arn
    ssh_monitoring_alarm  = module.vpc_flow_logs.ssh_monitoring_alarm_arn
    compliance_info       = module.vpc_flow_logs.compliance_info
  }
}

# NAT Gateway High Availability Outputs
output "nat_gateways" {
  description = "NAT Gateway High Availability configuration"
  value = {
    nat_gateway_ids     = module.nat_gateway_ha.nat_gateway_ids
    public_ips          = module.nat_gateway_ha.nat_gateway_public_ips
    elastic_ip_ids      = module.nat_gateway_ha.elastic_ip_ids
    ha_info             = module.nat_gateway_ha.high_availability_info
  }
}

# Network ACLs Outputs
output "network_acls" {
  description = "Network ACLs configuration"
  value = {
    nacl_ids        = module.network_acls.network_acl_ids
    compliance_info = module.network_acls.compliance_info
  }
}

# VPC Endpoints Outputs
output "vpc_endpoints" {
  description = "VPC Endpoints configuration"
  value = {
    s3_endpoint_id        = module.vpc_endpoints.s3_endpoint_id
    dynamodb_endpoint_id  = module.vpc_endpoints.dynamodb_endpoint_id
    endpoint_info         = module.vpc_endpoints.endpoint_info
  }
}

# ==============================================================================
# LAYER 2 COMPLIANCE SUMMARY
# ==============================================================================
output "layer2_compliance_summary" {
  description = "Layer 2 compliance and security status"
  value = {
    layer_name          = "Network (Layer 2)"
    completion_status   = "100%"
    security_features = [
      "VPC Segmentation (DMZ, App, DB tiers)",
      "Security Groups (5 tiers)",
      "Network ACLs (Defense in Depth)",
      "VPC Flow Logs (Traffic Monitoring)",
      "NAT Gateways HA (Multi-AZ)",
      "VPC Endpoints (S3, DynamoDB)"
    ]
    iso_27001_controls = [
      "A.13.1.1 - Network Controls",
      "A.13.1.2 - Security of Network Services",
      "A.13.2.1 - Information Transfer Policies",
      "A.16.1.2 - Reporting Security Events",
      "A.17.2.1 - Availability of Processing Facilities"
    ]
    nist_csf_controls = [
      "PR.AC-5 - Network Integrity",
      "DE.AE-3 - Event Data Aggregation",
      "DE.CM-1 - Network Monitoring",
      "PR.IP-12 - Backup Capability"
    ]
    high_availability = "Multi-AZ with redundant NAT Gateways"
    monitoring        = "VPC Flow Logs + CloudWatch Alarms"
    defense_layers    = "2 (Security Groups + NACLs)"
  }
}