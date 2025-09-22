# =========================================
# Glue Tag-Based Policy Building Blocks
# =========================================

# Glue Tag-Based Read Policy
data "aws_iam_policy_document" "glue_tag_based_read" {
  statement {
    sid    = "GlueTagBasedRead"
    effect = "Allow"
    
    actions = [
      "glue:GetJob",
      "glue:GetJobs",
      "glue:GetJobRun",
      "glue:GetJobRuns",
      "glue:GetJobBookmark",
      "glue:GetCrawler",
      "glue:GetCrawlers",
      "glue:GetCrawlerMetrics",
      "glue:GetDatabase",
      "glue:GetDatabases",
      "glue:GetTable",
      "glue:GetTables",
      "glue:GetTableVersion",
      "glue:GetTableVersions",
      "glue:GetPartition",
      "glue:GetPartitions",
      "glue:GetConnection",
      "glue:GetConnections",
      "glue:GetDevEndpoint",
      "glue:GetDevEndpoints",
      "glue:GetTrigger",
      "glue:GetTriggers",
      "glue:GetWorkflow",
      "glue:GetWorkflowRun",
      "glue:GetWorkflowRuns",
      "glue:GetWorkflowRunProperties"
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
    sid    = "GlueListOperations"
    effect = "Allow"
    
    actions = [
      "glue:ListJobs",
      "glue:ListCrawlers",
      "glue:ListDevEndpoints",
      "glue:ListTriggers",
      "glue:ListWorkflows",
      "glue:GetCatalogImportStatus",
      "glue:GetDataCatalogEncryptionSettings",
      "glue:GetResourcePolicy",
      "glue:BatchGetJobs",
      "glue:BatchGetCrawlers",
      "glue:BatchGetDevEndpoints",
      "glue:BatchGetTriggers",
      "glue:BatchGetWorkflows"
    ]
    
    resources = ["*"]
  }
}

# Glue Tag-Based Execute Policy
data "aws_iam_policy_document" "glue_tag_based_execute" {
  statement {
    sid    = "GlueTagBasedExecute"
    effect = "Allow"
    
    actions = [
      "glue:StartJobRun",
      "glue:BatchStopJobRun",
      "glue:StartCrawler",
      "glue:StopCrawler",
      "glue:StartTrigger",
      "glue:StopTrigger",
      "glue:StartWorkflowRun",
      "glue:StopWorkflowRun",
      "glue:ResumeWorkflowRun",
      "glue:ResetJobBookmark",
      "glue:UpdateJob",
      "glue:UpdateCrawler",
      "glue:UpdateTrigger",
      "glue:UpdateWorkflow",
      "glue:CreateJob",
      "glue:CreateCrawler",
      "glue:CreateTrigger",
      "glue:CreateWorkflow",
      "glue:DeleteJob",
      "glue:DeleteCrawler",
      "glue:DeleteTrigger",
      "glue:DeleteWorkflow"
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
    sid    = "GlueDataCatalogAccess"
    effect = "Allow"
    
    actions = [
      "glue:CreateDatabase",
      "glue:UpdateDatabase",
      "glue:DeleteDatabase",
      "glue:CreateTable",
      "glue:UpdateTable",
      "glue:DeleteTable",
      "glue:BatchCreatePartition",
      "glue:BatchDeletePartition",
      "glue:BatchUpdatePartition",
      "glue:CreatePartition",
      "glue:UpdatePartition",
      "glue:DeletePartition",
      "glue:ImportCatalogToGlue"
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
    sid    = "GlueReadAccess"
    effect = "Allow"
    
    actions = [
      "glue:GetJob",
      "glue:GetJobs",
      "glue:GetJobRun",
      "glue:GetJobRuns",
      "glue:GetJobBookmark",
      "glue:GetCrawler",
      "glue:GetCrawlers",
      "glue:GetCrawlerMetrics",
      "glue:GetDatabase",
      "glue:GetDatabases",
      "glue:GetTable",
      "glue:GetTables",
      "glue:GetTableVersion",
      "glue:GetTableVersions",
      "glue:GetPartition",
      "glue:GetPartitions",
      "glue:GetConnection",
      "glue:GetConnections",
      "glue:GetDevEndpoint",
      "glue:GetDevEndpoints",
      "glue:GetTrigger",
      "glue:GetTriggers",
      "glue:GetWorkflow",
      "glue:GetWorkflowRun",
      "glue:GetWorkflowRuns",
      "glue:GetWorkflowRunProperties"
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