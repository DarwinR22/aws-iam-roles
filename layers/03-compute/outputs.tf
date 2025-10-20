# ==============================================================================
# LAYER 3: COMPUTE - OUTPUTS
# ==============================================================================

# ==============================================================================
# ASG (Auto Scaling Group) OUTPUTS
# ==============================================================================

output "asg_id" {
  description = "ID del Auto Scaling Group"
  value       = module.asg.asg_id
}

output "asg_name" {
  description = "Nombre del Auto Scaling Group"
  value       = module.asg.asg_name
}

output "asg_arn" {
  description = "ARN del Auto Scaling Group"
  value       = module.asg.asg_arn
}

output "launch_template_id" {
  description = "ID del Launch Template"
  value       = module.asg.launch_template_id
}

output "iam_instance_profile_name" {
  description = "Nombre del IAM Instance Profile para EC2"
  value       = module.asg.iam_instance_profile_name
}

# ==============================================================================
# RDS (Database) OUTPUTS
# ==============================================================================

output "db_instance_id" {
  description = "ID de la instancia RDS"
  value       = module.rds.db_instance_id
}

output "db_instance_arn" {
  description = "ARN de la instancia RDS"
  value       = module.rds.db_instance_arn
}

output "db_instance_endpoint" {
  description = "Endpoint de conexión de la base de datos (host:port)"
  value       = module.rds.db_instance_endpoint
  sensitive   = true
}

output "db_instance_address" {
  description = "Dirección DNS de la instancia RDS"
  value       = module.rds.db_instance_address
  sensitive   = true
}

output "db_instance_port" {
  description = "Puerto de la base de datos"
  value       = module.rds.db_instance_port
}

output "db_instance_name" {
  description = "Nombre de la base de datos"
  value       = module.rds.db_instance_name
}

# ==============================================================================
# CLOUDWATCH ALARM OUTPUTS
# ==============================================================================

output "asg_cloudwatch_alarms" {
  description = "ARNs de alarmas de CloudWatch del ASG"
  value       = module.asg.cloudwatch_alarm_arns
}

output "rds_cloudwatch_alarms" {
  description = "ARNs de alarmas de CloudWatch de RDS"
  value       = module.rds.cloudwatch_alarm_arns
}

# ==============================================================================
# COMPLIANCE SUMMARY
# ==============================================================================

output "compliance_summary" {
  description = "Resumen de compliance del Layer 3"
  value = {
    layer = "Layer 3 - Compute"
    modules = {
      asg = module.asg.compliance_summary
      rds = module.rds.compliance_summary
    }
    overall_iso27001_controls = [
      "A.17.2.1",  # Availability (Multi-AZ, Auto Scaling)
      "A.12.3.1",  # Information backup (RDS backups)
      "A.12.6.1",  # Technical vulnerability management (Launch Templates)
      "A.10.1.1",  # Encryption at rest (EBS, RDS)
      "A.12.4.1",  # Event logging (CloudWatch)
      "A.9.4.2"    # Secure log-on procedures (RDS parameter group)
    ]
    overall_nist_controls = [
      "PR.IP-1",   # Baseline configuration (Launch Templates)
      "PR.DS-1",   # Data at rest protection (RDS encryption)
      "PR.IP-12",  # Vulnerability management (Patch management)
      "DE.CM-1"    # Network monitoring (CloudWatch)
    ]
    features = {
      load_balancer_enabled   = false
      auto_scaling_enabled    = true
      database_type           = var.rds_engine
      database_multi_az       = var.rds_multi_az
      database_backups        = "${var.rds_backup_retention_period} days"
      encrypted_storage       = true
      cloudwatch_monitoring   = true
      performance_insights    = true
    }
  }
}

# ==============================================================================
# DEPLOYMENT INFO
# ==============================================================================

output "deployment_info" {
  description = "Información del despliegue del Layer 3"
  value = {
    layer_name       = "compute"
    layer_number     = "03"
    state_key        = "sgsi/layer3-compute/terraform.tfstate"
    deployed_at      = timestamp()
    deployed_region  = var.aws_region
    environment      = var.environment
    modules_deployed = ["alb", "asg", "rds"]
  }
}

# ==============================================================================
# APPLICATION ACCESS
# ==============================================================================

output "application_url" {
  description = "URL para acceder a la aplicación"
  value       = "ALB deshabilitado - Acceder vía AWS Systems Manager Session Manager (SSM) a instancias EC2"
}

output "database_connection_info" {
  description = "Información de conexión a la base de datos (sin password)"
  value = {
    endpoint = module.rds.db_instance_endpoint
    database = module.rds.db_instance_name
    username = var.rds_master_username
    port     = module.rds.db_instance_port
    engine   = var.rds_engine
  }
  sensitive = true
}
