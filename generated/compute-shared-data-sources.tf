# Shared Data Sources for SGSI Layer 3
# Generated: 2025-10-18
# References to existing network resources created in Layer 2

# VPC Reference
data "aws_vpc" "sgsi_main" {
  filter {
    name   = "tag:Name"
    values = ["sgsi-vpc-main"]
  }
}

# Public Subnets (DMZ)
data "aws_subnet" "dmz_1a" {
  filter {
    name   = "tag:Name"
    values = ["sgsi-dmz-subnet-us-east-1a"]
  }
}

data "aws_subnet" "dmz_1b" {
  filter {
    name   = "tag:Name"
    values = ["sgsi-dmz-subnet-us-east-1b"]
  }
}

data "aws_subnet" "dmz_1c" {
  filter {
    name   = "tag:Name"
    values = ["sgsi-dmz-subnet-us-east-1c"]
  }
}

# Private App Subnets
data "aws_subnet" "app_1a" {
  filter {
    name   = "tag:Name"
    values = ["sgsi-app-subnet-us-east-1a"]
  }
}

data "aws_subnet" "app_1b" {
  filter {
    name   = "tag:Name"
    values = ["sgsi-app-subnet-us-east-1b"]
  }
}

data "aws_subnet" "app_1c" {
  filter {
    name   = "tag:Name"
    values = ["sgsi-app-subnet-us-east-1c"]
  }
}

# Private DB Subnets
data "aws_subnet" "db_1a" {
  filter {
    name   = "tag:Name"
    values = ["sgsi-db-subnet-us-east-1a"]
  }
}

data "aws_subnet" "db_1b" {
  filter {
    name   = "tag:Name"
    values = ["sgsi-db-subnet-us-east-1b"]
  }
}

data "aws_subnet" "db_1c" {
  filter {
    name   = "tag:Name"
    values = ["sgsi-db-subnet-us-east-1c"]
  }
}

# Security Groups
data "aws_security_group" "alb" {
  filter {
    name   = "tag:Name"
    values = ["sgsi-alb-sg"]
  }
}

data "aws_security_group" "web" {
  filter {
    name   = "tag:Name"
    values = ["sgsi-web-sg"]
  }
}

data "aws_security_group" "app" {
  filter {
    name   = "tag:Name"
    values = ["sgsi-app-sg"]
  }
}

data "aws_security_group" "db" {
  filter {
    name   = "tag:Name"
    values = ["sgsi-db-sg"]
  }
}

# Locals for easy reference
locals {
  vpc_id = data.aws_vpc.sgsi_main.id
  
  public_subnet_ids = [
    data.aws_subnet.dmz_1a.id,
    data.aws_subnet.dmz_1b.id,
    data.aws_subnet.dmz_1c.id
  ]
  
  private_subnet_ids = [
    data.aws_subnet.app_1a.id,
    data.aws_subnet.app_1b.id,
    data.aws_subnet.app_1c.id
  ]
  
  db_subnet_ids = [
    data.aws_subnet.db_1a.id,
    data.aws_subnet.db_1b.id,
    data.aws_subnet.db_1c.id
  ]
  
  alb_sg_id    = data.aws_security_group.alb.id
  web_sg_id    = data.aws_security_group.web.id
  app_sg_id    = data.aws_security_group.app.id
  db_sg_id     = data.aws_security_group.db.id
  lambda_sg_id = data.aws_security_group.app.id
}
