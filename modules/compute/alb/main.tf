# ==============================================================================
# MÓDULO: APPLICATION LOAD BALANCER (ALB)
# Propósito: Load balancing con alta disponibilidad y seguridad
# Compliance: ISO 27001 A.13.1.3, A.17.2.1 | NIST CSF PR.IP-1
# ==============================================================================

# ------------------------------------------------------------------------------
# APPLICATION LOAD BALANCER
# ------------------------------------------------------------------------------
resource "aws_lb" "main" {
  name               = "${var.project_name}-${var.environment}-alb"
  internal           = var.internal
  load_balancer_type = "application"
  security_groups    = var.security_group_ids
  subnets            = var.subnet_ids

  enable_deletion_protection       = var.enable_deletion_protection
  enable_http2                     = true
  enable_cross_zone_load_balancing = true
  drop_invalid_header_fields       = true
  idle_timeout                     = var.idle_timeout

  # Access Logs to S3 (ISO 27001 A.12.4.1 - Event logging)
  dynamic "access_logs" {
    for_each = var.access_logs_bucket != "" ? [1] : []
    content {
      bucket  = var.access_logs_bucket
      prefix  = "alb-logs"
      enabled = true
    }
  }

  tags = merge(
    var.common_tags,
    {
      Name              = "${var.project_name}-${var.environment}-alb"
      Module            = "compute/alb"
      AssetID           = "COMP-ALB-001"
      AssetType         = "Load-Balancer"
      SecurityLevel     = "High"
      InternetFacing    = var.internal ? "No" : "Yes"
      ISO27001Control   = "A.13.1.3+A.17.2.1"
      NISTControl       = "PR.IP-1"
    }
  )
}

# ------------------------------------------------------------------------------
# TARGET GROUP - WEB SERVERS
# ------------------------------------------------------------------------------
resource "aws_lb_target_group" "web" {
  name     = "${var.project_name}-${var.environment}-web-tg"
  port     = var.target_port
  protocol = var.target_protocol
  vpc_id   = var.vpc_id

  # Deregistration delay
  deregistration_delay = 30

  # Health Check (ISO 27001 A.17.2.1 - Availability monitoring)
  health_check {
    enabled             = true
    healthy_threshold   = var.health_check_healthy_threshold
    unhealthy_threshold = var.health_check_unhealthy_threshold
    interval            = var.health_check_interval
    matcher             = var.health_check_matcher
    path                = var.health_check_path
    port                = "traffic-port"
    protocol            = var.target_protocol
    timeout             = var.health_check_timeout
  }

  # Stickiness (session affinity)
  stickiness {
    type            = "lb_cookie"
    cookie_duration = 86400
    enabled         = var.enable_stickiness
  }

  tags = merge(
    var.common_tags,
    {
      Name              = "${var.project_name}-${var.environment}-web-tg"
      Module            = "compute/alb"
      AssetType         = "Target-Group"
      BackendPort       = var.target_port
    }
  )
}

# ------------------------------------------------------------------------------
# ALB LISTENER - HTTP (Redirect to HTTPS)
# ------------------------------------------------------------------------------
resource "aws_lb_listener" "http" {
  count             = var.enable_https ? 1 : 0
  load_balancer_arn = aws_lb.main.arn
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

  tags = merge(
    var.common_tags,
    {
      Name   = "${var.project_name}-http-redirect"
      Module = "compute/alb"
    }
  )
}

# ------------------------------------------------------------------------------
# ALB LISTENER - HTTP (No HTTPS)
# ------------------------------------------------------------------------------
resource "aws_lb_listener" "http_direct" {
  count             = var.enable_https ? 0 : 1
  load_balancer_arn = aws_lb.main.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.web.arn
  }

  tags = merge(
    var.common_tags,
    {
      Name   = "${var.project_name}-http-listener"
      Module = "compute/alb"
    }
  )
}

# ------------------------------------------------------------------------------
# ALB LISTENER - HTTPS (SSL/TLS)
# ------------------------------------------------------------------------------
resource "aws_lb_listener" "https" {
  count             = var.enable_https ? 1 : 0
  load_balancer_arn = aws_lb.main.arn
  port              = "443"
  protocol          = "HTTPS"
  ssl_policy        = var.ssl_policy
  certificate_arn   = var.certificate_arn

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.web.arn
  }

  tags = merge(
    var.common_tags,
    {
      Name   = "${var.project_name}-https-listener"
      Module = "compute/alb"
    }
  )
}

# ------------------------------------------------------------------------------
# CLOUDWATCH ALARMS - ALB MONITORING
# ------------------------------------------------------------------------------

# Alarm: Target Unhealthy Count
resource "aws_cloudwatch_metric_alarm" "target_unhealthy" {
  alarm_name          = "${var.project_name}-${var.environment}-alb-unhealthy-targets"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "2"
  metric_name         = "UnHealthyHostCount"
  namespace           = "AWS/ApplicationELB"
  period              = "60"
  statistic           = "Average"
  threshold           = "0"
  alarm_description   = "ALB tiene targets no saludables"
  treat_missing_data  = "notBreaching"

  dimensions = {
    LoadBalancer = aws_lb.main.arn_suffix
    TargetGroup  = aws_lb_target_group.web.arn_suffix
  }

  tags = merge(
    var.common_tags,
    {
      Name              = "${var.project_name}-alb-unhealthy-alarm"
      Module            = "compute/alb"
      AlarmType         = "HealthCheck"
      ISO27001Control   = "A.17.2.1"
    }
  )
}

# Alarm: Target Response Time
resource "aws_cloudwatch_metric_alarm" "target_response_time" {
  alarm_name          = "${var.project_name}-${var.environment}-alb-high-response-time"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "2"
  metric_name         = "TargetResponseTime"
  namespace           = "AWS/ApplicationELB"
  period              = "60"
  statistic           = "Average"
  threshold           = var.response_time_threshold
  alarm_description   = "Tiempo de respuesta del ALB es alto"
  treat_missing_data  = "notBreaching"

  dimensions = {
    LoadBalancer = aws_lb.main.arn_suffix
  }

  tags = merge(
    var.common_tags,
    {
      Name              = "${var.project_name}-alb-response-time-alarm"
      Module            = "compute/alb"
      AlarmType         = "Performance"
    }
  )
}

# Alarm: HTTP 5XX Errors
resource "aws_cloudwatch_metric_alarm" "http_5xx" {
  alarm_name          = "${var.project_name}-${var.environment}-alb-5xx-errors"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "2"
  metric_name         = "HTTPCode_Target_5XX_Count"
  namespace           = "AWS/ApplicationELB"
  period              = "60"
  statistic           = "Sum"
  threshold           = var.error_5xx_threshold
  alarm_description   = "Alta tasa de errores 5XX en targets"
  treat_missing_data  = "notBreaching"

  dimensions = {
    LoadBalancer = aws_lb.main.arn_suffix
  }

  tags = merge(
    var.common_tags,
    {
      Name              = "${var.project_name}-alb-5xx-alarm"
      Module            = "compute/alb"
      AlarmType         = "Error"
    }
  )
}
