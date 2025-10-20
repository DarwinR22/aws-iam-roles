# ==============================================================================
# MODULE: Network ACLs - Outputs
# ==============================================================================

output "dmz_nacl_id" {
  description = "ID of the DMZ Network ACL"
  value       = aws_network_acl.dmz_nacl.id
}

output "app_nacl_id" {
  description = "ID of the Application Network ACL"
  value       = aws_network_acl.app_nacl.id
}

output "db_nacl_id" {
  description = "ID of the Database Network ACL"
  value       = aws_network_acl.db_nacl.id
}

output "network_acl_ids" {
  description = "Map of all Network ACL IDs"
  value = {
    dmz         = aws_network_acl.dmz_nacl.id
    application = aws_network_acl.app_nacl.id
    database    = aws_network_acl.db_nacl.id
  }
}

output "compliance_info" {
  description = "Compliance information for Network ACLs"
  value = {
    iso_27001_control  = "A.13.1.1"
    defense_in_depth   = "Enabled"
    security_layers    = 2 # NACLs + Security Groups
    tiers_protected    = ["DMZ", "Application", "Database"]
    deny_rules_enabled = true
  }
}
