# ==============================================================================
# MODULE VARIABLES
# ==============================================================================

variable "instance_name" {
  description = "Name of the EC2 instance"
  type        = string
}

variable "instance_type" {
  description = "EC2 instance type"
  type        = string
  default     = "t3.medium"
}

variable "ami_id" {
  description = "AMI ID to use for the instance"
  type        = string
}

variable "ami_name_filter" {
  description = "Name filter for AMI lookup"
  type        = string
  default     = "amzn2-ami-hvm-*-x86_64-gp2"
}

variable "ami_owner" {
  description = "Owner of the AMI"
  type        = string
  default     = "amazon"
}

variable "subnet_id" {
  description = "Subnet ID where to launch the instance"
  type        = string
}

variable "vpc_id" {
  description = "VPC ID for security group creation"
  type        = string
}

variable "key_name" {
  description = "Name of the AWS key pair"
  type        = string
}

variable "associate_public_ip_address" {
  description = "Description for associate_public_ip_address"
  type        = bool
  default     = false
}

variable "detailed_monitoring" {
  description = "Description for detailed_monitoring"
  type        = bool
  default     = true
}

variable "ebs_encrypted" {
  description = "Description for ebs_encrypted"
  type        = bool
  default     = true
}

variable "create_cloudwatch_alarms" {
  description = "Description for create_cloudwatch_alarms"
  type        = bool
  default     = true
}

variable "cpu_alarm_threshold" {
  description = "Description for cpu_alarm_threshold"
  type        = number
  default     = 80
}

# Standard variables
variable "environment" {
  description = "Environment name"
  type        = string
  default     = "production"
}

variable "common_tags" {
  description = "Common tags to apply to all resources"
  type        = map(string)
  default = {
    Project     = "SGSI-Implementation"
    ManagedBy   = "Terraform"
  }
}

variable "additional_tags" {
  description = "Additional tags to apply to resources"
  type        = map(string)
  default     = {}
}
