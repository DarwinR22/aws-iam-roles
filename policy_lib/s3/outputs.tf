# policy_lib/s3/outputs.tf
# =========================
# S3 POLICY BLOCK OUTPUTS
# =========================

output "s3_tag_based_read_policy_json" {
  description = "S3 tag-based read policy document (JSON)"
  value       = data.aws_iam_policy_document.s3_tag_based_read.json
}

output "s3_tag_based_write_policy_json" {
  description = "S3 tag-based write policy document (JSON)"
  value       = data.aws_iam_policy_document.s3_tag_based_write.json
}

output "s3_path_based_read_policy_json" {
  description = "S3 path-based read policy document (JSON)"
  value       = var.enable_path_based_access ? data.aws_iam_policy_document.s3_path_based_read.json : ""
}

output "s3_path_based_write_policy_json" {
  description = "S3 path-based write policy document (JSON)"
  value       = var.enable_path_based_access ? data.aws_iam_policy_document.s3_path_based_write.json : ""
}