# Data source for current AWS caller identity
data "aws_caller_identity" "current" {}

# github-deployment-database Policy Module - Following ABAC Pattern
# Converted from definitions/policies/deployment/github-deployment-database.yaml
resource "aws_iam_policy" "main" {
  name        = "github-deployment-database"
  path        = "/"
  description = var.policy_description

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid      = "RDSInstanceManagement"
        Effect   = "Allow"
        Action   = ["rds:CreateDBInstance", "rds:DeleteDBInstance", "rds:DescribeDBInstances", "rds:ModifyDBInstance", "rds:RebootDBInstance", "rds:StartDBInstance", "rds:StopDBInstance", "rds:DescribeDBLogFiles", "rds:DownloadDBLogFilePortion", "rds:ApplyPendingMaintenanceAction", "rds:DescribePendingMaintenanceActions", "rds:CreateDBSnapshot", "rds:DeleteDBSnapshot", "rds:DescribeDBSnapshots", "rds:RestoreDBInstanceFromDBSnapshot", "rds:CopyDBSnapshot", "rds:DescribeDBInstanceAutomatedBackups", "rds:DeleteDBInstanceAutomatedBackup"]
        Resource = ["*"]
        }, {
        Sid      = "RDSSubnetGroupManagement"
        Effect   = "Allow"
        Action   = ["rds:CreateDBSubnetGroup", "rds:DeleteDBSubnetGroup", "rds:DescribeDBSubnetGroups", "rds:ModifyDBSubnetGroup"]
        Resource = ["*"]
        }, {
        Sid      = "RDSParameterGroupManagement"
        Effect   = "Allow"
        Action   = ["rds:CreateDBParameterGroup", "rds:DeleteDBParameterGroup", "rds:DescribeDBParameterGroups", "rds:ModifyDBParameterGroup", "rds:DescribeDBParameters", "rds:ResetDBParameterGroup", "rds:DescribeEngineDefaultParameters", "rds:DescribeEngineDefaultClusterParameters"]
        Resource = ["*"]
        }, {
        Sid      = "RDSOptionGroupManagement"
        Effect   = "Allow"
        Action   = ["rds:CreateOptionGroup", "rds:DeleteOptionGroup", "rds:DescribeOptionGroups", "rds:ModifyOptionGroup", "rds:DescribeOptionGroupOptions"]
        Resource = ["*"]
        }, {
        Sid      = "RDSSecurityGroupManagement"
        Effect   = "Allow"
        Action   = ["rds:CreateDBSecurityGroup", "rds:DeleteDBSecurityGroup", "rds:DescribeDBSecurityGroups", "rds:AuthorizeDBSecurityGroupIngress", "rds:RevokeDBSecurityGroupIngress"]
        Resource = ["*"]
        }, {
        Sid      = "RDSMonitoringAndPerformance"
        Effect   = "Allow"
        Action   = ["pi:DescribeDimensionKeys", "pi:GetDimensionKeyDetails", "pi:GetResourceMetrics", "logs:CreateLogGroup", "logs:CreateLogStream", "logs:PutLogEvents", "logs:DescribeLogGroups", "logs:DescribeLogStreams", "cloudwatch:PutMetricData", "cloudwatch:GetMetricStatistics", "cloudwatch:ListMetrics"]
        Resource = ["*"]
        }, {
        Sid      = "RDSEventsAndNotifications"
        Effect   = "Allow"
        Action   = ["rds:CreateEventSubscription", "rds:DeleteEventSubscription", "rds:DescribeEventSubscriptions", "rds:ModifyEventSubscription", "rds:DescribeEvents", "rds:DescribeEventCategories", "rds:DescribeSourceRegions"]
        Resource = ["*"]
        }, {
        Sid      = "RDSTagManagement"
        Effect   = "Allow"
        Action   = ["rds:AddTagsToResource", "rds:RemoveTagsFromResource", "rds:ListTagsForResource"]
        Resource = ["*"]
    }]
  })

  tags = merge(var.common_tags, {
    Name = "github-deployment-database-${var.environment}"
    Type = "Policy"
  })
}