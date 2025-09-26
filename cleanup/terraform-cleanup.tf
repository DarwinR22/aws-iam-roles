# Terraform cleanup script for old IAM policies
# Run this after new MCI policies are created

# First, discover existing policies with old naming pattern
data "aws_iam_policies" "old_policies" {
  name_regex = "^githubactions-(basepermissions|iammanagement|terraformbackend)-.*"
}

# Import and then remove old policies
locals {
  old_policy_names = [
    for policy in data.aws_iam_policies.old_policies.names : policy
    if can(regex("^githubactions-(basepermissions|iammanagement|terraformbackend)-[0-9]+$", policy))
  ]
}

# Terraform will plan to destroy these after import
resource "aws_iam_policy" "old_policies_to_cleanup" {
  for_each = toset(local.old_policy_names)
  
  name = each.value
  path = "/policies/"
  
  # Minimal policy for cleanup - will be destroyed
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = []
  })

  lifecycle {
    prevent_destroy = false
  }
}

output "policies_to_cleanup" {
  value = local.old_policy_names
  description = "Old policies that will be cleaned up"
}