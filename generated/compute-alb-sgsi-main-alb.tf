# ALB Terraform generated from sgsi-main-alb.yaml
# Application Load Balancer for SGSI Layer 3

resource "aws_lb" "sgsi_main_alb" {
  name               = "sgsi-main-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [data.aws_security_group.sgsi_alb_sg.id]
  subnets            = [
    data.aws_subnet.sgsi_public_subnet_1.id,
    data.aws_subnet.sgsi_public_subnet_2.id
  ]

  enable_deletion_protection = false

  tags = {
    Name        = "sgsi-main-alb"
    Environment = "dev"
    Layer       = "3-compute"
    Component   = "alb"
    Proposito   = "sgsi-web-load-balancer"
  }
}

resource "aws_lb_target_group" "sgsi_main_alb_tg" {
  name     = "sgsi-main-alb-tg"
  port     = 80
  protocol = "HTTP"
  vpc_id   = data.aws_vpc.sgsi_main_vpc.id

  health_check {
    enabled             = true
    healthy_threshold   = 3
    interval            = 30
    matcher             = "200"
    path                = "/health"
    port                = "traffic-port"
    protocol            = "HTTP"
    timeout             = 5
    unhealthy_threshold = 3
  }

  tags = {
    Name        = "sgsi-main-alb-tg"
    Environment = "dev"
    Layer       = "3-compute"
    Component   = "alb-target-group"
  }
}

resource "aws_lb_listener" "sgsi_main_alb_listener" {
  load_balancer_arn = aws_lb.sgsi_main_alb.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.sgsi_main_alb_tg.arn
  }

  tags = {
    Name        = "sgsi-main-alb-listener"
    Environment = "dev"
    Layer       = "3-compute"
    Component   = "alb-listener"
  }
}
