# ==============================================================================
# MODULE: VPC Flow Logs
# Purpose: Enable comprehensive network traffic monitoring and auditing
# Compliance: ISO 27001 A.13.1.1, NIST CSF DE.AE-3, Zero Trust
# ==============================================================================

# ==============================================================================
# CloudWatch Log Group for Flow Logs
# ==============================================================================
resource "aws_cloudwatch_log_group" "vpc_flow_logs" {
  name              = "/aws/vpc/flowlogs/${var.vpc_name}"
  retention_in_days = var.log_retention_days

  tags = merge(
    var.tags,
    {
      Name                = "vpc-flow-logs-${var.vpc_name}"
      Purpose             = "Network Traffic Monitoring"
      ISO27001Control     = "A.13.1.1"
      NISTControl         = "DE.AE-3"
      DataClassification  = "Confidential"
      RetentionDays       = var.log_retention_days
    }
  )
}

# ==============================================================================
# IAM Role for VPC Flow Logs
# ==============================================================================
resource "aws_iam_role" "vpc_flow_logs_role" {
  name = "${var.vpc_name}-flow-logs-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "vpc-flow-logs.amazonaws.com"
        }
        Action = "sts:AssumeRole"
      }
    ]
  })

  tags = merge(
    var.tags,
    {
      Name    = "${var.vpc_name}-flow-logs-role"
      Purpose = "VPC Flow Logs Service Role"
    }
  )
}

# ==============================================================================
# IAM Policy for VPC Flow Logs
# ==============================================================================
resource "aws_iam_role_policy" "vpc_flow_logs_policy" {
  name = "${var.vpc_name}-flow-logs-policy"
  role = aws_iam_role.vpc_flow_logs_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents",
          "logs:DescribeLogGroups",
          "logs:DescribeLogStreams"
        ]
        Resource = "*"
      }
    ]
  })
}

# ==============================================================================
# VPC Flow Logs Resource
# ==============================================================================
resource "aws_flow_log" "vpc_flow_log" {
  vpc_id          = var.vpc_id
  traffic_type    = var.traffic_type
  iam_role_arn    = aws_iam_role.vpc_flow_logs_role.arn
  log_destination = aws_cloudwatch_log_group.vpc_flow_logs.arn

  log_format = var.custom_log_format != "" ? var.custom_log_format : null

  tags = merge(
    var.tags,
    {
      Name                = "vpc-flow-log-${var.vpc_name}"
      TrafficType         = var.traffic_type
      ISO27001Control     = "A.13.1.1"
      NISTControl         = "DE.AE-3"
      ComplianceScope     = "Network-Monitoring"
    }
  )
}

# ==============================================================================
# CloudWatch Metric Filter - Rejected Traffic
# ==============================================================================
resource "aws_cloudwatch_log_metric_filter" "rejected_traffic" {
  count = var.enable_rejected_traffic_alarm ? 1 : 0

  name           = "${var.vpc_name}-rejected-traffic"
  pattern        = "[version, account, eni, source, destination, srcport, destport, protocol, packets, bytes, windowstart, windowend, action=REJECT, flowlogstatus]"
  log_group_name = aws_cloudwatch_log_group.vpc_flow_logs.name

  metric_transformation {
    name      = "RejectedTraffic"
    namespace = "VPC/FlowLogs"
    value     = "1"
  }
}

# ==============================================================================
# CloudWatch Alarm - High Rejected Traffic
# ==============================================================================
resource "aws_cloudwatch_metric_alarm" "high_rejected_traffic" {
  count = var.enable_rejected_traffic_alarm ? 1 : 0

  alarm_name          = "${var.vpc_name}-high-rejected-traffic"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "2"
  metric_name         = "RejectedTraffic"
  namespace           = "VPC/FlowLogs"
  period              = "300"
  statistic           = "Sum"
  threshold           = var.rejected_traffic_threshold
  alarm_description   = "Triggers when rejected traffic exceeds threshold"
  treat_missing_data  = "notBreaching"

  alarm_actions = var.alarm_actions

  tags = merge(
    var.tags,
    {
      Name            = "${var.vpc_name}-rejected-traffic-alarm"
      Severity        = "High"
      ISO27001Control = "A.16.1.2"
    }
  )
}

# ==============================================================================
# CloudWatch Metric Filter - SSH Traffic from Internet
# ==============================================================================
resource "aws_cloudwatch_log_metric_filter" "ssh_from_internet" {
  count = var.enable_ssh_monitoring ? 1 : 0

  name           = "${var.vpc_name}-ssh-from-internet"
  pattern        = "[version, account, eni, source!=10.*, destination, srcport, destport=22, protocol=6, packets, bytes, windowstart, windowend, action=ACCEPT, flowlogstatus]"
  log_group_name = aws_cloudwatch_log_group.vpc_flow_logs.name

  metric_transformation {
    name      = "SSHFromInternet"
    namespace = "VPC/Security"
    value     = "1"
  }
}

# ==============================================================================
# CloudWatch Alarm - SSH from Internet
# ==============================================================================
resource "aws_cloudwatch_metric_alarm" "ssh_from_internet" {
  count = var.enable_ssh_monitoring ? 1 : 0

  alarm_name          = "${var.vpc_name}-ssh-from-internet"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "1"
  metric_name         = "SSHFromInternet"
  namespace           = "VPC/Security"
  period              = "300"
  statistic           = "Sum"
  threshold           = "1"
  alarm_description   = "Alert when SSH traffic from internet is detected"
  treat_missing_data  = "notBreaching"

  alarm_actions = var.alarm_actions

  tags = merge(
    var.tags,
    {
      Name            = "${var.vpc_name}-ssh-internet-alarm"
      Severity        = "Critical"
      ISO27001Control = "A.13.1.1"
    }
  )
}
