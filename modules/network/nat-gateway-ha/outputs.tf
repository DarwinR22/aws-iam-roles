# ==============================================================================
# MODULE: NAT Gateway High Availability - Outputs
# ==============================================================================

output "nat_gateway_ids" {
  description = "IDs of the NAT Gateways"
  value = {
    az1 = aws_nat_gateway.nat_az1.id
    az2 = aws_nat_gateway.nat_az2.id
  }
}

output "nat_gateway_public_ips" {
  description = "Public IPs of the NAT Gateways"
  value = {
    az1 = aws_eip.nat_az1.public_ip
    az2 = aws_eip.nat_az2.public_ip
  }
}

output "elastic_ip_ids" {
  description = "IDs of the Elastic IPs"
  value = {
    az1 = aws_eip.nat_az1.id
    az2 = aws_eip.nat_az2.id
  }
}

output "private_route_table_ids" {
  description = "IDs of the private route tables"
  value = {
    az1 = aws_route_table.private_az1.id
    az2 = aws_route_table.private_az2.id
  }
}

output "high_availability_info" {
  description = "High availability configuration details"
  value = {
    availability_zones    = var.availability_zones
    nat_gateways_deployed = 2
    redundancy_level      = "Multi-AZ"
    iso_27001_control     = "A.17.2.1"
    nist_csf_control      = "PR.IP-12"
  }
}
