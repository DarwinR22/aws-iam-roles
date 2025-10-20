#!/bin/bash
# ==============================================================================
# USER DATA SCRIPT - EC2 INSTANCES
# Propósito: Configuración inicial de instancias EC2
# ==============================================================================

set -e

# Variables
ENVIRONMENT="${environment}"
PROJECT_NAME="${project_name}"
ENABLE_CLOUDWATCH="${enable_cloudwatch}"

# Actualizar sistema
yum update -y

# Instalar paquetes básicos
yum install -y \
    httpd \
    curl \
    wget \
    vim \
    git \
    amazon-cloudwatch-agent

# Configurar Apache
systemctl start httpd
systemctl enable httpd

# Página de bienvenida personalizada
cat > /var/www/html/index.html <<EOF
<!DOCTYPE html>
<html>
<head>
    <title>SGSI - $ENVIRONMENT</title>
    <style>
        body { 
            font-family: Arial, sans-serif; 
            text-align: center; 
            margin-top: 50px;
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            color: white;
        }
        .container {
            background: rgba(255,255,255,0.1);
            padding: 40px;
            border-radius: 10px;
            display: inline-block;
        }
        h1 { font-size: 48px; margin-bottom: 20px; }
        p { font-size: 20px; }
        .info { 
            background: rgba(0,0,0,0.3);
            padding: 20px;
            border-radius: 5px;
            margin-top: 20px;
        }
    </style>
</head>
<body>
    <div class="container">
        <h1>🔒 SGSI Implementation</h1>
        <p>Sistema de Gestión de Seguridad de la Información</p>
        <div class="info">
            <p><strong>Environment:</strong> $ENVIRONMENT</p>
            <p><strong>Instance ID:</strong> <span id="instance-id">Loading...</span></p>
            <p><strong>Availability Zone:</strong> <span id="az">Loading...</span></p>
            <p><strong>ISO 27001 Compliant</strong> ✅</p>
        </div>
    </div>
    
    <script>
        // Obtener metadatos de EC2
        fetch('http://169.254.169.254/latest/meta-data/instance-id')
            .then(r => r.text())
            .then(data => document.getElementById('instance-id').textContent = data);
        
        fetch('http://169.254.169.254/latest/meta-data/placement/availability-zone')
            .then(r => r.text())
            .then(data => document.getElementById('az').textContent = data);
    </script>
</body>
</html>
EOF

# Health check endpoint
cat > /var/www/html/health <<EOF
OK
EOF

# Configurar CloudWatch Agent (si está habilitado)
if [ "$ENABLE_CLOUDWATCH" == "true" ]; then
    cat > /opt/aws/amazon-cloudwatch-agent/etc/config.json <<EOF
{
  "metrics": {
    "namespace": "SGSI/$ENVIRONMENT",
    "metrics_collected": {
      "cpu": {
        "measurement": [
          {"name": "cpu_usage_idle", "rename": "CPU_IDLE", "unit": "Percent"},
          {"name": "cpu_usage_iowait", "rename": "CPU_IOWAIT", "unit": "Percent"},
          "cpu_time_guest"
        ],
        "metrics_collection_interval": 60,
        "totalcpu": false
      },
      "disk": {
        "measurement": [
          {"name": "used_percent", "rename": "DISK_USED", "unit": "Percent"}
        ],
        "metrics_collection_interval": 60,
        "resources": ["*"]
      },
      "mem": {
        "measurement": [
          {"name": "mem_used_percent", "rename": "MEM_USED", "unit": "Percent"}
        ],
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
            "log_group_name": "/aws/ec2/$PROJECT_NAME-$ENVIRONMENT/httpd",
            "log_stream_name": "{instance_id}/access.log"
          },
          {
            "file_path": "/var/log/httpd/error_log",
            "log_group_name": "/aws/ec2/$PROJECT_NAME-$ENVIRONMENT/httpd",
            "log_stream_name": "{instance_id}/error.log"
          }
        ]
      }
    }
  }
}
EOF

    # Iniciar CloudWatch Agent
    /opt/aws/amazon-cloudwatch-agent/bin/amazon-cloudwatch-agent-ctl \
        -a fetch-config \
        -m ec2 \
        -s \
        -c file:/opt/aws/amazon-cloudwatch-agent/etc/config.json
fi

# Configurar logs
echo "✅ User Data execution completed successfully" >> /var/log/user-data.log
