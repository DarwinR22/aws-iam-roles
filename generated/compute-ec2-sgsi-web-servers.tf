# EC2 Terraform generated from sgsi-web-servers.yaml
# EC2 Web Servers for SGSI Layer 3

# Launch Template for Web Servers
resource "aws_launch_template" "sgsi_web_server_template" {
  name_prefix   = "sgsi-web-server-"
  image_id      = "ami-0abcdef1234567890"
  instance_type = "t3.micro"
  
  vpc_security_group_ids = [data.aws_security_group.sgsi_web_sg.id]
  
  user_data = base64encode(<<-EOF
    #!/bin/bash
    yum update -y
    yum install -y httpd
    systemctl start httpd
    systemctl enable httpd
    
    # Create health check endpoint
    echo "<h1>SGSI Web Server</h1>" > /var/www/html/index.html
    echo "OK" > /var/www/html/health
    
    # Install CloudWatch Agent
    yum install -y amazon-cloudwatch-agent
    
    # Configure CloudWatch monitoring
    cat > /opt/aws/amazon-cloudwatch-agent/etc/amazon-cloudwatch-agent.json <<EOL
    {
      "metrics": {
        "namespace": "SGSI/EC2",
        "metrics_collected": {
          "cpu": {"measurement": ["cpu_usage_idle", "cpu_usage_iowait", "cpu_usage_user", "cpu_usage_system"]},
          "disk": {"measurement": ["used_percent"], "resources": ["*"]},
          "mem": {"measurement": ["mem_used_percent"]}
        }
      }
    }
EOL
    
    /opt/aws/amazon-cloudwatch-agent/bin/amazon-cloudwatch-agent-ctl \
      -a fetch-config -m ec2 -c file:/opt/aws/amazon-cloudwatch-agent/etc/amazon-cloudwatch-agent.json -s
  EOF
  )

  iam_instance_profile {
    name = aws_iam_instance_profile.sgsi_ec2_profile.name
  }

  tag_specifications {
    resource_type = "instance"
    tags = {
      Name        = "sgsi-web-servers"
      Environment = "dev"
      Layer       = "3-compute"
      Component   = "web-server"
      Proposito   = "sgsi-web-application"
    }
  }

  tags = {
    Name        = "sgsi-web-server-template"
    Environment = "dev"
    Layer       = "3-compute"
  }
}

# IAM Role for EC2 instances
resource "aws_iam_role" "sgsi_ec2_role" {
  name = "sgsi-ec2-cloudwatch-role"

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

  tags = {
    Name        = "sgsi-ec2-cloudwatch-role"
    Environment = "dev"
    Layer       = "3-compute"
  }
}

# IAM Policy for CloudWatch
resource "aws_iam_role_policy_attachment" "sgsi_ec2_cloudwatch" {
  policy_arn = "arn:aws:iam::aws:policy/CloudWatchAgentServerPolicy"
  role       = aws_iam_role.sgsi_ec2_role.name
}

# Instance Profile
resource "aws_iam_instance_profile" "sgsi_ec2_profile" {
  name = "sgsi-ec2-profile"
  role = aws_iam_role.sgsi_ec2_role.name

  tags = {
    Name        = "sgsi-ec2-profile"
    Environment = "dev"
    Layer       = "3-compute"
  }
}
