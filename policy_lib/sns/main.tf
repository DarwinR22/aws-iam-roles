# =========================================
# SNS Tag-Based Policy Building Blocks
# =========================================

# SNS Tag-Based Publish Policy
data "aws_iam_policy_document" "sns_tag_based_publish" {
  statement {
    sid    = "SNSTagBasedPublish"
    effect = "Allow"
    
    actions = [
      "sns:Publish",
      "sns:GetTopicAttributes"
    ]
    
    resources = [
      "arn:aws:sns:*:393209814297:*"
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
    sid    = "SNSListTopics"
    effect = "Allow"
    
    actions = [
      "sns:ListTopics",
      "sns:ListTagsForResource"
    ]
    
    resources = ["*"]
  }
}

# SNS Tag-Based Subscribe Policy
data "aws_iam_policy_document" "sns_tag_based_subscribe" {
  statement {
    sid    = "SNSTagBasedSubscribe"
    effect = "Allow"
    
    actions = [
      "sns:Subscribe",
      "sns:Unsubscribe",
      "sns:ConfirmSubscription",
      "sns:GetSubscriptionAttributes",
      "sns:SetSubscriptionAttributes",
      "sns:GetTopicAttributes"
    ]
    
    resources = [
      "arn:aws:sns:*:393209814297:*"
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
    sid    = "SNSListOperations"
    effect = "Allow"
    
    actions = [
      "sns:ListTopics",
      "sns:ListSubscriptions",
      "sns:ListSubscriptionsByTopic",
      "sns:ListTagsForResource"
    ]
    
    resources = ["*"]
  }
}