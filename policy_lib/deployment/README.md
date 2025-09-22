# Deployment Policy Library

## Overview
Esta carpeta contiene **building blocks** de políticas IAM para operaciones de **deployment** usando **ABAC** (Attribute-Based Access Control).

## Arquitectura Migrada

### ✅ **ANTES (Inconsistente)**
```
deployment/
├── MCI-Deployment-TerraformCore.json     ❌ JSON estático
├── MCI-Deployment-S3Analytics.json       ❌ JSON estático  
├── MCI-Deployment-CloudFormation.json    ❌ JSON estático
├── MCI-Deployment-Lambda.json            ❌ JSON estático
└── MCI-Deployment-Logs.json              ❌ JSON estático
```

### ✅ **AHORA (Consistente)**
```
deployment/
├── main.tf                               ✅ Building blocks Terraform
├── variables.tf                          ✅ Variables ABAC
├── outputs.tf                            ✅ Outputs reutilizables
└── README.md                             ✅ Documentación
```

## Políticas Disponibles

### **Individuales**
- `terraform_core_deployment` - Core Terraform operations
- `s3_analytics_deployment` - S3 analytics configuration
- `cloudformation_deployment` - CloudFormation stack management
- `lambda_deployment` - Lambda function deployment
- `logs_deployment` - CloudWatch logs management

### **Combinadas**
- `full_deployment_access` - Todas las políticas combinadas
- `basic_deployment_access` - CloudFormation + Lambda + Logs

## Uso en Terraform

```hcl
# Usar building block individual
module "terraform_deployment" {
  source = "./policy_lib/deployment"
  
  department  = "MCI"
  environment = "prod"
}

# Crear policy usando building block
resource "aws_iam_policy" "terraform_core" {
  name   = "MCI-Deployment-TerraformCore"
  policy = module.terraform_deployment.terraform_core_deployment_policy
  
  tags = {
    Department  = "MCI"
    Environment = "prod"
    PolicyType  = "Deployment"
  }
}
```

## Variables ABAC

| Variable | Descripción | Valores Permitidos |
|----------|-------------|--------------------|
| `department` | Gerencia/Department | `MCI`, `sistemas`, `data-analytics` |
| `environment` | Ambiente | `dev`, `qa`, `prod` |
| `policy_prefix` | Prefijo de políticas | `MCI-Deployment` (default) |

## Condiciones ABAC

Todas las políticas incluyen:

```hcl
condition {
  test     = "StringEquals"
  variable = "aws:PrincipalTag/Department"
  values   = [var.department]
}

condition {
  test     = "StringEquals" 
  variable = "aws:PrincipalTag/Environment"
  values   = [var.environment]
}
```

## Recursos con Naming Convention

```hcl
# S3 Buckets
"arn:aws:s3:::${department}-${environment}-*"

# Lambda Functions  
"arn:aws:lambda:*:*:function:${department}-${environment}-*"

# CloudFormation Stacks
"arn:aws:cloudformation:*:*:stack/${department}-${environment}-*/*"

# Log Groups
"arn:aws:logs:*:*:log-group:/aws/lambda/${department}-${environment}-*"
```

## Integración con Scripts

Los scripts enterprise pueden referenciar estas políticas:

```python
# create_role_scalable.py
deployment_policies = [
    module.deployment.terraform_core_deployment_policy,
    module.deployment.lambda_deployment_policy
]
```

## Validación

```bash
# Terraform validate
terraform validate

# Checkov security scan
checkov -f main.tf

# Enterprise validation
python scripts/iam_lint.py --check-deployment
```
- **Uso**: Deploy de infraestructura principal

### 2. **MCI-Deployment-S3Analytics**
- **Propósito**: Permisos para buckets S3 de analytics
- **Permisos**: Operaciones completas en buckets `s3-data-analytics-*`
- **Restricción**: Solo región `us-east-1`
- **Uso**: Deploy de buckets y objetos de analytics

### 3. **MCI-Deployment-CloudFormation**
- **Propósito**: Permisos para stacks de CloudFormation
- **Permisos**: CRUD completo en stacks + operaciones de consulta
- **Restricción**: Solo región `us-east-1`
- **Uso**: Deploy de infraestructura con CloudFormation

### 4. **MCI-Deployment-Lambda**
- **Propósito**: Permisos para funciones Lambda
- **Permisos**: CRUD de funciones + PassRole para roles `rol-mci-*`
- **Restricción**: Solo funciones en `us-east-1` y cuenta `393209814297`
- **Uso**: Deploy de funciones Lambda

### 5. **MCI-Deployment-Logs**
- **Propósito**: Permisos para CloudWatch Logs
- **Permisos**: Crear y gestionar log groups/streams
- **Restricción**: Solo región `us-east-1` y cuenta `393209814297`
- **Uso**: Logging para aplicaciones desplegadas

## 🔒 Características de Seguridad

- **SOX Compliance**: Todas las políticas marcadas como SOX compliant
- **Least Privilege**: Permisos mínimos necesarios para deployment
- **Resource-Based**: Restricciones específicas por recurso y región
- **Audit Trail**: Tags completos para trazabilidad

## 🏗️ Integración con GitHub Actions

Estas políticas están diseñadas para ser utilizadas por el rol:
```
arn:aws:iam::393209814297:role/GitHubActions-MCI-IAM-Role
```

### Workflow Integration
El workflow `validate-and-deploy-clean.yml` valida automáticamente la existencia de estas políticas después del deployment.

## 📦 Estructura de Archivos

```
policy_lib/deployment/
├── MCI-Deployment-TerraformCore.json     # Permisos IAM/Organizations
├── MCI-Deployment-S3Analytics.json      # Permisos S3 analytics
├── MCI-Deployment-CloudFormation.json   # Permisos CloudFormation
├── MCI-Deployment-Lambda.json           # Permisos Lambda + PassRole
├── MCI-Deployment-Logs.json             # Permisos CloudWatch Logs
└── README.md                            # Esta documentación
```

## 🚀 Uso Recomendado

1. **Rol de GitHub Actions**: Anexar todas las políticas al rol de deployment
2. **Terraform**: Referenciar desde `modules/iam-attachments/`
3. **Validación**: El workflow automáticamente valida su existencia
4. **Auditoria**: Revisar logs de CloudTrail para uso de permisos

## ⚠️ Consideraciones Importantes

- **Solo para Deployment**: Estas políticas NO son para uso por aplicaciones
- **Ambiente Prod**: Configuradas para deployment en todos los ambientes
- **Monitoreo**: Configurar alertas en CloudTrail para uso anómalo
- **Rotación**: Revisar permisos cada 6 meses

## 📞 Soporte

- **Propietario**: Darwin López (darwin.lopez@claro.com.gt)
- **Equipo**: MCI Infrastructure Team
- **Documentación**: Ver `docs/DEPLOYMENT.md` para más detalles