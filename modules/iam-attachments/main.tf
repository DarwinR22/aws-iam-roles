# modules/iam-attachments/main.tf
# ====================================
# ENTERPRISE IAM ATTACHMENTS MODULE
# ====================================

terraform {
  required_version = ">= 1.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

# ATTACH POLICIES WITH VALIDATION
resource "aws_iam_role_policy_attachment" "managed_policies" {
  for_each = toset(local.unique_policy_arns)
  
  lifecycle {
    precondition {
      condition     = !local.exceeds_limit
      error_message = "❌ POLICY ATTACHMENT LIMIT EXCEEDED: Attempting to attach ${local.policy_count} policies, but limit is ${var.max_attached_policies}. AWS allows maximum 20 policies per role."
    }
    
    precondition {
      condition     = can(regex("^arn:aws:iam::(aws|[0-9]+):policy/.+", each.value))
      error_message = "❌ INVALID POLICY ARN: ${each.value} is not a valid IAM policy ARN."
    }
  }

  role       = var.role_name
  policy_arn = each.value
}

# DATA SOURCE TO VALIDATE ROLE EXISTS
data "aws_iam_role" "target_role" {
  name = var.role_name
}