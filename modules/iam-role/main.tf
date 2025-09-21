# modules/iam-role/main.tf
# ========================================
# ENTERPRISE IAM ROLE MODULE WITH ABAC
# ========================================

terraform {
  required_version = ">= 1.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

# DATA SOURCES
data "aws_caller_identity" "current" {}

# LOCAL CALCULATIONS
locals {
  # Merge canonical tags with additional tags
  final_tags = merge(var.canonical_tags, var.tags)
  
  # Permission boundary logic
  effective_boundary_arn = var.permission_boundary_arn != "" ? var.permission_boundary_arn : "arn:aws:iam::${data.aws_caller_identity.current.account_id}:policy/App-StandardBoundary"
  
  # Tag validation: check for duplicates (case-insensitive)
  all_tag_keys = concat(keys(var.canonical_tags), keys(var.tags))
  lowercase_keys = [for k in local.all_tag_keys : lower(k)]
  unique_keys = toset(local.lowercase_keys)
  has_duplicates = length(local.lowercase_keys) != length(local.unique_keys)
  
  # Tag validation: unauthorized keys (only canonical tags allowed in addition to var.tags)
  canonical_keys = keys(var.canonical_tags)
  additional_keys = keys(var.tags)
  authorized_keys = toset(concat(local.canonical_keys, local.additional_keys))
  unauthorized_keys = setsubtract(toset(keys(local.final_tags)), local.authorized_keys)
}

# VALIDATION PRECONDITIONS
resource "aws_iam_role" "this" {
  lifecycle {
    precondition {
      condition     = !local.has_duplicates
      error_message = "❌ DUPLICATE TAG KEYS DETECTED: Found case-insensitive duplicate tag keys. AWS IAM treats tag keys as case-insensitive."
    }
    
    precondition {
      condition     = length(local.unauthorized_keys) == 0
      error_message = "❌ UNAUTHORIZED TAG KEYS: ${join(", ", local.unauthorized_keys)}. Only canonical tags are allowed."
    }
    
    precondition {
      condition     = length(var.trust_policy_document) > 0
      error_message = "❌ Trust policy document cannot be empty"
    }
  }
  
  name                  = var.role_name
  assume_role_policy    = var.trust_policy_document
  description           = var.description
  max_session_duration  = var.max_session_duration
  permissions_boundary  = local.effective_boundary_arn
  force_detach_policies = var.force_detach_policies

  tags = local.final_tags
}

# ATTACH MANAGED POLICIES
resource "aws_iam_role_policy_attachment" "managed_policies" {
  for_each = toset(var.managed_policy_arns)

  role       = aws_iam_role.this.name
  policy_arn = each.value
}

# ATTACH INLINE POLICIES
resource "aws_iam_role_policy" "inline_policies" {
  for_each = var.inline_policies

  name   = each.key
  role   = aws_iam_role.this.id
  policy = each.value
}
