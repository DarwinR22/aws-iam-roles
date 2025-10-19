# ==================================================
# SGSI Infrastructure Cleanup Script
# ==================================================
# Elimina recursos que generan costos pero preserva:
# - IAM Roles y Policies (sin costo)
# - VPC base y Security Groups (sin costo)
# - S3/DynamoDB para Terraform state (sin costo)

terraform {
  required_version = ">= 1.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
  
  backend "s3" {
    bucket         = "terraform-state-bucket-051963532279"
    key            = "cleanup/terraform.tfstate"
    region         = "us-east-1"
    dynamodb_table = "terraform-locks"
    encrypt        = true
  }
}

provider "aws" {
  region = "us-east-1"
  
  default_tags {
    tags = {
      "Environment"     = "dev"
      "Project"         = "SGSI-Cleanup"
      "ManagedBy"       = "Terraform"
      "Owner"           = "DarwinLopez"
      "Purpose"         = "Cost-Optimization"
      "AutoCleanup"     = "true"
    }
  }
}

# ==================================================
# VARIABLES
# ==================================================

variable "preserve_iam" {
  description = "Preservar IAM roles y policies (recomendado: true)"
  type        = bool
  default     = true
}

variable "preserve_vpc_base" {
  description = "Preservar VPC, subnets y security groups (sin costo)"
  type        = bool
  default     = true
}

variable "preserve_terraform_state" {
  description = "Preservar S3 bucket y DynamoDB para Terraform state"
  type        = bool
  default     = true
}

variable "cleanup_scope" {
  description = "Alcance de limpieza: minimal, moderate, aggressive"
  type        = string
  default     = "minimal"
  
  validation {
    condition     = contains(["minimal", "moderate", "aggressive"], var.cleanup_scope)
    error_message = "cleanup_scope debe ser: minimal, moderate, o aggressive."
  }
}

# ==================================================
# LOCALS PARA FILTROS
# ==================================================

locals {
  # Prefijos de recursos a limpiar
  sgsi_prefixes = ["sgsi-", "github-", "mci-"]
  
  # Recursos que generan costo (PRIORIDAD ALTA)
  high_cost_resources = [
    "aws_nat_gateway",
    "aws_instance", 
    "aws_rds_instance",
    "aws_rds_cluster",
    "aws_lb",
    "aws_vpc_endpoint"
  ]
  
  # Recursos que generan costo medio
  medium_cost_resources = [
    "aws_ebs_volume",
    "aws_eip",
    "aws_lambda_function"
  ]
  
  # Recursos sin costo o muy bajo
  low_cost_resources = [
    "aws_vpc",
    "aws_subnet", 
    "aws_security_group",
    "aws_route_table",
    "aws_internet_gateway"
  ]
}

# ==================================================
# DATA SOURCES PARA IDENTIFICAR RECURSOS
# ==================================================

# Buscar instancias EC2 con nuestros tags
data "aws_instances" "sgsi_instances" {
  filter {
    name   = "tag:Project"
    values = ["SGSI", "MCI-IAM"]
  }
  
  filter {
    name   = "instance-state-name"
    values = ["running", "stopped"]
  }
}

# Buscar NAT Gateways (ALTO COSTO)
data "aws_nat_gateways" "sgsi_nat_gateways" {
  filter {
    name   = "tag:Project"
    values = ["SGSI", "MCI-IAM"]
  }
}

# Buscar Load Balancers (ALTO COSTO)
data "aws_lb" "sgsi_load_balancers" {
  name = "sgsi-main-alb"
}

# ==================================================
# RECURSOS DE LIMPIEZA
# ==================================================

# 🔥 LIMPIEZA CRÍTICA: NAT Gateways (≈$45/mes cada uno)
resource "null_resource" "cleanup_nat_gateways" {
  count = var.cleanup_scope != "minimal" ? 1 : 0
  
  provisioner "local-exec" {
    command = <<-EOT
      echo "🔥 Eliminando NAT Gateways (ALTO COSTO)..."
      aws ec2 describe-nat-gateways --region us-east-1 \
        --filter "Name=tag:Project,Values=SGSI,MCI-IAM" \
        --query 'NatGateways[?State==`available`].NatGatewayId' \
        --output text | xargs -I {} aws ec2 delete-nat-gateway --nat-gateway-id {} --region us-east-1
    EOT
  }
  
  triggers = {
    cleanup_scope = var.cleanup_scope
  }
}

# 🔥 LIMPIEZA CRÍTICA: Instancias EC2 
resource "null_resource" "cleanup_ec2_instances" {
  count = var.cleanup_scope != "minimal" ? 1 : 0
  
  provisioner "local-exec" {
    command = <<-EOT
      echo "🔥 Eliminando instancias EC2..."
      aws ec2 describe-instances --region us-east-1 \
        --filters "Name=tag:Project,Values=SGSI,MCI-IAM" "Name=instance-state-name,Values=running,stopped" \
        --query 'Reservations[].Instances[].InstanceId' \
        --output text | xargs -I {} aws ec2 terminate-instances --instance-ids {} --region us-east-1
    EOT
  }
  
  depends_on = [null_resource.cleanup_nat_gateways]
}

# 🔥 LIMPIEZA CRÍTICA: Load Balancers
resource "null_resource" "cleanup_load_balancers" {
  count = var.cleanup_scope != "minimal" ? 1 : 0
  
  provisioner "local-exec" {
    command = <<-EOT
      echo "🔥 Eliminando Load Balancers..."
      aws elbv2 describe-load-balancers --region us-east-1 \
        --query 'LoadBalancers[?contains(LoadBalancerName, `sgsi`) || contains(LoadBalancerName, `mci`)].LoadBalancerArn' \
        --output text | xargs -I {} aws elbv2 delete-load-balancer --load-balancer-arn {} --region us-east-1
    EOT
  }
  
  depends_on = [null_resource.cleanup_ec2_instances]
}

# 🟡 LIMPIEZA MODERADA: Elastic IPs no asociadas
resource "null_resource" "cleanup_elastic_ips" {
  count = var.cleanup_scope == "aggressive" ? 1 : 0
  
  provisioner "local-exec" {
    command = <<-EOT
      echo "🟡 Liberando Elastic IPs no asociadas..."
      aws ec2 describe-addresses --region us-east-1 \
        --filters "Name=domain,Values=vpc" \
        --query 'Addresses[?AssociationId==null].AllocationId' \
        --output text | xargs -I {} aws ec2 release-address --allocation-id {} --region us-east-1
    EOT
  }
  
  depends_on = [null_resource.cleanup_load_balancers]
}

# 🟡 LIMPIEZA MODERADA: RDS Instances
resource "null_resource" "cleanup_rds_instances" {
  count = var.cleanup_scope == "aggressive" ? 1 : 0
  
  provisioner "local-exec" {
    command = <<-EOT
      echo "🟡 Eliminando instancias RDS..."
      aws rds describe-db-instances --region us-east-1 \
        --query 'DBInstances[?contains(DBName, `sgsi`) || contains(DBName, `mci`)].DBInstanceIdentifier' \
        --output text | xargs -I {} aws rds delete-db-instance --db-instance-identifier {} --skip-final-snapshot --region us-east-1
    EOT
  }
  
  depends_on = [null_resource.cleanup_elastic_ips]
}

# ==================================================
# OUTPUTS DE LIMPIEZA
# ==================================================

output "cleanup_summary" {
  description = "Resumen de recursos limpiados"
  value = {
    cleanup_scope        = var.cleanup_scope
    preserve_iam        = var.preserve_iam
    preserve_vpc_base   = var.preserve_vpc_base
    preserve_tf_state   = var.preserve_terraform_state
    estimated_savings   = var.cleanup_scope == "minimal" ? "$45-90/mes" : var.cleanup_scope == "moderate" ? "$70-150/mes" : "$100-200/mes"
  }
}

output "preserved_resources" {
  description = "Recursos preservados (sin costo)"
  value = [
    "IAM Roles y Policies",
    "VPC base y Subnets", 
    "Security Groups",
    "Route Tables",
    "Internet Gateway",
    "S3 Terraform Backend",
    "DynamoDB Locks Table"
  ]
}

output "next_steps" {
  description = "Próximos pasos recomendados"
  value = [
    "1. Verificar que no hay recursos costosos activos",
    "2. Monitorear AWS Cost Explorer", 
    "3. Re-desplegar solo cuando necesites trabajar",
    "4. Usar 'terraform apply' para recrear recursos rápidamente"
  ]
}