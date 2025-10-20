# ==============================================================================
# OBSERVABILITY MODULE: GUARDDUTY
# Propósito: IDS/IPS para detección de amenazas en tiempo real
# Compliance: ISO 27001 A.12.4.1, A.16.1.2 | NIST CSF DE.CM-1, DE.AE-2
# ==============================================================================

# ------------------------------------------------------------------------------
# GUARDDUTY DETECTOR - CORE
# ------------------------------------------------------------------------------
resource "aws_guardduty_detector" "main" {
  enable = var.enable_guardduty
  
  # Frequency of findings publishing (15 minutes, 1 hour, 6 hours)
  finding_publishing_frequency = var.finding_publishing_frequency
  
  # S3 Protection - Detectar acceso no autorizado a S3
  datasources {
    s3_logs {
      enable = var.enable_s3_protection
    }
    
    kubernetes {
      audit_logs {
        enable = var.enable_kubernetes_protection
      }
    }
    
    malware_protection {
      scan_ec2_instance_with_findings {
        ebs_volumes {
          enable = var.enable_malware_protection
        }
      }
    }
  }
  
  tags = merge(
    var.common_tags,
    {
      Name       = var.detector_name
      Layer      = "Observability"
      Module     = "GuardDuty"
      Purpose    = "IDS-IPS"
      Compliance = "ISO27001-A.12.4.1+A.16.1.2"
    }
  )
}

# ------------------------------------------------------------------------------
# SNS TOPIC - GUARDDUTY FINDINGS
# ------------------------------------------------------------------------------
resource "aws_sns_topic" "guardduty_findings" {
  count = var.enable_sns_notifications ? 1 : 0
  
  name         = "${var.detector_name}-findings"
  display_name = "GuardDuty Security Findings"
  
  tags = merge(
    var.common_tags,
    {
      Name    = "${var.detector_name}-findings"
      Purpose = "Security Alerts"
    }
  )
}

resource "aws_sns_topic_policy" "guardduty_findings" {
  count = var.enable_sns_notifications ? 1 : 0
  
  arn = aws_sns_topic.guardduty_findings[0].arn
  
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "events.amazonaws.com"
        }
        Action   = "SNS:Publish"
        Resource = aws_sns_topic.guardduty_findings[0].arn
      }
    ]
  })
}

# ------------------------------------------------------------------------------
# SNS SUBSCRIPTIONS - EMAIL
# ------------------------------------------------------------------------------
resource "aws_sns_topic_subscription" "guardduty_email" {
  count = var.enable_sns_notifications && length(var.notification_emails) > 0 ? length(var.notification_emails) : 0
  
  topic_arn = aws_sns_topic.guardduty_findings[0].arn
  protocol  = "email"
  endpoint  = var.notification_emails[count.index]
}

# ------------------------------------------------------------------------------
# EVENTBRIDGE RULE - HIGH/CRITICAL FINDINGS
# ------------------------------------------------------------------------------
resource "aws_cloudwatch_event_rule" "guardduty_high_severity" {
  count = var.enable_eventbridge_integration ? 1 : 0
  
  name        = "${var.detector_name}-high-severity"
  description = "Trigger on GuardDuty HIGH or CRITICAL findings"
  
  event_pattern = jsonencode({
    source      = ["aws.guardduty"]
    detail-type = ["GuardDuty Finding"]
    detail = {
      severity = [
        { numeric = [">=", 7] } # HIGH: 7.0-8.9, CRITICAL: 9.0-10.0
      ]
    }
  })
  
  tags = var.common_tags
}

resource "aws_cloudwatch_event_target" "guardduty_sns" {
  count = var.enable_eventbridge_integration && var.enable_sns_notifications ? 1 : 0
  
  rule      = aws_cloudwatch_event_rule.guardduty_high_severity[0].name
  target_id = "SendToSNS"
  arn       = aws_sns_topic.guardduty_findings[0].arn
}

# ------------------------------------------------------------------------------
# CLOUDWATCH LOG GROUP - GUARDDUTY FINDINGS
# ------------------------------------------------------------------------------
resource "aws_cloudwatch_log_group" "guardduty_findings" {
  count = var.enable_cloudwatch_logs ? 1 : 0
  
  name              = "/aws/guardduty/${var.detector_name}"
  retention_in_days = var.log_retention_days
  
  tags = merge(
    var.common_tags,
    {
      Name    = "${var.detector_name}-logs"
      Purpose = "GuardDuty Findings Archive"
    }
  )
}

# ------------------------------------------------------------------------------
# CLOUDWATCH ALARMS - CRITICAL FINDINGS
# ------------------------------------------------------------------------------
resource "aws_cloudwatch_metric_alarm" "critical_findings_alarm" {
  count = var.enable_sns_notifications ? 1 : 0
  
  alarm_name          = "${var.detector_name}-critical-findings"
  alarm_description   = "Alert on GuardDuty CRITICAL findings"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 1
  metric_name         = "FindingsCount"
  namespace           = "AWS/GuardDuty"
  period              = 300 # 5 minutes
  statistic           = "Sum"
  threshold           = 0 # Any critical finding triggers alarm
  treat_missing_data  = "notBreaching"
  
  dimensions = {
    DetectorId = aws_guardduty_detector.main.id
    Severity   = "Critical"
  }
  
  alarm_actions = var.enable_sns_notifications ? [aws_sns_topic.guardduty_findings[0].arn] : []
  ok_actions    = var.enable_sns_notifications ? [aws_sns_topic.guardduty_findings[0].arn] : []
  
  tags = merge(
    var.common_tags,
    {
      Severity = "Critical"
      Purpose  = "Security Monitoring"
    }
  )
}
