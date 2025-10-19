# Auto-generated policy module: github_deployment_monitoring

resource "aws_iam_policy" "github_deployment_monitoring" {
  name        = "${var.environment}-github-deployment-monitoring"
  description = "GitHub Actions deployment policy for Monitoring and Compliance infrastructure (CloudTrail, Config, GuardDuty, Security Hub)"
  path        = "/"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "cloudtrail:CreateTrail",
        "cloudtrail:DeleteTrail",
        "cloudtrail:DescribeTrails",
        "cloudtrail:GetTrailStatus",
        "cloudtrail:StartLogging",
        "cloudtrail:StopLogging",
        "cloudtrail:UpdateTrail",
        "cloudtrail:PutEventSelectors",
        "cloudtrail:GetEventSelectors",
        "cloudtrail:PutInsightSelectors",
        "cloudtrail:GetInsightSelectors",
        "cloudtrail:CreateEventDataStore",
        "cloudtrail:DeleteEventDataStore",
        "cloudtrail:GetEventDataStore",
        "cloudtrail:ListEventDataStores"
      ],
      "Sid": "CloudTrailManagement",
      "Resource": [
        "*"
      ]
    },
    {
      "Effect": "Allow",
      "Action": [
        "config:PutConfigurationRecorder",
        "config:DeleteConfigurationRecorder",
        "config:DescribeConfigurationRecorders",
        "config:PutDeliveryChannel",
        "config:DeleteDeliveryChannel",
        "config:DescribeDeliveryChannels",
        "config:StartConfigurationRecorder",
        "config:StopConfigurationRecorder",
        "config:PutConfigRule",
        "config:DeleteConfigRule",
        "config:DescribeConfigRules",
        "config:GetComplianceDetailsByConfigRule",
        "config:GetComplianceSummaryByConfigRule",
        "config:PutRemediationConfigurations",
        "config:DeleteRemediationConfiguration",
        "config:DescribeRemediationConfigurations",
        "config:PutOrganizationConfigRule",
        "config:DeleteOrganizationConfigRule"
      ],
      "Sid": "ConfigManagement",
      "Resource": [
        "*"
      ]
    },
    {
      "Effect": "Allow",
      "Action": [
        "guardduty:CreateDetector",
        "guardduty:DeleteDetector",
        "guardduty:GetDetector",
        "guardduty:ListDetectors",
        "guardduty:UpdateDetector",
        "guardduty:CreateIPSet",
        "guardduty:DeleteIPSet",
        "guardduty:GetIPSet",
        "guardduty:ListIPSets",
        "guardduty:UpdateIPSet",
        "guardduty:CreateThreatIntelSet",
        "guardduty:DeleteThreatIntelSet",
        "guardduty:GetThreatIntelSet",
        "guardduty:ListThreatIntelSets",
        "guardduty:UpdateThreatIntelSet",
        "guardduty:CreateFilter",
        "guardduty:DeleteFilter",
        "guardduty:GetFilter",
        "guardduty:ListFilters",
        "guardduty:UpdateFilter",
        "guardduty:CreatePublishingDestination",
        "guardduty:DeletePublishingDestination",
        "guardduty:DescribePublishingDestination",
        "guardduty:ListPublishingDestinations"
      ],
      "Sid": "GuardDutyManagement",
      "Resource": [
        "*"
      ]
    },
    {
      "Effect": "Allow",
      "Action": [
        "securityhub:EnableSecurityHub",
        "securityhub:DisableSecurityHub",
        "securityhub:GetEnabledStandards",
        "securityhub:BatchEnableStandards",
        "securityhub:BatchDisableStandards",
        "securityhub:UpdateStandardsControl",
        "securityhub:CreateInsight",
        "securityhub:DeleteInsight",
        "securityhub:GetInsights",
        "securityhub:UpdateInsight",
        "securityhub:CreateCustomAction",
        "securityhub:DeleteCustomAction",
        "securityhub:GetCustomActions",
        "securityhub:UpdateCustomAction",
        "securityhub:EnableImportFindingsForProduct",
        "securityhub:DisableImportFindingsForProduct",
        "securityhub:ListEnabledProductsForImport",
        "securityhub:GetMasterAccount",
        "securityhub:AcceptInvitation",
        "securityhub:DeclineInvitations",
        "securityhub:CreateMembers",
        "securityhub:DeleteMembers",
        "securityhub:GetMembers",
        "securityhub:InviteMembers"
      ],
      "Sid": "SecurityHubManagement",
      "Resource": [
        "*"
      ]
    },
    {
      "Effect": "Allow",
      "Action": [
        "cloudwatch:PutMetricAlarm",
        "cloudwatch:DeleteAlarms",
        "cloudwatch:DescribeAlarms",
        "cloudwatch:EnableAlarmActions",
        "cloudwatch:DisableAlarmActions",
        "cloudwatch:PutDashboard",
        "cloudwatch:DeleteDashboards",
        "cloudwatch:GetDashboard",
        "cloudwatch:ListDashboards",
        "cloudwatch:GetMetricStatistics",
        "cloudwatch:ListMetrics",
        "cloudwatch:PutMetricData",
        "logs:CreateLogGroup",
        "logs:DeleteLogGroup",
        "logs:DescribeLogGroups",
        "logs:CreateLogStream",
        "logs:DeleteLogStream",
        "logs:DescribeLogStreams",
        "logs:PutLogEvents",
        "logs:PutMetricFilter",
        "logs:DeleteMetricFilter",
        "logs:DescribeMetricFilters",
        "logs:PutRetentionPolicy",
        "logs:DeleteRetentionPolicy"
      ],
      "Sid": "CloudWatchManagement",
      "Resource": [
        "*"
      ]
    },
    {
      "Effect": "Allow",
      "Action": [
        "inspector2:EnableInspector",
        "inspector2:DisableInspector",
        "inspector2:GetConfiguration",
        "inspector2:UpdateConfiguration",
        "inspector2:CreateFilter",
        "inspector2:DeleteFilter",
        "inspector2:GetFilter",
        "inspector2:ListFilters",
        "inspector2:UpdateFilter",
        "inspector:CreateAssessmentTarget",
        "inspector:DeleteAssessmentTarget",
        "inspector:DescribeAssessmentTargets",
        "inspector:CreateAssessmentTemplate",
        "inspector:DeleteAssessmentTemplate",
        "inspector:DescribeAssessmentTemplates",
        "inspector:StartAssessmentRun",
        "inspector:StopAssessmentRun",
        "inspector:DescribeAssessmentRuns"
      ],
      "Sid": "InspectorManagement",
      "Resource": [
        "*"
      ]
    },
    {
      "Effect": "Allow",
      "Action": [
        "ssm:PutComplianceItems",
        "ssm:ListComplianceItems",
        "ssm:ListComplianceSummary",
        "ssm:GetComplianceSummary",
        "ssm:CreateAssociation",
        "ssm:DeleteAssociation",
        "ssm:DescribeAssociations",
        "ssm:UpdateAssociation",
        "ssm:CreateDocument",
        "ssm:DeleteDocument",
        "ssm:DescribeDocument",
        "ssm:ListDocuments",
        "ssm:UpdateDocument"
      ],
      "Sid": "SystemsManagerCompliance",
      "Resource": [
        "*"
      ]
    },
    {
      "Effect": "Allow",
      "Action": [
        "support:DescribeTrustedAdvisorChecks",
        "support:DescribeTrustedAdvisorCheckResult",
        "support:RefreshTrustedAdvisorCheck"
      ],
      "Sid": "TrustedAdvisorAccess",
      "Resource": [
        "*"
      ]
    },
    {
      "Effect": "Allow",
      "Action": [
        "wellarchitected:CreateWorkload",
        "wellarchitected:DeleteWorkload",
        "wellarchitected:GetWorkload",
        "wellarchitected:ListWorkloads",
        "wellarchitected:UpdateWorkload",
        "wellarchitected:CreateLensReview",
        "wellarchitected:DeleteLensReview",
        "wellarchitected:GetLensReview",
        "wellarchitected:UpdateLensReview"
      ],
      "Sid": "WellArchitectedTool",
      "Resource": [
        "*"
      ]
    },
    {
      "Effect": "Allow",
      "Action": [
        "sns:CreateTopic",
        "sns:DeleteTopic",
        "sns:GetTopicAttributes",
        "sns:ListTopics",
        "sns:SetTopicAttributes",
        "sns:Subscribe",
        "sns:Unsubscribe",
        "sns:Publish"
      ],
      "Sid": "SNSForMonitoring",
      "Resource": [
        "arn:aws:sns:*:*:sgsi-*",
        "arn:aws:sns:*:*:security-*",
        "arn:aws:sns:*:*:compliance-*"
      ]
    },
    {
      "Effect": "Allow",
      "Action": [
        "events:CreateRule",
        "events:DeleteRule",
        "events:DescribeRule",
        "events:ListRules",
        "events:PutRule",
        "events:PutTargets",
        "events:RemoveTargets",
        "events:EnableRule",
        "events:DisableRule"
      ],
      "Sid": "EventBridgeManagement",
      "Resource": [
        "*"
      ]
    },
    {
      "Effect": "Allow",
      "Action": [
        "cloudtrail:AddTags",
        "cloudtrail:RemoveTags",
        "cloudtrail:ListTags",
        "cloudwatch:TagResource",
        "cloudwatch:UntagResource",
        "cloudwatch:ListTagsForResource",
        "logs:TagLogGroup",
        "logs:UntagLogGroup",
        "logs:ListTagsLogGroup"
      ],
      "Sid": "MonitoringTagging",
      "Resource": [
        "*"
      ]
    }
  ]
}
EOF

  tags = merge(
    var.common_tags,
    {
      Name          = "${var.environment}-github-deployment-monitoring"
      PolicyType    = "Custom"
      Scope         = "Service"
      GeneratedFrom = "github_deployment_monitoring.yaml"
    }
  )
}
