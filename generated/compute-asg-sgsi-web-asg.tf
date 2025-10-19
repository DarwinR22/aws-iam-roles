# Auto Scaling Group generated from sgsi-web-asg.yaml
# Generated: 2025-10-18T22:18:12.536819

# Auto Scaling Group
resource "aws_autoscaling_group" "sgsi_web_asg" {
  name = "sgsi-web-asg"
  
  min_size         = 2
  max_size         = 6
  desired_capacity = 2
  
  vpc_zone_identifier = [
    data.aws_subnet.sgsi_app_subnet_us_east_1a.id,
    data.aws_subnet.sgsi_app_subnet_us_east_1b.id,
    data.aws_subnet.sgsi_app_subnet_us_east_1c.id,
  ]
  
  launch_template {
    id      = data.aws_launch_template.sgsi_web_server_template.id
    version = "$Latest"
  }
  
  health_check_type         = "ELB"
  health_check_grace_period = 300
  default_cooldown         = 300
  
  termination_policies = ["OldestInstance", "Default"]
  
  capacity_rebalance = true

  tag {
    key                 = "Pais"
    value               = "RG"
    propagate_at_launch = true
  }
  
  tag {
    key                 = "Gerencia"
    value               = "MejoraContinuaEInformacion"
    propagate_at_launch = true
  }
  
  tag {
    key                 = "Area"
    value               = "DevOps"
    propagate_at_launch = true
  }
  
  tag {
    key                 = "Ambiente"
    value               = "DEV"
    propagate_at_launch = true
  }
  
  tag {
    key                 = "Direccion"
    value               = "TICENAM"
    propagate_at_launch = true
  }
  
  tag {
    key                 = "Modulo"
    value               = "AutoScaling"
    propagate_at_launch = true
  }
  
  tag {
    key                 = "AlcanceSOX"
    value               = "No"
    propagate_at_launch = true
  }
  
  tag {
    key                 = "Propietario"
    value               = "DarwinLopez"
    propagate_at_launch = true
  }
  
  tag {
    key                 = "Proveedor"
    value               = "InHouse"
    propagate_at_launch = true
  }
  
  tag {
    key                 = "Layer"
    value               = "SGSI-Layer3-AutoScaling"
    propagate_at_launch = true
  }
  
  tag {
    key                 = "Dominio"
    value               = "BusinessIntelligence"
    propagate_at_launch = true
  }
  
  tag {
    key                 = "Subdominio"
    value               = "AutoScaling"
    propagate_at_launch = true
  }
  
  tag {
    key                 = "Aplicacion"
    value               = "SGSI"
    propagate_at_launch = true
  }
  
  tag {
    key                 = "Name"
    value               = "sgsi-web-asg"
    propagate_at_launch = true
  }
  
  tag {
    key                 = "Tipo de Recurso"
    value               = "AutoScalingGroup"
    propagate_at_launch = true
  }
  
  tag {
    key                 = "Soporte"
    value               = "darwin.lopez@claro.com.gt"
    propagate_at_launch = true
  }
  
  tag {
    key                 = "Contacto"
    value               = "darwin.lopez@claro.com.gt"
    propagate_at_launch = true
  }
  
  tag {
    key                 = "Creado Por"
    value               = "DarwinLopez"
    propagate_at_launch = true
  }
  
  tag {
    key                 = "Ciclo de Vida"
    value               = "Desarrollo"
    propagate_at_launch = true
  }
  
  tag {
    key                 = "Version"
    value               = "v1.0.0"
    propagate_at_launch = true
  }
  
  tag {
    key                 = "Fecha de Creacion"
    value               = "2025-10-18"
    propagate_at_launch = true
  }
  
  tag {
    key                 = "ScalingPolicy"
    value               = "TargetTracking"
    propagate_at_launch = true
  }
  
  tag {
    key                 = "MinSize"
    value               = "2"
    propagate_at_launch = true
  }
  
  tag {
    key                 = "MaxSize"
    value               = "6"
    propagate_at_launch = true
  }
  
  tag {
    key                 = "TargetUtilization"
    value               = "70%"
    propagate_at_launch = true
  }
  
  tag {
    key                 = "propagate_at_launch"
    value               = "True"
    propagate_at_launch = true
  }
  
  tag {
    key                 = "Name"
    value               = "sgsi-web-asg"
    propagate_at_launch = true
  }
}


# Target Tracking Scaling Policy: sgsi-web-scale-up
resource "aws_autoscaling_policy" "sgsi_web_scale_up" {
  name               = "sgsi-web-scale-up"
  scaling_adjustment = 0  # Not used in target tracking
  policy_type        = "TargetTrackingScaling"
  autoscaling_group_name = aws_autoscaling_group.sgsi_web_asg.name

  target_tracking_configuration {
    predefined_metric_specification {
      predefined_metric_type = "ASGAverageCPUUtilization"
    }
    
    target_value = 70.0
    scale_out_cooldown = 300
    scale_in_cooldown = 300
    disable_scale_in = false
  }
}


# Target Tracking Scaling Policy: sgsi-web-scale-up-requests
resource "aws_autoscaling_policy" "sgsi_web_scale_up_requests" {
  name               = "sgsi-web-scale-up-requests"
  scaling_adjustment = 0  # Not used in target tracking
  policy_type        = "TargetTrackingScaling"
  autoscaling_group_name = aws_autoscaling_group.sgsi_web_asg.name

  target_tracking_configuration {
    predefined_metric_specification {
      predefined_metric_type = "ALBRequestCountPerTarget"
      resource_label         = "app/sgsi-main-alb/*/targetgroup/sgsi-web-targets/*"
    }
    
    target_value = 1000.0
    scale_out_cooldown = 300
    scale_in_cooldown = 300
    disable_scale_in = false
  }
}

# Data sources are defined in compute-shared-data-sources.tf

