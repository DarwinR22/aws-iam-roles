# ==============================================================================
# MODULE: VPC Endpoints
# Purpose: Private connectivity to AWS services (S3, DynamoDB)
# Compliance: Cost optimization + Security (no internet exposure)
# ==============================================================================

# ==============================================================================
# S3 Gateway Endpoint
# ==============================================================================
resource "aws_vpc_endpoint" "s3" {
  vpc_id            = var.vpc_id
  service_name      = "com.amazonaws.${var.region}.s3"
  vpc_endpoint_type = "Gateway"
  route_table_ids   = var.route_table_ids

  tags = merge(
    var.tags,
    {
      Name                = "${var.name_prefix}-s3-endpoint"
      Service             = "S3"
      EndpointType        = "Gateway"
      Purpose             = "Private S3 Access"
      CostOptimization    = "Yes"
      SecurityBenefit     = "No Internet Exposure"
    }
  )
}

# ==============================================================================
# S3 Endpoint Policy (Restrict access to specific buckets)
# ==============================================================================
data "aws_iam_policy_document" "s3_endpoint_policy" {
  statement {
    sid    = "AllowS3Access"
    effect = "Allow"

    principals {
      type        = "*"
      identifiers = ["*"]
    }

    actions = [
      "s3:GetObject",
      "s3:PutObject",
      "s3:ListBucket",
      "s3:DeleteObject"
    ]

    resources = concat(
      [for bucket in var.allowed_s3_buckets : "arn:aws:s3:::${bucket}"],
      [for bucket in var.allowed_s3_buckets : "arn:aws:s3:::${bucket}/*"]
    )
  }
}

# Update S3 endpoint with policy if buckets are specified
resource "aws_vpc_endpoint_policy" "s3" {
  count = length(var.allowed_s3_buckets) > 0 ? 1 : 0

  vpc_endpoint_id = aws_vpc_endpoint.s3.id
  policy          = data.aws_iam_policy_document.s3_endpoint_policy.json
}

# ==============================================================================
# DynamoDB Gateway Endpoint
# ==============================================================================
resource "aws_vpc_endpoint" "dynamodb" {
  vpc_id            = var.vpc_id
  service_name      = "com.amazonaws.${var.region}.dynamodb"
  vpc_endpoint_type = "Gateway"
  route_table_ids   = var.route_table_ids

  tags = merge(
    var.tags,
    {
      Name                = "${var.name_prefix}-dynamodb-endpoint"
      Service             = "DynamoDB"
      EndpointType        = "Gateway"
      Purpose             = "Private DynamoDB Access"
      CostOptimization    = "Yes"
      SecurityBenefit     = "No Internet Exposure"
    }
  )
}

# ==============================================================================
# DynamoDB Endpoint Policy (Restrict access to specific tables)
# ==============================================================================
data "aws_iam_policy_document" "dynamodb_endpoint_policy" {
  statement {
    sid    = "AllowDynamoDBAccess"
    effect = "Allow"

    principals {
      type        = "*"
      identifiers = ["*"]
    }

    actions = [
      "dynamodb:GetItem",
      "dynamodb:PutItem",
      "dynamodb:Query",
      "dynamodb:Scan",
      "dynamodb:UpdateItem",
      "dynamodb:DeleteItem",
      "dynamodb:BatchGetItem",
      "dynamodb:BatchWriteItem"
    ]

    resources = length(var.allowed_dynamodb_tables) > 0 ? [
      for table in var.allowed_dynamodb_tables : "arn:aws:dynamodb:${var.region}:*:table/${table}"
    ] : ["*"]
  }
}

# Update DynamoDB endpoint with policy if tables are specified
resource "aws_vpc_endpoint_policy" "dynamodb" {
  count = length(var.allowed_dynamodb_tables) > 0 ? 1 : 0

  vpc_endpoint_id = aws_vpc_endpoint.dynamodb.id
  policy          = data.aws_iam_policy_document.dynamodb_endpoint_policy.json
}

# ==============================================================================
# Optional Interface Endpoints (if enabled)
# ==============================================================================

# Secrets Manager Interface Endpoint
resource "aws_vpc_endpoint" "secrets_manager" {
  count = var.enable_secrets_manager_endpoint ? 1 : 0

  vpc_id              = var.vpc_id
  service_name        = "com.amazonaws.${var.region}.secretsmanager"
  vpc_endpoint_type   = "Interface"
  security_group_ids  = [aws_security_group.vpc_endpoints[0].id]
  subnet_ids          = var.private_subnet_ids
  private_dns_enabled = true

  tags = merge(
    var.tags,
    {
      Name                = "${var.name_prefix}-secretsmanager-endpoint"
      Service             = "SecretsManager"
      EndpointType        = "Interface"
      Purpose             = "Private Secrets Manager Access"
    }
  )
}

# KMS Interface Endpoint
resource "aws_vpc_endpoint" "kms" {
  count = var.enable_kms_endpoint ? 1 : 0

  vpc_id              = var.vpc_id
  service_name        = "com.amazonaws.${var.region}.kms"
  vpc_endpoint_type   = "Interface"
  security_group_ids  = [aws_security_group.vpc_endpoints[0].id]
  subnet_ids          = var.private_subnet_ids
  private_dns_enabled = true

  tags = merge(
    var.tags,
    {
      Name                = "${var.name_prefix}-kms-endpoint"
      Service             = "KMS"
      EndpointType        = "Interface"
      Purpose             = "Private KMS Access"
    }
  )
}

# ==============================================================================
# Security Group for Interface Endpoints
# ==============================================================================
resource "aws_security_group" "vpc_endpoints" {
  count = var.enable_secrets_manager_endpoint || var.enable_kms_endpoint ? 1 : 0

  name        = "${var.name_prefix}-vpc-endpoints-sg"
  description = "Security group for VPC interface endpoints"
  vpc_id      = var.vpc_id

  ingress {
    description = "HTTPS from VPC"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = [var.vpc_cidr]
  }

  egress {
    description = "Allow all outbound"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(
    var.tags,
    {
      Name    = "${var.name_prefix}-vpc-endpoints-sg"
      Purpose = "VPC Interface Endpoints Security"
    }
  )
}
