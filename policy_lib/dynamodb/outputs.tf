# policy_lib/dynamodb/outputs.tf
# ===============================
# DYNAMODB POLICY BLOCK OUTPUTS
# ===============================

output "dynamodb_tag_based_read_policy_json" {
  description = "DynamoDB tag-based read policy document (JSON)"
  value       = data.aws_iam_policy_document.dynamodb_tag_based_read.json
}

output "dynamodb_tag_based_write_policy_json" {
  description = "DynamoDB tag-based write policy document (JSON)"
  value       = data.aws_iam_policy_document.dynamodb_tag_based_write.json
}

output "dynamodb_leading_keys_read_policy_json" {
  description = "DynamoDB leading keys read policy document (JSON)"
  value       = data.aws_iam_policy_document.dynamodb_leading_keys_read.json
}

output "dynamodb_explicit_read_policy_json" {
  description = "DynamoDB explicit read policy document (JSON)"
  value       = length(var.dynamodb_read_table_arns) > 0 ? data.aws_iam_policy_document.dynamodb_explicit_read[0].json : ""
}

output "dynamodb_explicit_write_policy_json" {
  description = "DynamoDB explicit write policy document (JSON)"
  value       = length(var.dynamodb_write_table_arns) > 0 ? data.aws_iam_policy_document.dynamodb_explicit_write[0].json : ""
}