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
      ComplianceScope     = "ISO27001,NIST-CSF"
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
      ComplianceScope      = "ISO27001,NIST-CSF,ZeroTrust"
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
# ROUTE TABLES
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

# Private Route Table
resource "aws_route_table" "private" {
  vpc_id = aws_vpc.sgsi_vpc_main.id

  tags = merge(
    var.common_tags,
    {
      Name                = "sgsi-private-rt"
      Type                = "private"
      AssetID             = "NET-RT-002"
    }
  )
}

# ==============================================================================
# ROUTE TABLE ASSOCIATIONS
# ==============================================================================
resource "aws_route_table_association" "public_1a" {
  subnet_id      = aws_subnet.dmz_public_1a.id
  route_table_id = aws_route_table.public.id
}

resource "aws_route_table_association" "public_1b" {
  subnet_id      = aws_subnet.dmz_public_1b.id
  route_table_id = aws_route_table.public.id
}

resource "aws_route_table_association" "private_1a" {
  subnet_id      = aws_subnet.app_private_1a.id
  route_table_id = aws_route_table.private.id
}

resource "aws_route_table_association" "private_1b" {
  subnet_id      = aws_subnet.app_private_1b.id
  route_table_id = aws_route_table.private.id
}

resource "aws_route_table_association" "db_private_1a" {
  subnet_id      = aws_subnet.db_private_1a.id
  route_table_id = aws_route_table.private.id
}

resource "aws_route_table_association" "db_private_1b" {
  subnet_id      = aws_subnet.db_private_1b.id
  route_table_id = aws_route_table.private.id
}