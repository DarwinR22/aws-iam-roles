# policy_lib/s3/main.tf
# =============================================
# S3 ABAC POLICY BUILDING BLOCKS
# =============================================

# S3 READ-ONLY ACCESS BY TAG MATCHING
data "aws_iam_policy_document" "s3_tag_based_read" {
  statement {
    sid    = "S3TagBasedReadAccess"
    effect = "Allow"
    actions = [
      "s3:GetObject",
      "s3:GetObjectVersion",
      "s3:GetObjectVersionTagging",
      "s3:GetObjectTagging"
    ]
    
    resources = ["arn:aws:s3:::*/*"]
    
    condition {
      test     = "StringEquals"
      variable = "s3:ExistingObjectTag/Ambiente"
      values   = ["$${aws:PrincipalTag/Ambiente}"]
    }
    
    condition {
      test     = "StringEquals"
      variable = "s3:ExistingObjectTag/Proyecto"
      values   = ["$${aws:PrincipalTag/Proyecto}"]
    }
    
    condition {
      test     = "StringEquals"
      variable = "s3:ExistingObjectTag/Gerencia"
      values   = ["$${aws:PrincipalTag/Gerencia}"]
    }
  }
  
  statement {
    sid    = "S3TagBasedListBucket"
    effect = "Allow"
    actions = [
      "s3:ListBucket",
      "s3:GetBucketLocation",
      "s3:GetBucketVersioning"
    ]
    
    resources = ["arn:aws:s3:::*"]
    
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
      test     = "StringLike"
      variable = "s3:prefix"
      values   = ["$${aws:PrincipalTag/Gerencia}/*"]
    }
  }
}

# S3 WRITE ACCESS BY TAG MATCHING
data "aws_iam_policy_document" "s3_tag_based_write" {
  statement {
    sid    = "S3TagBasedWriteAccess"
    effect = "Allow"
    actions = [
      "s3:PutObject",
      "s3:PutObjectTagging",
      "s3:DeleteObject"
    ]
    
    resources = ["arn:aws:s3:::*/*"]
    
    condition {
      test     = "StringEquals"
      variable = "s3:ExistingObjectTag/Ambiente"
      values   = ["$${aws:PrincipalTag/Ambiente}"]
    }
    
    condition {
      test     = "StringEquals"
      variable = "s3:ExistingObjectTag/Proyecto"
      values   = ["$${aws:PrincipalTag/Proyecto}"]
    }
    
    # Require tagging on new objects
    condition {
      test     = "StringEquals"
      variable = "s3:RequestedRegion"
      values   = ["us-east-1"]
    }
  }
  
  statement {
    sid    = "S3RequiredTagsOnNewObjects"
    effect = "Allow"
    actions = [
      "s3:PutObjectTagging"
    ]
    
    resources = ["arn:aws:s3:::*/*"]
    
    condition {
      test     = "StringEquals"
      variable = "s3:x-amz-tagging"
      values   = [
        "Ambiente=$${aws:PrincipalTag/Ambiente}&Proyecto=$${aws:PrincipalTag/Proyecto}&Gerencia=$${aws:PrincipalTag/Gerencia}"
      ]
    }
  }
}

# S3 PATH-BASED ACCESS (FALLBACK)
data "aws_iam_policy_document" "s3_path_based_read" {
  statement {
    sid    = "S3PathBasedReadAccess"
    effect = "Allow"
    actions = [
      "s3:GetObject",
      "s3:GetObjectVersion"
    ]
    
    resources = var.s3_read_paths
  }
  
  statement {
    sid    = "S3PathBasedListBucket"
    effect = "Allow"
    actions = [
      "s3:ListBucket"
    ]
    
    resources = var.s3_bucket_arns
    
    condition {
      test     = "StringLike"
      variable = "s3:prefix"
      values   = var.s3_read_prefixes
    }
  }
}

data "aws_iam_policy_document" "s3_path_based_write" {
  statement {
    sid    = "S3PathBasedWriteAccess"
    effect = "Allow"
    actions = [
      "s3:PutObject",
      "s3:PutObjectTagging",
      "s3:DeleteObject"
    ]
    
    resources = var.s3_write_paths
  }
}