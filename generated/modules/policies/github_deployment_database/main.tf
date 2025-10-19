# Auto-generated policy module: github_deployment_database

resource "aws_iam_policy" "github_deployment_database" {
  name        = "${var.environment}-github-deployment-database"
  description = "Política consolidada para recursos de base de datos (RDS) del SGSI Layer 3"
  path        = "/"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "rds:CreateDBInstance",
        "rds:DeleteDBInstance",
        "rds:DescribeDBInstances",
        "rds:ModifyDBInstance",
        "rds:RebootDBInstance",
        "rds:StartDBInstance",
        "rds:StopDBInstance",
        "rds:DescribeDBLogFiles",
        "rds:DownloadDBLogFilePortion",
        "rds:ApplyPendingMaintenanceAction",
        "rds:DescribePendingMaintenanceActions",
        "rds:CreateDBSnapshot",
        "rds:DeleteDBSnapshot",
        "rds:DescribeDBSnapshots",
        "rds:RestoreDBInstanceFromDBSnapshot",
        "rds:CopyDBSnapshot",
        "rds:DescribeDBInstanceAutomatedBackups",
        "rds:DeleteDBInstanceAutomatedBackup"
      ],
      "Sid": "RDSInstanceManagement",
      "Resource": [
        "*"
      ],
      "Condition": {
        "StringEquals": {
          "aws:RequestedRegion": "us-east-1"
        }
      }
    },
    {
      "Effect": "Allow",
      "Action": [
        "rds:CreateDBSubnetGroup",
        "rds:DeleteDBSubnetGroup",
        "rds:DescribeDBSubnetGroups",
        "rds:ModifyDBSubnetGroup"
      ],
      "Sid": "RDSSubnetGroupManagement",
      "Resource": [
        "*"
      ],
      "Condition": {
        "StringEquals": {
          "aws:RequestedRegion": "us-east-1"
        }
      }
    },
    {
      "Effect": "Allow",
      "Action": [
        "rds:CreateDBParameterGroup",
        "rds:DeleteDBParameterGroup",
        "rds:DescribeDBParameterGroups",
        "rds:ModifyDBParameterGroup",
        "rds:DescribeDBParameters",
        "rds:ResetDBParameterGroup",
        "rds:DescribeEngineDefaultParameters",
        "rds:DescribeEngineDefaultClusterParameters"
      ],
      "Sid": "RDSParameterGroupManagement",
      "Resource": [
        "*"
      ],
      "Condition": {
        "StringEquals": {
          "aws:RequestedRegion": "us-east-1"
        }
      }
    },
    {
      "Effect": "Allow",
      "Action": [
        "rds:CreateOptionGroup",
        "rds:DeleteOptionGroup",
        "rds:DescribeOptionGroups",
        "rds:ModifyOptionGroup",
        "rds:DescribeOptionGroupOptions"
      ],
      "Sid": "RDSOptionGroupManagement",
      "Resource": [
        "*"
      ],
      "Condition": {
        "StringEquals": {
          "aws:RequestedRegion": "us-east-1"
        }
      }
    },
    {
      "Effect": "Allow",
      "Action": [
        "rds:CreateDBSecurityGroup",
        "rds:DeleteDBSecurityGroup",
        "rds:DescribeDBSecurityGroups",
        "rds:AuthorizeDBSecurityGroupIngress",
        "rds:RevokeDBSecurityGroupIngress"
      ],
      "Sid": "RDSSecurityGroupManagement",
      "Resource": [
        "*"
      ],
      "Condition": {
        "StringEquals": {
          "aws:RequestedRegion": "us-east-1"
        }
      }
    },
    {
      "Effect": "Allow",
      "Action": [
        "pi:DescribeDimensionKeys",
        "pi:GetDimensionKeyDetails",
        "pi:GetResourceMetrics",
        "logs:CreateLogGroup",
        "logs:CreateLogStream",
        "logs:PutLogEvents",
        "logs:DescribeLogGroups",
        "logs:DescribeLogStreams",
        "cloudwatch:PutMetricData",
        "cloudwatch:GetMetricStatistics",
        "cloudwatch:ListMetrics"
      ],
      "Sid": "RDSMonitoringAndPerformance",
      "Resource": [
        "*"
      ],
      "Condition": {
        "StringEquals": {
          "aws:RequestedRegion": "us-east-1"
        }
      }
    },
    {
      "Effect": "Allow",
      "Action": [
        "rds:CreateEventSubscription",
        "rds:DeleteEventSubscription",
        "rds:DescribeEventSubscriptions",
        "rds:ModifyEventSubscription",
        "rds:DescribeEvents",
        "rds:DescribeEventCategories",
        "rds:DescribeSourceRegions"
      ],
      "Sid": "RDSEventsAndNotifications",
      "Resource": [
        "*"
      ],
      "Condition": {
        "StringEquals": {
          "aws:RequestedRegion": "us-east-1"
        }
      }
    },
    {
      "Effect": "Allow",
      "Action": [
        "rds:AddTagsToResource",
        "rds:RemoveTagsFromResource",
        "rds:ListTagsForResource"
      ],
      "Sid": "RDSTagManagement",
      "Resource": [
        "*"
      ],
      "Condition": {
        "StringEquals": {
          "aws:RequestedRegion": "us-east-1"
        }
      }
    }
  ]
}
EOF

  tags = merge(
    var.common_tags,
    {
      Name          = "${var.environment}-github-deployment-database"
      PolicyType    = "Custom"
      Scope         = "Service"
      GeneratedFrom = "github_deployment_database.yaml"
    }
  )
}
