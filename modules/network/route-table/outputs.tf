# ==============================================================================
# ROUTE TABLE MODULE - OUTPUTS
# ==============================================================================

output "module_info" {
  description = "Information about this route-table module"
  value = {
    module_name = "route-table"
    category    = "network"
    status      = "implemented"
  }
}

# TODO: Add specific outputs for route-table
