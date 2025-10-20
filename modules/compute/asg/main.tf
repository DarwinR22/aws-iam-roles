# ==============================================================================
# MÓDULO: AUTO SCALING GROUP (ASG)
# Propósito: Auto scaling con alta disponibilidad Multi-AZ
# Compliance: ISO 27001 A.17.2.1, A.12.6.1 | NIST CSF PR.IP-12
# ==============================================================================

# ------------------------------------------------------------------------------
# DATA SOURCE - LATEST AMAZON LINUX AMI
# ------------------------------------------------------------------------------
data "aws_ami" "amazon_linux" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-gp2"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

# ------------------------------------------------------------------------------
# IAM ROLE FOR EC2 INSTANCES
# ------------------------------------------------------------------------------
resource "aws_iam_role" "ec2_instance_role" {
  name = "${var.project_name}-${var.environment}-ec2-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      }
    ]
  })

  tags = merge(
    var.common_tags,
    {
      Name              = "${var.project_name}-${var.environment}-ec2-role"
      Module            = "compute/asg"
      AssetType         = "IAM-Role"
    }
  )
}

# Attach SSM policy for Systems Manager
resource "aws_iam_role_policy_attachment" "ssm_managed_instance" {
  role       = aws_iam_role.ec2_instance_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

# Attach CloudWatch policy
resource "aws_iam_role_policy_attachment" "cloudwatch_agent" {
  role       = aws_iam_role.ec2_instance_role.name
  policy_arn = "arn:aws:iam::aws:policy/CloudWatchAgentServerPolicy"
}

resource "aws_iam_instance_profile" "ec2_profile" {
  name = "${var.project_name}-${var.environment}-ec2-profile"
  role = aws_iam_role.ec2_instance_role.name

  tags = merge(
    var.common_tags,
    {
      Name   = "${var.project_name}-${var.environment}-ec2-profile"
      Module = "compute/asg"
    }
  )
}

# ------------------------------------------------------------------------------
# LAUNCH TEMPLATE
# ------------------------------------------------------------------------------
resource "aws_launch_template" "main" {
  name_prefix   = "${var.project_name}-${var.environment}-"
  image_id      = var.ami_id != "" ? var.ami_id : data.aws_ami.amazon_linux.id
  instance_type = var.instance_type

  # IAM Instance Profile
  iam_instance_profile {
    name = aws_iam_instance_profile.ec2_profile.name
  }

  # Network Configuration
  vpc_security_group_ids = var.security_group_ids

  # EBS Encryption (ISO 27001 A.10.1.1)
  block_device_mappings {
    device_name = "/dev/xvda"

    ebs {
      volume_size           = var.root_volume_size
      volume_type           = "gp3"
      encrypted             = true
      delete_on_termination = true
      iops                  = 3000
      throughput            = 125
    }
  }

  # User Data Script
  user_data = base64encode(templatefile("${path.module}/user-data.sh", {
    environment    = var.environment
    project_name   = var.project_name
    enable_cloudwatch = var.enable_cloudwatch_agent
  }))

  # Metadata Options (IMDSv2 - Security best practice)
  metadata_options {
    http_endpoint               = "enabled"
    http_tokens                 = "required"  # IMDSv2 only
    http_put_response_hop_limit = 1
    instance_metadata_tags      = "enabled"
  }

  # Monitoring
  monitoring {
    enabled = var.detailed_monitoring
  }

  # Tag specifications
  tag_specifications {
    resource_type = "instance"
    tags = merge(
      var.common_tags,
      {
        Name              = "${var.project_name}-${var.environment}-web-server"
        Module            = "compute/asg"
        AssetType         = "EC2-Instance"
        Role              = "WebServer"
        Backup            = "Daily"
      }
    )
  }

  tag_specifications {
    resource_type = "volume"
    tags = merge(
      var.common_tags,
      {
        Name              = "${var.project_name}-${var.environment}-web-volume"
        Module            = "compute/asg"
        AssetType         = "EBS-Volume"
        Encrypted         = "Yes"
      }
    )
  }

  tags = merge(
    var.common_tags,
    {
      Name              = "${var.project_name}-${var.environment}-launch-template"
      Module            = "compute/asg"
      AssetType         = "Launch-Template"
      ISO27001Control   = "A.12.6.1+A.10.1.1"
      NISTControl       = "PR.IP-12"
    }
  )
}

# ------------------------------------------------------------------------------
# AUTO SCALING GROUP
# ------------------------------------------------------------------------------
resource "aws_autoscaling_group" "main" {
  name                = "${var.project_name}-${var.environment}-asg"
  vpc_zone_identifier = var.subnet_ids
  target_group_arns   = var.target_group_arns
  health_check_type   = var.health_check_type
  health_check_grace_period = var.health_check_grace_period

  # Capacity Configuration
  min_size         = var.min_size
  max_size         = var.max_size
  desired_capacity = var.desired_capacity

  # Launch Template
  launch_template {
    id      = aws_launch_template.main.id
    version = "$Latest"
  }

  # Instance Refresh (for rolling updates)
  instance_refresh {
    strategy = "Rolling"
    preferences {
      min_healthy_percentage = 50
      instance_warmup        = 300
    }
  }

  # Termination Policies (ISO 27001 A.17.2.1 - HA)
  termination_policies = [
    "OldestLaunchTemplate",
    "OldestInstance"
  ]

  # Enabled Metrics (ISO 27001 A.12.4.1 - Monitoring)
  enabled_metrics = [
    "GroupDesiredCapacity",
    "GroupInServiceInstances",
    "GroupMaxSize",
    "GroupMinSize",
    "GroupPendingInstances",
    "GroupStandbyInstances",
    "GroupTerminatingInstances",
    "GroupTotalInstances"
  ]

  # Tags
  tag {
    key                 = "Name"
    value               = "${var.project_name}-${var.environment}-asg"
    propagate_at_launch = false
  }

  dynamic "tag" {
    for_each = var.common_tags
    content {
      key                 = tag.key
      value               = tag.value
      propagate_at_launch = true
    }
  }

  lifecycle {
    create_before_destroy = true
  }
}

# ------------------------------------------------------------------------------
# AUTO SCALING POLICIES
# ------------------------------------------------------------------------------

# Scale Up Policy (CPU Based)
resource "aws_autoscaling_policy" "scale_up" {
  name                   = "${var.project_name}-${var.environment}-scale-up"
  scaling_adjustment     = var.scale_up_adjustment
  adjustment_type        = "ChangeInCapacity"
  cooldown               = var.scale_up_cooldown
  autoscaling_group_name = aws_autoscaling_group.main.name
}

# Scale Down Policy (CPU Based)
resource "aws_autoscaling_policy" "scale_down" {
  name                   = "${var.project_name}-${var.environment}-scale-down"
  scaling_adjustment     = var.scale_down_adjustment
  adjustment_type        = "ChangeInCapacity"
  cooldown               = var.scale_down_cooldown
  autoscaling_group_name = aws_autoscaling_group.main.name
}

# ------------------------------------------------------------------------------
# CLOUDWATCH ALARMS FOR SCALING
# ------------------------------------------------------------------------------

# Alarm: High CPU (Scale Up)
resource "aws_cloudwatch_metric_alarm" "cpu_high" {
  alarm_name          = "${var.project_name}-${var.environment}-asg-cpu-high"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "2"
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = "60"
  statistic           = "Average"
  threshold           = var.cpu_high_threshold
  alarm_description   = "CPU utilization alta - Scale Up"
  alarm_actions       = [aws_autoscaling_policy.scale_up.arn]

  dimensions = {
    AutoScalingGroupName = aws_autoscaling_group.main.name
  }

  tags = merge(
    var.common_tags,
    {
      Name              = "${var.project_name}-asg-cpu-high"
      Module            = "compute/asg"
      AlarmType         = "Scaling"
    }
  )
}

# Alarm: Low CPU (Scale Down)
resource "aws_cloudwatch_metric_alarm" "cpu_low" {
  alarm_name          = "${var.project_name}-${var.environment}-asg-cpu-low"
  comparison_operator = "LessThanThreshold"
  evaluation_periods  = "2"
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = "300"
  statistic           = "Average"
  threshold           = var.cpu_low_threshold
  alarm_description   = "CPU utilization baja - Scale Down"
  alarm_actions       = [aws_autoscaling_policy.scale_down.arn]

  dimensions = {
    AutoScalingGroupName = aws_autoscaling_group.main.name
  }

  tags = merge(
    var.common_tags,
    {
      Name              = "${var.project_name}-asg-cpu-low"
      Module            = "compute/asg"
      AlarmType         = "Scaling"
    }
  )
}
