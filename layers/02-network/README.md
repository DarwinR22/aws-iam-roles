# Layer 2: Network Infrastructure - Complete SGSI Implementation

## 📋 Overview

Layer 2 provides a comprehensive, enterprise-grade network infrastructure with **100% SGSI compliance**, implementing defense-in-depth security principles, high availability, and comprehensive monitoring capabilities.

## 🏗️ Architecture

### Network Segmentation (3-Tier)

```
┌─────────────────────────────────────────────────────────────┐
│                        INTERNET                              │
└───────────────────────┬─────────────────────────────────────┘
                        │
             ┌──────────▼──────────┐
             │  Internet Gateway   │
             └──────────┬──────────┘
                        │
        ┌───────────────┴───────────────┐
        │   DMZ TIER (Public Subnets)   │
        │  - ALB (Load Balancer)        │
        │  - NAT Gateways (2x HA)       │
        │  - Bastion Hosts              │
        │  CIDR: 10.0.1.0/24 (AZ1)      │
        │  CIDR: 10.0.2.0/24 (AZ2)      │
        └───────────────┬───────────────┘
                        │
        ┌───────────────▼───────────────┐
        │  APP TIER (Private Subnets)   │
        │  - Web Servers                │
        │  - Application Servers        │
        │  - Lambda Functions           │
        │  CIDR: 10.0.16.0/24 (AZ1)     │
        │  CIDR: 10.0.17.0/24 (AZ2)     │
        └───────────────┬───────────────┘
                        │
        ┌───────────────▼───────────────┐
        │  DB TIER (Private Subnets)    │
        │  - RDS Instances              │
        │  - ElastiCache                │
        │  - Secrets Manager            │
        │  CIDR: 10.0.32.0/24 (AZ1)     │
        │  CIDR: 10.0.33.0/24 (AZ2)     │
        └───────────────────────────────┘
```

## 🔒 Security Features Implemented

### 1. **VPC Flow Logs** ✅
- **Purpose**: Comprehensive network traffic monitoring and auditing
- **Scope**: ALL traffic (ACCEPT + REJECT)
- **Retention**: 90 days
- **Features**:
  - CloudWatch Logs integration
  - Metric filters for suspicious activity
  - Alarms for:
    - High rejected traffic (threshold: 100 connections)
    - SSH access from internet
- **Compliance**: ISO 27001 A.13.1.1, NIST CSF DE.AE-3

### 2. **NAT Gateways High Availability** ✅
- **Configuration**: Multi-AZ (2 NAT Gateways)
- **Availability Zones**: us-east-1a, us-east-1b
- **Features**:
  - Dedicated Elastic IPs per AZ
  - Automatic failover capability
  - Separate route tables per AZ
  - CloudWatch monitoring for each NAT Gateway
- **Compliance**: ISO 27001 A.17.2.1, NIST CSF PR.IP-12

### 3. **Network ACLs (Defense in Depth)** ✅
- **Layers**: 3 NACLs (DMZ, Application, Database)
- **Purpose**: Subnet-level firewall (additional to Security Groups)
- **Rules**:
  - **DMZ NACL**: HTTP/HTTPS inbound, restrictive outbound
  - **App NACL**: Internal traffic only, DB access allowed
  - **DB NACL**: Most restrictive, only DB ports allowed
  - **Deny Rules**: Telnet (23), RDP (3389), SMB (445)
- **Compliance**: ISO 27001 A.13.1.1

### 4. **VPC Endpoints** ✅
- **Gateway Endpoints**:
  - S3 (restricted to terraform-state-bucket)
  - DynamoDB (restricted to terraform-locks table)
- **Benefits**:
  - No internet exposure for AWS service access
  - Reduced data transfer costs
  - Lower latency
- **Optional Interface Endpoints**:
  - Secrets Manager (disabled by default)
  - KMS (disabled by default)

### 5. **Security Groups** ✅
- **Total**: 5 Security Groups
- **Tiers**:
  - `sgsi-alb-sg`: ALB tier (HTTP/HTTPS from internet)
  - `sgsi-web-sg`: Web servers (traffic from ALB only)
  - `sgsi-app-sg`: Application servers (traffic from web tier)
  - `sgsi-db-sg`: Database tier (most restrictive)
  - `sgsi-mgmt-sg`: Management/monitoring tier

## 📊 Modules Structure

```
modules/network/
├── vpc-flow-logs/
│   ├── main.tf         # Flow logs, CloudWatch, IAM role
│   ├── variables.tf    # Configuration options
│   └── outputs.tf      # Flow log info, alarms
├── nat-gateway-ha/
│   ├── main.tf         # NAT Gateways, EIPs, route tables
│   ├── variables.tf    # AZ configuration
│   └── outputs.tf      # NAT IPs, route table IDs
├── network-acls/
│   ├── main.tf         # NACLs for DMZ/App/DB tiers
│   ├── variables.tf    # Subnet associations
│   └── outputs.tf      # NACL IDs
└── vpc-endpoints/
    ├── main.tf         # S3, DynamoDB, optional endpoints
    ├── variables.tf    # Endpoint configuration
    └── outputs.tf      # Endpoint IDs
```

## 🎯 Compliance Mapping

### ISO 27001:2013
- **A.13.1.1**: Network Controls - ✅ Implemented
  - VPC segmentation
  - Security Groups
  - Network ACLs
  - VPC Flow Logs
- **A.13.1.2**: Security of Network Services - ✅ Implemented
  - VPC Endpoints (no internet exposure)
  - Private subnets
- **A.13.2.1**: Information Transfer Policies - ✅ Implemented
  - Encrypted connections (TLS)
  - Traffic monitoring
- **A.16.1.2**: Reporting Security Events - ✅ Implemented
  - CloudWatch alarms
  - VPC Flow Logs
- **A.17.2.1**: Availability - ✅ Implemented
  - Multi-AZ NAT Gateways
  - Redundant subnets

### NIST Cybersecurity Framework
- **PR.AC-5**: Network Integrity - ✅ Implemented
  - Network segmentation
  - Access control lists
- **DE.AE-3**: Event Data Aggregation - ✅ Implemented
  - VPC Flow Logs aggregation
  - CloudWatch Logs
- **DE.CM-1**: Network Monitoring - ✅ Implemented
  - Flow logs monitoring
  - CloudWatch alarms
- **PR.IP-12**: Backup Capability - ✅ Implemented
  - Multi-AZ redundancy

## 🚀 Deployment

### Prerequisites
- Layer 1 (Foundation) deployed
- AWS credentials configured
- Terraform >= 1.5.0

### Deploy
```bash
cd layers/02-network
terraform init
terraform plan
terraform apply
```

### Validate
```bash
# Validate Layer 2 deployment
python validate_sgsi_layers.py --layer 2

# Check VPC Flow Logs
aws logs describe-log-groups --log-group-name-prefix "/aws/vpc/flowlogs"

# Check NAT Gateways
aws ec2 describe-nat-gateways --filter "Name=state,Values=available"

# Check VPC Endpoints
aws ec2 describe-vpc-endpoints
```

## 📈 Monitoring & Alerts

### CloudWatch Alarms
1. **High Rejected Traffic**
   - Metric: RejectedTraffic
   - Threshold: > 100 connections
   - Period: 5 minutes
   - Action: SNS notification (if configured)

2. **SSH from Internet**
   - Metric: SSHFromInternet
   - Threshold: > 1 connection
   - Period: 5 minutes
   - Severity: Critical

3. **NAT Gateway Connectivity**
   - Metric: BytesOutToDestination
   - Threshold: < 1000 bytes
   - Purpose: Detect NAT Gateway issues

### Log Queries
```bash
# Query rejected connections
aws logs filter-log-events \
  --log-group-name "/aws/vpc/flowlogs/sgsi-vpc-main" \
  --filter-pattern "[version, account, eni, source, destination, srcport, destport, protocol, packets, bytes, windowstart, windowend, action=REJECT, flowlogstatus]"

# Query SSH attempts from internet
aws logs filter-log-events \
  --log-group-name "/aws/vpc/flowlogs/sgsi-vpc-main" \
  --filter-pattern "[version, account, eni, source!=10.*, destination, srcport, destport=22, protocol=6]"
```

## 🔧 Configuration Options

### VPC Flow Logs
```hcl
module "vpc_flow_logs" {
  traffic_type       = "ALL"      # ACCEPT, REJECT, or ALL
  log_retention_days = 90         # 1-3653 days
  enable_rejected_traffic_alarm = true
  enable_ssh_monitoring = true
  alarm_actions = []  # Add SNS topic ARNs
}
```

### NAT Gateways
```hcl
module "nat_gateway_ha" {
  availability_zones = ["us-east-1a", "us-east-1b"]
  enable_monitoring  = true
  min_bytes_threshold = 1000
}
```

### VPC Endpoints
```hcl
module "vpc_endpoints" {
  allowed_s3_buckets = ["terraform-state-bucket-051963532279"]
  allowed_dynamodb_tables = ["terraform-locks"]
  enable_secrets_manager_endpoint = false
  enable_kms_endpoint = false
}
```

## 📊 Outputs

### Key Outputs
- `vpc_id`: VPC identifier
- `public_subnet_ids`: DMZ subnet IDs
- `app_private_subnet_ids`: Application subnet IDs
- `db_private_subnet_ids`: Database subnet IDs
- `security_group_ids`: Map of all security groups
- `nat_gateways`: NAT Gateway IDs and public IPs
- `vpc_flow_logs`: Flow logs configuration
- `vpc_endpoints`: VPC endpoint IDs
- `layer2_compliance_summary`: Complete compliance status

## 🎓 SGSI Academic Project

### Completion Status
- **Layer 2 Compliance**: **100%** ✅
- **Security Features**: 6/6 implemented
- **High Availability**: Multi-AZ redundancy
- **Monitoring**: Comprehensive CloudWatch integration
- **Defense Layers**: 2 (Security Groups + NACLs)

### Key Achievements
1. ✅ Complete network segmentation (DMZ, App, DB)
2. ✅ VPC Flow Logs for traffic analysis
3. ✅ High Availability NAT Gateways
4. ✅ Network ACLs (defense in depth)
5. ✅ VPC Endpoints (cost + security)
6. ✅ Comprehensive security groups

## 🔄 Next Steps

### Layer 3: Compute (Next Priority)
- ALB + Target Groups
- Auto Scaling Groups
- EC2 instances
- RDS Multi-AZ

### Layer 5: Observability (High Impact)
- GuardDuty (IDS/IPS) → SGSI requirement
- Security Hub (SIEM) → SGSI requirement
- Inspector (vulnerability scanning)
- Macie (data security)

## 📚 References

- [AWS VPC Best Practices](https://docs.aws.amazon.com/vpc/latest/userguide/vpc-security-best-practices.html)
- [AWS VPC Flow Logs](https://docs.aws.amazon.com/vpc/latest/userguide/flow-logs.html)
- [ISO 27001:2013 Annex A.13](https://www.iso.org/standard/54533.html)
- [NIST Cybersecurity Framework](https://www.nist.gov/cyberframework)

---

**Ready for deployment** ✅

*Last updated: November 26, 2025 - Layer 2 deployment triggered*
