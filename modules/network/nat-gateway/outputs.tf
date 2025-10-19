# ==============================================================================
# NAT GATEWAY MODULE - OUTPUTS
# ==============================================================================

output "module_info" {
  description = "Information about this nat-gateway module"
  value = {
    module_name = "nat-gateway"
    category    = "network"
    status      = "implemented"
  }
}

# TODO: Add specific outputs for nat-gateway
