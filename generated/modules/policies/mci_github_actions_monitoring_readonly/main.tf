# Data source for current AWS caller identity
data "aws_caller_identity" "current" {}

# github-actions-monitoring-readonly Policy Module - Following ABAC Pattern
# Converted from definitions/policies/deployment/monitoring-readonly.yaml
resource "aws_iam_policy" "main" {
  name        = "mci-github-actions-monitoring-readonly"
  path        = "/policies/"
  description = var.policy_description

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid      = "CloudWatchMetricsReadOnly"
        Effect   = "Allow"
        Action   = ["cloudwatch:DescribeAlarms", "cloudwatch:GetMetricData", "cloudwatch:GetMetricStatistics", "cloudwatch:ListMetrics"]
        Resource = ["*"]
        }, {
        Sid      = "CloudWatchLogsReadOnly"
        Effect   = "Allow"
        Action   = ["logs:DescribeLogGroups", "logs:DescribeLogStreams", "logs:GetLogEvents", "logs:FilterLogEvents"]
        Resource = ["*"]
    }]
  })

  tags = merge(var.common_tags, {
    Name = "github-actions-monitoring-readonly-${var.environment}"
    Type = "Policy"
  })
}