# ==============================================================================
# MODULE: Network ACLs (Defense in Depth)
# Purpose: Additional layer of security at subnet level
# Compliance: ISO 27001 A.13.1.1, Zero Trust - Multiple security layers
# ==============================================================================

# ==============================================================================
# DMZ TIER - Network ACL
# ==============================================================================
resource "aws_network_acl" "dmz_nacl" {
  vpc_id     = var.vpc_id
  subnet_ids = var.dmz_subnet_ids

  tags = merge(
    var.tags,
    {
      Name                = "${var.name_prefix}-dmz-nacl"
      Tier                = "dmz"
      SecurityLevel       = "Medium"
      ISO27001Control     = "A.13.1.1"
      Purpose             = "DMZ Network Access Control"
    }
  )
}

# DMZ Ingress Rules
resource "aws_network_acl_rule" "dmz_ingress_http" {
  network_acl_id = aws_network_acl.dmz_nacl.id
  rule_number    = 100
  protocol       = "tcp"
  rule_action    = "allow"
  cidr_block     = "0.0.0.0/0"
  from_port      = 80
  to_port        = 80
  egress         = false
}

resource "aws_network_acl_rule" "dmz_ingress_https" {
  network_acl_id = aws_network_acl.dmz_nacl.id
  rule_number    = 110
  protocol       = "tcp"
  rule_action    = "allow"
  cidr_block     = "0.0.0.0/0"
  from_port      = 443
  to_port        = 443
  egress         = false
}

resource "aws_network_acl_rule" "dmz_ingress_ephemeral" {
  network_acl_id = aws_network_acl.dmz_nacl.id
  rule_number    = 120
  protocol       = "tcp"
  rule_action    = "allow"
  cidr_block     = "0.0.0.0/0"
  from_port      = 1024
  to_port        = 65535
  egress         = false
}

# DMZ Egress Rules
resource "aws_network_acl_rule" "dmz_egress_http" {
  network_acl_id = aws_network_acl.dmz_nacl.id
  rule_number    = 100
  protocol       = "tcp"
  rule_action    = "allow"
  cidr_block     = "0.0.0.0/0"
  from_port      = 80
  to_port        = 80
  egress         = true
}

resource "aws_network_acl_rule" "dmz_egress_https" {
  network_acl_id = aws_network_acl.dmz_nacl.id
  rule_number    = 110
  protocol       = "tcp"
  rule_action    = "allow"
  cidr_block     = "0.0.0.0/0"
  from_port      = 443
  to_port        = 443
  egress         = true
}

resource "aws_network_acl_rule" "dmz_egress_app" {
  network_acl_id = aws_network_acl.dmz_nacl.id
  rule_number    = 120
  protocol       = "tcp"
  rule_action    = "allow"
  cidr_block     = var.vpc_cidr
  from_port      = 8080
  to_port        = 8080
  egress         = true
}

resource "aws_network_acl_rule" "dmz_egress_ephemeral" {
  network_acl_id = aws_network_acl.dmz_nacl.id
  rule_number    = 130
  protocol       = "tcp"
  rule_action    = "allow"
  cidr_block     = "0.0.0.0/0"
  from_port      = 1024
  to_port        = 65535
  egress         = true
}

# ==============================================================================
# APPLICATION TIER - Network ACL
# ==============================================================================
resource "aws_network_acl" "app_nacl" {
  vpc_id     = var.vpc_id
  subnet_ids = var.app_subnet_ids

  tags = merge(
    var.tags,
    {
      Name                = "${var.name_prefix}-app-nacl"
      Tier                = "application"
      SecurityLevel       = "High"
      ISO27001Control     = "A.13.1.1"
      Purpose             = "Application Network Access Control"
    }
  )
}

# App Ingress Rules
resource "aws_network_acl_rule" "app_ingress_from_dmz" {
  network_acl_id = aws_network_acl.app_nacl.id
  rule_number    = 100
  protocol       = "tcp"
  rule_action    = "allow"
  cidr_block     = var.vpc_cidr
  from_port      = 8080
  to_port        = 8080
  egress         = false
}

resource "aws_network_acl_rule" "app_ingress_https" {
  network_acl_id = aws_network_acl.app_nacl.id
  rule_number    = 110
  protocol       = "tcp"
  rule_action    = "allow"
  cidr_block     = var.vpc_cidr
  from_port      = 8443
  to_port        = 8443
  egress         = false
}

resource "aws_network_acl_rule" "app_ingress_ssh" {
  network_acl_id = aws_network_acl.app_nacl.id
  rule_number    = 120
  protocol       = "tcp"
  rule_action    = "allow"
  cidr_block     = var.vpc_cidr
  from_port      = 22
  to_port        = 22
  egress         = false
}

resource "aws_network_acl_rule" "app_ingress_ephemeral" {
  network_acl_id = aws_network_acl.app_nacl.id
  rule_number    = 130
  protocol       = "tcp"
  rule_action    = "allow"
  cidr_block     = "0.0.0.0/0"
  from_port      = 1024
  to_port        = 65535
  egress         = false
}

# App Egress Rules
resource "aws_network_acl_rule" "app_egress_http" {
  network_acl_id = aws_network_acl.app_nacl.id
  rule_number    = 100
  protocol       = "tcp"
  rule_action    = "allow"
  cidr_block     = "0.0.0.0/0"
  from_port      = 80
  to_port        = 80
  egress         = true
}

resource "aws_network_acl_rule" "app_egress_https" {
  network_acl_id = aws_network_acl.app_nacl.id
  rule_number    = 110
  protocol       = "tcp"
  rule_action    = "allow"
  cidr_block     = "0.0.0.0/0"
  from_port      = 443
  to_port        = 443
  egress         = true
}

resource "aws_network_acl_rule" "app_egress_db_mysql" {
  network_acl_id = aws_network_acl.app_nacl.id
  rule_number    = 120
  protocol       = "tcp"
  rule_action    = "allow"
  cidr_block     = var.vpc_cidr
  from_port      = 3306
  to_port        = 3306
  egress         = true
}

resource "aws_network_acl_rule" "app_egress_db_postgres" {
  network_acl_id = aws_network_acl.app_nacl.id
  rule_number    = 130
  protocol       = "tcp"
  rule_action    = "allow"
  cidr_block     = var.vpc_cidr
  from_port      = 5432
  to_port        = 5432
  egress         = true
}

resource "aws_network_acl_rule" "app_egress_ephemeral" {
  network_acl_id = aws_network_acl.app_nacl.id
  rule_number    = 140
  protocol       = "tcp"
  rule_action    = "allow"
  cidr_block     = "0.0.0.0/0"
  from_port      = 1024
  to_port        = 65535
  egress         = true
}

# ==============================================================================
# DATABASE TIER - Network ACL
# ==============================================================================
resource "aws_network_acl" "db_nacl" {
  vpc_id     = var.vpc_id
  subnet_ids = var.db_subnet_ids

  tags = merge(
    var.tags,
    {
      Name                = "${var.name_prefix}-db-nacl"
      Tier                = "database"
      SecurityLevel       = "Critical"
      ISO27001Control     = "A.13.1.1"
      Purpose             = "Database Network Access Control"
    }
  )
}

# DB Ingress Rules
resource "aws_network_acl_rule" "db_ingress_mysql" {
  network_acl_id = aws_network_acl.db_nacl.id
  rule_number    = 100
  protocol       = "tcp"
  rule_action    = "allow"
  cidr_block     = var.vpc_cidr
  from_port      = 3306
  to_port        = 3306
  egress         = false
}

resource "aws_network_acl_rule" "db_ingress_postgres" {
  network_acl_id = aws_network_acl.db_nacl.id
  rule_number    = 110
  protocol       = "tcp"
  rule_action    = "allow"
  cidr_block     = var.vpc_cidr
  from_port      = 5432
  to_port        = 5432
  egress         = false
}

resource "aws_network_acl_rule" "db_ingress_ssh" {
  network_acl_id = aws_network_acl.db_nacl.id
  rule_number    = 120
  protocol       = "tcp"
  rule_action    = "allow"
  cidr_block     = var.vpc_cidr
  from_port      = 22
  to_port        = 22
  egress         = false
}

resource "aws_network_acl_rule" "db_ingress_ephemeral" {
  network_acl_id = aws_network_acl.db_nacl.id
  rule_number    = 130
  protocol       = "tcp"
  rule_action    = "allow"
  cidr_block     = var.vpc_cidr
  from_port      = 1024
  to_port        = 65535
  egress         = false
}

# DB Egress Rules - Highly Restricted
resource "aws_network_acl_rule" "db_egress_https" {
  network_acl_id = aws_network_acl.db_nacl.id
  rule_number    = 100
  protocol       = "tcp"
  rule_action    = "allow"
  cidr_block     = "0.0.0.0/0"
  from_port      = 443
  to_port        = 443
  egress         = true
}

resource "aws_network_acl_rule" "db_egress_ephemeral" {
  network_acl_id = aws_network_acl.db_nacl.id
  rule_number    = 110
  protocol       = "tcp"
  rule_action    = "allow"
  cidr_block     = var.vpc_cidr
  from_port      = 1024
  to_port        = 65535
  egress         = true
}

# ==============================================================================
# DENY Rules for Known Bad Ports (All NACLs)
# ==============================================================================
resource "aws_network_acl_rule" "deny_telnet_dmz" {
  network_acl_id = aws_network_acl.dmz_nacl.id
  rule_number    = 10
  protocol       = "tcp"
  rule_action    = "deny"
  cidr_block     = "0.0.0.0/0"
  from_port      = 23
  to_port        = 23
  egress         = false
}

resource "aws_network_acl_rule" "deny_rdp_dmz" {
  network_acl_id = aws_network_acl.dmz_nacl.id
  rule_number    = 20
  protocol       = "tcp"
  rule_action    = "deny"
  cidr_block     = "0.0.0.0/0"
  from_port      = 3389
  to_port        = 3389
  egress         = false
}

resource "aws_network_acl_rule" "deny_smb_dmz" {
  network_acl_id = aws_network_acl.dmz_nacl.id
  rule_number    = 30
  protocol       = "tcp"
  rule_action    = "deny"
  cidr_block     = "0.0.0.0/0"
  from_port      = 445
  to_port        = 445
  egress         = false
}
