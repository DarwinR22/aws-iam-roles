# ==============================================================================
# LAYER 2: NETWORK
# VPC, Subnets, Security Groups, Route Tables, NAT Gateways
# ==============================================================================

terraform {
  required_version = ">= 1.5.0"
  
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
  
  backend "s3" {
    bucket         = "terraform-state-bucket-051963532279"
    key            = "sgsi/layer2-network/terraform.tfstate"
    region         = "us-east-1"
    dynamodb_table = "terraform-locks"
    encrypt        = true
  }
}

# ==============================================================================
# DATA SOURCES (Read from Layer 1)
# ==============================================================================
data "terraform_remote_state" "foundation" {
  backend = "s3"
  config = {
    bucket = "terraform-state-bucket-051963532279"
    key    = "sgsi/layer1-foundation/terraform.tfstate"
    region = "us-east-1"
  }
}

data "aws_caller_identity" "current" {}
data "aws_region" "current" {}

# ==============================================================================
# AWS PROVIDER CONFIGURATION
# ==============================================================================
provider "aws" {
  region = var.aws_region
  
  default_tags {
    tags = {
      Project              = "SGSI-Implementation"
      Layer                = "Network"
      Environment          = var.environment
      ManagedBy           = "Terraform"
      SecurityLevel       = "High"
      ComplianceScope     = "ISO27001+NIST-CSF"
      CreatedBy           = "GitHub-Actions"
      MaintenanceWindow   = "Sunday-2AM-6AM"
    }
  }
}

# ==============================================================================
# VPC RESOURCE
# ==============================================================================
resource "aws_vpc" "sgsi_vpc_main" {
  cidr_block           = var.vpc_cidr
  instance_tenancy     = "default"
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = merge(
    var.common_tags,
    {
      Name                 = "sgsi-vpc-main"
      AssetID              = "NET-VPC-001"
      AssetType            = "Network-Infrastructure"
      AssetOwner           = "SGSI-Team"
      DataClassification   = "Internal"
      ISO27001Control      = "A.13.1.1,A.13.1.2,A.13.2.1"
      SecurityLevel        = "High"
      ComplianceScope      = "ISO27001+NIST-CSF+ZeroTrust"
      BackupRequired       = "No"
      MonitoringEnabled    = "Yes"
      LoggingEnabled       = "Yes"
    }
  )
}

# ==============================================================================
# INTERNET GATEWAY
# ==============================================================================
resource "aws_internet_gateway" "sgsi_igw" {
  vpc_id = aws_vpc.sgsi_vpc_main.id

  tags = merge(
    var.common_tags,
    {
      Name                = "sgsi-igw"
      AssetID             = "NET-IGW-001"
      AssetType           = "Network-Gateway"
      SecurityLevel       = "High"
    }
  )
}

# ==============================================================================
# AVAILABILITY ZONES DATA
# ==============================================================================
data "aws_availability_zones" "available" {
  state = "available"
}

# ==============================================================================
# PUBLIC SUBNETS (DMZ TIER)
# ==============================================================================
resource "aws_subnet" "dmz_public_1a" {
  vpc_id                  = aws_vpc.sgsi_vpc_main.id
  cidr_block              = "10.0.1.0/24"
  availability_zone       = "us-east-1a"
  map_public_ip_on_launch = true

  tags = merge(
    var.common_tags,
    {
      Name                = "dmz-public-1a"
      Tier                = "dmz"
      Type                = "public"
      AssetID             = "NET-SUB-001"
      SecurityLevel       = "Medium"
    }
  )
}

resource "aws_subnet" "dmz_public_1b" {
  vpc_id                  = aws_vpc.sgsi_vpc_main.id
  cidr_block              = "10.0.2.0/24"
  availability_zone       = "us-east-1b"
  map_public_ip_on_launch = true

  tags = merge(
    var.common_tags,
    {
      Name                = "dmz-public-1b"
      Tier                = "dmz"
      Type                = "public"
      AssetID             = "NET-SUB-002"
      SecurityLevel       = "Medium"
    }
  )
}

# ==============================================================================
# PRIVATE SUBNETS (APPLICATION TIER)
# ==============================================================================
resource "aws_subnet" "app_private_1a" {
  vpc_id            = aws_vpc.sgsi_vpc_main.id
  cidr_block        = "10.0.16.0/24"
  availability_zone = "us-east-1a"

  tags = merge(
    var.common_tags,
    {
      Name                = "app-private-1a"
      Tier                = "application"
      Type                = "private"
      AssetID             = "NET-SUB-003"
      SecurityLevel       = "High"
    }
  )
}

resource "aws_subnet" "app_private_1b" {
  vpc_id            = aws_vpc.sgsi_vpc_main.id
  cidr_block        = "10.0.17.0/24"
  availability_zone = "us-east-1b"

  tags = merge(
    var.common_tags,
    {
      Name                = "app-private-1b"
      Tier                = "application"
      Type                = "private"
      AssetID             = "NET-SUB-004"
      SecurityLevel       = "High"
    }
  )
}

# ==============================================================================
# PRIVATE SUBNETS (DATABASE TIER)
# ==============================================================================
resource "aws_subnet" "db_private_1a" {
  vpc_id            = aws_vpc.sgsi_vpc_main.id
  cidr_block        = "10.0.32.0/24"
  availability_zone = "us-east-1a"

  tags = merge(
    var.common_tags,
    {
      Name                = "db-private-1a"
      Tier                = "database"
      Type                = "private"
      AssetID             = "NET-SUB-005"
      SecurityLevel       = "Critical"
    }
  )
}

resource "aws_subnet" "db_private_1b" {
  vpc_id            = aws_vpc.sgsi_vpc_main.id
  cidr_block        = "10.0.33.0/24"
  availability_zone = "us-east-1b"

  tags = merge(
    var.common_tags,
    {
      Name                = "db-private-1b"
      Tier                = "database"
      Type                = "private"
      AssetID             = "NET-SUB-006"
      SecurityLevel       = "Critical"
    }
  )
}

# ==============================================================================
# ROUTE TABLES - PUBLIC ONLY
# ==============================================================================
# Public Route Table
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.sgsi_vpc_main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.sgsi_igw.id
  }

  tags = merge(
    var.common_tags,
    {
      Name                = "sgsi-public-rt"
      Type                = "public"
      AssetID             = "NET-RT-001"
    }
  )
}

# Note: Private route tables are now managed by the nat-gateway-ha module

# ==============================================================================
# ROUTE TABLE ASSOCIATIONS - PUBLIC SUBNETS
# ==============================================================================
resource "aws_route_table_association" "public_1a" {
  subnet_id      = aws_subnet.dmz_public_1a.id
  route_table_id = aws_route_table.public.id
}

resource "aws_route_table_association" "public_1b" {
  subnet_id      = aws_subnet.dmz_public_1b.id
  route_table_id = aws_route_table.public.id
}

# ==============================================================================
# ENHANCED NETWORK SECURITY MODULES
# ==============================================================================

# Module: VPC Flow Logs for network traffic monitoring
module "vpc_flow_logs" {
  source = "../../modules/network/vpc-flow-logs"

  vpc_id     = aws_vpc.sgsi_vpc_main.id
  vpc_name   = "sgsi-vpc-main"

  traffic_type       = "ALL"
  log_retention_days = 90

  enable_rejected_traffic_alarm = true
  rejected_traffic_threshold    = 100

  enable_ssh_monitoring = true
  alarm_actions         = [] # Add SNS topic ARNs here if needed

  tags = var.common_tags
}

# Module: NAT Gateways High Availability
module "nat_gateway_ha" {
  source = "../../modules/network/nat-gateway-ha"

  vpc_id               = aws_vpc.sgsi_vpc_main.id
  name_prefix          = "sgsi"
  internet_gateway_id  = aws_internet_gateway.sgsi_igw.id
  
  availability_zones = ["us-east-1a", "us-east-1b"]
  public_subnet_ids  = [
    aws_subnet.dmz_public_1a.id,
    aws_subnet.dmz_public_1b.id
  ]

  app_subnet_ids_az1 = [aws_subnet.app_private_1a.id]
  app_subnet_ids_az2 = [aws_subnet.app_private_1b.id]
  db_subnet_ids_az1  = [aws_subnet.db_private_1a.id]
  db_subnet_ids_az2  = [aws_subnet.db_private_1b.id]

  enable_monitoring     = true
  min_bytes_threshold   = 1000
  alarm_actions         = [] # Add SNS topic ARNs here if needed

  tags = var.common_tags
}

# Module: Network ACLs (Defense in Depth)
module "network_acls" {
  source = "../../modules/network/network-acls"

  vpc_id      = aws_vpc.sgsi_vpc_main.id
  vpc_cidr    = var.vpc_cidr
  name_prefix = "sgsi"

  dmz_subnet_ids = [
    aws_subnet.dmz_public_1a.id,
    aws_subnet.dmz_public_1b.id
  ]

  app_subnet_ids = [
    aws_subnet.app_private_1a.id,
    aws_subnet.app_private_1b.id
  ]

  db_subnet_ids = [
    aws_subnet.db_private_1a.id,
    aws_subnet.db_private_1b.id
  ]

  tags = var.common_tags
}

# Module: VPC Endpoints for cost and security optimization
module "vpc_endpoints" {
  source = "../../modules/network/vpc-endpoints"

  vpc_id      = aws_vpc.sgsi_vpc_main.id
  vpc_cidr    = var.vpc_cidr
  region      = var.aws_region
  name_prefix = "sgsi"

  route_table_ids = [
    aws_route_table.public.id,
    module.nat_gateway_ha.private_route_table_ids["az1"],
    module.nat_gateway_ha.private_route_table_ids["az2"]
  ]

  private_subnet_ids = [
    aws_subnet.app_private_1a.id,
    aws_subnet.app_private_1b.id
  ]

  # Restrict access to specific buckets (empty = all buckets)
  allowed_s3_buckets = [
    "terraform-state-bucket-051963532279"
  ]

  # Restrict access to specific tables (empty = all tables)
  allowed_dynamodb_tables = [
    "terraform-locks"
  ]

  enable_secrets_manager_endpoint = false
  enable_kms_endpoint             = false

  tags = var.common_tags
}