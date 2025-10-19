# ==============================================================================
# MODULE OUTPUTS
# ==============================================================================

output "dashboard_arn" {
  description = "Dashboard Arn"
  value       = aws_cloudwatch_dashboard.main.dashboard_arn
}

output "dashboard_url" {
  description = "Dashboard Url"
  value       = aws_cloudwatch_dashboard.main.dashboard_url
}

output "module_info" {
  description = "Information about this module"
  value = {
    module_name = "cloudwatch-dashboard"
    status      = "implemented"
  }
}
