# ==============================================================================
# MODULE OUTPUTS
# ==============================================================================

output "lb_id" {
  description = "Lb Id"
  value       = aws_lb.main.id
}

output "lb_arn" {
  description = "Lb Arn"
  value       = aws_lb.main.arn
}

output "lb_dns_name" {
  description = "Lb Dns Name"
  value       = aws_lb.main.dns_name
}

output "lb_zone_id" {
  description = "Lb Zone Id"
  value       = aws_lb.main.zone_id
}

output "module_info" {
  description = "Information about this module"
  value = {
    module_name = "application-load-balancer"
    status      = "implemented"
  }
}
