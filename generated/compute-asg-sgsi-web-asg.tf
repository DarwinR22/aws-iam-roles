# ASG Terraform generated from sgsi-web-asg.yaml
# Auto Scaling Group for SGSI Layer 3

resource "aws_autoscaling_group" "sgsi_web_asg" {
  name                = "sgsi-web-asg"
  vpc_zone_identifier = local.private_subnet_ids
  target_group_arns   = [aws_lb_target_group.sgsi_main_alb_tg.arn]
  health_check_type   = "ELB"
  health_check_grace_period = 300

  min_size         = 2
  max_size         = 6
  desired_capacity = 2

  launch_template {
    id      = aws_launch_template.sgsi_web_server_template.id
    version = "$Latest"
  }

  # Instance refresh settings
  instance_refresh {
    strategy = "Rolling"
    preferences {
      min_healthy_percentage = 50
    }
  }

  tag {
    key                 = "Name"
    value               = "sgsi-web-asg"
    propagate_at_launch = true
  }

  tag {
    key                 = "Environment"
    value               = "dev"
    propagate_at_launch = true
  }

  tag {
    key                 = "Layer"
    value               = "3-compute"
    propagate_at_launch = true
  }

  tag {
    key                 = "Component"
    value               = "web-server"
    propagate_at_launch = true
  }

  tag {
    key                 = "Proposito"
    value               = "sgsi-web-application"
    propagate_at_launch = true
  }
}

# Auto Scaling Policy - Scale Up
resource "aws_autoscaling_policy" "sgsi_scale_up" {
  name                   = "sgsi-scale-up"
  scaling_adjustment     = 1
  adjustment_type        = "ChangeInCapacity"
  cooldown               = 300
  autoscaling_group_name = aws_autoscaling_group.sgsi_web_asg.name
}

# Auto Scaling Policy - Scale Down
resource "aws_autoscaling_policy" "sgsi_scale_down" {
  name                   = "sgsi-scale-down"
  scaling_adjustment     = -1
  adjustment_type        = "ChangeInCapacity"
  cooldown               = 300
  autoscaling_group_name = aws_autoscaling_group.sgsi_web_asg.name
}

# CloudWatch Alarm - High CPU
resource "aws_cloudwatch_metric_alarm" "sgsi_high_cpu" {
  alarm_name          = "sgsi-high-cpu"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "2"
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = "120"
  statistic           = "Average"
  threshold           = "70"
  alarm_description   = "This metric monitors ec2 cpu utilization"
  alarm_actions       = [aws_autoscaling_policy.sgsi_scale_up.arn]

  dimensions = {
    AutoScalingGroupName = aws_autoscaling_group.sgsi_web_asg.name
  }

  tags = {
    Name        = "sgsi-high-cpu-alarm"
    Environment = "dev"
    Layer       = "3-compute"
  }
}

# CloudWatch Alarm - Low CPU
resource "aws_cloudwatch_metric_alarm" "sgsi_low_cpu" {
  alarm_name          = "sgsi-low-cpu"
  comparison_operator = "LessThanThreshold"
  evaluation_periods  = "2"
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = "120"
  statistic           = "Average"
  threshold           = "30"
  alarm_description   = "This metric monitors ec2 cpu utilization"
  alarm_actions       = [aws_autoscaling_policy.sgsi_scale_down.arn]

  dimensions = {
    AutoScalingGroupName = aws_autoscaling_group.sgsi_web_asg.name
  }

  tags = {
    Name        = "sgsi-low-cpu-alarm"
    Environment = "dev"
    Layer       = "3-compute"
  }
}

# Scheduled Scaling - Business Hours Scale Up
resource "aws_autoscaling_schedule" "sgsi_business_hours_scale_up" {
  scheduled_action_name  = "sgsi-business-hours-scale-up"
  min_size               = 3
  max_size               = 6
  desired_capacity       = 3
  recurrence             = "0 8 * * MON-FRI"
  autoscaling_group_name = aws_autoscaling_group.sgsi_web_asg.name
}

# Scheduled Scaling - Off Hours Scale Down
resource "aws_autoscaling_schedule" "sgsi_off_hours_scale_down" {
  scheduled_action_name  = "sgsi-off-hours-scale-down"
  min_size               = 2
  max_size               = 6
  desired_capacity       = 2
  recurrence             = "0 18 * * MON-FRI"
  autoscaling_group_name = aws_autoscaling_group.sgsi_web_asg.name
}
