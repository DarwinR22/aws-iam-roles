# Shared Local Values for SGSI Layer 3
# Generated: 2025-10-18
# This file contains locals to reference existing network resources

locals {
  # VPC Reference
  vpc_id = aws_vpc.sgsi_vpc_main.id

  # Public Subnets (DMZ)
  public_subnet_ids = [
    aws_subnet.dmz_public_1a.id,
    aws_subnet.dmz_public_1b.id,
    aws_subnet.dmz_public_1c.id
  ]

  # Private Subnets (App Layer)
  private_subnet_ids = [
    aws_subnet.app_private_1a.id,
    aws_subnet.app_private_1b.id,
    aws_subnet.app_private_1c.id
  ]

  # Database Subnets (Isolated)
  db_subnet_ids = [
    aws_subnet.db_private_1a.id,
    aws_subnet.db_private_1b.id,
    aws_subnet.db_private_1c.id
  ]

  # Security Groups
  alb_sg_id     = aws_security_group.sgsi_alb_sg.id
  web_sg_id     = aws_security_group.sgsi_web_sg.id
  app_sg_id     = aws_security_group.sgsi_app_sg.id
  db_sg_id      = aws_security_group.sgsi_db_sg.id
  lambda_sg_id  = aws_security_group.sgsi_app_sg.id  # Lambda usa el mismo SG que app
}
