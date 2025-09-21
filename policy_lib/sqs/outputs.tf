# policy_lib/sqs/outputs.tf
# =========================
# SQS POLICY BLOCK OUTPUTS
# =========================

output "sqs_tag_based_produce_policy_json" {
  description = "SQS tag-based produce policy document (JSON)"
  value       = data.aws_iam_policy_document.sqs_tag_based_produce.json
}

output "sqs_tag_based_consume_policy_json" {
  description = "SQS tag-based consume policy document (JSON)"
  value       = data.aws_iam_policy_document.sqs_tag_based_consume.json
}

output "sqs_explicit_produce_policy_json" {
  description = "SQS explicit produce policy document (JSON)"
  value       = length(var.sqs_produce_queue_arns) > 0 ? data.aws_iam_policy_document.sqs_explicit_produce[0].json : ""
}

output "sqs_explicit_consume_policy_json" {
  description = "SQS explicit consume policy document (JSON)"
  value       = length(var.sqs_consume_queue_arns) > 0 ? data.aws_iam_policy_document.sqs_explicit_consume[0].json : ""
}