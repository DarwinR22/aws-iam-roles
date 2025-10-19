# ==============================================================================
# LAYER 2: NETWORK - SECURITY GROUPS
# Based on definitions from sgsi-security-groups.yaml
# ==============================================================================

# ==============================================================================
# DMZ TIER SECURITY GROUPS
# ==============================================================================
resource "aws_security_group" "sgsi_alb_sg" {
  name        = "sgsi-alb-sg"
  description = "Security Group for Application Load Balancer (DMZ Tier)"
  vpc_id      = aws_vpc.sgsi_vpc_main.id

  # Tráfico web desde Internet (Zero Trust: verificar todo)
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

  # Solo hacia Application Tier en puertos específicos
  egress {
    from_port       = 8080
    to_port         = 8080
    protocol        = "tcp"
    security_groups = [aws_security_group.sgsi_web_sg.id]
    description     = "HTTP to web servers"
  }

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

# ==============================================================================
# APPLICATION TIER SECURITY GROUPS
# ==============================================================================
resource "aws_security_group" "sgsi_web_sg" {
  name        = "sgsi-web-sg"
  description = "Security Group for Web Servers (Application Tier)"
  vpc_id      = aws_vpc.sgsi_vpc_main.id

  # Solo tráfico desde Load Balancer
  ingress {
    from_port       = 8080
    to_port         = 8080
    protocol        = "tcp"
    security_groups = [aws_security_group.sgsi_alb_sg.id]
    description     = "HTTP from ALB only"
  }

  # SSH para administración (solo desde Management Tier)
  ingress {
    from_port       = 22
    to_port         = 22
    protocol        = "tcp"
    security_groups = [aws_security_group.sgsi_mgmt_sg.id]
    description     = "SSH from management subnet only"
  }

  # Conexión a base de datos
  egress {
    from_port       = 3306
    to_port         = 3306
    protocol        = "tcp"
    security_groups = [aws_security_group.sgsi_db_sg.id]
    description     = "MySQL to database"
  }

  egress {
    from_port       = 5432
    to_port         = 5432
    protocol        = "tcp"
    security_groups = [aws_security_group.sgsi_db_sg.id]
    description     = "PostgreSQL to database"
  }

  # HTTPS para APIs externas (a través de NAT)
  egress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "HTTPS for external APIs"
  }

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

  # Tráfico desde Web Servers
  ingress {
    from_port       = 8443
    to_port         = 8443
    protocol        = "tcp"
    security_groups = [aws_security_group.sgsi_web_sg.id]
    description     = "HTTPS from web servers"
  }

  # SSH para administración
  ingress {
    from_port       = 22
    to_port         = 22
    protocol        = "tcp"
    security_groups = [aws_security_group.sgsi_mgmt_sg.id]
    description     = "SSH from management only"
  }

  # Conexión a base de datos
  egress {
    from_port       = 3306
    to_port         = 3306
    protocol        = "tcp"
    security_groups = [aws_security_group.sgsi_db_sg.id]
    description     = "MySQL to database"
  }

  # HTTPS para servicios externos
  egress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "HTTPS for external services"
  }

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

# ==============================================================================
# DATABASE TIER SECURITY GROUPS
# ==============================================================================
resource "aws_security_group" "sgsi_db_sg" {
  name        = "sgsi-db-sg"
  description = "Security Group for Database Servers (Database Tier)"
  vpc_id      = aws_vpc.sgsi_vpc_main.id

  # MySQL desde Application Tier únicamente
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

  # PostgreSQL desde Application Tier únicamente
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

  # SSH para administración (solo desde Management)
  ingress {
    from_port       = 22
    to_port         = 22
    protocol        = "tcp"
    security_groups = [aws_security_group.sgsi_mgmt_sg.id]
    description     = "SSH from management only"
  }

  # Sin salida a Internet (máxima seguridad)
  # Solo respuestas a conexiones establecidas
  egress {
    from_port   = 1024
    to_port     = 65535
    protocol    = "tcp"
    cidr_blocks = ["10.0.0.0/16"]
    description = "Response traffic within VPC"
  }

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

# ==============================================================================
# MANAGEMENT TIER SECURITY GROUPS
# ==============================================================================
resource "aws_security_group" "sgsi_mgmt_sg" {
  name        = "sgsi-mgmt-sg"
  description = "Security Group for Management and Monitoring (Management Tier)"
  vpc_id      = aws_vpc.sgsi_vpc_main.id

  # SSH desde IP específica del administrador
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.admin_ip]
    description = "SSH from admin IP"
  }

  # HTTPS para herramientas de monitoreo
  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["10.0.0.0/16"]
    description = "HTTPS for monitoring tools"
  }

  # Prometheus/Grafana
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

  # Acceso completo para administración
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