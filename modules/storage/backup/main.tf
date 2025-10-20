# ==============================================================================
# STORAGE MODULE: AWS BACKUP
# Propósito: Disaster Recovery - Backup centralizado RDS, EFS, EBS
# Compliance: ISO 27001 A.12.3.1, A.17.1.2 | NIST CSF PR.IP-4, RC.RP-1
# ==============================================================================

# ------------------------------------------------------------------------------
# BACKUP VAULT - ENCRYPTED
# ------------------------------------------------------------------------------
resource "aws_backup_vault" "main" {
  name        = var.vault_name
  kms_key_arn = var.kms_key_arn
  
  tags = merge(
    var.common_tags,
    {
      Name       = var.vault_name
      Layer      = "Storage"
      Module     = "Backup"
      Compliance = "ISO27001-A.12.3.1+A.17.1.2"
    }
  )
}

# ------------------------------------------------------------------------------
# BACKUP VAULT LOCK POLICY - WORM (OPCIONAL)
# ------------------------------------------------------------------------------
resource "aws_backup_vault_lock_configuration" "main" {
  count = var.enable_vault_lock ? 1 : 0
  
  backup_vault_name   = aws_backup_vault.main.name
  changeable_for_days = var.vault_lock_changeable_days
  min_retention_days  = var.vault_lock_min_retention_days
  max_retention_days  = var.vault_lock_max_retention_days
}

# ------------------------------------------------------------------------------
# BACKUP VAULT POLICY - ACCESS CONTROL
# ------------------------------------------------------------------------------
resource "aws_backup_vault_policy" "main" {
  count = var.vault_policy_json != null ? 1 : 0
  
  backup_vault_name = aws_backup_vault.main.name
  policy            = var.vault_policy_json
}

# ------------------------------------------------------------------------------
# BACKUP PLAN - SCHEDULE & RETENTION
# ------------------------------------------------------------------------------
resource "aws_backup_plan" "main" {
  name = var.plan_name
  
  # Regla 1: Backup Diario
  rule {
    rule_name         = "daily-backup"
    target_vault_name = aws_backup_vault.main.name
    schedule          = var.daily_backup_schedule
    start_window      = var.backup_start_window
    completion_window = var.backup_completion_window
    
    lifecycle {
      delete_after       = var.daily_retention_days
      cold_storage_after = var.daily_retention_days > 90 ? 90 : null
    }
    
    recovery_point_tags = merge(
      var.common_tags,
      {
        BackupType = "Daily"
        Frequency  = "Daily"
      }
    )
    
    # Backup cross-region
    dynamic "copy_action" {
      for_each = var.enable_cross_region_backup && var.destination_vault_arn != null ? [1] : []
      content {
        destination_vault_arn = var.destination_vault_arn
        lifecycle {
          delete_after       = var.daily_retention_days
          cold_storage_after = var.daily_retention_days > 90 ? 90 : null
        }
      }
    }
  }
  
  # Regla 2: Backup Semanal (Largo Plazo)
  rule {
    rule_name         = "weekly-backup"
    target_vault_name = aws_backup_vault.main.name
    schedule          = var.weekly_backup_schedule
    start_window      = var.backup_start_window
    completion_window = var.backup_completion_window
    
    lifecycle {
      delete_after       = var.weekly_retention_days
      cold_storage_after = var.weekly_retention_days > 90 ? 90 : null
    }
    
    recovery_point_tags = merge(
      var.common_tags,
      {
        BackupType = "Weekly"
        Frequency  = "Weekly"
      }
    )
  }
  
  # Regla 3: Backup Mensual (Archivo)
  rule {
    rule_name         = "monthly-backup"
    target_vault_name = aws_backup_vault.main.name
    schedule          = var.monthly_backup_schedule
    start_window      = var.backup_start_window
    completion_window = var.backup_completion_window
    
    lifecycle {
      delete_after       = var.monthly_retention_days
      cold_storage_after = var.monthly_retention_days > 90 ? 90 : null
    }
    
    recovery_point_tags = merge(
      var.common_tags,
      {
        BackupType = "Monthly"
        Frequency  = "Monthly"
      }
    )
  }
  
  tags = merge(
    var.common_tags,
    {
      Name = var.plan_name
    }
  )
}

# ------------------------------------------------------------------------------
# BACKUP SELECTION - QUÉ RECURSOS RESPALDAR
# ------------------------------------------------------------------------------
resource "aws_backup_selection" "main" {
  name         = "${var.plan_name}-selection"
  plan_id      = aws_backup_plan.main.id
  iam_role_arn = var.backup_role_arn
  
  # Selección por tags
  selection_tag {
    type  = "STRINGEQUALS"
    key   = var.backup_tag_key
    value = var.backup_tag_value
  }
  
  # Recursos específicos (opcional) - resources es un atributo, no un bloque
  resources = var.resource_arns
  
  # Condiciones avanzadas
  dynamic "condition" {
    for_each = var.backup_selection_conditions != null ? [1] : []
    content {
      dynamic "string_equals" {
        for_each = var.backup_selection_conditions.string_equals != null ? [1] : []
        content {
          key   = var.backup_selection_conditions.string_equals.key
          value = var.backup_selection_conditions.string_equals.value
        }
      }
      
      dynamic "string_not_equals" {
        for_each = var.backup_selection_conditions.string_not_equals != null ? [1] : []
        content {
          key   = var.backup_selection_conditions.string_not_equals.key
          value = var.backup_selection_conditions.string_not_equals.value
        }
      }
    }
  }
}

# ------------------------------------------------------------------------------
# SNS TOPIC - NOTIFICACIONES
# ------------------------------------------------------------------------------
resource "aws_sns_topic" "backup_notifications" {
  count = var.create_sns_topic ? 1 : 0
  name  = "${var.plan_name}-notifications"
  
  tags = merge(
    var.common_tags,
    {
      Name = "${var.plan_name}-notifications"
    }
  )
}

resource "aws_backup_vault_notifications" "main" {
  count = var.create_sns_topic ? 1 : 0
  
  backup_vault_name   = aws_backup_vault.main.name
  sns_topic_arn       = aws_sns_topic.backup_notifications[0].arn
  backup_vault_events = var.backup_vault_events
}

# ------------------------------------------------------------------------------
# CLOUDWATCH ALARMS - MONITORING
# ------------------------------------------------------------------------------
resource "aws_cloudwatch_metric_alarm" "backup_failed" {
  count = var.enable_cloudwatch_alarms ? 1 : 0
  
  alarm_name          = "${var.plan_name}-backup-failed"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 1
  metric_name         = "NumberOfBackupJobsFailed"
  namespace           = "AWS/Backup"
  period              = 3600
  statistic           = "Sum"
  threshold           = 0
  alarm_description   = "Backup job failed"
  treat_missing_data  = "notBreaching"
  
  dimensions = {
    BackupVaultName = aws_backup_vault.main.name
  }
  
  alarm_actions = var.create_sns_topic ? [aws_sns_topic.backup_notifications[0].arn] : []
  
  tags = var.common_tags
}

resource "aws_cloudwatch_metric_alarm" "backup_late" {
  count = var.enable_cloudwatch_alarms ? 1 : 0
  
  alarm_name          = "${var.plan_name}-backup-late"
  comparison_operator = "LessThanThreshold"
  evaluation_periods  = 1
  metric_name         = "NumberOfBackupJobsCompleted"
  namespace           = "AWS/Backup"
  period              = 86400 # 24 horas
  statistic           = "Sum"
  threshold           = 1
  alarm_description   = "No backup completed in last 24 hours"
  treat_missing_data  = "breaching"
  
  dimensions = {
    BackupVaultName = aws_backup_vault.main.name
  }
  
  alarm_actions = var.create_sns_topic ? [aws_sns_topic.backup_notifications[0].arn] : []
  
  tags = var.common_tags
}
