# Shared Data Sources for SGSI Layer 3
# Generated: 2025-10-18
# This file contains all shared data sources to avoid duplicates

# VPC DATA SOURCE
data "aws_vpc" "sgsi_vpc_main" {
  filter {
    name   = "tag:Name"
    values = ["sgsi-vpc-main"]
  }
}

# SUBNET DATA SOURCES - DMZ (Public)
data "aws_subnet" "sgsi_dmz_subnet_us_east_1a" {
  filter {
    name   = "tag:Name"
    values = ["sgsi-dmz-subnet-us-east-1a"]
  }
}

data "aws_subnet" "sgsi_dmz_subnet_us_east_1b" {
  filter {
    name   = "tag:Name"
    values = ["sgsi-dmz-subnet-us-east-1b"]
  }
}

data "aws_subnet" "sgsi_dmz_subnet_us_east_1c" {
  filter {
    name   = "tag:Name"
    values = ["sgsi-dmz-subnet-us-east-1c"]
  }
}

# SUBNET DATA SOURCES - App (Private)
data "aws_subnet" "sgsi_app_subnet_us_east_1a" {
  filter {
    name   = "tag:Name"
    values = ["sgsi-app-subnet-us-east-1a"]
  }
}

data "aws_subnet" "sgsi_app_subnet_us_east_1b" {
  filter {
    name   = "tag:Name"
    values = ["sgsi-app-subnet-us-east-1b"]
  }
}

data "aws_subnet" "sgsi_app_subnet_us_east_1c" {
  filter {
    name   = "tag:Name"
    values = ["sgsi-app-subnet-us-east-1c"]
  }
}

# SUBNET DATA SOURCES - DB (Isolated)
data "aws_subnet" "sgsi_db_subnet_us_east_1a" {
  filter {
    name   = "tag:Name"
    values = ["sgsi-db-subnet-us-east-1a"]
  }
}

data "aws_subnet" "sgsi_db_subnet_us_east_1b" {
  filter {
    name   = "tag:Name"
    values = ["sgsi-db-subnet-us-east-1b"]
  }
}

data "aws_subnet" "sgsi_db_subnet_us_east_1c" {
  filter {
    name   = "tag:Name"
    values = ["sgsi-db-subnet-us-east-1c"]
  }
}

# SECURITY GROUP DATA SOURCES
data "aws_security_group" "sgsi_alb_sg" {
  filter {
    name   = "tag:Name"
    values = ["sgsi-alb-sg"]
  }
}

data "aws_security_group" "sgsi_web_sg" {
  filter {
    name   = "tag:Name"
    values = ["sgsi-web-sg"]
  }
}

data "aws_security_group" "sgsi_app_sg" {
  filter {
    name   = "tag:Name"
    values = ["sgsi-app-sg"]
  }
}

data "aws_security_group" "sgsi_db_sg" {
  filter {
    name   = "tag:Name"
    values = ["sgsi-db-sg"]
  }
}

data "aws_security_group" "sgsi_lambda_sg" {
  filter {
    name   = "tag:Name"
    values = ["sgsi-lambda-sg"]
  }
}

# LAUNCH TEMPLATE DATA SOURCE
data "aws_launch_template" "sgsi_web_server_template" {
  name = "sgsi-web-server-template"
}
