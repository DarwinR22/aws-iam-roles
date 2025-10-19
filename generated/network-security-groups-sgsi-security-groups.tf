# Security Groups generated from sgsi-security-groups.yaml
<<<<<<< HEAD:generated/network-security-groups-sgsi-security-groups.tf
# Generated: 2025-10-18T20:24:33.805147
=======
# Generated: 2025-10-19T02:21:22.254487
>>>>>>> fa720ecd0ece8054553aa20e31aa53c1ba52877d:generated/network/security-groups-sgsi-security-groups.tf


resource "aws_security_group" "sgsi_alb_sg" {
  name        = "sgsi-alb-sg"
  description = "Security Group for Application Load Balancer (DMZ Tier)"

  # Ingress rules
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "HTTP traffic from Internet"
  }
  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "HTTPS traffic from Internet"
  }

  # Egress rules
  egress {
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    description = "HTTP to web servers"
  }

  tags = {
    Name            = "sgsi-alb-sg"
    Tier            = "dmz"
    SecurityLevel   = "High"
    ComplianceScope = "ISO27001"
  }
}


resource "aws_security_group" "sgsi_web_sg" {
  name        = "sgsi-web-sg"
  description = "Security Group for Web Servers (Application Tier)"

  # Ingress rules
  ingress {
    from_port       = 8080
    to_port         = 8080
    protocol        = "tcp"
    security_groups = [aws_security_group.sgsi_alb_sg.id]
    description     = "HTTP from ALB only"
  }
  ingress {
    from_port       = 22
    to_port         = 22
    protocol        = "tcp"
    security_groups = [aws_security_group.sgsi_mgmt_sg.id]
    description     = "SSH from management subnet only"
  }

  # Egress rules
  egress {
    from_port   = 3306
    to_port     = 3306
    protocol    = "tcp"
    description = "MySQL to database"
  }
  egress {
    from_port   = 5432
    to_port     = 5432
    protocol    = "tcp"
    description = "PostgreSQL to database"
  }
  egress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "HTTPS for external APIs"
  }

  tags = {
    Name            = "sgsi-web-sg"
    Tier            = "application"
    SecurityLevel   = "High"
    ComplianceScope = "ISO27001"
  }
}


resource "aws_security_group" "sgsi_app_sg" {
  name        = "sgsi-app-sg"
  description = "Security Group for Application Servers (Application Tier)"

  # Ingress rules
  ingress {
    from_port       = 8443
    to_port         = 8443
    protocol        = "tcp"
    security_groups = [aws_security_group.sgsi_web_sg.id]
    description     = "HTTPS from web servers"
  }
  ingress {
    from_port       = 22
    to_port         = 22
    protocol        = "tcp"
    security_groups = [aws_security_group.sgsi_mgmt_sg.id]
    description     = "SSH from management only"
  }

  # Egress rules
  egress {
    from_port   = 3306
    to_port     = 3306
    protocol    = "tcp"
    description = "MySQL to database"
  }
  egress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "HTTPS for external services"
  }

  tags = {
    Name            = "sgsi-app-sg"
    Tier            = "application"
    SecurityLevel   = "High"
    ComplianceScope = "ISO27001"
  }
}


resource "aws_security_group" "sgsi_db_sg" {
  name        = "sgsi-db-sg"
  description = "Security Group for Database Servers (Database Tier)"

  # Ingress rules
  ingress {
    from_port       = 3306
    to_port         = 3306
    protocol        = "tcp"
    security_groups = [aws_security_group.sgsi_web_sg.id]
    description     = "MySQL from web servers"
  }
  ingress {
    from_port       = 3306
    to_port         = 3306
    protocol        = "tcp"
    security_groups = [aws_security_group.sgsi_app_sg.id]
    description     = "MySQL from app servers"
  }
  ingress {
    from_port       = 5432
    to_port         = 5432
    protocol        = "tcp"
    security_groups = [aws_security_group.sgsi_web_sg.id]
    description     = "PostgreSQL from web servers"
  }
  ingress {
    from_port       = 5432
    to_port         = 5432
    protocol        = "tcp"
    security_groups = [aws_security_group.sgsi_app_sg.id]
    description     = "PostgreSQL from app servers"
  }
  ingress {
    from_port       = 22
    to_port         = 22
    protocol        = "tcp"
    security_groups = [aws_security_group.sgsi_mgmt_sg.id]
    description     = "SSH from management only"
  }

  # Egress rules
  egress {
    from_port   = 1024
    to_port     = 65535
    protocol    = "tcp"
    cidr_blocks = ["10.0.0.0/16"]
    description = "Response traffic within VPC"
  }

  tags = {
    Name            = "sgsi-db-sg"
    Tier            = "database"
    SecurityLevel   = "High"
    ComplianceScope = "ISO27001"
  }
}


resource "aws_security_group" "sgsi_mgmt_sg" {
  name        = "sgsi-mgmt-sg"
  description = "Security Group for Management and Monitoring (Management Tier)"

  # Ingress rules
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "SSH from admin IP (change to specific IP)"
  }
  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["10.0.0.0/16"]
    description = "HTTPS for monitoring tools"
  }
  ingress {
    from_port   = 3000
    to_port     = 3000
    protocol    = "tcp"
    cidr_blocks = ["10.0.0.0/16"]
    description = "Grafana dashboard"
  }
  ingress {
    from_port   = 9090
    to_port     = 9090
    protocol    = "tcp"
    cidr_blocks = ["10.0.0.0/16"]
    description = "Prometheus metrics"
  }

  # Egress rules
  egress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["10.0.0.0/16"]
    description = "SSH to all instances"
  }
  egress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "HTTPS for updates and external services"
  }
  egress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "HTTP for package updates"
  }

  tags = {
    Name            = "sgsi-mgmt-sg"
    Tier            = "management"
    SecurityLevel   = "High"
    ComplianceScope = "ISO27001"
  }
}

