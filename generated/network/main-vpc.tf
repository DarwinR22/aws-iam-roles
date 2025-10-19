# ==============================================================================
# VPC Module: main-vpc
# ==============================================================================
# Generated: 2025-10-18T20:18:36.298672
# Source: main-vpc.yaml
# ==============================================================================

# VPC Resource
resource "aws_vpc" "main_vpc" {
  cidr_block           = "10.0.0.0/16"
  instance_tenancy     = "default"
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = merge(
    {
      Name = "main-vpc"
"Environment" = "dev"
"Project" = "aws-iam-roles"
"ManagedBy" = "Terraform"
"Owner" = "DarwinLopez"
"Purpose" = "NetworkInfrastructure"
},
    var.additional_tags
  )
}

# Internet Gateway
resource "aws_internet_gateway" "main_igw" {
  vpc_id = aws_vpc.main_vpc.id

  tags = merge(
    {
      Name = "main-igw"
"Environment" = "dev"
"Project" = "aws-iam-roles"
"ManagedBy" = "Terraform"
"Owner" = "DarwinLopez"
"Purpose" = "NetworkInfrastructure"
},
    var.additional_tags
  )
}

# Subnets
resource "aws_subnet" "public_subnet_1a" {
  vpc_id                  = aws_vpc.main_vpc.id
  cidr_block              = "10.0.1.0/24"
  availability_zone       = "us-east-1a"
  map_public_ip_on_launch = true

  tags = merge(
    {
      Name = "public-subnet-1a"
      Type = "public"
"Environment" = "dev"
"Project" = "aws-iam-roles"
"ManagedBy" = "Terraform"
"Owner" = "DarwinLopez"
"Purpose" = "NetworkInfrastructure"
},
    var.additional_tags
  )
}

resource "aws_subnet" "public_subnet_1b" {
  vpc_id                  = aws_vpc.main_vpc.id
  cidr_block              = "10.0.2.0/24"
  availability_zone       = "us-east-1b"
  map_public_ip_on_launch = true

  tags = merge(
    {
      Name = "public-subnet-1b"
      Type = "public"
"Environment" = "dev"
"Project" = "aws-iam-roles"
"ManagedBy" = "Terraform"
"Owner" = "DarwinLopez"
"Purpose" = "NetworkInfrastructure"
},
    var.additional_tags
  )
}

resource "aws_subnet" "private_subnet_1a" {
  vpc_id                  = aws_vpc.main_vpc.id
  cidr_block              = "10.0.10.0/24"
  availability_zone       = "us-east-1a"
  map_public_ip_on_launch = false

  tags = merge(
    {
      Name = "private-subnet-1a"
      Type = "private"
"Environment" = "dev"
"Project" = "aws-iam-roles"
"ManagedBy" = "Terraform"
"Owner" = "DarwinLopez"
"Purpose" = "NetworkInfrastructure"
},
    var.additional_tags
  )
}

resource "aws_subnet" "private_subnet_1b" {
  vpc_id                  = aws_vpc.main_vpc.id
  cidr_block              = "10.0.20.0/24"
  availability_zone       = "us-east-1b"
  map_public_ip_on_launch = false

  tags = merge(
    {
      Name = "private-subnet-1b"
      Type = "private"
"Environment" = "dev"
"Project" = "aws-iam-roles"
"ManagedBy" = "Terraform"
"Owner" = "DarwinLopez"
"Purpose" = "NetworkInfrastructure"
},
    var.additional_tags
  )
}

resource "aws_subnet" "db_subnet_1a" {
  vpc_id                  = aws_vpc.main_vpc.id
  cidr_block              = "10.0.50.0/24"
  availability_zone       = "us-east-1a"
  map_public_ip_on_launch = false

  tags = merge(
    {
      Name = "db-subnet-1a"
      Type = "database"
"Environment" = "dev"
"Project" = "aws-iam-roles"
"ManagedBy" = "Terraform"
"Owner" = "DarwinLopez"
"Purpose" = "NetworkInfrastructure"
},
    var.additional_tags
  )
}

resource "aws_subnet" "db_subnet_1b" {
  vpc_id                  = aws_vpc.main_vpc.id
  cidr_block              = "10.0.60.0/24"
  availability_zone       = "us-east-1b"
  map_public_ip_on_launch = false

  tags = merge(
    {
      Name = "db-subnet-1b"
      Type = "database"
"Environment" = "dev"
"Project" = "aws-iam-roles"
"ManagedBy" = "Terraform"
"Owner" = "DarwinLopez"
"Purpose" = "NetworkInfrastructure"
},
    var.additional_tags
  )
}


# Elastic IPs for NAT Gateways
resource "aws_eip" "nat_gw_1a_eip" {
  domain = "vpc"
  
  tags = merge(
    {
      Name = "nat-gw-1a-eip"
"Environment" = "dev"
"Project" = "aws-iam-roles"
"ManagedBy" = "Terraform"
"Owner" = "DarwinLopez"
"Purpose" = "NetworkInfrastructure"
},
    var.additional_tags
  )
  
  depends_on = [aws_internet_gateway.main_igw]
}

# NAT Gateway
resource "aws_nat_gateway" "nat_gw_1a" {
  allocation_id = aws_eip.nat_gw_1a_eip.id
  subnet_id     = aws_subnet.public_subnet_1a.id

  tags = merge(
    {
      Name = "nat-gw-1a"
"Environment" = "dev"
"Project" = "aws-iam-roles"
"ManagedBy" = "Terraform"
"Owner" = "DarwinLopez"
"Purpose" = "NetworkInfrastructure"
},
    var.additional_tags
  )

  depends_on = [aws_internet_gateway.main_igw]
}


# Route Tables
resource "aws_route_table" "public_rt" {
  vpc_id = aws_vpc.main_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
gateway_id = aws_internet_gateway.main_igw.id
}

  tags = merge(
    {
      Name = "public-rt"
      Type = "public"
"Environment" = "dev"
"Project" = "aws-iam-roles"
"ManagedBy" = "Terraform"
"Owner" = "DarwinLopez"
"Purpose" = "NetworkInfrastructure"
},
    var.additional_tags
  )
}

# Route Table Associations for public-rt
resource "aws_route_table_association" "public_rt_public_subnet_1a" {
  subnet_id      = aws_subnet.public_subnet_1a.id
  route_table_id = aws_route_table.public_rt.id
}
resource "aws_route_table_association" "public_rt_public_subnet_1b" {
  subnet_id      = aws_subnet.public_subnet_1b.id
  route_table_id = aws_route_table.public_rt.id
}

resource "aws_route_table" "private_rt_1a" {
  vpc_id = aws_vpc.main_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
nat_gateway_id = aws_nat_gateway.nat_gw_1a.id
}

  tags = merge(
    {
      Name = "private-rt-1a"
      Type = "private"
"Environment" = "dev"
"Project" = "aws-iam-roles"
"ManagedBy" = "Terraform"
"Owner" = "DarwinLopez"
"Purpose" = "NetworkInfrastructure"
},
    var.additional_tags
  )
}

# Route Table Associations for private-rt-1a
resource "aws_route_table_association" "private_rt_1a_private_subnet_1a" {
  subnet_id      = aws_subnet.private_subnet_1a.id
  route_table_id = aws_route_table.private_rt_1a.id
}
resource "aws_route_table_association" "private_rt_1a_db_subnet_1a" {
  subnet_id      = aws_subnet.db_subnet_1a.id
  route_table_id = aws_route_table.private_rt_1a.id
}


# ==============================================================================
# Outputs
# ==============================================================================

output "vpc_id" {
  description = "ID of the VPC"
  value       = aws_vpc.main_vpc.id
}

output "vpc_arn" {
  description = "ARN of the VPC"
  value       = aws_vpc.main_vpc.arn
}

output "vpc_cidr_block" {
  description = "CIDR block of the VPC"
  value       = aws_vpc.main_vpc.cidr_block
}

# Subnet outputs
output "public_subnet_1a_id" {
  description = "ID of public-subnet-1a subnet"
  value       = aws_subnet.public_subnet_1a.id
}
output "public_subnet_1b_id" {
  description = "ID of public-subnet-1b subnet"
  value       = aws_subnet.public_subnet_1b.id
}
output "private_subnet_1a_id" {
  description = "ID of private-subnet-1a subnet"
  value       = aws_subnet.private_subnet_1a.id
}
output "private_subnet_1b_id" {
  description = "ID of private-subnet-1b subnet"
  value       = aws_subnet.private_subnet_1b.id
}
output "db_subnet_1a_id" {
  description = "ID of db-subnet-1a subnet"
  value       = aws_subnet.db_subnet_1a.id
}
output "db_subnet_1b_id" {
  description = "ID of db-subnet-1b subnet"
  value       = aws_subnet.db_subnet_1b.id
}

output "internet_gateway_id" {
  description = "ID of the Internet Gateway"
  value       = aws_internet_gateway.main_igw.id
}
