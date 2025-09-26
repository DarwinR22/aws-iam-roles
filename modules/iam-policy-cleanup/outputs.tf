# modules/iam-policy-cleanup/outputs.tf
# Outputs para el módulo de cleanup de políticas obsoletas

output "obsolete_policies_found" {
  description = "List of obsolete policies found"
  value       = local.obsolete_policy_names
}

output "cleanup_resources_created" {
  description = "Number of cleanup resources created"
  value       = length(local.obsolete_policies_map)
}

output "cleanup_summary" {
  description = "Summary of cleanup operations"
  value = {
    total_obsolete_policies = length(local.obsolete_policy_names)
    policies_to_cleanup    = keys(local.obsolete_policies_map)
    cleanup_enabled        = var.cleanup_enabled
    environment           = var.environment
  }
}