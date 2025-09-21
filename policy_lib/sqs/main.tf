# policy_lib/sqs/main.tf
# =================================
# SQS ABAC POLICY BUILDING BLOCKS
# =================================

# SQS PRODUCE (SEND MESSAGE) BY TAG MATCHING
data "aws_iam_policy_document" "sqs_tag_based_produce" {
  statement {
    sid    = "SQSTagBasedProduce"
    effect = "Allow"
    actions = [
      "sqs:SendMessage",
      "sqs:SendMessageBatch",
      "sqs:GetQueueAttributes"
    ]
    
    resources = [
      "arn:aws:sqs:us-east-1:393209814297:*"
    ]
    
    condition {
      test     = "StringEquals"
      variable = "aws:ResourceTag/Ambiente"
      values   = ["$${aws:PrincipalTag/Ambiente}"]
    }
    
    condition {
      test     = "StringEquals"
      variable = "aws:ResourceTag/Proyecto"
      values   = ["$${aws:PrincipalTag/Proyecto}"]
    }
    
    condition {
      test     = "StringEquals"
      variable = "aws:ResourceTag/Gerencia"
      values   = ["$${aws:PrincipalTag/Gerencia}"]
    }
  }
}

# SQS CONSUME (RECEIVE MESSAGE) BY TAG MATCHING
data "aws_iam_policy_document" "sqs_tag_based_consume" {
  statement {
    sid    = "SQSTagBasedConsume"
    effect = "Allow"
    actions = [
      "sqs:ReceiveMessage",
      "sqs:DeleteMessage",
      "sqs:DeleteMessageBatch",
      "sqs:GetQueueAttributes",
      "sqs:ChangeMessageVisibility",
      "sqs:ChangeMessageVisibilityBatch"
    ]
    
    resources = [
      "arn:aws:sqs:us-east-1:393209814297:*"
    ]
    
    condition {
      test     = "StringEquals"
      variable = "aws:ResourceTag/Ambiente"
      values   = ["$${aws:PrincipalTag/Ambiente}"]
    }
    
    condition {
      test     = "StringEquals"
      variable = "aws:ResourceTag/Proyecto"
      values   = ["$${aws:PrincipalTag/Proyecto}"]
    }
    
    condition {
      test     = "StringEquals"
      variable = "aws:ResourceTag/Gerencia"
      values   = ["$${aws:PrincipalTag/Gerencia}"]
    }
  }
}

# SQS EXPLICIT QUEUE ACCESS (FALLBACK)
data "aws_iam_policy_document" "sqs_explicit_produce" {
  count = length(var.sqs_produce_queue_arns) > 0 ? 1 : 0
  
  statement {
    sid    = "SQSExplicitProduce"
    effect = "Allow"
    actions = [
      "sqs:SendMessage",
      "sqs:SendMessageBatch",
      "sqs:GetQueueAttributes"
    ]
    
    resources = var.sqs_produce_queue_arns
  }
}

data "aws_iam_policy_document" "sqs_explicit_consume" {
  count = length(var.sqs_consume_queue_arns) > 0 ? 1 : 0
  
  statement {
    sid    = "SQSExplicitConsume"
    effect = "Allow"
    actions = [
      "sqs:ReceiveMessage",
      "sqs:DeleteMessage",
      "sqs:DeleteMessageBatch",
      "sqs:GetQueueAttributes",
      "sqs:ChangeMessageVisibility",
      "sqs:ChangeMessageVisibilityBatch"
    ]
    
    resources = var.sqs_consume_queue_arns
  }
}