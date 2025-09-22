# =========================================
# Redshift Tag-Based Policy Building Blocks
# =========================================

# Redshift Tag-Based Read Policy
data "aws_iam_policy_document" "redshift_tag_based_read" {
  statement {
    sid    = "RedshiftTagBasedRead"
    effect = "Allow"
    
    actions = [
      "redshift:DescribeClusters",
      "redshift:DescribeClusterSubnetGroups",
      "redshift:DescribeClusterParameterGroups",
      "redshift:DescribeClusterSecurityGroups",
      "redshift:DescribeClusterSnapshots",
      "redshift:DescribeEvents",
      "redshift:DescribeResize",
      "redshift:DescribeLoggingStatus",
      "redshift:GetClusterCredentials"
    ]
    
    resources = [
      "arn:aws:redshift:*:393209814297:cluster:*",
      "arn:aws:redshift:*:393209814297:snapshot:*",
      "arn:aws:redshift:*:393209814297:subnetgroup:*",
      "arn:aws:redshift:*:393209814297:parametergroup:*",
      "arn:aws:redshift:*:393209814297:securitygroup:*"
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
      variable = "aws:ResourceTag/Aplicacion"
      values   = ["$${aws:PrincipalTag/Aplicacion}"]
    }
  }
  
  statement {
    sid    = "RedshiftListOperations"
    effect = "Allow"
    
    actions = [
      "redshift:DescribeAccountAttributes",
      "redshift:DescribeDefaultClusterParameters",
      "redshift:DescribeEventCategories",
      "redshift:DescribeEventSubscriptions",
      "redshift:DescribeOrderableClusterOptions",
      "redshift:DescribeReservedNodeOfferings",
      "redshift:DescribeReservedNodes",
      "redshift:DescribeHsmClientCertificates",
      "redshift:DescribeHsmConfigurations",
      "redshift:DescribeTags"
    ]
    
    resources = [
      "arn:aws:redshift:*:393209814297:cluster:*",
      "arn:aws:redshift:*:393209814297:snapshot:*",
      "arn:aws:redshift:*:393209814297:subnetgroup:*",
      "arn:aws:redshift:*:393209814297:parametergroup:*",
      "arn:aws:redshift:*:393209814297:securitygroup:*"
    ]
  }
}

# Redshift Tag-Based Write Policy
data "aws_iam_policy_document" "redshift_tag_based_write" {
  statement {
    sid    = "RedshiftTagBasedWrite"
    effect = "Allow"
    
    actions = [
      "redshift:CreateCluster",
      "redshift:ModifyCluster",
      "redshift:DeleteCluster",
      "redshift:RebootCluster",
      "redshift:ResizeCluster",
      "redshift:CreateClusterSnapshot",
      "redshift:DeleteClusterSnapshot",
      "redshift:CopyClusterSnapshot",
      "redshift:RestoreFromClusterSnapshot",
      "redshift:EnableLogging",
      "redshift:DisableLogging",
      "redshift:ModifyClusterIamRoles",
      "redshift:CreateClusterSubnetGroup",
      "redshift:ModifyClusterSubnetGroup",
      "redshift:DeleteClusterSubnetGroup",
      "redshift:CreateClusterParameterGroup",
      "redshift:ModifyClusterParameterGroup",
      "redshift:DeleteClusterParameterGroup",
      "redshift:ResetClusterParameterGroup"
    ]
    
    resources = [
      "arn:aws:redshift:*:393209814297:cluster:*",
      "arn:aws:redshift:*:393209814297:snapshot:*",
      "arn:aws:redshift:*:393209814297:subnetgroup:*",
      "arn:aws:redshift:*:393209814297:parametergroup:*",
      "arn:aws:redshift:*:393209814297:securitygroup:*"
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
      variable = "aws:ResourceTag/Aplicacion"
      values   = ["$${aws:PrincipalTag/Aplicacion}"]
    }
  }
  
  statement {
    sid    = "RedshiftTagOperations"
    effect = "Allow"
    
    actions = [
      "redshift:CreateTags",
      "redshift:DeleteTags",
      "redshift:DescribeTags"
    ]
    
    resources = [
      "arn:aws:redshift:*:393209814297:cluster:*",
      "arn:aws:redshift:*:393209814297:snapshot:*",
      "arn:aws:redshift:*:393209814297:subnetgroup:*",
      "arn:aws:redshift:*:393209814297:parametergroup:*",
      "arn:aws:redshift:*:393209814297:securitygroup:*"
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
      variable = "aws:ResourceTag/Aplicacion"
      values   = ["$${aws:PrincipalTag/Aplicacion}"]
    }
  }
  
  # Include read permissions
  statement {
    sid    = "RedshiftReadAccess"
    effect = "Allow"
    
    actions = [
      "redshift:DescribeClusters",
      "redshift:DescribeClusterSubnetGroups",
      "redshift:DescribeClusterParameterGroups",
      "redshift:DescribeClusterSecurityGroups",
      "redshift:DescribeClusterSnapshots",
      "redshift:DescribeEvents",
      "redshift:DescribeResize",
      "redshift:DescribeLoggingStatus",
      "redshift:GetClusterCredentials"
    ]
    
    resources = [
      "arn:aws:redshift:*:393209814297:cluster:*",
      "arn:aws:redshift:*:393209814297:snapshot:*",
      "arn:aws:redshift:*:393209814297:subnetgroup:*",
      "arn:aws:redshift:*:393209814297:parametergroup:*",
      "arn:aws:redshift:*:393209814297:securitygroup:*"
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
      variable = "aws:ResourceTag/Aplicacion"
      values   = ["$${aws:PrincipalTag/Aplicacion}"]
    }
  }
}