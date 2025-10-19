# ==============================================================================
# LAYER 2: NETWORK - SECURITY GROUPS
# Based on definitions from sgsi-security-groups.yaml
# Fixed: Separated security groups from rules to avoid circular dependencies
# ==============================================================================

# ==============================================================================
# SECURITY GROUPS (WITHOUT INLINE RULES)
# ==============================================================================

# DMZ TIER
resource "aws_security_group" "sgsi_alb_sg" {
  name        = "sgsi-alb-sg"
  description = "Security Group for Application Load Balancer (DMZ Tier)"
  vpc_id      = aws_vpc.sgsi_vpc_main.id

  tags = merge(
    var.common_tags,
    {
      Name            = "sgsi-alb-sg"
      Tier            = "dmz"
      SecurityLevel   = "High"
      ComplianceScope = "ISO27001-A.13"
      AssetType       = "Network-Security"
      ZeroTrustLayer  = "Network-Segmentation"
    }
  )
}

# APPLICATION TIER
resource "aws_security_group" "sgsi_web_sg" {
  name        = "sgsi-web-sg"
  description = "Security Group for Web Servers (Application Tier)"
  vpc_id      = aws_vpc.sgsi_vpc_main.id

  tags = merge(
    var.common_tags,
    {
      Name            = "sgsi-web-sg"
      Tier            = "application"
      SecurityLevel   = "High"
      ComplianceScope = "ISO27001-A.13"
      AssetType       = "Network-Security"
    }
  )
}

resource "aws_security_group" "sgsi_app_sg" {
  name        = "sgsi-app-sg"
  description = "Security Group for Application Servers (Application Tier)"
  vpc_id      = aws_vpc.sgsi_vpc_main.id

  tags = merge(
    var.common_tags,
    {
      Name            = "sgsi-app-sg"
      Tier            = "application"
      SecurityLevel   = "High"
      ComplianceScope = "ISO27001-A.13"
      AssetType       = "Network-Security"
    }
  )
}

# DATABASE TIER
resource "aws_security_group" "sgsi_db_sg" {
  name        = "sgsi-db-sg"
  description = "Security Group for Database Servers (Database Tier)"
  vpc_id      = aws_vpc.sgsi_vpc_main.id

  tags = merge(
    var.common_tags,
    {
      Name            = "sgsi-db-sg"
      Tier            = "database"
      SecurityLevel   = "Critical"
      ComplianceScope = "ISO27001-A.13"
      AssetType       = "Network-Security"
    }
  )
}

# MANAGEMENT TIER
resource "aws_security_group" "sgsi_mgmt_sg" {
  name        = "sgsi-mgmt-sg"
  description = "Security Group for Management and Monitoring (Management Tier)"
  vpc_id      = aws_vpc.sgsi_vpc_main.id

  tags = merge(
    var.common_tags,
    {
      Name            = "sgsi-mgmt-sg"
      Tier            = "management"
      SecurityLevel   = "High"
      ComplianceScope = "ISO27001-A.13"
      AssetType       = "Network-Security"
    }
  )
}

# ==============================================================================
# SECURITY GROUP RULES (INGRESS)
# ==============================================================================

# ALB Security Group Rules
resource "aws_security_group_rule" "alb_http_ingress" {
  type              = "ingress"
  from_port         = 80
  to_port           = 80
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  description       = "HTTP traffic from Internet"
  security_group_id = aws_security_group.sgsi_alb_sg.id
}

resource "aws_security_group_rule" "alb_https_ingress" {
  type              = "ingress"
  from_port         = 443
  to_port           = 443
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  description       = "HTTPS traffic from Internet"
  security_group_id = aws_security_group.sgsi_alb_sg.id
}

# Web Server Security Group Rules
resource "aws_security_group_rule" "web_http_from_alb" {
  type                     = "ingress"
  from_port                = 8080
  to_port                  = 8080
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.sgsi_alb_sg.id
  description              = "HTTP from ALB only"
  security_group_id        = aws_security_group.sgsi_web_sg.id
}

resource "aws_security_group_rule" "web_ssh_from_mgmt" {
  type                     = "ingress"
  from_port                = 22
  to_port                  = 22
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.sgsi_mgmt_sg.id
  description              = "SSH from management subnet only"
  security_group_id        = aws_security_group.sgsi_web_sg.id
}

# App Server Security Group Rules
resource "aws_security_group_rule" "app_https_from_web" {
  type                     = "ingress"
  from_port                = 8443
  to_port                  = 8443
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.sgsi_web_sg.id
  description              = "HTTPS from web servers"
  security_group_id        = aws_security_group.sgsi_app_sg.id
}

resource "aws_security_group_rule" "app_ssh_from_mgmt" {
  type                     = "ingress"
  from_port                = 22
  to_port                  = 22
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.sgsi_mgmt_sg.id
  description              = "SSH from management only"
  security_group_id        = aws_security_group.sgsi_app_sg.id
}

# Database Security Group Rules
resource "aws_security_group_rule" "db_mysql_from_web" {
  type                     = "ingress"
  from_port                = 3306
  to_port                  = 3306
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.sgsi_web_sg.id
  description              = "MySQL from web servers"
  security_group_id        = aws_security_group.sgsi_db_sg.id
}

resource "aws_security_group_rule" "db_mysql_from_app" {
  type                     = "ingress"
  from_port                = 3306
  to_port                  = 3306
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.sgsi_app_sg.id
  description              = "MySQL from app servers"
  security_group_id        = aws_security_group.sgsi_db_sg.id
}

resource "aws_security_group_rule" "db_postgresql_from_web" {
  type                     = "ingress"
  from_port                = 5432
  to_port                  = 5432
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.sgsi_web_sg.id
  description              = "PostgreSQL from web servers"
  security_group_id        = aws_security_group.sgsi_db_sg.id
}

resource "aws_security_group_rule" "db_postgresql_from_app" {
  type                     = "ingress"
  from_port                = 5432
  to_port                  = 5432
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.sgsi_app_sg.id
  description              = "PostgreSQL from app servers"
  security_group_id        = aws_security_group.sgsi_db_sg.id
}

resource "aws_security_group_rule" "db_ssh_from_mgmt" {
  type                     = "ingress"
  from_port                = 22
  to_port                  = 22
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.sgsi_mgmt_sg.id
  description              = "SSH from management only"
  security_group_id        = aws_security_group.sgsi_db_sg.id
}

# Management Security Group Rules
resource "aws_security_group_rule" "mgmt_ssh_from_admin" {
  type              = "ingress"
  from_port         = 22
  to_port           = 22
  protocol          = "tcp"
  cidr_blocks       = [var.admin_ip]
  description       = "SSH from admin IP"
  security_group_id = aws_security_group.sgsi_mgmt_sg.id
}

resource "aws_security_group_rule" "mgmt_https_internal" {
  type              = "ingress"
  from_port         = 443
  to_port           = 443
  protocol          = "tcp"
  cidr_blocks       = ["10.0.0.0/16"]
  description       = "HTTPS for monitoring tools"
  security_group_id = aws_security_group.sgsi_mgmt_sg.id
}

resource "aws_security_group_rule" "mgmt_grafana" {
  type              = "ingress"
  from_port         = 3000
  to_port           = 3000
  protocol          = "tcp"
  cidr_blocks       = ["10.0.0.0/16"]
  description       = "Grafana dashboard"
  security_group_id = aws_security_group.sgsi_mgmt_sg.id
}

resource "aws_security_group_rule" "mgmt_prometheus" {
  type              = "ingress"
  from_port         = 9090
  to_port           = 9090
  protocol          = "tcp"
  cidr_blocks       = ["10.0.0.0/16"]
  description       = "Prometheus metrics"
  security_group_id = aws_security_group.sgsi_mgmt_sg.id
}

# ==============================================================================
# SECURITY GROUP RULES (EGRESS)
# ==============================================================================

# ALB Egress Rules
resource "aws_security_group_rule" "alb_to_web" {
  type                     = "egress"
  from_port                = 8080
  to_port                  = 8080
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.sgsi_web_sg.id
  description              = "HTTP to web servers"
  security_group_id        = aws_security_group.sgsi_alb_sg.id
}

# Web Server Egress Rules
resource "aws_security_group_rule" "web_to_db_mysql" {
  type                     = "egress"
  from_port                = 3306
  to_port                  = 3306
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.sgsi_db_sg.id
  description              = "MySQL to database"
  security_group_id        = aws_security_group.sgsi_web_sg.id
}

resource "aws_security_group_rule" "web_to_db_postgresql" {
  type                     = "egress"
  from_port                = 5432
  to_port                  = 5432
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.sgsi_db_sg.id
  description              = "PostgreSQL to database"
  security_group_id        = aws_security_group.sgsi_web_sg.id
}

resource "aws_security_group_rule" "web_https_external" {
  type              = "egress"
  from_port         = 443
  to_port           = 443
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  description       = "HTTPS for external APIs"
  security_group_id = aws_security_group.sgsi_web_sg.id
}

# App Server Egress Rules
resource "aws_security_group_rule" "app_to_db_mysql" {
  type                     = "egress"
  from_port                = 3306
  to_port                  = 3306
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.sgsi_db_sg.id
  description              = "MySQL to database"
  security_group_id        = aws_security_group.sgsi_app_sg.id
}

resource "aws_security_group_rule" "app_https_external" {
  type              = "egress"
  from_port         = 443
  to_port           = 443
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  description       = "HTTPS for external services"
  security_group_id = aws_security_group.sgsi_app_sg.id
}

# Database Egress Rules
resource "aws_security_group_rule" "db_response_traffic" {
  type              = "egress"
  from_port         = 1024
  to_port           = 65535
  protocol          = "tcp"
  cidr_blocks       = ["10.0.0.0/16"]
  description       = "Response traffic within VPC"
  security_group_id = aws_security_group.sgsi_db_sg.id
}

# Management Egress Rules
resource "aws_security_group_rule" "mgmt_ssh_to_all" {
  type              = "egress"
  from_port         = 22
  to_port           = 22
  protocol          = "tcp"
  cidr_blocks       = ["10.0.0.0/16"]
  description       = "SSH to all instances"
  security_group_id = aws_security_group.sgsi_mgmt_sg.id
}

resource "aws_security_group_rule" "mgmt_https_external" {
  type              = "egress"
  from_port         = 443
  to_port           = 443
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  description       = "HTTPS for updates and external services"
  security_group_id = aws_security_group.sgsi_mgmt_sg.id
}

resource "aws_security_group_rule" "mgmt_http_updates" {
  type              = "egress"
  from_port         = 80
  to_port           = 80
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  description       = "HTTP for package updates"
  security_group_id = aws_security_group.sgsi_mgmt_sg.id
}