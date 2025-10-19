# ==============================================================================
# LAYER 3: COMPUTE
# EC2, ALB, Auto Scaling, Lambda, RDS
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
    key            = "sgsi/layer3-compute/terraform.tfstate"
    region         = "us-east-1"
    dynamodb_table = "terraform-state-lock"
    encrypt        = true
  }
}

# ==============================================================================
# DATA SOURCES (Read from previous layers)
# ==============================================================================
data "terraform_remote_state" "foundation" {
  backend = "s3"
  config = {
    bucket = "terraform-state-bucket-051963532279"
    key    = "sgsi/layer1-foundation/terraform.tfstate"
    region = "us-east-1"
  }
}

data "terraform_remote_state" "network" {
  backend = "s3"
  config = {
    bucket = "terraform-state-bucket-051963532279"
    key    = "sgsi/layer2-network/terraform.tfstate"
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
      Layer                = "Compute"
      Environment          = var.environment
      ManagedBy           = "Terraform"
      SecurityLevel       = "High"
      ComplianceScope     = "ISO27001,NIST-CSF"
      CreatedBy           = "GitHub-Actions"
      MaintenanceWindow   = "Sunday-2AM-6AM"
    }
  }
}

# ==============================================================================
# APPLICATION LOAD BALANCER
# ==============================================================================
resource "aws_lb" "sgsi_main_alb" {
  name               = "sgsi-main-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [data.terraform_remote_state.network.outputs.security_group_ids.alb]
  subnets           = data.terraform_remote_state.network.outputs.public_subnet_ids

  enable_deletion_protection = false
  enable_http2              = true
  enable_cross_zone_load_balancing = true

  tags = merge(
    var.common_tags,
    {
      Name                = "sgsi-main-alb"
      AssetID             = "COMP-ALB-001"
      AssetType           = "Load-Balancer"
      SecurityLevel       = "High"
      InternetFacing      = "Yes"
    }
  )
}

# Target Group for Web Servers
resource "aws_lb_target_group" "web_servers" {
  name     = "sgsi-web-servers-tg"
  port     = 8080
  protocol = "HTTP"
  vpc_id   = data.terraform_remote_state.network.outputs.vpc_id

  health_check {
    enabled             = true
    healthy_threshold   = 2
    interval            = 30
    matcher             = "200"
    path                = "/"
    port                = "traffic-port"
    protocol            = "HTTP"
    timeout             = 5
    unhealthy_threshold = 2
  }

  tags = merge(
    var.common_tags,
    {
      Name                = "sgsi-web-servers-tg"
      AssetType           = "Target-Group"
    }
  )
}

# ALB Listener
resource "aws_lb_listener" "web" {
  load_balancer_arn = aws_lb.sgsi_main_alb.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.web_servers.arn
  }

  tags = var.common_tags
}

# ==============================================================================
# LAUNCH TEMPLATE
# ==============================================================================
data "aws_ami" "amazon_linux" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-gp2"]
  }
}

resource "aws_launch_template" "web_servers" {
  name_prefix   = "sgsi-web-"
  image_id      = data.aws_ami.amazon_linux.id
  instance_type = var.instance_type
  
  vpc_security_group_ids = [data.terraform_remote_state.network.outputs.security_group_ids.web]

  user_data = base64encode(templatefile("${path.module}/user-data.sh", {
    environment = var.environment
  }))

  tag_specifications {
    resource_type = "instance"
    tags = merge(
      var.common_tags,
      {
        Name                = "sgsi-web-server"
        AssetType           = "EC2-Instance"
        Role                = "WebServer"
      }
    )
  }

  tags = merge(
    var.common_tags,
    {
      Name                = "sgsi-web-launch-template"
      AssetType           = "Launch-Template"
    }
  )
}

# ==============================================================================
# AUTO SCALING GROUP
# ==============================================================================
resource "aws_autoscaling_group" "web_servers" {
  name                = "sgsi-web-asg"
  vpc_zone_identifier = data.terraform_remote_state.network.outputs.app_private_subnet_ids
  target_group_arns   = [aws_lb_target_group.web_servers.arn]
  health_check_type   = "ELB"
  health_check_grace_period = 300

  min_size         = var.asg_min_size
  max_size         = var.asg_max_size
  desired_capacity = var.asg_desired_capacity

  launch_template {
    id      = aws_launch_template.web_servers.id
    version = "$Latest"
  }

  tag {
    key                 = "Name"
    value               = "sgsi-web-asg"
    propagate_at_launch = false
  }

  dynamic "tag" {
    for_each = var.common_tags
    content {
      key                 = tag.key
      value               = tag.value
      propagate_at_launch = true
    }
  }
}

# ==============================================================================
# RDS DATABASE
# ==============================================================================
resource "aws_db_subnet_group" "sgsi_db" {
  name       = "sgsi-db-subnet-group"
  subnet_ids = data.terraform_remote_state.network.outputs.db_private_subnet_ids

  tags = merge(
    var.common_tags,
    {
      Name                = "sgsi-db-subnet-group"
      AssetType           = "DB-Subnet-Group"
    }
  )
}

resource "aws_db_instance" "sgsi_main" {
  identifier = "sgsi-main-db"

  allocated_storage     = var.db_allocated_storage
  max_allocated_storage = var.db_max_allocated_storage
  storage_type          = "gp3"
  storage_encrypted     = true

  engine         = "mysql"
  engine_version = "8.0"
  instance_class = var.db_instance_class

  db_name  = var.db_name
  username = var.db_username
  password = var.db_password

  db_subnet_group_name   = aws_db_subnet_group.sgsi_db.name
  vpc_security_group_ids = [data.terraform_remote_state.network.outputs.security_group_ids.db]

  backup_retention_period = 7
  backup_window          = "03:00-04:00"
  maintenance_window     = "sun:04:00-sun:05:00"

  skip_final_snapshot = true
  deletion_protection = false

  performance_insights_enabled = true
  monitoring_interval         = 60

  tags = merge(
    var.common_tags,
    {
      Name                = "sgsi-main-db"
      AssetID             = "COMP-RDS-001"
      AssetType           = "Database"
      SecurityLevel       = "Critical"
      BackupRequired      = "Yes"
      MonitoringEnabled   = "Yes"
    }
  )
}

# ==============================================================================
# LAMBDA FUNCTIONS
# ==============================================================================
resource "aws_lambda_function" "api_handler" {
  filename         = "api_handler.zip"
  function_name    = "sgsi-api-handler"
  role            = aws_iam_role.lambda_execution_role.arn
  handler         = "index.handler"
  runtime         = "python3.9"
  timeout         = 30

  vpc_config {
    subnet_ids         = data.terraform_remote_state.network.outputs.app_private_subnet_ids
    security_group_ids = [data.terraform_remote_state.network.outputs.security_group_ids.app]
  }

  environment {
    variables = {
      ENVIRONMENT = var.environment
      DB_HOST     = aws_db_instance.sgsi_main.endpoint
    }
  }

  tags = merge(
    var.common_tags,
    {
      Name                = "sgsi-api-handler"
      AssetType           = "Lambda-Function"
      Role                = "API-Handler"
    }
  )
}

# Lambda Execution Role
resource "aws_iam_role" "lambda_execution_role" {
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

  tags = merge(
    var.common_tags,
    {
      Name                = "sgsi-lambda-execution-role"
      AssetType           = "IAM-Role"
    }
  )
}

resource "aws_iam_role_policy_attachment" "lambda_vpc_access" {
  role       = aws_iam_role.lambda_execution_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaVPCAccessExecutionRole"
}