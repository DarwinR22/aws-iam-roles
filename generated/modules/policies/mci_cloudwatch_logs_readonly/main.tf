# Data source for current AWS caller identity
data "aws_caller_identity" "current" {}

# cloudwatch-logs-readonly Policy Module - Following ABAC Pattern
# Converted from definitions/policies/deployment/cloudwatch-logs-readonly.yaml
resource "aws_iam_policy" "main" {
  name        = "mci-cloudwatch-logs-readonly"
  path        = "/policies/"
  description = var.policy_description

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid      = "CloudWatchLogsReadAccess"
        Effect   = "Allow"
        Action   = ["logs:DescribeLogGroups", "logs:DescribeLogStreams", "logs:GetLogEvents", "logs:FilterLogEvents", "logs:StartQuery", "logs:StopQuery", "logs:DescribeQueries", "logs:GetQueryResults"]
        Resource = ["arn:aws:logs:*:*:log-group:/aws/github-actions/*", "arn:aws:logs:*:*:log-group:/aws/lambda/*"]
        }, {
        Sid      = "CloudWatchMetricsReadAccess"
        Effect   = "Allow"
        Action   = ["cloudwatch:GetMetricStatistics", "cloudwatch:ListMetrics", "cloudwatch:GetMetricData"]
        Resource = ["*"]
    }]
  })

  tags = merge(var.common_tags, {
    Name = "cloudwatch-logs-readonly-${var.environment}"
    Type = "Policy"
  })
}