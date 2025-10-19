# ==============================================================================
# CREDENTIAL ROTATION POLICY MODULE
# Manages IAM password policies and access key rotation requirements
# ==============================================================================

# IAM Account Password Policy
resource "aws_iam_account_password_policy" "main" {
  minimum_password_length        = var.minimum_password_length
  require_lowercase_characters   = var.require_lowercase
  require_uppercase_characters   = var.require_uppercase
  require_numbers               = var.require_numbers
  require_symbols               = var.require_symbols
  allow_users_to_change_password = var.allow_users_to_change_password
  max_password_age              = var.max_password_age
  password_reuse_prevention     = var.password_reuse_prevention
  hard_expiry                   = var.hard_expiry
}

# CloudWatch Event Rule for detecting aged access keys
resource "aws_cloudwatch_event_rule" "aged_access_keys" {
  count = var.enable_access_key_monitoring ? 1 : 0

  name        = "${var.environment}-aged-access-keys"
  description = "Detect IAM access keys older than ${var.access_key_max_age} days"
  
  schedule_expression = "rate(1 day)"

  tags = merge(
    var.common_tags,
    {
      Name       = "${var.environment}-aged-access-keys-rule"
      Component  = "Credential-Management"
      Compliance = "ISO27001-A.9.2.1"
    }
  )
}

# Lambda function to check and report aged access keys
resource "aws_lambda_function" "check_access_keys" {
  count = var.enable_access_key_monitoring ? 1 : 0

  filename         = var.lambda_package_path
  function_name    = "${var.environment}-check-aged-access-keys"
  role            = aws_iam_role.lambda_execution[0].arn
  handler         = "index.handler"
  source_code_hash = fileexists(var.lambda_package_path) ? filebase64sha256(var.lambda_package_path) : null
  runtime         = "python3.11"
  timeout         = 60

  environment {
    variables = {
      MAX_KEY_AGE_DAYS = var.access_key_max_age
      SNS_TOPIC_ARN   = var.notification_topic_arn
    }
  }

  tags = merge(
    var.common_tags,
    {
      Name      = "${var.environment}-check-access-keys"
      Component = "Security-Automation"
    }
  )
}

# IAM Role for Lambda execution
resource "aws_iam_role" "lambda_execution" {
  count = var.enable_access_key_monitoring ? 1 : 0

  name = "${var.environment}-access-key-checker-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = {
        Service = "lambda.amazonaws.com"
      }
    }]
  })

  tags = merge(
    var.common_tags,
    {
      Name      = "${var.environment}-lambda-execution-role"
      Component = "IAM-Automation"
    }
  )
}

# IAM Policy for Lambda to check access keys
resource "aws_iam_role_policy" "lambda_policy" {
  count = var.enable_access_key_monitoring ? 1 : 0

  name = "${var.environment}-access-key-checker-policy"
  role = aws_iam_role.lambda_execution[0].id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "iam:ListUsers",
          "iam:ListAccessKeys",
          "iam:GetAccessKeyLastUsed"
        ]
        Resource = "*"
      },
      {
        Effect = "Allow"
        Action = [
          "sns:Publish"
        ]
        Resource = var.notification_topic_arn
      },
      {
        Effect = "Allow"
        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ]
        Resource = "arn:aws:logs:*:*:*"
      }
    ]
  })
}

# CloudWatch Event Target
resource "aws_cloudwatch_event_target" "lambda" {
  count = var.enable_access_key_monitoring ? 1 : 0

  rule      = aws_cloudwatch_event_rule.aged_access_keys[0].name
  target_id = "CheckAccessKeys"
  arn       = aws_lambda_function.check_access_keys[0].arn
}

# Lambda permission for CloudWatch Events
resource "aws_lambda_permission" "allow_cloudwatch" {
  count = var.enable_access_key_monitoring ? 1 : 0

  statement_id  = "AllowExecutionFromCloudWatch"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.check_access_keys[0].function_name
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.aged_access_keys[0].arn
}

# CloudWatch Log Group for Lambda
resource "aws_cloudwatch_log_group" "lambda_logs" {
  count = var.enable_access_key_monitoring ? 1 : 0

  name              = "/aws/lambda/${aws_lambda_function.check_access_keys[0].function_name}"
  retention_in_days = var.log_retention_days

  tags = merge(
    var.common_tags,
    {
      Name      = "${var.environment}-access-key-logs"
      Component = "Security-Logging"
    }
  )
}
