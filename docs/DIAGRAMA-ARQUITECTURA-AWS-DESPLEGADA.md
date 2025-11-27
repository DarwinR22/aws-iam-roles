# 🏗️ DIAGRAMA DE ARQUITECTURA AWS - INFRAESTRUCTURA DESPLEGADA

**Cuenta AWS:** 051963532279  
**Región:** us-east-1 (N. Virginia)  
**Fecha:** 2025  
**Proyecto:** SGSI Implementation

---

## 📊 DIAGRAMA DE ARQUITECTURA COMPLETA

```
┌─────────────────────────────────────────────────────────────────────────────────────┐
│                              REGIÓN: us-east-1                                      │
│                         Account: 051963532279                                       │
└─────────────────────────────────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────────────────────────────────┐
│                          🌐 INTERNET / USUARIOS                                     │
└─────────────────────────────────────────────────────────────────────────────────────┘
                                        │
                                        ▼
┌─────────────────────────────────────────────────────────────────────────────────────┐
│                    VPC: sgsi-vpc-main (10.0.0.0/16)                                 │
│                    vpc-0c61cbedb02cd6a41                                            │
│                                                                                     │
│  ┌─────────────────────────────────────────────────────────────────────────────┐  │
│  │                    Internet Gateway: sgsi-igw                                │  │
│  │                    igw-0d3654783b07830f7                                     │  │
│  └─────────────────────────────────────────────────────────────────────────────┘  │
│                                        │                                            │
│  ╔═════════════════════════════════════════════════════════════════════════════╗  │
│  ║                         CAPA DMZ (PUBLIC TIER)                              ║  │
│  ╠═════════════════════════════════════════════════════════════════════════════╣  │
│  ║                                                                             ║  │
│  ║  ┌────────────────────────────────┐  ┌────────────────────────────────┐   ║  │
│  ║  │  Subnet: dmz-public-1a         │  │  Subnet: dmz-public-1b         │   ║  │
│  ║  │  10.0.1.0/24                   │  │  10.0.2.0/24                   │   ║  │
│  ║  │  AZ: us-east-1a                │  │  AZ: us-east-1b                │   ║  │
│  ║  │  subnet-028ee447214e78ab5      │  │  subnet-0b0e1a3c9105409b3      │   ║  │
│  ║  │                                │  │                                │   ║  │
│  ║  │  ┌──────────────────────────┐ │  │  ┌──────────────────────────┐ │   ║  │
│  ║  │  │ NAT Gateway              │ │  │  │ NAT Gateway              │ │   ║  │
│  ║  │  │ sgsi-nat-gateway-az1     │ │  │  │ sgsi-nat-gateway-az2     │ │   ║  │
│  ║  │  │ nat-0c66a9d06f624f952    │ │  │  │ nat-0060517fc80d0a231    │ │   ║  │
│  ║  │  └──────────────────────────┘ │  │  └──────────────────────────┘ │   ║  │
│  ║  └────────────────────────────────┘  └────────────────────────────────┘   ║  │
│  ║                                                                             ║  │
│  ║  Security Group: sgsi-alb-sg (sg-05aa2c7930f757256)                        ║  │
│  ║  - Inbound: HTTP/HTTPS desde Internet                                      ║  │
│  ╚═════════════════════════════════════════════════════════════════════════════╝  │
│                                        │                                            │
│                                        ▼                                            │
│  ╔═════════════════════════════════════════════════════════════════════════════╗  │
│  ║                    CAPA APLICACIÓN (PRIVATE TIER)                           ║  │
│  ╠═════════════════════════════════════════════════════════════════════════════╣  │
│  ║                                                                             ║  │
│  ║  ┌────────────────────────────────┐  ┌────────────────────────────────┐   ║  │
│  ║  │  Subnet: app-private-1a        │  │  Subnet: app-private-1b        │   ║  │
│  ║  │  10.0.16.0/24                  │  │  10.0.17.0/24                  │   ║  │
│  ║  │  AZ: us-east-1a                │  │  AZ: us-east-1b                │   ║  │
│  ║  │  subnet-00484e1c92fb53d78      │  │  subnet-0c07a3d1d03d3fa67      │   ║  │
│  ║  │                                │  │                                │   ║  │
│  ║  │  ┌──────────────────────────┐ │  │  ┌──────────────────────────┐ │   ║  │
│  ║  │  │ EC2 Instance             │ │  │  │ EC2 Instance             │ │   ║  │
│  ║  │  │ sgsi-dev-web-server      │ │  │  │ sgsi-dev-web-server      │ │   ║  │
│  ║  │  │ i-0c43c9526adbe0f45      │ │  │  │ i-088a6226d69e11b2c      │ │   ║  │
│  ║  │  │ Type: t3.micro           │ │  │  │ Type: t3.micro           │ │   ║  │
│  ║  │  │ IP: 10.0.16.108          │ │  │  │ IP: 10.0.17.18           │ │   ║  │
│  ║  │  │ Status: running          │ │  │  │ Status: running          │ │   ║  │
│  ║  │  └──────────────────────────┘ │  │  └──────────────────────────┘ │   ║  │
│  ║  │                                │  │                                │   ║  │
│  ║  │  ┌──────────────────────────┐ │  │  ┌──────────────────────────┐ │   ║  │
│  ║  │  │ EFS Mount Target         │ │  │  │ EFS Mount Target         │ │   ║  │
│  ║  │  └──────────────────────────┘ │  │  └──────────────────────────┘ │   ║  │
│  ║  └────────────────────────────────┘  └────────────────────────────────┘   ║  │
│  ║                                                                             ║  │
│  ║  Security Groups:                                                           ║  │
│  ║  - sgsi-web-sg (sg-0bfdfe23f1a82ce3c) - Web Servers                        ║  │
│  ║  - sgsi-app-sg (sg-02b53c19c35397ce1) - Application Servers                ║  │
│  ╚═════════════════════════════════════════════════════════════════════════════╝  │
│                                        │                                            │
│                                        ▼                                            │
│  ╔═════════════════════════════════════════════════════════════════════════════╗  │
│  ║                     CAPA BASE DE DATOS (PRIVATE TIER)                       ║  │
│  ╠═════════════════════════════════════════════════════════════════════════════╣  │
│  ║                                                                             ║  │
│  ║  ┌────────────────────────────────┐  ┌────────────────────────────────┐   ║  │
│  ║  │  Subnet: db-private-1a         │  │  Subnet: db-private-1b         │   ║  │
│  ║  │  10.0.32.0/24                  │  │  10.0.33.0/24                  │   ║  │
│  ║  │  AZ: us-east-1a                │  │  AZ: us-east-1b                │   ║  │
│  ║  │  subnet-0b9073ea7363cde41      │  │  subnet-0002dcf9e5f3ab82e      │   ║  │
│  ║  └────────────────────────────────┘  └────────────────────────────────┘   ║  │
│  ║                                                                             ║  │
│  ║  ┌───────────────────────────────────────────────────────────────────┐    ║  │
│  ║  │  RDS PostgreSQL (Multi-AZ)                                        │    ║  │
│  ║  │  Instance: sgsi-dev-db                                            │    ║  │
│  ║  │  Engine: postgres                                                 │    ║  │
│  ║  │  Class: db.t3.micro                                               │    ║  │
│  ║  │  Multi-AZ: Enabled                                                │    ║  │
│  ║  │  Status: available                                                │    ║  │
│  ║  │  Endpoint: sgsi-dev-db.cshog2igwpch.us-east-1.rds.amazonaws.com  │    ║  │
│  ║  └───────────────────────────────────────────────────────────────────┘    ║  │
│  ║                                                                             ║  │
│  ║  Security Group: sgsi-db-sg (sg-00e2134ae19f66fc0)                         ║  │
│  ║  - Inbound: PostgreSQL (5432) desde Application Tier                       ║  │
│  ╚═════════════════════════════════════════════════════════════════════════════╝  │
│                                                                                     │
└─────────────────────────────────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────────────────────────────────┐
│                          📦 CAPA DE ALMACENAMIENTO (S3)                             │
├─────────────────────────────────────────────────────────────────────────────────────┤
│                                                                                     │
│  ┌─────────────────────────┐  ┌─────────────────────────┐  ┌──────────────────┐  │
│  │  S3 Bucket              │  │  S3 Bucket              │  │  S3 Bucket       │  │
│  │  sgsi-dev-app-data      │  │  sgsi-dev-logs          │  │  sgsi-dev-backup │  │
│  │  - Versioning: ON       │  │  - Versioning: ON       │  │  - Versioning: ON│  │
│  │  - Encryption: AES256   │  │  - Object Lock: ON      │  │  - Object Lock:ON│  │
│  │  - Lifecycle: Enabled   │  │  - CloudTrail logs      │  │  - AWS Backup    │  │
│  └─────────────────────────┘  └─────────────────────────┘  └──────────────────┘  │
│                                                                                     │
│  ┌─────────────────────────────────────────────────────────────────────────────┐  │
│  │  S3 Bucket: terraform-state-bucket-051963532279                             │  │
│  │  - Terraform State Files                                                    │  │
│  │  - DynamoDB Lock Table: terraform-locks                                     │  │
│  └─────────────────────────────────────────────────────────────────────────────┘  │
│                                                                                     │
└─────────────────────────────────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────────────────────────────────┐
│                      💾 ALMACENAMIENTO COMPARTIDO (EFS)                             │
├─────────────────────────────────────────────────────────────────────────────────────┤
│                                                                                     │
│  ┌─────────────────────────────────────────────────────────────────────────────┐  │
│  │  EFS File System: sgsi-dev-efs                                              │  │
│  │  ID: fs-08f59a55b9bbf60e4                                                   │  │
│  │  Status: available                                                          │  │
│  │  Size: 6 KB                                                                 │  │
│  │  Encryption: Enabled                                                        │  │
│  │  Mount Targets: us-east-1a, us-east-1b                                     │  │
│  └─────────────────────────────────────────────────────────────────────────────┘  │
│                                                                                     │
└─────────────────────────────────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────────────────────────────────┐
│                      🔍 CAPA DE OBSERVABILIDAD Y SEGURIDAD                          │
├─────────────────────────────────────────────────────────────────────────────────────┤
│                                                                                     │
│  ┌─────────────────────────────────────────────────────────────────────────────┐  │
│  │  CloudTrail: sgsi-audit-trail                                               │  │
│  │  - Multi-Region: Enabled                                                    │  │
│  │  - S3 Bucket: sgsi-dev-logs                                                 │  │
│  │  - Management Events: All                                                   │  │
│  │  - Status: Logging                                                          │  │
│  └─────────────────────────────────────────────────────────────────────────────┘  │
│                                                                                     │
│  ┌─────────────────────────────────────────────────────────────────────────────┐  │
│  │  CloudWatch                                                                 │  │
│  │  - Dashboard: SGSI-Security-Dashboard                                       │  │
│  │  - Alarms: CPU, Memory, Disk, Network                                       │  │
│  │  - Log Groups: /aws/ec2/sgsi-dev/httpd                                      │  │
│  └─────────────────────────────────────────────────────────────────────────────┘  │
│                                                                                     │
│  ┌─────────────────────────────────────────────────────────────────────────────┐  │
│  │  SNS Topic: sgsi-security-alerts                                            │  │
│  │  - Alarm notifications                                                      │  │
│  └─────────────────────────────────────────────────────────────────────────────┘  │
│                                                                                     │
└─────────────────────────────────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────────────────────────────────┐
│                          🔐 CAPA DE SEGURIDAD (IAM)                                 │
├─────────────────────────────────────────────────────────────────────────────────────┤
│                                                                                     │
│  ┌─────────────────────────────────────────────────────────────────────────────┐  │
│  │  IAM Policies (10 Managed Policies)                                         │  │
│  │  - github_deployment_iam         - IAM + STS Management                     │  │
│  │  - github_deployment_network     - VPC Infrastructure                       │  │
│  │  - github_deployment_cloudwatch  - Logs, Metrics, SNS                       │  │
│  │  - github_deployment_monitoring  - Security Monitoring                      │  │
│  │  - github_deployment_deployment  - CloudFormation + Terraform               │  │
│  │  - github_deployment_application - Lambda, EventBridge                      │  │
│  │  - github_deployment_database    - RDS Services                             │  │
│  │  - github_deployment_storage     - S3, EFS                                  │  │
│  │  - github_deployment_glue        - AWS Glue/ETL                             │  │
│  │  - github_deployment_compute     - ELB, ALB, ASG, EC2                       │  │
│  └─────────────────────────────────────────────────────────────────────────────┘  │
│                                                                                     │
│  ┌─────────────────────────────────────────────────────────────────────────────┐  │
│  │  IAM Role: github-actions-deployment-role                                   │  │
│  │  - OIDC Provider: token.actions.githubusercontent.com                       │  │
│  │  - Attached Policies: 10 managed policies                                   │  │
│  └─────────────────────────────────────────────────────────────────────────────┘  │
│                                                                                     │
│  ┌─────────────────────────────────────────────────────────────────────────────┐  │
│  │  Security Modules                                                           │  │
│  │  - IAM Access Analyzer: Account-level external access detection            │  │
│  │  - Password Policy: 14 chars, complexity, 90-day rotation                  │  │
│  │  - VPC Flow Logs: Network traffic monitoring                                │  │
│  │  - Network ACLs: Defense in depth                                           │  │
│  └─────────────────────────────────────────────────────────────────────────────┘  │
│                                                                                     │
└─────────────────────────────────────────────────────────────────────────────────────┘
```

---

## 📋 RESUMEN DE RECURSOS DESPLEGADOS

### 🌐 Networking (Layer 2)
| Recurso | ID/Nombre | Detalles |
|---------|-----------|----------|
| **VPC** | vpc-0c61cbedb02cd6a41 | sgsi-vpc-main (10.0.0.0/16) |
| **Internet Gateway** | igw-0d3654783b07830f7 | sgsi-igw |
| **NAT Gateway AZ1** | nat-0c66a9d06f624f952 | sgsi-nat-gateway-az1 (us-east-1a) |
| **NAT Gateway AZ2** | nat-0060517fc80d0a231 | sgsi-nat-gateway-az2 (us-east-1b) |
| **Public Subnet 1a** | subnet-028ee447214e78ab5 | dmz-public-1a (10.0.1.0/24) |
| **Public Subnet 1b** | subnet-0b0e1a3c9105409b3 | dmz-public-1b (10.0.2.0/24) |
| **Private Subnet 1a** | subnet-00484e1c92fb53d78 | app-private-1a (10.0.16.0/24) |
| **Private Subnet 1b** | subnet-0c07a3d1d03d3fa67 | app-private-1b (10.0.17.0/24) |
| **DB Subnet 1a** | subnet-0b9073ea7363cde41 | db-private-1a (10.0.32.0/24) |
| **DB Subnet 1b** | subnet-0002dcf9e5f3ab82e | db-private-1b (10.0.33.0/24) |

### 🔒 Security Groups
| Security Group | ID | Propósito |
|----------------|-----|-----------|
| **sgsi-alb-sg** | sg-05aa2c7930f757256 | Application Load Balancer (DMZ) |
| **sgsi-web-sg** | sg-0bfdfe23f1a82ce3c | Web Servers (Application Tier) |
| **sgsi-app-sg** | sg-02b53c19c35397ce1 | Application Servers |
| **sgsi-db-sg** | sg-00e2134ae19f66fc0 | Database Servers |
| **sgsi-mgmt-sg** | sg-07df87a66a7553f7d | Management & Monitoring |

### 💻 Compute (Layer 3)
| Recurso | ID | Detalles |
|---------|-----|----------|
| **EC2 Instance 1** | i-0c43c9526adbe0f45 | t3.micro, 10.0.16.108 (us-east-1a) |
| **EC2 Instance 2** | i-088a6226d69e11b2c | t3.micro, 10.0.17.18 (us-east-1b) |
| **RDS PostgreSQL** | sgsi-dev-db | db.t3.micro, Multi-AZ, Available |

### 📦 Storage (Layer 4)
| Recurso | Nombre | Características |
|---------|--------|-----------------|
| **S3 App Data** | sgsi-dev-app-data | Versioning, Encryption, Lifecycle |
| **S3 Logs** | sgsi-dev-logs | Versioning, Object Lock, CloudTrail |
| **S3 Backup** | sgsi-dev-backup | Versioning, Object Lock, AWS Backup |
| **S3 Terraform State** | terraform-state-bucket-051963532279 | State files + DynamoDB locks |
| **EFS** | fs-08f59a55b9bbf60e4 | sgsi-dev-efs, Encrypted, Multi-AZ |

### 🔍 Observability (Layer 5)
| Recurso | Nombre | Estado |
|---------|--------|--------|
| **CloudTrail** | sgsi-audit-trail | Multi-region, Logging enabled |
| **CloudWatch Dashboard** | SGSI-Security-Dashboard | Active |
| **SNS Topic** | sgsi-security-alerts | Active |
| **CloudWatch Alarms** | sgsi-high-cpu-alarm | Monitoring EC2 CPU |

---

## 🔐 FLUJO DE TRÁFICO

### Tráfico Entrante (Internet → Aplicación)
```
Internet → Internet Gateway → Public Subnets (DMZ) 
→ [ALB - NO DESPLEGADO] → EC2 Instances (App Tier)
→ RDS PostgreSQL (DB Tier)
```

### Tráfico Saliente (Aplicación → Internet)
```
EC2 Instances → NAT Gateway (AZ1/AZ2) → Internet Gateway → Internet
```

### Almacenamiento Compartido
```
EC2 Instances ↔ EFS Mount Targets (Multi-AZ)
```

---

## 📊 ARQUITECTURA DE RED

### Segmentación por Capas
- **DMZ Tier (Public):** 10.0.1.0/24, 10.0.2.0/24
- **Application Tier (Private):** 10.0.16.0/24, 10.0.17.0/24
- **Database Tier (Private):** 10.0.32.0/24, 10.0.33.0/24

### Alta Disponibilidad
- ✅ Multi-AZ deployment (us-east-1a, us-east-1b)
- ✅ 2 NAT Gateways (uno por AZ)
- ✅ 2 EC2 Instances (distribuidas en AZs)
- ✅ RDS Multi-AZ (failover automático)
- ✅ EFS Multi-AZ (mount targets en ambas AZs)

---

## 🛡️ COMPLIANCE Y SEGURIDAD

### ISO 27001 Controls Implementados
- **A.13.1.1** - Network controls (VPC, Subnets, NACLs)
- **A.13.1.2** - Security of network services (Security Groups)
- **A.13.1.3** - Segregation in networks (3-tier architecture)
- **A.12.4.1** - Event logging (CloudTrail, VPC Flow Logs)
- **A.17.2.1** - Availability (Multi-AZ, Auto Scaling)
- **A.12.3.1** - Backup (AWS Backup, S3 versioning)

### NIST CSF Controls
- **PR.IP-1** - Baseline configuration (Terraform IaC)
- **PR.DS-1** - Data-at-rest protection (Encryption)
- **DE.CM-1** - Network monitoring (VPC Flow Logs)
- **DE.AE-3** - Event correlation (CloudWatch, CloudTrail)

---

## 📝 NOTAS IMPORTANTES

1. **ALB No Desplegado:** El Application Load Balancer está configurado pero no desplegado debido a restricciones de la cuenta AWS Academy.

2. **Auto Scaling Group:** Las instancias EC2 están gestionadas por ASG con capacidad de escalar entre 2-4 instancias.

3. **Backup Strategy:** AWS Backup configurado con retención de 7/30/365 días (diario/semanal/mensual).

4. **Encryption:** Todos los recursos de almacenamiento usan encriptación (S3, EFS, RDS).

5. **Monitoring:** CloudWatch alarms configuradas para CPU, memoria, disco y métricas de red.

---

**Generado desde:** AWS CLI  
**Usuario:** darwin.lopez  
**Fecha:** 2025
