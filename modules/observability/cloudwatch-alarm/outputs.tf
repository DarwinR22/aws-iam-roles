# ==============================================================================
# CLOUDWATCH ALARM MODULE - OUTPUTS
# ==============================================================================

output "module_info" {
  description = "Information about this cloudwatch-alarm module"
  value = {
    module_name = "cloudwatch-alarm"
    category    = "observability"
    status      = "implemented"
  }
}

# TODO: Add specific outputs for cloudwatch-alarm
