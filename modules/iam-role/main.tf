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
