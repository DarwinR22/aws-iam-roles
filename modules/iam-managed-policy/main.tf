# modules/iam-managed-policy/main.tf
# =========================================
# ENTERPRISE IAM MANAGED POLICY MODULE
# =========================================

terraform {
  required_version = ">= 1.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

# VALIDATION AND POLICY CREATION
resource "aws_iam_policy" "this" {
  lifecycle {
    precondition {
      condition     = !local.has_duplicates
      error_message = "❌ DUPLICATE TAG KEYS DETECTED: Found case-insensitive duplicate tag keys."
    }
    
    precondition {
      condition     = length(var.policy_document_json) > 0
      error_message = "❌ Policy document cannot be empty"
    }
    
    precondition {
      condition = can(jsondecode(var.policy_document_json))
      error_message = "❌ Policy document must be valid JSON"
    }
  }
  
  name        = var.policy_name
  description = var.description
  path        = var.path
  policy      = var.policy_document_json
  
  tags = local.final_tags
}

# POLICY VALIDATION (using AWS CLI if available)
resource "null_resource" "policy_validation" {
  count = 1
  
  triggers = {
    policy_content = var.policy_document_json
  }
  
  # This would validate the policy using AWS CLI (optional)
  # provisioner "local-exec" {
  #   command = "aws iam validate-policy --policy-document '${var.policy_document_json}'"
  # }
}