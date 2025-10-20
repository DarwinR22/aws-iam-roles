# 📦 LAYER 4: STORAGE

## 🎯 Propósito

Capa de almacenamiento con arquitectura modular para:
- **S3 Enhanced**: Buckets con versionado, lifecycle, encriptación, Object Lock
- **EFS**: File system compartido NFS con Multi-AZ y encriptación
- **AWS Backup**: Disaster Recovery con backups automatizados de RDS, EFS, EBS

## 🏗️ Arquitectura

```
┌─────────────────────────────────────────────────────────────┐
│                    LAYER 4: STORAGE                          │
├─────────────────────────────────────────────────────────────┤
│                                                              │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐     │
│  │   S3 Module  │  │  EFS Module  │  │ Backup Module│     │
│  ├──────────────┤  ├──────────────┤  ├──────────────┤     │
│  │ • App Data   │  │ • Multi-AZ   │  │ • Daily      │     │
│  │ • Logs       │  │ • Encrypted  │  │ • Weekly     │     │
│  │ • Backups    │  │ • Access Pts │  │ • Monthly    │     │
│  │ • Versioning │  │ • Lifecycle  │  │ • SNS Alerts │     │
│  │ • Lifecycle  │  │ • Burst/Prov │  │ • WORM Lock  │     │
│  │ • Object Lock│  │ • Monitoring │  │ • Cross-Rgn  │     │
│  │ • Replication│  │              │  │              │     │
│  └──────────────┘  └──────────────┘  └──────────────┘     │
│                                                              │
└─────────────────────────────────────────────────────────────┘
```

## 📋 Recursos Desplegados

### S3 Buckets (3)
1. **sgsi-dev-app-data**
   - Versionado: ✅ Enabled
   - Lifecycle: 30d → IA, 90d → Glacier
   - Encriptación: AES256
   - Public Access: ❌ Blocked
   - Logging: ✅ Enabled
   - Metrics: ✅ Enabled
   - Inventory: ✅ Daily

2. **sgsi-dev-logs**
   - Versionado: ❌ Disabled (logs no necesitan)
   - Lifecycle: 30d → IA, 90d → Glacier
   - Object Lock: ✅ 90 días (WORM para auditoría)
   - Encriptación: AES256
   - Public Access: ❌ Blocked

3. **sgsi-dev-backup** (Opcional)
   - Versionado: ✅ Enabled
   - Lifecycle: 30d → IA, 90d → Glacier
   - Object Lock: ✅ 365 días (WORM)
   - Retención: 2 años
   - Clasificación: Confidential

### EFS File System
- **sgsi-dev-efs**
  - Performance Mode: generalPurpose
  - Throughput Mode: bursting
  - Encriptación: ✅ AWS Managed Key
  - Lifecycle: AFTER_30_DAYS → IA
  - Multi-AZ: ✅ 2 mount targets
  - Access Points: /app, /data
  - CloudWatch Alarms: ✅ Burst credit, connections

### AWS Backup
- **sgsi-dev-vault**
  - Encriptación: ✅ AWS Managed KMS
  - Vault Lock: ⚠️ Disabled (dev), ✅ Enabled (prod)
  
- **Backup Plan**: sgsi-dev-plan
  - **Daily**: 02:00 AM UTC → Retención 7 días
  - **Weekly**: Domingos 03:00 AM UTC → Retención 30 días
  - **Monthly**: Día 1 04:00 AM UTC → Retención 365 días
  
- **Backup Selection**: Tag `Backup=true`
  - RDS (Layer 3)
  - EFS (Layer 4)
  - EBS volumes (Layer 3 ASG)

- **Notificaciones SNS**: ✅ Enabled
  - BACKUP_JOB_STARTED
  - BACKUP_JOB_COMPLETED
  - BACKUP_JOB_FAILED
  - RESTORE_JOB_STARTED/COMPLETED/FAILED

## 🔧 Variables Configurables

### S3 Configuration
```hcl
enable_s3_replication   = false  # true en producción
enable_s3_backup_bucket = true   # Bucket adicional para backups
```

### EFS Configuration
```hcl
efs_performance_mode          = "generalPurpose"  # O "maxIO"
efs_throughput_mode           = "bursting"        # O "provisioned" o "elastic"
efs_provisioned_throughput    = null              # MiB/s si mode=provisioned
efs_lifecycle_transition_to_ia = "AFTER_30_DAYS"  # 7, 14, 30, 60, 90 días
```

### AWS Backup Configuration
```hcl
enable_backup_vault_lock      = false  # true en prod para WORM
backup_daily_retention_days   = 7      # 1 semana
backup_weekly_retention_days  = 30     # 1 mes
backup_monthly_retention_days = 365    # 1 año
enable_cross_region_backup    = false  # DR multi-región
```

## 📊 Compliance

### ISO 27001
- **A.12.3.1** - Information backup
- **A.18.1.3** - Protection of records
- **A.17.1.2** - Implementing information security continuity
- **A.12.4.1** - Event logging

### NIST Cybersecurity Framework
- **PR.DS-1** - Data-at-rest is protected
- **PR.DS-6** - Integrity checking mechanisms
- **PR.IP-4** - Backups of information are conducted
- **RC.RP-1** - Recovery plan is executed

## 🚀 Deployment

### Pre-requisitos
- Layer 1 (Foundation) desplegado
- Layer 2 (Network) desplegado
- Layer 3 (Compute) desplegado con tag `Backup=true` en RDS

### Comandos

```powershell
# 1. Inicializar Terraform
cd layers/04-storage
terraform init

# 2. Validar configuración
terraform validate

# 3. Plan (revisar cambios)
terraform plan

# 4. Aplicar (desplegar)
terraform apply -auto-approve

# 5. Ver outputs
terraform output
```

### GitHub Actions
El workflow `.github/workflows/sgsi-deployment.yaml` detecta cambios en `layers/04-storage/**` y despliega automáticamente.

## 📈 Monitoreo

### CloudWatch Alarms - EFS
1. **Burst Credit Low** (<1 TB)
   - Acción: Considerar cambiar a Provisioned Throughput
2. **High Client Connections** (>50)
   - Acción: Revisar aplicaciones conectadas

### CloudWatch Alarms - Backup
1. **Backup Job Failed**
   - Acción inmediata: Verificar IAM role y recursos
2. **No Backup Completed** (24h)
   - Acción: Revisar backup plan y schedule

### SNS Notifications
- Topic: `sgsi-dev-plan-notifications`
- Suscripción: Configurar email/Slack manualmente

## 🔐 Seguridad

### S3 Security Features
- ✅ Server-side encryption (AES256/KMS)
- ✅ Versioning enabled
- ✅ Public access blocked
- ✅ Object Lock (WORM) para logs y backups
- ✅ Lifecycle policies (cost optimization)
- ✅ Access logging
- ✅ Inventory reports

### EFS Security Features
- ✅ Encryption at rest (AWS managed KMS)
- ✅ Encryption in transit (TLS)
- ✅ Network isolation (Security Groups)
- ✅ Access Points (multi-tenancy)
- ✅ POSIX permissions

### Backup Security Features
- ✅ Vault encryption (KMS)
- ✅ Vault Lock (WORM en prod)
- ✅ IAM role con least privilege
- ✅ Cross-region copy (DR)
- ✅ Audit logging (CloudTrail)

## 📝 Uso de EFS

### Montar EFS en EC2

```bash
# 1. Instalar cliente NFS
sudo yum install -y amazon-efs-utils

# 2. Crear directorio de montaje
sudo mkdir -p /mnt/efs

# 3. Montar usando DNS
sudo mount -t nfs4 -o nfsvers=4.1,rsize=1048576,wsize=1048576,hard,timeo=600,retrans=2,noresvport ${EFS_DNS_NAME}:/ /mnt/efs

# 4. Verificar montaje
df -h /mnt/efs

# 5. Auto-mount en /etc/fstab
echo "${EFS_DNS_NAME}:/ /mnt/efs nfs4 nfsvers=4.1,rsize=1048576,wsize=1048576,hard,timeo=600,retrans=2,noresvport,_netdev 0 0" | sudo tee -a /etc/fstab
```

### Usar Access Points

```bash
# Access Point /app
sudo mount -t efs -o tls,accesspoint=${ACCESS_POINT_APP_ID} ${EFS_ID}:/ /mnt/app

# Access Point /data
sudo mount -t efs -o tls,accesspoint=${ACCESS_POINT_DATA_ID} ${EFS_ID}:/ /mnt/data
```

## 🔄 Disaster Recovery

### Backup Recovery Process

1. **Identificar Recovery Point**
```bash
aws backup list-recovery-points-by-backup-vault --backup-vault-name sgsi-dev-vault
```

2. **Iniciar Restore Job**
```bash
aws backup start-restore-job \
  --recovery-point-arn <ARN> \
  --iam-role-arn <BACKUP_ROLE_ARN> \
  --metadata <TARGET_CONFIG>
```

3. **Monitorear Restore**
```bash
aws backup describe-restore-job --restore-job-id <JOB_ID>
```

### S3 Version Recovery

```bash
# Listar versiones de objeto
aws s3api list-object-versions --bucket sgsi-dev-app-data --prefix myfile.txt

# Restaurar versión específica
aws s3api copy-object \
  --copy-source sgsi-dev-app-data/myfile.txt?versionId=VERSION_ID \
  --bucket sgsi-dev-app-data \
  --key myfile.txt
```

### EFS Recovery

```bash
# Restaurar desde AWS Backup recovery point
# El proceso crea un nuevo EFS, luego:

# 1. Montar EFS restaurado
sudo mount -t nfs4 ${RESTORED_EFS_DNS}:/ /mnt/efs-restored

# 2. Copiar datos de vuelta al EFS principal
sudo rsync -av /mnt/efs-restored/ /mnt/efs/
```

## 💰 Cost Optimization

### S3 Lifecycle
- **Día 0-30**: STANDARD
- **Día 30-90**: STANDARD_IA (ahorro 50%)
- **Día 90+**: GLACIER (ahorro 80%)

### EFS Lifecycle
- **Acceso frecuente**: STANDARD
- **Sin acceso 30d**: IA (ahorro 92%)
- **Re-acceso**: Automático a STANDARD

### Backup Retention
- **Daily**: 7 días (costo bajo)
- **Weekly**: 30 días (costo medio)
- **Monthly**: 365 días → Glacier (costo bajo)

## 🧪 Testing

```bash
# Test S3
aws s3 ls s3://sgsi-dev-app-data/
aws s3 cp test.txt s3://sgsi-dev-app-data/
aws s3api get-bucket-versioning --bucket sgsi-dev-app-data

# Test EFS
echo "Hello EFS" | sudo tee /mnt/efs/test.txt
cat /mnt/efs/test.txt

# Test Backup
aws backup get-backup-plan --backup-plan-id <PLAN_ID>
aws backup list-backup-jobs --by-backup-vault-name sgsi-dev-vault
```

## 📚 Referencias

- [AWS S3 Best Practices](https://docs.aws.amazon.com/AmazonS3/latest/userguide/best-practices.html)
- [AWS EFS Performance](https://docs.aws.amazon.com/efs/latest/ug/performance.html)
- [AWS Backup Documentation](https://docs.aws.amazon.com/aws-backup/latest/devguide/whatisbackup.html)
- [ISO 27001 Annex A.12.3](https://www.iso.org/standard/54534.html)
- [NIST CSF - Protect Function](https://www.nist.gov/cyberframework/framework)

## 🐛 Troubleshooting

### S3 Issues

**Error: Bucket already exists**
```
Solution: Buckets usan random suffix, verificar terraform.tfstate
```

**Error: Object Lock requiere versioning**
```
Solution: Habilitado automáticamente en módulo
```

### EFS Issues

**Error: Mount targets failed**
```bash
# Verificar security group permite puerto 2049
aws ec2 describe-security-groups --group-ids <SG_ID>

# Verificar subnets existen
aws ec2 describe-subnets --subnet-ids <SUBNET_IDS>
```

**Performance degradation**
```
Solution: Revisar Burst Credit Balance, cambiar a Provisioned Throughput
```

### Backup Issues

**Error: IAM role cannot perform backup**
```bash
# Verificar role tiene policies
aws iam list-attached-role-policies --role-name sgsi-dev-backup-role

# Debe tener:
# - AWSBackupServiceRolePolicyForBackup
# - AWSBackupServiceRolePolicyForRestores
```

**Backup job failed**
```bash
# Ver detalles del error
aws backup describe-backup-job --backup-job-id <JOB_ID>

# Causas comunes:
# - Recurso eliminado
# - Tag "Backup=true" faltante
# - KMS key inaccesible
```

---

**Layer 4 - Storage** | ISO 27001 + NIST CSF Compliant | Modular Architecture
