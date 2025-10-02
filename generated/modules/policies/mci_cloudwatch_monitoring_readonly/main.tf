# Data source for current AWS caller identity
data "aws_caller_identity" "current" {}

# mci-cloudwatch-monitoring-readonly Policy Module - Following ABAC Pattern
# Converted from definitions/policies/deployment/cloudwatch-monitoring-readonly.yaml
resource "aws_iam_policy" "main" {
  name        = "mci-mci-cloudwatch-monitoring-readonly"
  path        = "/policies/"
  description = var.policy_description

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid      = "CloudWatchMetricsRead"
        Effect   = "Allow"
        Action   = ["cloudwatch:GetMetricStatistics", "cloudwatch:ListMetrics", "cloudwatch:GetMetricData", "cloudwatch:GetMetricWidgetImage"]
        Resource = ["*"]
        }, {
        Sid      = "CloudWatchAlarmsRead"
        Effect   = "Allow"
        Action   = ["cloudwatch:DescribeAlarms", "cloudwatch:DescribeAlarmsForMetric", "cloudwatch:DescribeAlarmHistory"]
        Resource = ["*"]
        }, {
        Sid      = "CloudWatchLogsRead"
        Effect   = "Allow"
        Action   = ["logs:DescribeLogGroups", "logs:DescribeLogStreams", "logs:GetLogEvents", "logs:FilterLogEvents", "logs:DescribeQueries"]
        Resource = ["*"]
        }, {
        Sid      = "CloudWatchInsightsRead"
        Effect   = "Allow"
        Action   = ["logs:StartQuery", "logs:GetQueryResults", "cloudwatch:GetInsightRuleReport"]
        Resource = ["*"]
        }, {
        Sid      = "CloudWatchDashboardsRead"
        Effect   = "Allow"
        Action   = ["cloudwatch:GetDashboard", "cloudwatch:ListDashboards"]
        Resource = ["*"]
    }]
  })

  tags = merge(var.common_tags, {
    Name = "mci-cloudwatch-monitoring-readonly-${var.environment}"
    Type = "Policy"
  })
}