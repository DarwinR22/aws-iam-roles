# ==============================================================================
# LAYER 5: OBSERVABILITY
# CloudTrail, Config, GuardDuty, Security Hub, CloudWatch
# ==============================================================================

terraform {
  required_version = ">= 1.5.0"
  
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
  
  backend "s3" {
    bucket         = "terraform-state-bucket-051963532279"
    key            = "sgsi/layer5-observability/terraform.tfstate"
    region         = "us-east-1"
    dynamodb_table = "terraform-locks"
    encrypt        = true
  }
}

# ==============================================================================
# DATA SOURCES
# ==============================================================================
data "terraform_remote_state" "foundation" {
  backend = "s3"
  config = {
    bucket = "terraform-state-bucket-051963532279"
    key    = "sgsi/layer1-foundation/terraform.tfstate"
    region = "us-east-1"
  }
}

data "terraform_remote_state" "storage" {
  backend = "s3"
  config = {
    bucket = "terraform-state-bucket-051963532279"
    key    = "sgsi/layer4-storage/terraform.tfstate"
    region = "us-east-1"
  }
}

data "aws_caller_identity" "current" {}
data "aws_region" "current" {}

# ==============================================================================
# AWS PROVIDER CONFIGURATION
# ==============================================================================
provider "aws" {
  region = var.aws_region
  
  default_tags {
    tags = {
      Project              = "SGSI-Implementation"
      Layer                = "Observability"
      Environment          = var.environment
      ManagedBy           = "Terraform"
      SecurityLevel       = "Critical"
      ComplianceScope     = "ISO27001+NIST-CSF+SOX"
      CreatedBy           = "GitHub-Actions"
      MaintenanceWindow   = "Sunday-2AM-6AM"
    }
  }
}

# ==============================================================================
# S3 BUCKET POLICY - ALLOW CLOUDTRAIL & CONFIG
# ==============================================================================
resource "aws_s3_bucket_policy" "logs_bucket_policy" {
  bucket = data.terraform_remote_state.storage.outputs.s3_logs_bucket_id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "AWSCloudTrailAclCheck"
        Effect = "Allow"
        Principal = {
          Service = "cloudtrail.amazonaws.com"
        }
        Action   = "s3:GetBucketAcl"
        Resource = data.terraform_remote_state.storage.outputs.s3_logs_bucket_arn
      },
      {
        Sid    = "AWSCloudTrailWrite"
        Effect = "Allow"
        Principal = {
          Service = "cloudtrail.amazonaws.com"
        }
        Action   = "s3:PutObject"
        Resource = "${data.terraform_remote_state.storage.outputs.s3_logs_bucket_arn}/*"
        Condition = {
          StringEquals = {
            "s3:x-amz-acl" = "bucket-owner-full-control"
          }
        }
      },
      {
        Sid    = "AWSConfigBucketPermissionsCheck"
        Effect = "Allow"
        Principal = {
          Service = "config.amazonaws.com"
        }
        Action   = "s3:GetBucketAcl"
        Resource = data.terraform_remote_state.storage.outputs.s3_logs_bucket_arn
      },
      {
        Sid    = "AWSConfigBucketExistenceCheck"
        Effect = "Allow"
        Principal = {
          Service = "config.amazonaws.com"
        }
        Action   = "s3:ListBucket"
        Resource = data.terraform_remote_state.storage.outputs.s3_logs_bucket_arn
      },
      {
        Sid    = "AWSConfigWrite"
        Effect = "Allow"
        Principal = {
          Service = "config.amazonaws.com"
        }
        Action   = "s3:PutObject"
        Resource = "${data.terraform_remote_state.storage.outputs.s3_logs_bucket_arn}/*"
        Condition = {
          StringEquals = {
            "s3:x-amz-acl" = "bucket-owner-full-control"
          }
        }
      }
    ]
  })
}

# ==============================================================================
# CLOUDTRAIL
# ==============================================================================
resource "aws_cloudtrail" "sgsi_trail" {
  name           = "sgsi-audit-trail"
  s3_bucket_name = data.terraform_remote_state.storage.outputs.s3_logs_bucket_id

  include_global_service_events = true
  is_multi_region_trail         = true
  enable_logging               = true

  # Event selector simplificado - solo management events
  event_selector {
    read_write_type           = "All"
    include_management_events = true
  }

  tags = merge(
    var.common_tags,
    {
      Name                = "sgsi-audit-trail"
      AssetID             = "OBS-CT-001"
      AssetType           = "CloudTrail"
      SecurityLevel       = "Critical"
    }
  )
  
  depends_on = [aws_s3_bucket_policy.logs_bucket_policy]
}

# ==============================================================================
# AWS CONFIG
# ==============================================================================
resource "aws_config_configuration_recorder" "sgsi_recorder" {
  name     = "sgsi-config-recorder"
  role_arn = aws_iam_role.config_role.arn

  recording_group {
    all_supported = true
  }
}

resource "aws_config_delivery_channel" "sgsi_delivery_channel" {
  name           = "sgsi-config-delivery-channel"
  s3_bucket_name = data.terraform_remote_state.storage.outputs.s3_logs_bucket_id
  
  depends_on = [
    aws_config_configuration_recorder.sgsi_recorder,
    aws_s3_bucket_policy.logs_bucket_policy
  ]
}

# Config IAM Role
resource "aws_iam_role" "config_role" {
  name = "sgsi-config-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "config.amazonaws.com"
        }
      }
    ]
  })

  tags = merge(
    var.common_tags,
    {
      Name                = "sgsi-config-role"
      AssetType           = "IAM-Role"
    }
  )
}

resource "aws_iam_role_policy_attachment" "config_role_policy" {
  role       = aws_iam_role.config_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWS_ConfigRole"
}

# Inline policy para S3 access
resource "aws_iam_role_policy" "config_s3_policy" {
  name = "ConfigS3DeliveryPolicy"
  role = aws_iam_role.config_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "s3:PutObject",
          "s3:PutObjectAcl",
          "s3:GetBucketVersioning"
        ]
        Resource = [
          data.terraform_remote_state.storage.outputs.s3_logs_bucket_arn,
          "${data.terraform_remote_state.storage.outputs.s3_logs_bucket_arn}/*"
        ]
      },
      {
        Effect = "Allow"
        Action = [
          "s3:GetBucketAcl"
        ]
        Resource = data.terraform_remote_state.storage.outputs.s3_logs_bucket_arn
      }
    ]
  })
}

# ==============================================================================
# GUARDDUTY (DESHABILITADO - No disponible en AWS Academy)
# ==============================================================================
# resource "aws_guardduty_detector" "sgsi_detector" {
#   enable = true
#   finding_publishing_frequency = var.guardduty_findings_frequency
#
#   tags = merge(
#     var.common_tags,
#     {
#       Name                = "sgsi-guardduty-detector"
#       AssetID             = "OBS-GD-001"
#       AssetType           = "GuardDuty-Detector"
#       SecurityLevel       = "Critical"
#     }
#   )
# }

# ==============================================================================
# SECURITY HUB (DESHABILITADO - No disponible en AWS Academy)
# ==============================================================================
# resource "aws_securityhub_account" "sgsi_security_hub" {
#   enable_default_standards = true
#   control_finding_generator = "SECURITY_CONTROL"
# }
#
# # Enable AWS Foundational Security Standard
# resource "aws_securityhub_standards_subscription" "aws_foundational" {
#   standards_arn = "arn:aws:securityhub:::ruleset/finding-format/aws-foundational-security-best-practices/v/1.0.0"
#   depends_on    = [aws_securityhub_account.sgsi_security_hub]
# }

# ==============================================================================
# CLOUDWATCH DASHBOARDS AND ALARMS
# ==============================================================================
resource "aws_cloudwatch_dashboard" "sgsi_dashboard" {
  dashboard_name = "SGSI-Security-Dashboard"

  dashboard_body = jsonencode({
    widgets = [
      {
        type   = "metric"
        x      = 0
        y      = 0
        width  = 12
        height = 6

        properties = {
          metrics = [
            ["AWS/ApplicationELB", "RequestCount"],
            ["AWS/RDS", "DatabaseConnections"],
            ["AWS/Lambda", "Invocations"]
          ]
          view    = "timeSeries"
          stacked = false
          region  = var.aws_region
          title   = "Application Metrics"
          period  = 300
        }
      }
    ]
  })
}

# CloudWatch Alarms
resource "aws_cloudwatch_metric_alarm" "high_cpu" {
  alarm_name          = "sgsi-high-cpu-utilization"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "2"
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = "300"
  statistic           = "Average"
  threshold           = "80"
  alarm_description   = "This metric monitors ec2 cpu utilization"
  alarm_actions       = [aws_sns_topic.alerts.arn]

  tags = merge(
    var.common_tags,
    {
      Name                = "sgsi-high-cpu-alarm"
      AssetType           = "CloudWatch-Alarm"
    }
  )
}

# SNS Topic for Alerts
resource "aws_sns_topic" "alerts" {
  name = "sgsi-security-alerts"

  tags = merge(
    var.common_tags,
    {
      Name                = "sgsi-security-alerts"
      AssetType           = "SNS-Topic"
    }
  )
}