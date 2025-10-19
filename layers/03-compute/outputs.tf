# ==============================================================================
# LAYER 3: COMPUTE - OUTPUTS
# ==============================================================================

# Load Balancer Outputs
output "alb_arn" {
  description = "ARN of the Application Load Balancer"
  value       = aws_lb.sgsi_main_alb.arn
}

output "alb_dns_name" {
  description = "DNS name of the Application Load Balancer"
  value       = aws_lb.sgsi_main_alb.dns_name
}

output "alb_zone_id" {
  description = "Zone ID of the Application Load Balancer"
  value       = aws_lb.sgsi_main_alb.zone_id
}

# Auto Scaling Group Outputs
output "asg_arn" {
  description = "ARN of the Auto Scaling Group"
  value       = aws_autoscaling_group.web_servers.arn
}

output "asg_name" {
  description = "Name of the Auto Scaling Group"
  value       = aws_autoscaling_group.web_servers.name
}

# RDS Outputs
output "db_instance_endpoint" {
  description = "RDS instance endpoint"
  value       = aws_db_instance.sgsi_main.endpoint
  sensitive   = true
}

output "db_instance_id" {
  description = "RDS instance ID"
  value       = aws_db_instance.sgsi_main.id
}

output "db_instance_arn" {
  description = "RDS instance ARN"
  value       = aws_db_instance.sgsi_main.arn
}

# Lambda Outputs
output "lambda_function_arn" {
  description = "ARN of the Lambda function"
  value       = aws_lambda_function.api_handler.arn
}

output "lambda_function_name" {
  description = "Name of the Lambda function"
  value       = aws_lambda_function.api_handler.function_name
}

# Layer Information
output "layer_info" {
  description = "Layer information for downstream layers"
  value = {
    layer_name    = "compute"
    layer_number  = "03"
    state_key     = "sgsi/layer3-compute/terraform.tfstate"
    deployed_at   = timestamp()
  }
}

# Compute Configuration for other layers
output "compute_config" {
  description = "Compute configuration for other layers"
  value = {
    alb_dns_name           = aws_lb.sgsi_main_alb.dns_name
    alb_arn               = aws_lb.sgsi_main_alb.arn
    asg_name              = aws_autoscaling_group.web_servers.name
    db_endpoint           = aws_db_instance.sgsi_main.endpoint
    lambda_function_name  = aws_lambda_function.api_handler.function_name
  }
  sensitive = true
}