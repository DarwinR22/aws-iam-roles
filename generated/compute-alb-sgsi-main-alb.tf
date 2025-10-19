# Application Load Balancer generated from sgsi-main-alb.yaml
# Generated: 2025-10-18T22:18:12.435275

# S3 Bucket for ALB logs
resource "aws_s3_bucket" "alb_logs" {
  bucket = "sgsi-alb-logs-051963532279"
}

resource "aws_s3_bucket_policy" "alb_logs_policy" {
  bucket = aws_s3_bucket.alb_logs.id
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          AWS = "arn:aws:iam::033677994240:root"  # ELB Service Account for us-east-1
        }
        Action = "s3:PutObject"
        Resource = "${aws_s3_bucket.alb_logs.arn}/alb-logs/*"
      }
    ]
  })
}

# Application Load Balancer
resource "aws_lb" "sgsi_main_alb" {
  name               = "sgsi-main-alb"
  load_balancer_type = "application"
  scheme             = "internet-facing"
  ip_address_type    = "ipv4"
  
  subnets = [
    data.aws_subnet.sgsi_dmz_subnet_us_east_1a.id,
    data.aws_subnet.sgsi_dmz_subnet_us_east_1b.id,
    data.aws_subnet.sgsi_dmz_subnet_us_east_1c.id,
  ]
  
  security_groups = [
    data.aws_security_group.sgsi_alb_sg.id,
  ]
  
  enable_deletion_protection = false
  
  access_logs {
    bucket  = aws_s3_bucket.alb_logs.bucket
    prefix  = "alb-logs"
    enabled = true
  }

  tags = {
    "Pais" = "RG"
    "Gerencia" = "MejoraContinuaEInformacion"
    "Area" = "DevOps"
    "Ambiente" = "DEV"
    "Direccion" = "TICENAM"
    "Modulo" = "LoadBalancer"
    "AlcanceSOX" = "No"
    "Propietario" = "DarwinLopez"
    "Proveedor" = "InHouse"
    "Layer" = "SGSI-Layer3-Compute"
    "Dominio" = "BusinessIntelligence"
    "Subdominio" = "WebServices"
    "Aplicacion" = "SGSI"
    "Name" = "sgsi-main-alb"
    "Tipo de Recurso" = "ApplicationLoadBalancer"
    "Soporte" = "darwin.lopez@claro.com.gt"
    "Contacto" = "darwin.lopez@claro.com.gt"
    "Creado Por" = "DarwinLopez"
    "Ciclo de Vida" = "Desarrollo"
    "Version" = "v1.0.0"
    "Fecha de Creacion" = "2025-10-18"
    "Confidencialidad" = "Interno"
    "Criticidad" = "Alta"
    "BackupRequired" = "Yes"
    "MonitoringLevel" = "Enhanced"
  }
}


# Target Group: sgsi-web-targets
resource "aws_lb_target_group" "sgsi_web_targets" {
  name     = "sgsi-web-targets"
  port     = 80
  protocol = "HTTP"
  vpc_id   = data.aws_vpc.sgsi_vpc_main.id
  
  health_check {
    enabled             = true
    healthy_threshold   = 2
    unhealthy_threshold = 2
    timeout             = 5
    interval            = 30
    path                = "/health"
    matcher             = "200"
    port                = "traffic-port"
    protocol            = "HTTP"
  }

  tags = {
    Name = "sgsi-web-targets"
  }
}


# Target Group: sgsi-api-targets
resource "aws_lb_target_group" "sgsi_api_targets" {
  name     = "sgsi-api-targets"
  port     = 8080
  protocol = "HTTP"
  vpc_id   = data.aws_vpc.sgsi_vpc_main.id
  
  health_check {
    enabled             = true
    healthy_threshold   = 2
    unhealthy_threshold = 3
    timeout             = 5
    interval            = 30
    path                = "/api/health"
    matcher             = "200,202"
    port                = "8080"
    protocol            = "HTTP"
  }

  tags = {
    Name = "sgsi-api-targets"
  }
}


# Listener: Port 80
resource "aws_lb_listener" "sgsi_main_alb_listener_80" {
  load_balancer_arn = aws_lb.sgsi_main_alb.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type = "redirect"
    redirect {
      port        = "443"
      protocol    = "HTTPS"
      status_code = "HTTP_301"
    }
  }
}


# Listener: Port 443
resource "aws_lb_listener" "sgsi_main_alb_listener_443" {
  load_balancer_arn = aws_lb.sgsi_main_alb.arn
  port              = "443"
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-TLS-1-2-2017-01"
  certificate_arn   = "arn:aws:acm:us-east-1:051963532279:certificate/sgsi-cert"

  default_action {
    type = "forward"
    target_group_arn = aws_lb_target_group.sgsi_web_targets.arn
  }
}


# Data sources are defined in compute-shared-data-sources.tf

