# ==============================================================================
# SECURITY GROUP MODULE
# Security group with ingress and egress rules
# ==============================================================================

terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

# TODO: Implement security-group resources
# This template provides the basic structure for the module

# Example resource structure:
# resource "aws_service" "main" {
#   # Configuration here
#   
#   tags = merge(var.common_tags, var.additional_tags, {
#     Name        = var.name
#     Environment = var.environment
#   })
# }
