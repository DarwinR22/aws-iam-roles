# EC2 Instances generated from sgsi-web-servers.yaml
# Generated: 2025-10-18T22:18:12.464579


# Launch Template
resource "aws_launch_template" "sgsi_web_server_template" {
  name_prefix   = "sgsi-web-server-template-"
  description   = "Template para servidores web SGSI con configuración estandarizada"
  
  image_id      = "ami-0c55b159cbfafe1d0"
  instance_type = "t3.medium"
  key_name      = "sgsi-keypair"
  
  vpc_security_group_ids = [
    data.aws_security_group.sgsi_web_sg.id,
    data.aws_security_group.sgsi_app_sg.id,
  ]
  
  iam_instance_profile {
    name = "sgsi-web-instance-profile"
  }
  
  block_device_mappings {
    device_name = "/dev/xvda"
    ebs {
      volume_type = "gp3"
      volume_size = 20
      iops        = 3000
      throughput  = 125
      encrypted   = true
      delete_on_termination = true
    }
  }
  
  user_data = base64encode(<<-EOF
#!/bin/bash
# SGSI Web Server Bootstrap Script
yum update -y

# Install web server and tools
yum install -y httpd php mysql git htop awscli

# Configure Apache
systemctl enable httpd
systemctl start httpd

# Install CloudWatch agent
wget https://s3.amazonaws.com/amazoncloudwatch-agent/amazon_linux/amd64/latest/amazon-cloudwatch-agent.rpm
rpm -U ./amazon-cloudwatch-agent.rpm

# Create web application
cat > /var/www/html/index.php << 'EOF'
<?php
$instance_id = file_get_contents("http://169.254.169.254/latest/meta-data/instance-id");
$availability_zone = file_get_contents("http://169.254.169.254/latest/meta-data/placement/availability-zone");
?>
<!DOCTYPE html>
<html>
<head>
    <title>SGSI Layer 3 - Web Server</title>
    <style>
        body { font-family: Arial, sans-serif; margin: 40px; }
        .header { background-color: #4CAF50; color: white; padding: 20px; }
        .info { background-color: #f1f1f1; padding: 15px; margin: 10px 0; }
    </style>
</head>
<body>
    <div class="header">
        <h1>🛡️ SGSI Layer 3 - Compute Infrastructure</h1>
    </div>
    <div class="info">
        <h2>Server Information</h2>
        <p><strong>Instance ID:</strong> <?php echo $instance_id; ?></p>
        <p><strong>Availability Zone:</strong> <?php echo $availability_zone; ?></p>
        <p><strong>Server Time:</strong> <?php echo date('Y-m-d H:i:s'); ?></p>
        <p><strong>Layer:</strong> Layer 3 - Compute</p>
        <p><strong>Status:</strong> ✅ Active</p>
    </div>
    <div class="info">
        <h2>Health Check Endpoint</h2>
        <p><a href="/health">/health</a> - ALB Health Check</p>
        <p><a href="/api/health">/api/health</a> - API Health Check</p>
    </div>
</body>
</html>
EOF

# Create health check endpoints
cat > /var/www/html/health << 'EOF'
OK
EOF

mkdir -p /var/www/html/api
cat > /var/www/html/api/health << 'EOF'
{"status":"healthy","timestamp":"<?php echo time(); ?>","layer":"compute"}
EOF

# Set permissions
chown -R apache:apache /var/www/html/
chmod -R 644 /var/www/html/

# Configure CloudWatch monitoring
cat > /opt/aws/amazon-cloudwatch-agent/etc/amazon-cloudwatch-agent.json << 'EOF'
{
  "metrics": {
    "namespace": "SGSI/Layer3",
    "metrics_collected": {
      "cpu": {
        "measurement": ["cpu_usage_idle", "cpu_usage_iowait"],
        "metrics_collection_interval": 60
      },
      "disk": {
        "measurement": ["used_percent"],
        "metrics_collection_interval": 60,
        "resources": ["*"]
      },
      "mem": {
        "measurement": ["mem_used_percent"],
        "metrics_collection_interval": 60
      }
    }
  },
  "logs": {
    "logs_collected": {
      "files": {
        "collect_list": [
          {
            "file_path": "/var/log/httpd/access_log",
            "log_group_name": "/sgsi/layer3/web/access",
            "log_stream_name": "{instance_id}"
          },
          {
            "file_path": "/var/log/httpd/error_log", 
            "log_group_name": "/sgsi/layer3/web/error",
            "log_stream_name": "{instance_id}"
          }
        ]
      }
    }
  }
}
EOF

# Start CloudWatch agent
/opt/aws/amazon-cloudwatch-agent/bin/amazon-cloudwatch-agent-ctl \
  -a fetch-config -m ec2 -c file:/opt/aws/amazon-cloudwatch-agent/etc/amazon-cloudwatch-agent.json -s

# Send success signal
echo "SGSI Web Server bootstrap completed successfully" > /var/log/sgsi-bootstrap.log

EOF
  )

  tags = {
    "Pais" = "RG"
    "Gerencia" = "MejoraContinuaEInformacion"
    "Area" = "DevOps"
    "Ambiente" = "DEV"
    "Direccion" = "TICENAM"
    "Modulo" = "WebServers"
    "AlcanceSOX" = "No"
    "Propietario" = "DarwinLopez"
    "Proveedor" = "InHouse"
    "Layer" = "SGSI-Layer3-Compute"
    "Dominio" = "BusinessIntelligence"
    "Subdominio" = "WebServices"
    "Aplicacion" = "SGSI"
    "Name" = "sgsi-web-servers"
    "Tipo de Recurso" = "EC2Instance"
    "Soporte" = "darwin.lopez@claro.com.gt"
    "Contacto" = "darwin.lopez@claro.com.gt"
    "Creado Por" = "DarwinLopez"
    "Ciclo de Vida" = "Desarrollo"
    "Version" = "v1.0.0"
    "Fecha de Creacion" = "2025-10-18"
    "Confidencialidad" = "Interno"
    "Criticidad" = "Alta"
    "BackupRequired" = "Yes"
    "PatchGroup" = "WebServers"
  }
}


# EC2 Instance: sgsi-web-server-1
resource "aws_instance" "sgsi_web_server_1" {
  launch_template {
    id      = aws_launch_template.sgsi_web_server_template.id
    version = "$Latest"
  }
  
  subnet_id         = data.aws_subnet.sgsi_app_subnet_us_east_1a.id
  availability_zone = "us-east-1a"
  
  instance_type = "t3.medium"
  
  tags = merge(aws_launch_template.sgsi_web_server_template.tags, {
    "Server" = "Primary"
    "AZ" = "us-east-1a"
    "Role" = "WebServer"
    "Environment" = "Development"
    "Name" = "sgsi-web-server-1"
  })
}


# EC2 Instance: sgsi-web-server-2
resource "aws_instance" "sgsi_web_server_2" {
  launch_template {
    id      = aws_launch_template.sgsi_web_server_template.id
    version = "$Latest"
  }
  
  subnet_id         = data.aws_subnet.sgsi_app_subnet_us_east_1b.id
  availability_zone = "us-east-1b"
  
  instance_type = "t3.medium"
  
  tags = merge(aws_launch_template.sgsi_web_server_template.tags, {
    "Server" = "Secondary"
    "AZ" = "us-east-1b"
    "Role" = "WebServer"
    "Environment" = "Development"
    "Name" = "sgsi-web-server-2"
  })
}

# Data sources for subnets and security groups
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

