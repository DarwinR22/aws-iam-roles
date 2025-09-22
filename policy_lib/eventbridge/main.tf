# =========================================
# EventBridge Tag-Based Policy Building Blocks
# =========================================

# EventBridge Tag-Based Read Policy
data "aws_iam_policy_document" "eventbridge_tag_based_read" {
  statement {
    sid    = "EventBridgeTagBasedRead"
    effect = "Allow"
    
    actions = [
      "events:DescribeRule",
      "events:ListRules",
      "events:ListTargetsByRule",
      "events:DescribeEventBus",
      "events:ListEventBuses",
      "events:DescribeArchive",
      "events:ListArchives",
      "events:DescribeReplay",
      "events:ListReplays",
      "events:DescribeConnection",
      "events:ListConnections",
      "events:DescribeDestination",
      "events:ListDestinations",
      "events:TestEventPattern"
    ]
    
    resources = [
      "arn:aws:events:*:393209814297:rule/*",
      "arn:aws:events:*:393209814297:event-bus/*",
      "arn:aws:events:*:393209814297:archive/*",
      "arn:aws:events:*:393209814297:replay/*",
      "arn:aws:events:*:393209814297:connection/*",
      "arn:aws:events:*:393209814297:destination/*"
    ]
    
    condition {
      test     = "StringEquals"
      variable = "aws:ResourceTag/Ambiente"
      values   = ["$${aws:PrincipalTag/Ambiente}"]
    }
    
    condition {
      test     = "StringEquals"
      variable = "aws:ResourceTag/Pais"
      values   = ["$${aws:PrincipalTag/Pais}"]
    }
    
    condition {
      test     = "StringEquals"
      variable = "aws:ResourceTag/Gerencia"
      values   = ["$${aws:PrincipalTag/Gerencia}"]
    }
    
    condition {
      test     = "StringEquals"
      variable = "aws:ResourceTag/Aplicación"
      values   = ["$${aws:PrincipalTag/Aplicación}"]
    }
  }
  
  statement {
    sid    = "EventBridgeListOperations"
    effect = "Allow"
    
    actions = [
      "events:ListTagsForResource"
    ]
    
    resources = ["*"]
  }
}

# EventBridge Tag-Based Execute Policy
data "aws_iam_policy_document" "eventbridge_tag_based_execute" {
  statement {
    sid    = "EventBridgeTagBasedExecute"
    effect = "Allow"
    
    actions = [
      "events:PutEvents",
      "events:PutRule",
      "events:DeleteRule",
      "events:PutTargets",
      "events:RemoveTargets",
      "events:EnableRule",
      "events:DisableRule",
      "events:CreateEventBus",
      "events:DeleteEventBus",
      "events:PutPermission",
      "events:RemovePermission",
      "events:CreateArchive",
      "events:UpdateArchive",
      "events:DeleteArchive",
      "events:StartReplay",
      "events:CancelReplay",
      "events:CreateConnection",
      "events:UpdateConnection",
      "events:DeleteConnection",
      "events:AuthorizeConnection",
      "events:DeauthorizeConnection",
      "events:InvokeApiDestination",
      "events:CreateDestination",
      "events:UpdateDestination",
      "events:DeleteDestination"
    ]
    
    resources = [
      "arn:aws:events:*:393209814297:rule/*",
      "arn:aws:events:*:393209814297:event-bus/*",
      "arn:aws:events:*:393209814297:archive/*",
      "arn:aws:events:*:393209814297:replay/*",
      "arn:aws:events:*:393209814297:connection/*",
      "arn:aws:events:*:393209814297:destination/*"
    ]
    
    condition {
      test     = "StringEquals"
      variable = "aws:ResourceTag/Ambiente"
      values   = ["$${aws:PrincipalTag/Ambiente}"]
    }
    
    condition {
      test     = "StringEquals"
      variable = "aws:ResourceTag/Pais"
      values   = ["$${aws:PrincipalTag/Pais}"]
    }
    
    condition {
      test     = "StringEquals"
      variable = "aws:ResourceTag/Gerencia"
      values   = ["$${aws:PrincipalTag/Gerencia}"]
    }
    
    condition {
      test     = "StringEquals"
      variable = "aws:ResourceTag/Aplicación"
      values   = ["$${aws:PrincipalTag/Aplicación}"]
    }
  }
  
  statement {
    sid    = "EventBridgeTagOperations"
    effect = "Allow"
    
    actions = [
      "events:TagResource",
      "events:UntagResource",
      "events:ListTagsForResource"
    ]
    
    resources = [
      "arn:aws:events:*:393209814297:rule/*",
      "arn:aws:events:*:393209814297:event-bus/*",
      "arn:aws:events:*:393209814297:archive/*",
      "arn:aws:events:*:393209814297:replay/*",
      "arn:aws:events:*:393209814297:connection/*",
      "arn:aws:events:*:393209814297:destination/*"
    ]
    
    condition {
      test     = "StringEquals"
      variable = "aws:ResourceTag/Ambiente"
      values   = ["$${aws:PrincipalTag/Ambiente}"]
    }
    
    condition {
      test     = "StringEquals"
      variable = "aws:ResourceTag/Pais"
      values   = ["$${aws:PrincipalTag/Pais}"]
    }
    
    condition {
      test     = "StringEquals"
      variable = "aws:ResourceTag/Gerencia"
      values   = ["$${aws:PrincipalTag/Gerencia}"]
    }
    
    condition {
      test     = "StringEquals"
      variable = "aws:ResourceTag/Aplicación"
      values   = ["$${aws:PrincipalTag/Aplicación}"]
    }
  }
  
  # Include read permissions
  statement {
    sid    = "EventBridgeReadAccess"
    effect = "Allow"
    
    actions = [
      "events:DescribeRule",
      "events:ListRules",
      "events:ListTargetsByRule",
      "events:DescribeEventBus",
      "events:ListEventBuses",
      "events:DescribeArchive",
      "events:ListArchives",
      "events:DescribeReplay",
      "events:ListReplays",
      "events:DescribeConnection",
      "events:ListConnections",
      "events:DescribeDestination",
      "events:ListDestinations",
      "events:TestEventPattern"
    ]
    
    resources = [
      "arn:aws:events:*:393209814297:rule/*",
      "arn:aws:events:*:393209814297:event-bus/*",
      "arn:aws:events:*:393209814297:archive/*",
      "arn:aws:events:*:393209814297:replay/*",
      "arn:aws:events:*:393209814297:connection/*",
      "arn:aws:events:*:393209814297:destination/*"
    ]
    
    condition {
      test     = "StringEquals"
      variable = "aws:ResourceTag/Ambiente"
      values   = ["$${aws:PrincipalTag/Ambiente}"]
    }
    
    condition {
      test     = "StringEquals"
      variable = "aws:ResourceTag/Pais"
      values   = ["$${aws:PrincipalTag/Pais}"]
    }
    
    condition {
      test     = "StringEquals"
      variable = "aws:ResourceTag/Gerencia"
      values   = ["$${aws:PrincipalTag/Gerencia}"]
    }
    
    condition {
      test     = "StringEquals"
      variable = "aws:ResourceTag/Aplicación"
      values   = ["$${aws:PrincipalTag/Aplicación}"]
    }
  }
  
  statement {
    sid    = "EventBridgeServiceIntegration"
    effect = "Allow"
    
    actions = [
      "lambda:InvokeFunction",
      "sns:Publish",
      "sqs:SendMessage",
      "kinesis:PutRecord",
      "kinesis:PutRecords",
      "firehose:PutRecord",
      "firehose:PutRecordBatch"
    ]
    
    resources = [
      "arn:aws:lambda:*:393209814297:function:*",
      "arn:aws:sns:*:393209814297:*",
      "arn:aws:sqs:*:393209814297:*",
      "arn:aws:kinesis:*:393209814297:stream/*",
      "arn:aws:firehose:*:393209814297:deliverystream/*"
    ]
    
    condition {
      test     = "StringEquals"
      variable = "aws:ResourceTag/Ambiente"
      values   = ["$${aws:PrincipalTag/Ambiente}"]
    }
    
    condition {
      test     = "StringEquals"
      variable = "aws:ResourceTag/Pais"
      values   = ["$${aws:PrincipalTag/Pais}"]
    }
    
    condition {
      test     = "StringEquals"
      variable = "aws:ResourceTag/Gerencia"
      values   = ["$${aws:PrincipalTag/Gerencia}"]
    }
    
    condition {
      test     = "StringEquals"
      variable = "aws:ResourceTag/Aplicación"
      values   = ["$${aws:PrincipalTag/Aplicación}"]
    }
  }
}