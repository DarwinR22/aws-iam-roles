# ==============================================================================
# OUTPUTS - ALB MODULE
# ==============================================================================

output "alb_id" {
  description = "ID del Application Load Balancer"
  value       = aws_lb.main.id
}

output "alb_arn" {
  description = "ARN del Application Load Balancer"
  value       = aws_lb.main.arn
}

output "alb_arn_suffix" {
  description = "ARN suffix del ALB para CloudWatch metrics"
  value       = aws_lb.main.arn_suffix
}

output "alb_dns_name" {
  description = "DNS name del ALB"
  value       = aws_lb.main.dns_name
}

output "alb_zone_id" {
  description = "Zone ID del ALB para Route53"
  value       = aws_lb.main.zone_id
}

output "target_group_arn" {
  description = "ARN del Target Group"
  value       = aws_lb_target_group.web.arn
}

output "target_group_arn_suffix" {
  description = "ARN suffix del Target Group"
  value       = aws_lb_target_group.web.arn_suffix
}

output "target_group_name" {
  description = "Nombre del Target Group"
  value       = aws_lb_target_group.web.name
}

output "http_listener_arn" {
  description = "ARN del HTTP listener"
  value       = var.enable_https ? (length(aws_lb_listener.http) > 0 ? aws_lb_listener.http[0].arn : "") : (length(aws_lb_listener.http_direct) > 0 ? aws_lb_listener.http_direct[0].arn : "")
}

output "https_listener_arn" {
  description = "ARN del HTTPS listener (si está habilitado)"
  value       = var.enable_https && length(aws_lb_listener.https) > 0 ? aws_lb_listener.https[0].arn : ""
}

output "cloudwatch_alarm_arns" {
  description = "ARNs de las alarmas de CloudWatch"
  value = {
    unhealthy_targets = aws_cloudwatch_metric_alarm.target_unhealthy.arn
    response_time     = aws_cloudwatch_metric_alarm.target_response_time.arn
    http_5xx          = aws_cloudwatch_metric_alarm.http_5xx.arn
  }
}

output "compliance_summary" {
  description = "Resumen de compliance del módulo ALB"
  value = {
    iso27001_controls = ["A.13.1.3", "A.17.2.1", "A.12.4.1"]
    nist_controls     = ["PR.IP-1", "DE.AE-3"]
    features = {
      cross_zone_lb         = true
      health_checks         = true
      cloudwatch_alarms     = true
      access_logs           = var.access_logs_bucket != ""
      https_enabled         = var.enable_https
      drop_invalid_headers  = true
    }
  }
}
