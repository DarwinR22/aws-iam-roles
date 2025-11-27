# 🖥️ Layer 3: Compute - Arquitectura Modular

## 📋 Descripción General

El **Layer 3 (Compute)** implementa la capa de cómputo del proyecto SGSI con una arquitectura completamente modular, escalable y conforme a ISO 27001 y NIST CSF. Incluye:

- **Application Load Balancer (ALB)** - Balanceo de carga con health checks y monitoreo
- **Auto Scaling Group (ASG)** - Auto escalado Multi-AZ con Launch Templates
- **RDS PostgreSQL Multi-AZ** - Base de datos con alta disponibilidad y backups automáticos
- **CloudWatch Monitoring** - Alarmas y métricas personalizadas
- **SNS Notifications** (opcional) - Notificaciones de alarmas

**🚀 Ready for deployment - November 26, 2025**

---

## 🏗️ Arquitectura Modular

```
layers/03-compute/
├── main.tf           # Orquestador de módulos
├── variables.tf      # Variables del layer
├── outputs.tf        # Outputs con compliance summary
├── terraform.tfvars  # Configuración del environment
└── user-data.sh      # Script de inicialización EC2

modules/compute/
├── alb/              # Módulo Application Load Balancer
│   ├── main.tf
│   ├── variables.tf
│   └── outputs.tf
├── asg/              # Módulo Auto Scaling Group
│   ├── main.tf
│   ├── variables.tf
│   ├── outputs.tf
│   └── user-data.sh
└── rds/              # Módulo RDS Database
    ├── main.tf
    ├── variables.tf
    └── outputs.tf
```

---

## 🔒 Compliance y Seguridad

### ISO 27001 Controls Implementados

| Control | Descripción | Implementación |
|---------|-------------|----------------|
| **A.17.2.1** | Availability of information processing facilities | Multi-AZ deployment (ALB, RDS), Auto Scaling |
| **A.12.3.1** | Information backup | RDS automated backups (30 días), snapshots |
| **A.13.1.3** | Segregation in networks | Security Groups, ALB Target Groups |
| **A.12.6.1** | Management of technical vulnerabilities | Launch Templates, automated patching |
| **A.10.1.1** | Cryptographic controls | EBS encryption, RDS encryption at rest |
| **A.12.4.1** | Event logging | CloudWatch Logs, RDS logs, VPC Flow Logs |
| **A.9.4.2** | Secure log-on procedures | RDS parameter group (log connections) |

### NIST Cybersecurity Framework

| Function | Category | Implementación |
|----------|----------|----------------|
| **PROTECT** | PR.IP-1 | Baseline configuration (Launch Templates) |
| **PROTECT** | PR.DS-1 | Data at rest protection (RDS/EBS encryption) |
| **PROTECT** | PR.IP-12 | Vulnerability management (Patching via ASG) |
| **DETECT** | DE.CM-1 | Continuous monitoring (CloudWatch) |
| **DETECT** | DE.AE-3 | Event correlation (CloudWatch Alarms) |

---

## 📦 Módulos Implementados

### 1. ALB (Application Load Balancer)

**Características:**
- ✅ Cross-Zone Load Balancing habilitado
- ✅ Health checks configurables
- ✅ HTTPS/TLS support (opcional con ACM)
- ✅ Access logs a S3 (opcional)
- ✅ CloudWatch Alarms (unhealthy targets, response time, 5XX errors)
- ✅ Drop invalid HTTP headers

**Outputs:**
- `alb_dns_name` - DNS público para acceder a la aplicación
- `target_group_arn` - ARN del Target Group
- `cloudwatch_alarm_arns` - ARNs de alarmas

### 2. ASG (Auto Scaling Group)

**Características:**
- ✅ Launch Template con Amazon Linux 2
- ✅ Multi-AZ deployment
- ✅ IAM Instance Profile con SSM + CloudWatch
- ✅ EBS encryption habilitado
- ✅ IMDSv2 enforced (metadata service v2)
- ✅ Auto scaling basado en CPU
- ✅ CloudWatch Agent para métricas personalizadas
- ✅ Instance Refresh para rolling updates

**Scaling Policies:**
- Scale UP cuando CPU > 70% (2 períodos de 1 min)
- Scale DOWN cuando CPU < 30% (2 períodos de 5 min)

**Outputs:**
- `asg_name` - Nombre del ASG
- `iam_instance_profile_name` - IAM profile para EC2
- `launch_template_id` - ID del Launch Template

### 3. RDS (PostgreSQL Multi-AZ)

**Características:**
- ✅ PostgreSQL 14.9
- ✅ Multi-AZ deployment (alta disponibilidad)
- ✅ Encryption at rest (KMS)
- ✅ Automated backups (30 días retención)
- ✅ Enhanced Monitoring (60 segundos)
- ✅ Performance Insights habilitado
- ✅ CloudWatch Logs export
- ✅ Deletion protection
- ✅ Storage autoscaling (20 GB → 100 GB)

**Parameter Group:**
- `log_connections = 1` (auditoría ISO 27001)
- `log_disconnections = 1`
- `log_duration = 1`
- `log_statement = all`

**Outputs:**
- `db_instance_endpoint` - Host:Port de conexión
- `db_instance_address` - DNS de la instancia
- `cloudwatch_alarm_arns` - Alarmas de CPU, storage, connections

---

## 🚀 Despliegue

### Prerrequisitos

1. **Layer 1 (Foundation)** desplegado exitosamente
2. **Layer 2 (Network)** desplegado exitosamente
3. AWS CLI configurado
4. Terraform >= 1.5.0 instalado

### Paso 1: Configurar Variables

Editar `terraform.tfvars`:

```hcl
# RDS Password (⚠️ CAMBIAR EN PRODUCCIÓN)
rds_master_password = "TuPasswordSeguro123!"

# Opcional: Habilitar HTTPS
alb_enable_https    = true
alb_certificate_arn = "arn:aws:acm:us-east-1:ACCOUNT:certificate/CERT_ID"

# Opcional: Habilitar SNS Alarms
enable_sns_alarms = true
sns_alarm_email   = "tu-email@ejemplo.com"
```

### Paso 2: Inicializar Terraform

```powershell
cd layers\03-compute
terraform init
```

### Paso 3: Revisar Plan

```powershell
terraform plan -out=tfplan
```

**Recursos a crear:** ~30 recursos
- 1 ALB + 1 Target Group + 2-3 Listeners
- 1 Launch Template + 1 ASG + 2 Scaling Policies
- 1 RDS Instance + 1 DB Subnet Group + 1 Parameter Group
- 6 IAM Roles/Policies
- 9 CloudWatch Alarms
- 1 CloudWatch Log Group
- 1 SNS Topic (opcional)

### Paso 4: Aplicar Cambios

```powershell
terraform apply tfplan
```

⏱️ **Tiempo estimado:** 15-20 minutos (RDS Multi-AZ toma ~10-15 min)

### Paso 5: Obtener Outputs

```powershell
terraform output alb_dns_name
terraform output application_url
terraform output -json compliance_summary
```

---

## 🔍 Validación Post-Despliegue

### 1. Verificar ALB

```powershell
# Ver estado del ALB
aws elbv2 describe-load-balancers --names sgsi-dev-alb

# Ver Target Groups health
aws elbv2 describe-target-health --target-group-arn <TARGET_GROUP_ARN>
```

### 2. Verificar ASG

```powershell
# Ver estado del ASG
aws autoscaling describe-auto-scaling-groups --auto-scaling-group-names sgsi-dev-asg

# Ver instancias EC2
aws ec2 describe-instances --filters "Name=tag:aws:autoscaling:groupName,Values=sgsi-dev-asg"
```

### 3. Verificar RDS

```powershell
# Ver estado de RDS
aws rds describe-db-instances --db-instance-identifier sgsi-dev-db

# Ver backups automáticos
aws rds describe-db-snapshots --db-instance-identifier sgsi-dev-db
```

### 4. Verificar CloudWatch Alarms

```powershell
aws cloudwatch describe-alarms --alarm-name-prefix "sgsi-dev"
```

### 5. Acceder a la Aplicación

```powershell
# Obtener URL
$ALB_DNS = terraform output -raw alb_dns_name
Start-Process "http://$ALB_DNS"
```

Deberías ver la página de bienvenida del proyecto SGSI con:
- Environment (dev)
- Instance ID
- Availability Zone
- Estado de compliance ISO 27001

---

## 📊 Monitoreo y Alarmas

### CloudWatch Alarms Configuradas

#### ALB Alarms
- **sgsi-dev-alb-unhealthy-targets** - Detecta targets no saludables
- **sgsi-dev-alb-high-response-time** - Tiempo de respuesta > 1s
- **sgsi-dev-alb-5xx-errors** - Errores 5XX > 10 en 1 minuto

#### ASG Alarms
- **sgsi-dev-asg-cpu-high** - CPU > 70% (escala hacia arriba)
- **sgsi-dev-asg-cpu-low** - CPU < 30% (escala hacia abajo)

#### RDS Alarms
- **sgsi-dev-rds-cpu-high** - CPU > 80%
- **sgsi-dev-rds-storage-low** - Almacenamiento < 10 GB
- **sgsi-dev-rds-connections-high** - Conexiones > 80

### Logs Disponibles

- `/aws/ec2/sgsi-dev/httpd` - Logs de Apache (access + error)
- RDS PostgreSQL Logs exportados a CloudWatch
- VPC Flow Logs (Layer 2)

---

## 🛠️ Mantenimiento

### Actualizar Launch Template

```powershell
# Editar modules/compute/asg/user-data.sh
# Luego aplicar cambios:
terraform apply

# Forzar refresh de instancias (rolling update):
aws autoscaling start-instance-refresh \
    --auto-scaling-group-name sgsi-dev-asg \
    --preferences MinHealthyPercentage=50
```

### Escalar Manualmente ASG

```powershell
# Aumentar capacidad deseada
aws autoscaling set-desired-capacity \
    --auto-scaling-group-name sgsi-dev-asg \
    --desired-capacity 4
```

### Backup Manual de RDS

```powershell
aws rds create-db-snapshot \
    --db-instance-identifier sgsi-dev-db \
    --db-snapshot-identifier sgsi-dev-manual-backup-$(Get-Date -Format "yyyy-MM-dd-HHmm")
```

---

## 🔧 Troubleshooting

### Problema: Target Group sin instancias saludables

```powershell
# Verificar security groups
aws ec2 describe-security-groups --group-ids <WEB_SG_ID>

# Ver user-data logs en EC2
aws ssm start-session --target <INSTANCE_ID>
sudo tail -f /var/log/user-data.log
sudo systemctl status httpd
```

### Problema: RDS no accesible

```powershell
# Verificar security group de DB
aws ec2 describe-security-groups --group-ids <DB_SG_ID>

# Verificar subnet group
aws rds describe-db-subnet-groups --db-subnet-group-name sgsi-dev-db-subnet-group
```

### Problema: Alarmas en estado ALARM

```powershell
# Ver detalles de la alarma
aws cloudwatch describe-alarm-history --alarm-name <ALARM_NAME> --max-records 10

# Ver métricas
aws cloudwatch get-metric-statistics \
    --namespace AWS/ApplicationELB \
    --metric-name TargetResponseTime \
    --dimensions Name=LoadBalancer,Value=<ALB_ARN_SUFFIX> \
    --start-time $(Get-Date).AddHours(-1) \
    --end-time $(Get-Date) \
    --period 300 \
    --statistics Average
```

---

## 🎯 Próximos Pasos

1. **Habilitar HTTPS** con ACM certificate
2. **Configurar WAF** en el ALB (Layer 5)
3. **Implementar CodeDeploy** para CI/CD
4. **Configurar Route53** para DNS personalizado
5. **Integrar con GuardDuty** (IDS/IPS)
6. **Configurar Security Hub** (SIEM)

---

## 📚 Referencias

- [AWS ALB Best Practices](https://docs.aws.amazon.com/elasticloadbalancing/latest/application/introduction.html)
- [AWS Auto Scaling Documentation](https://docs.aws.amazon.com/autoscaling/)
- [RDS PostgreSQL Documentation](https://docs.aws.amazon.com/AmazonRDS/latest/UserGuide/CHAP_PostgreSQL.html)
- [ISO 27001:2022 Controls](https://www.iso.org/standard/27001)
- [NIST Cybersecurity Framework](https://www.nist.gov/cyberframework)

---

## 📝 Changelog

### [1.0.0] - 2025-01-19
- ✅ Arquitectura modular completa (ALB, ASG, RDS)
- ✅ Multi-AZ deployment en todos los componentes
- ✅ RDS PostgreSQL con backups 30 días
- ✅ CloudWatch Alarms (9 alarmas configuradas)
- ✅ IAM Roles con least privilege
- ✅ Encryption at rest (EBS + RDS)
- ✅ IMDSv2 enforced
- ✅ Compliance ISO 27001 + NIST CSF

---

**Maintainer:** SGSI Team  
**Last Updated:** 2025-01-19  
**License:** Internal Use Only
