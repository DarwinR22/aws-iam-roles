# Auto-generated policy module: github_deployment_observability

resource "aws_iam_policy" "github_deployment_observability" {
  name        = "${var.environment}-github-deployment-observability"
  description = "Política consolidada para observabilidad completa (CloudWatch, Logs, Monitoring, Security) del SGSI - Consolidación de cloudwatch + monitoring"
  path        = "/"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "logs:CreateLogGroup",
        "logs:DeleteLogGroup",
        "logs:DescribeLogGroups",
        "logs:PutRetentionPolicy",
        "logs:DeleteRetentionPolicy",
        "logs:CreateLogStream",
        "logs:DeleteLogStream",
        "logs:DescribeLogStreams",
        "logs:PutLogEvents",
        "logs:GetLogEvents",
        "logs:FilterLogEvents",
        "logs:PutMetricFilter",
        "logs:DeleteMetricFilter",
        "logs:DescribeMetricFilters",
        "logs:TagLogGroup",
        "logs:UntagLogGroup",
        "logs:ListTagsLogGroup",
        "logs:ListTagsForResource",
        "logs:TagResource",
        "logs:UntagResource"
      ],
      "Sid": "CloudWatchLogsManagement",
      "Resource": [
        "arn:aws:logs:*:*:log-group:*",
        "arn:aws:logs:*:*:log-group:*:log-stream:*"
      ]
    },
    {
      "Effect": "Allow",
      "Action": [
        "cloudwatch:PutMetricData",
        "cloudwatch:GetMetricData",
        "cloudwatch:GetMetricStatistics",
        "cloudwatch:ListMetrics",
        "cloudwatch:PutMetricAlarm",
        "cloudwatch:DeleteAlarms",
        "cloudwatch:DescribeAlarms",
        "cloudwatch:DescribeAlarmsForMetric",
        "cloudwatch:DescribeAlarmHistory",
        "cloudwatch:SetAlarmState",
        "cloudwatch:EnableAlarmActions",
        "cloudwatch:DisableAlarmActions",
        "cloudwatch:TagResource",
        "cloudwatch:UntagResource",
        "cloudwatch:ListTagsForResource"
      ],
      "Sid": "CloudWatchMetricsAndAlarms",
      "Resource": [
        "arn:aws:cloudwatch:*:*:alarm:*",
        "*"
      ]
    },
    {
      "Effect": "Allow",
      "Action": [
        "cloudwatch:PutDashboard",
        "cloudwatch:GetDashboard",
        "cloudwatch:DeleteDashboards",
        "cloudwatch:ListDashboards"
      ],
      "Sid": "CloudWatchDashboards",
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
        "sns:SetTopicAttributes",
        "sns:ListTopics",
        "sns:Subscribe",
        "sns:Unsubscribe",
        "sns:ListSubscriptions",
        "sns:ListSubscriptionsByTopic",
        "sns:GetSubscriptionAttributes",
        "sns:SetSubscriptionAttributes",
        "sns:Publish",
        "sns:AddPermission",
        "sns:RemovePermission",
        "sns:TagResource",
        "sns:UntagResource",
        "sns:ListTagsForResource",
        "sns:CreatePlatformApplication",
        "sns:DeletePlatformApplication",
        "sns:GetPlatformApplicationAttributes",
        "sns:SetPlatformApplicationAttributes",
        "sns:ListPlatformApplications",
        "sns:CreatePlatformEndpoint",
        "sns:DeleteEndpoint",
        "sns:GetEndpointAttributes",
        "sns:SetEndpointAttributes"
      ],
      "Sid": "SNSManagement",
      "Resource": [
        "arn:aws:sns:*:*:*",
        "arn:aws:sns:*:*:app/*",
        "arn:aws:sns:*:*:endpoint/*",
        "arn:aws:sns:*:*:sgsi-*",
        "arn:aws:sns:*:*:security-*",
        "arn:aws:sns:*:*:compliance-*"
      ]
    },
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
        "cloudtrail:ListEventDataStores",
        "cloudtrail:AddTags",
        "cloudtrail:RemoveTags",
        "cloudtrail:ListTags"
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
        "guardduty:ListPublishingDestinations",
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
      "Sid": "SecurityMonitoring",
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
        "inspector:DescribeAssessmentRuns",
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
        "ssm:UpdateDocument",
        "support:DescribeTrustedAdvisorChecks",
        "support:DescribeTrustedAdvisorCheckResult",
        "support:RefreshTrustedAdvisorCheck",
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
      "Sid": "InspectorAndCompliance",
      "Resource": [
        "*"
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
    }
  ]
}
EOF

  tags = merge(
    var.common_tags,
    {
      Name          = "${var.environment}-github-deployment-observability"
      PolicyType    = "Custom"
      Scope         = "Service"
      GeneratedFrom = "github_deployment_observability.yaml"
    }
  )
}
