# Data source for current AWS caller identity
data "aws_caller_identity" "current" {}

# github-deployment-cloudwatch Policy Module - Following ABAC Pattern
# Converted from definitions/policies/deployment/github-deployment-cloudwatch.yaml
resource "aws_iam_policy" "main" {
  name        = "github-deployment-cloudwatch"
  path        = "/"
  description = var.policy_description

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid      = "CloudWatchLogsManagement"
        Effect   = "Allow"
        Action   = ["logs:CreateLogGroup", "logs:DeleteLogGroup", "logs:DescribeLogGroups", "logs:PutRetentionPolicy", "logs:DeleteRetentionPolicy", "logs:CreateLogStream", "logs:DeleteLogStream", "logs:DescribeLogStreams", "logs:PutLogEvents", "logs:GetLogEvents", "logs:FilterLogEvents", "logs:PutMetricFilter", "logs:DeleteMetricFilter", "logs:DescribeMetricFilters", "logs:TagLogGroup", "logs:UntagLogGroup", "logs:ListTagsLogGroup", "logs:ListTagsForResource", "logs:TagResource", "logs:UntagResource"]
        Resource = ["arn:aws:logs:*:*:log-group:*", "arn:aws:logs:*:*:log-group:*:log-stream:*"]
        }, {
        Sid      = "CloudWatchMetricsAndAlarms"
        Effect   = "Allow"
        Action   = ["cloudwatch:PutMetricData", "cloudwatch:GetMetricData", "cloudwatch:GetMetricStatistics", "cloudwatch:ListMetrics", "cloudwatch:PutMetricAlarm", "cloudwatch:DeleteAlarms", "cloudwatch:DescribeAlarms", "cloudwatch:DescribeAlarmsForMetric", "cloudwatch:DescribeAlarmHistory", "cloudwatch:SetAlarmState", "cloudwatch:TagResource", "cloudwatch:UntagResource", "cloudwatch:ListTagsForResource"]
        Resource = ["arn:aws:cloudwatch:*:*:alarm:*", "*"]
        }, {
        Sid      = "CloudWatchDashboards"
        Effect   = "Allow"
        Action   = ["cloudwatch:PutDashboard", "cloudwatch:GetDashboard", "cloudwatch:DeleteDashboards", "cloudwatch:ListDashboards"]
        Resource = ["*"]
        }, {
        Sid      = "SNSFullManagement"
        Effect   = "Allow"
        Action   = ["sns:CreateTopic", "sns:DeleteTopic", "sns:GetTopicAttributes", "sns:SetTopicAttributes", "sns:ListTopics", "sns:Subscribe", "sns:Unsubscribe", "sns:ListSubscriptions", "sns:ListSubscriptionsByTopic", "sns:GetSubscriptionAttributes", "sns:SetSubscriptionAttributes", "sns:Publish", "sns:AddPermission", "sns:RemovePermission", "sns:TagResource", "sns:UntagResource", "sns:ListTagsForResource"]
        Resource = ["arn:aws:sns:*:*:*"]
        }, {
        Sid      = "SNSPlatformEndpoints"
        Effect   = "Allow"
        Action   = ["sns:CreatePlatformApplication", "sns:DeletePlatformApplication", "sns:GetPlatformApplicationAttributes", "sns:SetPlatformApplicationAttributes", "sns:ListPlatformApplications", "sns:CreatePlatformEndpoint", "sns:DeleteEndpoint", "sns:GetEndpointAttributes", "sns:SetEndpointAttributes"]
        Resource = ["arn:aws:sns:*:*:app/*", "arn:aws:sns:*:*:endpoint/*"]
    }]
  })

  tags = merge(var.common_tags, {
    Name = "github-deployment-cloudwatch-${var.environment}"
    Type = "Policy"
  })
}