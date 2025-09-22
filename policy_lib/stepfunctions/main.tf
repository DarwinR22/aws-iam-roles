# =========================================
# Step Functions Tag-Based Policy Building Blocks
# =========================================

# Step Functions Tag-Based Read Policy
data "aws_iam_policy_document" "stepfunctions_tag_based_read" {
  statement {
    sid    = "StepFunctionsTagBasedRead"
    effect = "Allow"
    
    actions = [
      "states:DescribeStateMachine",
      "states:DescribeExecution",
      "states:DescribeActivity",
      "states:GetExecutionHistory",
      "states:GetActivityTask",
      "states:ListExecutions",
      "states:ListStateMachines",
      "states:ListActivities"
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
    sid    = "StepFunctionsListOperations"
    effect = "Allow"
    
    actions = [
      "states:ListTagsForResource"
    ]
    
    resources = ["*"]
  }
}

# Step Functions Tag-Based Execute Policy
data "aws_iam_policy_document" "stepfunctions_tag_based_execute" {
  statement {
    sid    = "StepFunctionsTagBasedExecute"
    effect = "Allow"
    
    actions = [
      "states:StartExecution",
      "states:StopExecution",
      "states:CreateStateMachine",
      "states:UpdateStateMachine",
      "states:DeleteStateMachine",
      "states:CreateActivity",
      "states:DeleteActivity",
      "states:SendTaskSuccess",
      "states:SendTaskFailure",
      "states:SendTaskHeartbeat"
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
    sid    = "StepFunctionsTagOperations"
    effect = "Allow"
    
    actions = [
      "states:TagResource",
      "states:UntagResource",
      "states:ListTagsForResource"
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
    sid    = "StepFunctionsReadAccess"
    effect = "Allow"
    
    actions = [
      "states:DescribeStateMachine",
      "states:DescribeExecution",
      "states:DescribeActivity",
      "states:GetExecutionHistory",
      "states:GetActivityTask",
      "states:ListExecutions",
      "states:ListStateMachines",
      "states:ListActivities"
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
    sid    = "StepFunctionsServiceIntegration"
    effect = "Allow"
    
    actions = [
      "lambda:InvokeFunction",
      "sns:Publish",
      "sqs:SendMessage",
      "dynamodb:GetItem",
      "dynamodb:PutItem",
      "dynamodb:UpdateItem",
      "dynamodb:DeleteItem"
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