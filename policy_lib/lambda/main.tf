# policy_lib/lambda/main.tf
# ====================================
# LAMBDA ABAC POLICY BUILDING BLOCKS
# ====================================

# LAMBDA INVOKE BY FUNCTION PREFIX
data "aws_iam_policy_document" "lambda_invoke_by_prefix" {
  statement {
    sid    = "LambdaInvokeByPrefix"
    effect = "Allow"
    actions = [
      "lambda:InvokeFunction"
    ]
    
    resources = [
      "arn:aws:lambda:us-east-1:393209814297:function:$${aws:PrincipalTag/Gerencia}-*"
    ]
    
    condition {
      test     = "StringEquals"
      variable = "lambda:FunctionTag/Ambiente"
      values   = ["$${aws:PrincipalTag/Ambiente}"]
    }
    
    condition {
      test     = "StringEquals"
      variable = "lambda:FunctionTag/Proyecto"
      values   = ["$${aws:PrincipalTag/Proyecto}"]
    }
  }
}

# LAMBDA TAG-BASED INVOKE
data "aws_iam_policy_document" "lambda_tag_based_invoke" {
  statement {
    sid    = "LambdaTagBasedInvoke"
    effect = "Allow"
    actions = [
      "lambda:InvokeFunction",
      "lambda:GetFunction",
      "lambda:GetFunctionConfiguration"
    ]
    
    resources = [
      "arn:aws:lambda:us-east-1:393209814297:function:*"
    ]
    
    condition {
      test     = "StringEquals"
      variable = "lambda:FunctionTag/Ambiente"
      values   = ["$${aws:PrincipalTag/Ambiente}"]
    }
    
    condition {
      test     = "StringEquals"
      variable = "lambda:FunctionTag/Proyecto"
      values   = ["$${aws:PrincipalTag/Proyecto}"]
    }
    
    condition {
      test     = "StringEquals"
      variable = "lambda:FunctionTag/Gerencia"
      values   = ["$${aws:PrincipalTag/Gerencia}"]
    }
  }
}

# LAMBDA EXECUTION ROLE PERMISSIONS
data "aws_iam_policy_document" "lambda_execution_basic" {
  statement {
    sid    = "LambdaBasicExecution"
    effect = "Allow"
    actions = [
      "logs:CreateLogGroup",
      "logs:CreateLogStream",
      "logs:PutLogEvents"
    ]
    
    resources = [
      "arn:aws:logs:us-east-1:393209814297:log-group:/aws/lambda/$${aws:PrincipalTag/Gerencia}-*",
      "arn:aws:logs:us-east-1:393209814297:log-group:/aws/lambda/$${aws:PrincipalTag/Gerencia}-*:*"
    ]
  }
}

# LAMBDA EXPLICIT INVOKE (FALLBACK)
data "aws_iam_policy_document" "lambda_explicit_invoke" {
  count = length(var.lambda_function_arns) > 0 ? 1 : 0
  
  statement {
    sid    = "LambdaExplicitInvoke"
    effect = "Allow"
    actions = [
      "lambda:InvokeFunction"
    ]
    
    resources = var.lambda_function_arns
  }
}