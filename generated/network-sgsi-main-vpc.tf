# ==============================================================================
# VPC Module: sgsi-vpc-main
# ==============================================================================
# Generated: 2025-10-19T03:23:40.506084
# Source: sgsi-main-vpc.yaml
# ==============================================================================

# Variables
variable "additional_tags" {
  description = "Additional tags to be applied to all resources"
  type        = map(string)
  default     = {}
}

# VPC Resource
resource "aws_vpc" "sgsi_vpc_main" {
  cidr_block           = "10.0.0.0/16"
  instance_tenancy     = "default"
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = merge(
    {
      Name                 = "sgsi-vpc-main"
      "AssetID"            = "NET-VPC-001"
      "AssetType"          = "Network-Infrastructure"
      "AssetOwner"         = "DarwinLopez"
      "DataClassification" = "Internal"
      "ISO27001-Control"   = "A.13.1.1,A.13.1.2,A.13.2.1"
      "SecurityLevel"      = "High"
      "ComplianceScope"    = "ISO27001,NIST-CSF,ZeroTrust"
      "Environment"        = "Production"
      "Project"            = "SGSI-Implementation"
      "CostCenter"         = "Security-Infrastructure"
      "MaintenanceWindow"  = "Sunday-2AM-6AM"
      "TechnicalContact"   = "darwin.lopez@example.com"
      "SecurityContact"    = "security@example.com"
      "BusinessOwner"      = "SGSI-Team"
      "BackupRequired"     = "Yes"
      "MonitoringEnabled"  = "Yes"
      "LoggingEnabled"     = "Yes"
      "ChangeManagement"   = "ITIL-v4"
    },
    var.additional_tags
  )
}

# Internet Gateway
resource "aws_internet_gateway" "sgsi_igw" {
  vpc_id = aws_vpc.sgsi_vpc_main.id

  tags = merge(
    {
      Name                 = "sgsi-igw"
      "AssetID"            = "NET-VPC-001"
      "AssetType"          = "Network-Infrastructure"
      "AssetOwner"         = "DarwinLopez"
      "DataClassification" = "Internal"
      "ISO27001-Control"   = "A.13.1.1,A.13.1.2,A.13.2.1"
      "SecurityLevel"      = "High"
      "ComplianceScope"    = "ISO27001,NIST-CSF,ZeroTrust"
      "Environment"        = "Production"
      "Project"            = "SGSI-Implementation"
      "CostCenter"         = "Security-Infrastructure"
      "MaintenanceWindow"  = "Sunday-2AM-6AM"
      "TechnicalContact"   = "darwin.lopez@example.com"
      "SecurityContact"    = "security@example.com"
      "BusinessOwner"      = "SGSI-Team"
      "BackupRequired"     = "Yes"
      "MonitoringEnabled"  = "Yes"
      "LoggingEnabled"     = "Yes"
      "ChangeManagement"   = "ITIL-v4"
    },
    var.additional_tags
  )
}

# Subnets
resource "aws_subnet" "dmz_public_1a" {
  vpc_id                  = aws_vpc.sgsi_vpc_main.id
  cidr_block              = "10.0.1.0/24"
  availability_zone       = "us-east-1a"
  map_public_ip_on_launch = true

  tags = merge(
    {
      Name                 = "dmz-public-1a"
      Type                 = "public"
      "AssetID"            = "NET-VPC-001"
      "AssetType"          = "Network-Infrastructure"
      "AssetOwner"         = "DarwinLopez"
      "DataClassification" = "Internal"
      "ISO27001-Control"   = "A.13.1.1,A.13.1.2,A.13.2.1"
      "SecurityLevel"      = "High"
      "ComplianceScope"    = "ISO27001,NIST-CSF,ZeroTrust"
      "Environment"        = "Production"
      "Project"            = "SGSI-Implementation"
      "CostCenter"         = "Security-Infrastructure"
      "MaintenanceWindow"  = "Sunday-2AM-6AM"
      "TechnicalContact"   = "darwin.lopez@example.com"
      "SecurityContact"    = "security@example.com"
      "BusinessOwner"      = "SGSI-Team"
      "BackupRequired"     = "Yes"
      "MonitoringEnabled"  = "Yes"
      "LoggingEnabled"     = "Yes"
      "ChangeManagement"   = "ITIL-v4"
    },
    var.additional_tags
  )
}

resource "aws_subnet" "dmz_public_1b" {
  vpc_id                  = aws_vpc.sgsi_vpc_main.id
  cidr_block              = "10.0.2.0/24"
  availability_zone       = "us-east-1b"
  map_public_ip_on_launch = true

  tags = merge(
    {
      Name                 = "dmz-public-1b"
      Type                 = "public"
      "AssetID"            = "NET-VPC-001"
      "AssetType"          = "Network-Infrastructure"
      "AssetOwner"         = "DarwinLopez"
      "DataClassification" = "Internal"
      "ISO27001-Control"   = "A.13.1.1,A.13.1.2,A.13.2.1"
      "SecurityLevel"      = "High"
      "ComplianceScope"    = "ISO27001,NIST-CSF,ZeroTrust"
      "Environment"        = "Production"
      "Project"            = "SGSI-Implementation"
      "CostCenter"         = "Security-Infrastructure"
      "MaintenanceWindow"  = "Sunday-2AM-6AM"
      "TechnicalContact"   = "darwin.lopez@example.com"
      "SecurityContact"    = "security@example.com"
      "BusinessOwner"      = "SGSI-Team"
      "BackupRequired"     = "Yes"
      "MonitoringEnabled"  = "Yes"
      "LoggingEnabled"     = "Yes"
      "ChangeManagement"   = "ITIL-v4"
    },
    var.additional_tags
  )
}

resource "aws_subnet" "dmz_public_1c" {
  vpc_id                  = aws_vpc.sgsi_vpc_main.id
  cidr_block              = "10.0.3.0/24"
  availability_zone       = "us-east-1c"
  map_public_ip_on_launch = true

  tags = merge(
    {
      Name                 = "dmz-public-1c"
      Type                 = "public"
      "AssetID"            = "NET-VPC-001"
      "AssetType"          = "Network-Infrastructure"
      "AssetOwner"         = "DarwinLopez"
      "DataClassification" = "Internal"
      "ISO27001-Control"   = "A.13.1.1,A.13.1.2,A.13.2.1"
      "SecurityLevel"      = "High"
      "ComplianceScope"    = "ISO27001,NIST-CSF,ZeroTrust"
      "Environment"        = "Production"
      "Project"            = "SGSI-Implementation"
      "CostCenter"         = "Security-Infrastructure"
      "MaintenanceWindow"  = "Sunday-2AM-6AM"
      "TechnicalContact"   = "darwin.lopez@example.com"
      "SecurityContact"    = "security@example.com"
      "BusinessOwner"      = "SGSI-Team"
      "BackupRequired"     = "Yes"
      "MonitoringEnabled"  = "Yes"
      "LoggingEnabled"     = "Yes"
      "ChangeManagement"   = "ITIL-v4"
    },
    var.additional_tags
  )
}

resource "aws_subnet" "app_private_1a" {
  vpc_id                  = aws_vpc.sgsi_vpc_main.id
  cidr_block              = "10.0.16.0/24"
  availability_zone       = "us-east-1a"
  map_public_ip_on_launch = false

  tags = merge(
    {
      Name                 = "app-private-1a"
      Type                 = "private"
      "AssetID"            = "NET-VPC-001"
      "AssetType"          = "Network-Infrastructure"
      "AssetOwner"         = "DarwinLopez"
      "DataClassification" = "Internal"
      "ISO27001-Control"   = "A.13.1.1,A.13.1.2,A.13.2.1"
      "SecurityLevel"      = "High"
      "ComplianceScope"    = "ISO27001,NIST-CSF,ZeroTrust"
      "Environment"        = "Production"
      "Project"            = "SGSI-Implementation"
      "CostCenter"         = "Security-Infrastructure"
      "MaintenanceWindow"  = "Sunday-2AM-6AM"
      "TechnicalContact"   = "darwin.lopez@example.com"
      "SecurityContact"    = "security@example.com"
      "BusinessOwner"      = "SGSI-Team"
      "BackupRequired"     = "Yes"
      "MonitoringEnabled"  = "Yes"
      "LoggingEnabled"     = "Yes"
      "ChangeManagement"   = "ITIL-v4"
    },
    var.additional_tags
  )
}

resource "aws_subnet" "app_private_1b" {
  vpc_id                  = aws_vpc.sgsi_vpc_main.id
  cidr_block              = "10.0.17.0/24"
  availability_zone       = "us-east-1b"
  map_public_ip_on_launch = false

  tags = merge(
    {
      Name                 = "app-private-1b"
      Type                 = "private"
      "AssetID"            = "NET-VPC-001"
      "AssetType"          = "Network-Infrastructure"
      "AssetOwner"         = "DarwinLopez"
      "DataClassification" = "Internal"
      "ISO27001-Control"   = "A.13.1.1,A.13.1.2,A.13.2.1"
      "SecurityLevel"      = "High"
      "ComplianceScope"    = "ISO27001,NIST-CSF,ZeroTrust"
      "Environment"        = "Production"
      "Project"            = "SGSI-Implementation"
      "CostCenter"         = "Security-Infrastructure"
      "MaintenanceWindow"  = "Sunday-2AM-6AM"
      "TechnicalContact"   = "darwin.lopez@example.com"
      "SecurityContact"    = "security@example.com"
      "BusinessOwner"      = "SGSI-Team"
      "BackupRequired"     = "Yes"
      "MonitoringEnabled"  = "Yes"
      "LoggingEnabled"     = "Yes"
      "ChangeManagement"   = "ITIL-v4"
    },
    var.additional_tags
  )
}

resource "aws_subnet" "app_private_1c" {
  vpc_id                  = aws_vpc.sgsi_vpc_main.id
  cidr_block              = "10.0.18.0/24"
  availability_zone       = "us-east-1c"
  map_public_ip_on_launch = false

  tags = merge(
    {
      Name                 = "app-private-1c"
      Type                 = "private"
      "AssetID"            = "NET-VPC-001"
      "AssetType"          = "Network-Infrastructure"
      "AssetOwner"         = "DarwinLopez"
      "DataClassification" = "Internal"
      "ISO27001-Control"   = "A.13.1.1,A.13.1.2,A.13.2.1"
      "SecurityLevel"      = "High"
      "ComplianceScope"    = "ISO27001,NIST-CSF,ZeroTrust"
      "Environment"        = "Production"
      "Project"            = "SGSI-Implementation"
      "CostCenter"         = "Security-Infrastructure"
      "MaintenanceWindow"  = "Sunday-2AM-6AM"
      "TechnicalContact"   = "darwin.lopez@example.com"
      "SecurityContact"    = "security@example.com"
      "BusinessOwner"      = "SGSI-Team"
      "BackupRequired"     = "Yes"
      "MonitoringEnabled"  = "Yes"
      "LoggingEnabled"     = "Yes"
      "ChangeManagement"   = "ITIL-v4"
    },
    var.additional_tags
  )
}

resource "aws_subnet" "db_private_1a" {
  vpc_id                  = aws_vpc.sgsi_vpc_main.id
  cidr_block              = "10.0.32.0/24"
  availability_zone       = "us-east-1a"
  map_public_ip_on_launch = false

  tags = merge(
    {
      Name                 = "db-private-1a"
      Type                 = "private"
      "AssetID"            = "NET-VPC-001"
      "AssetType"          = "Network-Infrastructure"
      "AssetOwner"         = "DarwinLopez"
      "DataClassification" = "Internal"
      "ISO27001-Control"   = "A.13.1.1,A.13.1.2,A.13.2.1"
      "SecurityLevel"      = "High"
      "ComplianceScope"    = "ISO27001,NIST-CSF,ZeroTrust"
      "Environment"        = "Production"
      "Project"            = "SGSI-Implementation"
      "CostCenter"         = "Security-Infrastructure"
      "MaintenanceWindow"  = "Sunday-2AM-6AM"
      "TechnicalContact"   = "darwin.lopez@example.com"
      "SecurityContact"    = "security@example.com"
      "BusinessOwner"      = "SGSI-Team"
      "BackupRequired"     = "Yes"
      "MonitoringEnabled"  = "Yes"
      "LoggingEnabled"     = "Yes"
      "ChangeManagement"   = "ITIL-v4"
    },
    var.additional_tags
  )
}

resource "aws_subnet" "db_private_1b" {
  vpc_id                  = aws_vpc.sgsi_vpc_main.id
  cidr_block              = "10.0.33.0/24"
  availability_zone       = "us-east-1b"
  map_public_ip_on_launch = false

  tags = merge(
    {
      Name                 = "db-private-1b"
      Type                 = "private"
      "AssetID"            = "NET-VPC-001"
      "AssetType"          = "Network-Infrastructure"
      "AssetOwner"         = "DarwinLopez"
      "DataClassification" = "Internal"
      "ISO27001-Control"   = "A.13.1.1,A.13.1.2,A.13.2.1"
      "SecurityLevel"      = "High"
      "ComplianceScope"    = "ISO27001,NIST-CSF,ZeroTrust"
      "Environment"        = "Production"
      "Project"            = "SGSI-Implementation"
      "CostCenter"         = "Security-Infrastructure"
      "MaintenanceWindow"  = "Sunday-2AM-6AM"
      "TechnicalContact"   = "darwin.lopez@example.com"
      "SecurityContact"    = "security@example.com"
      "BusinessOwner"      = "SGSI-Team"
      "BackupRequired"     = "Yes"
      "MonitoringEnabled"  = "Yes"
      "LoggingEnabled"     = "Yes"
      "ChangeManagement"   = "ITIL-v4"
    },
    var.additional_tags
  )
}

resource "aws_subnet" "db_private_1c" {
  vpc_id                  = aws_vpc.sgsi_vpc_main.id
  cidr_block              = "10.0.34.0/24"
  availability_zone       = "us-east-1c"
  map_public_ip_on_launch = false

  tags = merge(
    {
      Name                 = "db-private-1c"
      Type                 = "private"
      "AssetID"            = "NET-VPC-001"
      "AssetType"          = "Network-Infrastructure"
      "AssetOwner"         = "DarwinLopez"
      "DataClassification" = "Internal"
      "ISO27001-Control"   = "A.13.1.1,A.13.1.2,A.13.2.1"
      "SecurityLevel"      = "High"
      "ComplianceScope"    = "ISO27001,NIST-CSF,ZeroTrust"
      "Environment"        = "Production"
      "Project"            = "SGSI-Implementation"
      "CostCenter"         = "Security-Infrastructure"
      "MaintenanceWindow"  = "Sunday-2AM-6AM"
      "TechnicalContact"   = "darwin.lopez@example.com"
      "SecurityContact"    = "security@example.com"
      "BusinessOwner"      = "SGSI-Team"
      "BackupRequired"     = "Yes"
      "MonitoringEnabled"  = "Yes"
      "LoggingEnabled"     = "Yes"
      "ChangeManagement"   = "ITIL-v4"
    },
    var.additional_tags
  )
}

resource "aws_subnet" "mgmt_private_1a" {
  vpc_id                  = aws_vpc.sgsi_vpc_main.id
  cidr_block              = "10.0.48.0/24"
  availability_zone       = "us-east-1a"
  map_public_ip_on_launch = false

  tags = merge(
    {
      Name                 = "mgmt-private-1a"
      Type                 = "private"
      "AssetID"            = "NET-VPC-001"
      "AssetType"          = "Network-Infrastructure"
      "AssetOwner"         = "DarwinLopez"
      "DataClassification" = "Internal"
      "ISO27001-Control"   = "A.13.1.1,A.13.1.2,A.13.2.1"
      "SecurityLevel"      = "High"
      "ComplianceScope"    = "ISO27001,NIST-CSF,ZeroTrust"
      "Environment"        = "Production"
      "Project"            = "SGSI-Implementation"
      "CostCenter"         = "Security-Infrastructure"
      "MaintenanceWindow"  = "Sunday-2AM-6AM"
      "TechnicalContact"   = "darwin.lopez@example.com"
      "SecurityContact"    = "security@example.com"
      "BusinessOwner"      = "SGSI-Team"
      "BackupRequired"     = "Yes"
      "MonitoringEnabled"  = "Yes"
      "LoggingEnabled"     = "Yes"
      "ChangeManagement"   = "ITIL-v4"
    },
    var.additional_tags
  )
}

resource "aws_subnet" "mgmt_private_1b" {
  vpc_id                  = aws_vpc.sgsi_vpc_main.id
  cidr_block              = "10.0.49.0/24"
  availability_zone       = "us-east-1b"
  map_public_ip_on_launch = false

  tags = merge(
    {
      Name                 = "mgmt-private-1b"
      Type                 = "private"
      "AssetID"            = "NET-VPC-001"
      "AssetType"          = "Network-Infrastructure"
      "AssetOwner"         = "DarwinLopez"
      "DataClassification" = "Internal"
      "ISO27001-Control"   = "A.13.1.1,A.13.1.2,A.13.2.1"
      "SecurityLevel"      = "High"
      "ComplianceScope"    = "ISO27001,NIST-CSF,ZeroTrust"
      "Environment"        = "Production"
      "Project"            = "SGSI-Implementation"
      "CostCenter"         = "Security-Infrastructure"
      "MaintenanceWindow"  = "Sunday-2AM-6AM"
      "TechnicalContact"   = "darwin.lopez@example.com"
      "SecurityContact"    = "security@example.com"
      "BusinessOwner"      = "SGSI-Team"
      "BackupRequired"     = "Yes"
      "MonitoringEnabled"  = "Yes"
      "LoggingEnabled"     = "Yes"
      "ChangeManagement"   = "ITIL-v4"
    },
    var.additional_tags
  )
}


# Elastic IPs for NAT Gateways
resource "aws_eip" "sgsi_nat_1a_eip" {
  domain = "vpc"

  tags = merge(
    {
      Name                 = "sgsi-nat-1a-eip"
      "AssetID"            = "NET-VPC-001"
      "AssetType"          = "Network-Infrastructure"
      "AssetOwner"         = "DarwinLopez"
      "DataClassification" = "Internal"
      "ISO27001-Control"   = "A.13.1.1,A.13.1.2,A.13.2.1"
      "SecurityLevel"      = "High"
      "ComplianceScope"    = "ISO27001,NIST-CSF,ZeroTrust"
      "Environment"        = "Production"
      "Project"            = "SGSI-Implementation"
      "CostCenter"         = "Security-Infrastructure"
      "MaintenanceWindow"  = "Sunday-2AM-6AM"
      "TechnicalContact"   = "darwin.lopez@example.com"
      "SecurityContact"    = "security@example.com"
      "BusinessOwner"      = "SGSI-Team"
      "BackupRequired"     = "Yes"
      "MonitoringEnabled"  = "Yes"
      "LoggingEnabled"     = "Yes"
      "ChangeManagement"   = "ITIL-v4"
    },
    var.additional_tags
  )

  depends_on = [aws_internet_gateway.sgsi_igw]
}

# NAT Gateway
resource "aws_nat_gateway" "sgsi_nat_1a" {
  allocation_id = aws_eip.sgsi_nat_1a_eip.id
  subnet_id     = aws_subnet.dmz_public_1a.id

  tags = merge(
    {
      Name                 = "sgsi-nat-1a"
      "AssetID"            = "NET-VPC-001"
      "AssetType"          = "Network-Infrastructure"
      "AssetOwner"         = "DarwinLopez"
      "DataClassification" = "Internal"
      "ISO27001-Control"   = "A.13.1.1,A.13.1.2,A.13.2.1"
      "SecurityLevel"      = "High"
      "ComplianceScope"    = "ISO27001,NIST-CSF,ZeroTrust"
      "Environment"        = "Production"
      "Project"            = "SGSI-Implementation"
      "CostCenter"         = "Security-Infrastructure"
      "MaintenanceWindow"  = "Sunday-2AM-6AM"
      "TechnicalContact"   = "darwin.lopez@example.com"
      "SecurityContact"    = "security@example.com"
      "BusinessOwner"      = "SGSI-Team"
      "BackupRequired"     = "Yes"
      "MonitoringEnabled"  = "Yes"
      "LoggingEnabled"     = "Yes"
      "ChangeManagement"   = "ITIL-v4"
    },
    var.additional_tags
  )

  depends_on = [aws_internet_gateway.sgsi_igw]
}

resource "aws_eip" "sgsi_nat_1b_eip" {
  domain = "vpc"

  tags = merge(
    {
      Name                 = "sgsi-nat-1b-eip"
      "AssetID"            = "NET-VPC-001"
      "AssetType"          = "Network-Infrastructure"
      "AssetOwner"         = "DarwinLopez"
      "DataClassification" = "Internal"
      "ISO27001-Control"   = "A.13.1.1,A.13.1.2,A.13.2.1"
      "SecurityLevel"      = "High"
      "ComplianceScope"    = "ISO27001,NIST-CSF,ZeroTrust"
      "Environment"        = "Production"
      "Project"            = "SGSI-Implementation"
      "CostCenter"         = "Security-Infrastructure"
      "MaintenanceWindow"  = "Sunday-2AM-6AM"
      "TechnicalContact"   = "darwin.lopez@example.com"
      "SecurityContact"    = "security@example.com"
      "BusinessOwner"      = "SGSI-Team"
      "BackupRequired"     = "Yes"
      "MonitoringEnabled"  = "Yes"
      "LoggingEnabled"     = "Yes"
      "ChangeManagement"   = "ITIL-v4"
    },
    var.additional_tags
  )

  depends_on = [aws_internet_gateway.sgsi_igw]
}

# NAT Gateway
resource "aws_nat_gateway" "sgsi_nat_1b" {
  allocation_id = aws_eip.sgsi_nat_1b_eip.id
  subnet_id     = aws_subnet.dmz_public_1b.id

  tags = merge(
    {
      Name                 = "sgsi-nat-1b"
      "AssetID"            = "NET-VPC-001"
      "AssetType"          = "Network-Infrastructure"
      "AssetOwner"         = "DarwinLopez"
      "DataClassification" = "Internal"
      "ISO27001-Control"   = "A.13.1.1,A.13.1.2,A.13.2.1"
      "SecurityLevel"      = "High"
      "ComplianceScope"    = "ISO27001,NIST-CSF,ZeroTrust"
      "Environment"        = "Production"
      "Project"            = "SGSI-Implementation"
      "CostCenter"         = "Security-Infrastructure"
      "MaintenanceWindow"  = "Sunday-2AM-6AM"
      "TechnicalContact"   = "darwin.lopez@example.com"
      "SecurityContact"    = "security@example.com"
      "BusinessOwner"      = "SGSI-Team"
      "BackupRequired"     = "Yes"
      "MonitoringEnabled"  = "Yes"
      "LoggingEnabled"     = "Yes"
      "ChangeManagement"   = "ITIL-v4"
    },
    var.additional_tags
  )

  depends_on = [aws_internet_gateway.sgsi_igw]
}


# Route Tables
resource "aws_route_table" "dmz_route_table" {
  vpc_id = aws_vpc.sgsi_vpc_main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.sgsi_igw.id
  }

  tags = merge(
    {
      Name                 = "dmz-route-table"
      Type                 = "public"
      "AssetID"            = "NET-VPC-001"
      "AssetType"          = "Network-Infrastructure"
      "AssetOwner"         = "DarwinLopez"
      "DataClassification" = "Internal"
      "ISO27001-Control"   = "A.13.1.1,A.13.1.2,A.13.2.1"
      "SecurityLevel"      = "High"
      "ComplianceScope"    = "ISO27001,NIST-CSF,ZeroTrust"
      "Environment"        = "Production"
      "Project"            = "SGSI-Implementation"
      "CostCenter"         = "Security-Infrastructure"
      "MaintenanceWindow"  = "Sunday-2AM-6AM"
      "TechnicalContact"   = "darwin.lopez@example.com"
      "SecurityContact"    = "security@example.com"
      "BusinessOwner"      = "SGSI-Team"
      "BackupRequired"     = "Yes"
      "MonitoringEnabled"  = "Yes"
      "LoggingEnabled"     = "Yes"
      "ChangeManagement"   = "ITIL-v4"
    },
    var.additional_tags
  )
}

# Route Table Associations for dmz-route-table
resource "aws_route_table_association" "dmz_route_table_dmz_public_1a" {
  subnet_id      = aws_subnet.dmz_public_1a.id
  route_table_id = aws_route_table.dmz_route_table.id
}
resource "aws_route_table_association" "dmz_route_table_dmz_public_1b" {
  subnet_id      = aws_subnet.dmz_public_1b.id
  route_table_id = aws_route_table.dmz_route_table.id
}
resource "aws_route_table_association" "dmz_route_table_dmz_public_1c" {
  subnet_id      = aws_subnet.dmz_public_1c.id
  route_table_id = aws_route_table.dmz_route_table.id
}

resource "aws_route_table" "app_route_table_1a" {
  vpc_id = aws_vpc.sgsi_vpc_main.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.sgsi_nat_1a.id
  }

  tags = merge(
    {
      Name                 = "app-route-table-1a"
      Type                 = "private"
      "AssetID"            = "NET-VPC-001"
      "AssetType"          = "Network-Infrastructure"
      "AssetOwner"         = "DarwinLopez"
      "DataClassification" = "Internal"
      "ISO27001-Control"   = "A.13.1.1,A.13.1.2,A.13.2.1"
      "SecurityLevel"      = "High"
      "ComplianceScope"    = "ISO27001,NIST-CSF,ZeroTrust"
      "Environment"        = "Production"
      "Project"            = "SGSI-Implementation"
      "CostCenter"         = "Security-Infrastructure"
      "MaintenanceWindow"  = "Sunday-2AM-6AM"
      "TechnicalContact"   = "darwin.lopez@example.com"
      "SecurityContact"    = "security@example.com"
      "BusinessOwner"      = "SGSI-Team"
      "BackupRequired"     = "Yes"
      "MonitoringEnabled"  = "Yes"
      "LoggingEnabled"     = "Yes"
      "ChangeManagement"   = "ITIL-v4"
    },
    var.additional_tags
  )
}

# Route Table Associations for app-route-table-1a
resource "aws_route_table_association" "app_route_table_1a_app_private_1a" {
  subnet_id      = aws_subnet.app_private_1a.id
  route_table_id = aws_route_table.app_route_table_1a.id
}
resource "aws_route_table_association" "app_route_table_1a_db_private_1a" {
  subnet_id      = aws_subnet.db_private_1a.id
  route_table_id = aws_route_table.app_route_table_1a.id
}
resource "aws_route_table_association" "app_route_table_1a_mgmt_private_1a" {
  subnet_id      = aws_subnet.mgmt_private_1a.id
  route_table_id = aws_route_table.app_route_table_1a.id
}

resource "aws_route_table" "app_route_table_1b" {
  vpc_id = aws_vpc.sgsi_vpc_main.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.sgsi_nat_1b.id
  }

  tags = merge(
    {
      Name                 = "app-route-table-1b"
      Type                 = "private"
      "AssetID"            = "NET-VPC-001"
      "AssetType"          = "Network-Infrastructure"
      "AssetOwner"         = "DarwinLopez"
      "DataClassification" = "Internal"
      "ISO27001-Control"   = "A.13.1.1,A.13.1.2,A.13.2.1"
      "SecurityLevel"      = "High"
      "ComplianceScope"    = "ISO27001,NIST-CSF,ZeroTrust"
      "Environment"        = "Production"
      "Project"            = "SGSI-Implementation"
      "CostCenter"         = "Security-Infrastructure"
      "MaintenanceWindow"  = "Sunday-2AM-6AM"
      "TechnicalContact"   = "darwin.lopez@example.com"
      "SecurityContact"    = "security@example.com"
      "BusinessOwner"      = "SGSI-Team"
      "BackupRequired"     = "Yes"
      "MonitoringEnabled"  = "Yes"
      "LoggingEnabled"     = "Yes"
      "ChangeManagement"   = "ITIL-v4"
    },
    var.additional_tags
  )
}

# Route Table Associations for app-route-table-1b
resource "aws_route_table_association" "app_route_table_1b_app_private_1b" {
  subnet_id      = aws_subnet.app_private_1b.id
  route_table_id = aws_route_table.app_route_table_1b.id
}
resource "aws_route_table_association" "app_route_table_1b_db_private_1b" {
  subnet_id      = aws_subnet.db_private_1b.id
  route_table_id = aws_route_table.app_route_table_1b.id
}
resource "aws_route_table_association" "app_route_table_1b_mgmt_private_1b" {
  subnet_id      = aws_subnet.mgmt_private_1b.id
  route_table_id = aws_route_table.app_route_table_1b.id
}

resource "aws_route_table" "db_route_table" {
  vpc_id = aws_vpc.sgsi_vpc_main.id


  tags = merge(
    {
      Name                 = "db-route-table"
      Type                 = "isolated"
      "AssetID"            = "NET-VPC-001"
      "AssetType"          = "Network-Infrastructure"
      "AssetOwner"         = "DarwinLopez"
      "DataClassification" = "Internal"
      "ISO27001-Control"   = "A.13.1.1,A.13.1.2,A.13.2.1"
      "SecurityLevel"      = "High"
      "ComplianceScope"    = "ISO27001,NIST-CSF,ZeroTrust"
      "Environment"        = "Production"
      "Project"            = "SGSI-Implementation"
      "CostCenter"         = "Security-Infrastructure"
      "MaintenanceWindow"  = "Sunday-2AM-6AM"
      "TechnicalContact"   = "darwin.lopez@example.com"
      "SecurityContact"    = "security@example.com"
      "BusinessOwner"      = "SGSI-Team"
      "BackupRequired"     = "Yes"
      "MonitoringEnabled"  = "Yes"
      "LoggingEnabled"     = "Yes"
      "ChangeManagement"   = "ITIL-v4"
    },
    var.additional_tags
  )
}

# Route Table Associations for db-route-table

resource "aws_route_table" "mgmt_route_table" {
  vpc_id = aws_vpc.sgsi_vpc_main.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.sgsi_nat_1a.id
  }

  tags = merge(
    {
      Name                 = "mgmt-route-table"
      Type                 = "private"
      "AssetID"            = "NET-VPC-001"
      "AssetType"          = "Network-Infrastructure"
      "AssetOwner"         = "DarwinLopez"
      "DataClassification" = "Internal"
      "ISO27001-Control"   = "A.13.1.1,A.13.1.2,A.13.2.1"
      "SecurityLevel"      = "High"
      "ComplianceScope"    = "ISO27001,NIST-CSF,ZeroTrust"
      "Environment"        = "Production"
      "Project"            = "SGSI-Implementation"
      "CostCenter"         = "Security-Infrastructure"
      "MaintenanceWindow"  = "Sunday-2AM-6AM"
      "TechnicalContact"   = "darwin.lopez@example.com"
      "SecurityContact"    = "security@example.com"
      "BusinessOwner"      = "SGSI-Team"
      "BackupRequired"     = "Yes"
      "MonitoringEnabled"  = "Yes"
      "LoggingEnabled"     = "Yes"
      "ChangeManagement"   = "ITIL-v4"
    },
    var.additional_tags
  )
}

# Route Table Associations for mgmt-route-table


# ==============================================================================
# Outputs
# ==============================================================================

output "sgsi_vpc_main_id" {
  description = "ID of the sgsi-vpc-main VPC"
  value       = aws_vpc.sgsi_vpc_main.id
}

output "sgsi_vpc_main_arn" {
  description = "ARN of the sgsi-vpc-main VPC"
  value       = aws_vpc.sgsi_vpc_main.arn
}

output "sgsi_vpc_main_cidr_block" {
  description = "CIDR block of the sgsi-vpc-main VPC"
  value       = aws_vpc.sgsi_vpc_main.cidr_block
}

# Subnet outputs
output "dmz_public_1a_id" {
  description = "ID of dmz-public-1a subnet"
  value       = aws_subnet.dmz_public_1a.id
}
output "dmz_public_1b_id" {
  description = "ID of dmz-public-1b subnet"
  value       = aws_subnet.dmz_public_1b.id
}
output "dmz_public_1c_id" {
  description = "ID of dmz-public-1c subnet"
  value       = aws_subnet.dmz_public_1c.id
}
output "app_private_1a_id" {
  description = "ID of app-private-1a subnet"
  value       = aws_subnet.app_private_1a.id
}
output "app_private_1b_id" {
  description = "ID of app-private-1b subnet"
  value       = aws_subnet.app_private_1b.id
}
output "app_private_1c_id" {
  description = "ID of app-private-1c subnet"
  value       = aws_subnet.app_private_1c.id
}
output "db_private_1a_id" {
  description = "ID of db-private-1a subnet"
  value       = aws_subnet.db_private_1a.id
}
output "db_private_1b_id" {
  description = "ID of db-private-1b subnet"
  value       = aws_subnet.db_private_1b.id
}
output "db_private_1c_id" {
  description = "ID of db-private-1c subnet"
  value       = aws_subnet.db_private_1c.id
}
output "mgmt_private_1a_id" {
  description = "ID of mgmt-private-1a subnet"
  value       = aws_subnet.mgmt_private_1a.id
}
output "mgmt_private_1b_id" {
  description = "ID of mgmt-private-1b subnet"
  value       = aws_subnet.mgmt_private_1b.id
}

output "sgsi_vpc_main_internet_gateway_id" {
  description = "ID of the Internet Gateway for sgsi-vpc-main"
  value       = aws_internet_gateway.sgsi_igw.id
}
