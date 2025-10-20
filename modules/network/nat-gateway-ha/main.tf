# ==============================================================================
# MODULE: NAT Gateway High Availability
# Purpose: Provide redundant NAT Gateways for private subnet internet access
# Compliance: SGSI HA requirements, NIST CSF PR.IP-12 (backup capability)
# ==============================================================================

# ==============================================================================
# Elastic IPs for NAT Gateways
# ==============================================================================
resource "aws_eip" "nat_az1" {
  domain = "vpc"

  tags = merge(
    var.tags,
    {
      Name                = "${var.name_prefix}-nat-eip-az1"
      Purpose             = "NAT Gateway AZ1"
      AvailabilityZone    = var.availability_zones[0]
      HighAvailability    = "Yes"
    }
  )

  depends_on = [var.internet_gateway_id]
}

resource "aws_eip" "nat_az2" {
  domain = "vpc"

  tags = merge(
    var.tags,
    {
      Name                = "${var.name_prefix}-nat-eip-az2"
      Purpose             = "NAT Gateway AZ2"
      AvailabilityZone    = var.availability_zones[1]
      HighAvailability    = "Yes"
    }
  )

  depends_on = [var.internet_gateway_id]
}

# ==============================================================================
# NAT Gateway in AZ1 (Primary)
# ==============================================================================
resource "aws_nat_gateway" "nat_az1" {
  allocation_id = aws_eip.nat_az1.id
  subnet_id     = var.public_subnet_ids[0]

  tags = merge(
    var.tags,
    {
      Name                = "${var.name_prefix}-nat-gateway-az1"
      AvailabilityZone    = var.availability_zones[0]
      Purpose             = "Private Subnet Internet Access"
      HighAvailability    = "Primary"
      ISO27001Control     = "A.17.2.1"
      NISTControl         = "PR.IP-12"
    }
  )

  depends_on = [var.internet_gateway_id]
}

# ==============================================================================
# NAT Gateway in AZ2 (Secondary)
# ==============================================================================
resource "aws_nat_gateway" "nat_az2" {
  allocation_id = aws_eip.nat_az2.id
  subnet_id     = var.public_subnet_ids[1]

  tags = merge(
    var.tags,
    {
      Name                = "${var.name_prefix}-nat-gateway-az2"
      AvailabilityZone    = var.availability_zones[1]
      Purpose             = "Private Subnet Internet Access"
      HighAvailability    = "Secondary"
      ISO27001Control     = "A.17.2.1"
      NISTControl         = "PR.IP-12"
    }
  )

  depends_on = [var.internet_gateway_id]
}

# ==============================================================================
# Private Route Table for AZ1
# ==============================================================================
resource "aws_route_table" "private_az1" {
  vpc_id = var.vpc_id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat_az1.id
  }

  tags = merge(
    var.tags,
    {
      Name                = "${var.name_prefix}-private-rt-az1"
      AvailabilityZone    = var.availability_zones[0]
      Type                = "private"
      NAT                 = "az1"
    }
  )
}

# ==============================================================================
# Private Route Table for AZ2
# ==============================================================================
resource "aws_route_table" "private_az2" {
  vpc_id = var.vpc_id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat_az2.id
  }

  tags = merge(
    var.tags,
    {
      Name                = "${var.name_prefix}-private-rt-az2"
      AvailabilityZone    = var.availability_zones[1]
      Type                = "private"
      NAT                 = "az2"
    }
  )
}

# ==============================================================================
# Route Table Associations for App Subnets
# ==============================================================================
resource "aws_route_table_association" "app_private_az1" {
  count = length(var.app_subnet_ids_az1)

  subnet_id      = var.app_subnet_ids_az1[count.index]
  route_table_id = aws_route_table.private_az1.id
}

resource "aws_route_table_association" "app_private_az2" {
  count = length(var.app_subnet_ids_az2)

  subnet_id      = var.app_subnet_ids_az2[count.index]
  route_table_id = aws_route_table.private_az2.id
}

# ==============================================================================
# Route Table Associations for DB Subnets
# ==============================================================================
resource "aws_route_table_association" "db_private_az1" {
  count = length(var.db_subnet_ids_az1)

  subnet_id      = var.db_subnet_ids_az1[count.index]
  route_table_id = aws_route_table.private_az1.id
}

resource "aws_route_table_association" "db_private_az2" {
  count = length(var.db_subnet_ids_az2)

  subnet_id      = var.db_subnet_ids_az2[count.index]
  route_table_id = aws_route_table.private_az2.id
}

# ==============================================================================
# CloudWatch Alarms - NAT Gateway Bytes Out
# ==============================================================================
resource "aws_cloudwatch_metric_alarm" "nat_az1_bytes_out" {
  count = var.enable_monitoring ? 1 : 0

  alarm_name          = "${var.name_prefix}-nat-az1-bytes-out"
  comparison_operator = "LessThanThreshold"
  evaluation_periods  = "2"
  metric_name         = "BytesOutToDestination"
  namespace           = "AWS/NATGateway"
  period              = "300"
  statistic           = "Sum"
  threshold           = var.min_bytes_threshold
  alarm_description   = "NAT Gateway AZ1 - Low traffic may indicate connectivity issues"
  treat_missing_data  = "breaching"

  dimensions = {
    NatGatewayId = aws_nat_gateway.nat_az1.id
  }

  alarm_actions = var.alarm_actions

  tags = merge(
    var.tags,
    {
      Name     = "${var.name_prefix}-nat-az1-monitoring"
      Severity = "Medium"
    }
  )
}

resource "aws_cloudwatch_metric_alarm" "nat_az2_bytes_out" {
  count = var.enable_monitoring ? 1 : 0

  alarm_name          = "${var.name_prefix}-nat-az2-bytes-out"
  comparison_operator = "LessThanThreshold"
  evaluation_periods  = "2"
  metric_name         = "BytesOutToDestination"
  namespace           = "AWS/NATGateway"
  period              = "300"
  statistic           = "Sum"
  threshold           = var.min_bytes_threshold
  alarm_description   = "NAT Gateway AZ2 - Low traffic may indicate connectivity issues"
  treat_missing_data  = "breaching"

  dimensions = {
    NatGatewayId = aws_nat_gateway.nat_az2.id
  }

  alarm_actions = var.alarm_actions

  tags = merge(
    var.tags,
    {
      Name     = "${var.name_prefix}-nat-az2-monitoring"
      Severity = "Medium"
    }
  )
}
