# policy_lib/dynamodb/main.tf
# =======================================
# DYNAMODB ABAC POLICY BUILDING BLOCKS
# =======================================

# DYNAMODB READ-ONLY ACCESS BY TAG MATCHING
data "aws_iam_policy_document" "dynamodb_tag_based_read" {
  statement {
    sid    = "DynamoDBTagBasedReadAccess"
    effect = "Allow"
    actions = [
      "dynamodb:GetItem",
      "dynamodb:Query",
      "dynamodb:Scan",
      "dynamodb:BatchGetItem",
      "dynamodb:DescribeTable",
      "dynamodb:GetRecords",
      "dynamodb:GetShardIterator",
      "dynamodb:ListStreams"
    ]
    
    resources = [
      "arn:aws:dynamodb:us-east-1:393209814297:table/*",
      "arn:aws:dynamodb:us-east-1:393209814297:table/*/stream/*",
      "arn:aws:dynamodb:us-east-1:393209814297:table/*/index/*"
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

# DYNAMODB WRITE ACCESS BY TAG MATCHING
data "aws_iam_policy_document" "dynamodb_tag_based_write" {
  statement {
    sid    = "DynamoDBTagBasedWriteAccess"
    effect = "Allow"
    actions = [
      "dynamodb:PutItem",
      "dynamodb:UpdateItem",
      "dynamodb:DeleteItem",
      "dynamodb:BatchWriteItem"
    ]
    
    resources = [
      "arn:aws:dynamodb:us-east-1:393209814297:table/*"
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

# DYNAMODB LEADING KEYS RESTRICTION (ABAC)
data "aws_iam_policy_document" "dynamodb_leading_keys_read" {
  statement {
    sid    = "DynamoDBLeadingKeysReadAccess"
    effect = "Allow"
    actions = [
      "dynamodb:GetItem",
      "dynamodb:Query"
    ]
    
    resources = [
      "arn:aws:dynamodb:us-east-1:393209814297:table/*"
    ]
    
    condition {
      test     = "ForAllValues:StringLike"
      variable = "dynamodb:LeadingKeys"
      values   = ["$${aws:PrincipalTag/Gerencia}-*"]
    }
    
    condition {
      test     = "StringEquals"
      variable = "aws:ResourceTag/Ambiente"
      values   = ["$${aws:PrincipalTag/Ambiente}"]
    }
  }
}

# DYNAMODB PATH-BASED ACCESS (FALLBACK)
data "aws_iam_policy_document" "dynamodb_explicit_read" {
  count = length(var.dynamodb_read_table_arns) > 0 ? 1 : 0
  
  statement {
    sid    = "DynamoDBExplicitReadAccess"
    effect = "Allow"
    actions = [
      "dynamodb:GetItem",
      "dynamodb:Query",
      "dynamodb:Scan",
      "dynamodb:BatchGetItem",
      "dynamodb:DescribeTable"
    ]
    
    resources = var.dynamodb_read_table_arns
  }
}

data "aws_iam_policy_document" "dynamodb_explicit_write" {
  count = length(var.dynamodb_write_table_arns) > 0 ? 1 : 0
  
  statement {
    sid    = "DynamoDBExplicitWriteAccess"
    effect = "Allow"
    actions = [
      "dynamodb:PutItem",
      "dynamodb:UpdateItem",
      "dynamodb:DeleteItem",
      "dynamodb:BatchWriteItem"
    ]
    
    resources = var.dynamodb_write_table_arns
  }
}