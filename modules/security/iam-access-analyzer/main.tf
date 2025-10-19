# ==============================================================================
# IAM ACCESS ANALYZER MODULE
# Detects resources shared with external entities and analyzes IAM policies
# ==============================================================================

resource "aws_accessanalyzer_analyzer" "main" {
  analyzer_name = "${var.environment}-sgsi-access-analyzer"
  type         = var.analyzer_type

  tags = merge(
    var.common_tags,
    {
      Name        = "${var.environment}-sgsi-access-analyzer"
      Component   = "IAM-Access-Analyzer"
      Purpose     = "External-Access-Detection"
      Compliance  = "ISO27001-A.9.1.1"
      NIST_CSF    = "PR.AC-4"
      Layer       = "Foundation"
    }
  )
}

# Archive rule to suppress findings for expected external access
resource "aws_accessanalyzer_archive_rule" "approved_external_access" {
  count = length(var.archive_rules) > 0 ? length(var.archive_rules) : 0

  analyzer_name = aws_accessanalyzer_analyzer.main.analyzer_name
  rule_name     = var.archive_rules[count.index].name

  dynamic "filter" {
    for_each = var.archive_rules[count.index].filters
    content {
      criteria  = filter.value.criteria
      contains  = lookup(filter.value, "contains", null)
      eq        = lookup(filter.value, "eq", null)
      exists    = lookup(filter.value, "exists", null)
      neq       = lookup(filter.value, "neq", null)
    }
  }
}

# CloudWatch alarm for new findings
resource "aws_cloudwatch_metric_alarm" "new_findings" {
  count = var.create_cloudwatch_alarm ? 1 : 0

  alarm_name          = "${var.environment}-access-analyzer-new-findings"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "1"
  metric_name         = "NewFindings"
  namespace           = "AWS/AccessAnalyzer"
  period              = "300"
  statistic           = "Sum"
  threshold           = var.alarm_threshold
  alarm_description   = "Alert when Access Analyzer detects new external access findings"
  treat_missing_data  = "notBreaching"

  dimensions = {
    AnalyzerName = aws_accessanalyzer_analyzer.main.analyzer_name
  }

  alarm_actions = var.alarm_actions

  tags = merge(
    var.common_tags,
    {
      Name      = "${var.environment}-access-analyzer-alarm"
      Component = "Security-Monitoring"
    }
  )
}

# EventBridge rule to capture Access Analyzer findings
resource "aws_cloudwatch_event_rule" "access_analyzer_findings" {
  count = var.create_eventbridge_rule ? 1 : 0

  name        = "${var.environment}-access-analyzer-findings"
  description = "Capture Access Analyzer findings for automated response"

  event_pattern = jsonencode({
    source      = ["aws.access-analyzer"]
    detail-type = ["Access Analyzer Finding"]
    detail = {
      status = ["ACTIVE"]
    }
  })

  tags = merge(
    var.common_tags,
    {
      Name      = "${var.environment}-access-analyzer-events"
      Component = "Event-Automation"
    }
  )
}

resource "aws_cloudwatch_event_target" "sns" {
  count = var.create_eventbridge_rule && length(var.event_targets) > 0 ? length(var.event_targets) : 0

  rule      = aws_cloudwatch_event_rule.access_analyzer_findings[0].name
  target_id = "SendToSNS-${count.index}"
  arn       = var.event_targets[count.index]
}
