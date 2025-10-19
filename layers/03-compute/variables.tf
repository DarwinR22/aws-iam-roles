# ==============================================================================
# LAYER 3: COMPUTE - VARIABLES
# ==============================================================================

variable "aws_region" {
  description = "AWS region for deployment"
  type        = string
  default     = "us-east-1"
}

variable "environment" {
  description = "Environment name (dev, qa, prod)"
  type        = string
  default     = "dev"
}

variable "common_tags" {
  description = "Common tags to be applied to all resources"
  type        = map(string)
  default     = {}
}

# EC2 Configuration
variable "instance_type" {
  description = "EC2 instance type for web servers"
  type        = string
  default     = "t3.micro"
}

# Auto Scaling Configuration
variable "asg_min_size" {
  description = "Minimum number of instances in ASG"
  type        = number
  default     = 1
}

variable "asg_max_size" {
  description = "Maximum number of instances in ASG"
  type        = number
  default     = 3
}

variable "asg_desired_capacity" {
  description = "Desired number of instances in ASG"
  type        = number
  default     = 2
}

# RDS Configuration
variable "db_allocated_storage" {
  description = "The allocated storage in gigabytes"
  type        = number
  default     = 20
}

variable "db_max_allocated_storage" {
  description = "The upper limit to which Amazon RDS can automatically scale"
  type        = number
  default     = 100
}

variable "db_instance_class" {
  description = "The instance type of the RDS instance"
  type        = string
  default     = "db.t3.micro"
}

variable "db_name" {
  description = "The name of the database"
  type        = string
  default     = "sgsidb"
}

variable "db_username" {
  description = "Username for the master DB user"
  type        = string
  default     = "admin"
}

variable "db_password" {
  description = "Password for the master DB user"
  type        = string
  sensitive   = true
  default     = "changeme123!"
}