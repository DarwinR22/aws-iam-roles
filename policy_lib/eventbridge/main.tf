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
    
    resources = ["*"]
    
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
    
    resources = ["*"]
    
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
    
    resources = ["*"]
    
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
    
    resources = ["*"]
    
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
    
    resources = ["*"]
    
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