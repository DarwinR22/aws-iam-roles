# =========================================
# Bedrock Tag-Based Policy Building Blocks
# =========================================

# Bedrock Tag-Based Read Policy
data "aws_iam_policy_document" "bedrock_tag_based_read" {
  statement {
    sid    = "BedrockTagBasedRead"
    effect = "Allow"
    
    actions = [
      "bedrock:GetFoundationModel",
      "bedrock:ListFoundationModels",
      "bedrock:GetModelInvocationLoggingConfiguration",
      "bedrock:GetUsageMetrics",
      "bedrock:ListModelCustomizationJobs",
      "bedrock:GetModelCustomizationJob",
      "bedrock:ListCustomModels",
      "bedrock:GetCustomModel",
      "bedrock:ListProvisionedModelThroughputs",
      "bedrock:GetProvisionedModelThroughput"
    ]
    
    resources = [
      "arn:aws:bedrock:*:393209814297:foundation-model/*",
      "arn:aws:bedrock:*:393209814297:custom-model/*",
      "arn:aws:bedrock:*:393209814297:provisioned-model/*",
      "arn:aws:bedrock:*:393209814297:model-customization-job/*"
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
    sid    = "BedrockListOperations"
    effect = "Allow"
    
    actions = [
      "bedrock:ListTagsForResource"
    ]
    
    resources = [
      "arn:aws:bedrock:*:393209814297:foundation-model/*",
      "arn:aws:bedrock:*:393209814297:custom-model/*",
      "arn:aws:bedrock:*:393209814297:provisioned-model/*",
      "arn:aws:bedrock:*:393209814297:model-customization-job/*"
    ]
  }
}

# Bedrock Tag-Based Invoke Policy
data "aws_iam_policy_document" "bedrock_tag_based_invoke" {
  statement {
    sid    = "BedrockTagBasedInvoke"
    effect = "Allow"
    
    actions = [
      "bedrock:InvokeModel",
      "bedrock:InvokeModelWithResponseStream",
      "bedrock:CreateModelCustomizationJob",
      "bedrock:StopModelCustomizationJob",
      "bedrock:DeleteCustomModel",
      "bedrock:CreateProvisionedModelThroughput",
      "bedrock:UpdateProvisionedModelThroughput",
      "bedrock:DeleteProvisionedModelThroughput"
    ]
    
    resources = [
      "arn:aws:bedrock:*:393209814297:foundation-model/*",
      "arn:aws:bedrock:*:393209814297:custom-model/*",
      "arn:aws:bedrock:*:393209814297:provisioned-model/*",
      "arn:aws:bedrock:*:393209814297:model-customization-job/*"
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
    sid    = "BedrockTagOperations"
    effect = "Allow"
    
    actions = [
      "bedrock:TagResource",
      "bedrock:UntagResource",
      "bedrock:ListTagsForResource"
    ]
    
    resources = [
      "arn:aws:bedrock:*:393209814297:foundation-model/*",
      "arn:aws:bedrock:*:393209814297:custom-model/*",
      "arn:aws:bedrock:*:393209814297:provisioned-model/*",
      "arn:aws:bedrock:*:393209814297:model-customization-job/*"
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
    sid    = "BedrockReadAccess"
    effect = "Allow"
    
    actions = [
      "bedrock:GetFoundationModel",
      "bedrock:ListFoundationModels",
      "bedrock:GetModelInvocationLoggingConfiguration",
      "bedrock:GetUsageMetrics",
      "bedrock:ListModelCustomizationJobs",
      "bedrock:GetModelCustomizationJob",
      "bedrock:ListCustomModels",
      "bedrock:GetCustomModel",
      "bedrock:ListProvisionedModelThroughputs",
      "bedrock:GetProvisionedModelThroughput"
    ]
    
    resources = [
      "arn:aws:bedrock:*:393209814297:foundation-model/*",
      "arn:aws:bedrock:*:393209814297:custom-model/*",
      "arn:aws:bedrock:*:393209814297:provisioned-model/*",
      "arn:aws:bedrock:*:393209814297:model-customization-job/*"
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
    sid    = "BedrockS3Integration"
    effect = "Allow"
    
    actions = [
      "s3:GetObject",
      "s3:PutObject",
      "s3:DeleteObject",
      "s3:ListBucket"
    ]
    
    resources = [
      "arn:aws:s3:::bedrock-*",
      "arn:aws:s3:::bedrock-*/*"
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