# Lambda Terraform generated from sgsi-lambda-functions.yaml
# Lambda Functions for SGSI Layer 3

# Lambda Function 1: API Handler
resource "aws_lambda_function" "sgsi_api_handler" {
  filename         = "api_handler.zip"
  function_name    = "sgsi-api-handler"
  role            = aws_iam_role.sgsi_lambda_role.arn
  handler         = "index.handler"
  source_code_hash = filebase64sha256("api_handler.zip")
  runtime         = "python3.9"
  timeout         = 30
  memory_size     = 128

  vpc_config {
    subnet_ids         = [
      data.aws_subnet.sgsi_private_subnet_1.id,
      data.aws_subnet.sgsi_private_subnet_2.id
    ]
    security_group_ids = [data.aws_security_group.sgsi_lambda_sg.id]
  }

  environment {
    variables = {
      ENVIRONMENT = "dev"
      DB_HOST     = aws_db_instance.sgsi_main_database.endpoint
      DB_NAME     = "sgsidb"
    }
  }

  tags = {
    Name        = "sgsi-api-handler"
    Environment = "dev"
    Layer       = "3-compute"
    Component   = "lambda"
    Proposito   = "sgsi-api-processing"
  }
}

# Lambda Function 2: Data Processor
resource "aws_lambda_function" "sgsi_data_processor" {
  filename         = "data_processor.zip"
  function_name    = "sgsi-data-processor"
  role            = aws_iam_role.sgsi_lambda_role.arn
  handler         = "processor.handler"
  source_code_hash = filebase64sha256("data_processor.zip")
  runtime         = "python3.9"
  timeout         = 300
  memory_size     = 512

  vpc_config {
    subnet_ids         = [
      data.aws_subnet.sgsi_private_subnet_1.id,
      data.aws_subnet.sgsi_private_subnet_2.id
    ]
    security_group_ids = [data.aws_security_group.sgsi_lambda_sg.id]
  }

  environment {
    variables = {
      ENVIRONMENT = "dev"
      DB_HOST     = aws_db_instance.sgsi_main_database.endpoint
      DB_NAME     = "sgsidb"
    }
  }

  tags = {
    Name        = "sgsi-data-processor"
    Environment = "dev"
    Layer       = "3-compute"
    Component   = "lambda"
    Proposito   = "sgsi-data-processing"
  }
}

# IAM Role for Lambda
resource "aws_iam_role" "sgsi_lambda_role" {
  name = "sgsi-lambda-execution-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "lambda.amazonaws.com"
        }
      }
    ]
  })

  tags = {
    Name        = "sgsi-lambda-execution-role"
    Environment = "dev"
    Layer       = "3-compute"
  }
}

# Lambda VPC Execution Policy
resource "aws_iam_role_policy_attachment" "sgsi_lambda_vpc_execution" {
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaVPCAccessExecutionRole"
  role       = aws_iam_role.sgsi_lambda_role.name
}

# CloudWatch Logs Policy
resource "aws_iam_role_policy_attachment" "sgsi_lambda_logs" {
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
  role       = aws_iam_role.sgsi_lambda_role.name
}

# CloudWatch Log Groups
resource "aws_cloudwatch_log_group" "sgsi_api_handler_logs" {
  name              = "/aws/lambda/sgsi-api-handler"
  retention_in_days = 14

  tags = {
    Name        = "sgsi-api-handler-logs"
    Environment = "dev"
    Layer       = "3-compute"
  }
}

resource "aws_cloudwatch_log_group" "sgsi_data_processor_logs" {
  name              = "/aws/lambda/sgsi-data-processor"
  retention_in_days = 14

  tags = {
    Name        = "sgsi-data-processor-logs"
    Environment = "dev"
    Layer       = "3-compute"
  }
}
