# ==============================================================================
# GUARDDUTY MODULE - OUTPUTS
# ==============================================================================

output "module_info" {
  description = "Information about this guardduty module"
  value = {
    module_name = "guardduty"
    category    = "observability"
    status      = "implemented"
  }
}

# TODO: Add specific outputs for guardduty
