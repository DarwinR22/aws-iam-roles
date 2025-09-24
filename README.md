# MCI AWS IAM Enterprise Architecture

[![Terraform CI](https://github.com/ClaroCENAM/mci-aws-iam/workflows/Enterprise%20IAM%20Terraform%20CI/badge.svg)](https://github.com/ClaroCENAM/mci-aws-iam/actions)
[![Security Scan](https://github.com/ClaroCENAM/mci-aws-iam/workflows/Security%20Validation/badge.svg)](https://github.com/ClaroCENAM/mci-aws-iam/actions)
[![Drift Detection](https://github.com/ClaroCENAM/mci-aws-iam/workflows/Drift%20Detection/badge.svg)](https://github.com/ClaroCENAM/mci-aws-iam/actions)

**Enterprise-grade IAM management with Attribute-Based Access Control (ABAC), automated governance, and comprehensive security guardrails for Claro CENAM.**

> 🔐 **NEW**: Enterprise KMS encryption implemented! Customer-managed keys now secure DynamoDB state locks and S3 Terraform state with automatic key rotation and optimized costs.

> 🎯 **UPDATE**: Intelligent drift detection now differentiates between CI/CD managed resources (auto-cleanup) vs manually created resources (report-only) for enhanced safety.

## 🏗️ Architecture Overview

This repository implements a **zero-trust, tag-based ABAC architecture** for AWS IAM management with enterprise governance and compliance capabilities.

### 📦 **Clean Enterprise Structure**

```
📦 mci-aws-iam/
├── 🧱 policy_lib/          # ABAC building blocks (S3, DynamoDB, Lambda)
├── 📋 catalog/             # Single source of truth (roles.yaml, policies.yaml)
├── 🏢 gerencias/           # Organizational structure with roles
├── 🔧 modules/             # Terraform enterprise modules  
├── 🌍 environments/        # Environment-specific configs (dev/qa/prod)
├── 🛡️ guardrails/          # Security validation & compliance
├── � ci/                  # GitHub Actions workflows
├── 📝 docs/                # Enterprise documentation
└── 🚀 scripts/create_role_dinamico_clean.py  # Role creation tool
```

### 🎯 **Key Features**
- ✅ **Tag-Based ABAC Policies** → Auto-scaling access control
- ✅ **Organizational Structure Detection** → Dynamic role management
- ✅ **25+ Mandatory Tags Governance** → Complete compliance
- ✅ **Building Blocks Integration** → Reusable MCI policies
- ✅ **Multi-Environment Support** → dev/qa/prod workflows

## ✅ Estado del Proyecto

**Repositorio PRODUCTION-READY** - Arquitectura empresarial tag-based operativa:

- ✅ **CI/CD Completo** - Validación → Plan → Deploy → Verificación automática
- ✅ **Backend S3/DynamoDB** - Estado centralizado y locks de Terraform
- ✅ **Tag-Based Policies** - 4 políticas inteligentes escalables automáticamente  
- ✅ **Auto-discovery** - Encuentra automáticamente archivos de roles/políticas
- ✅ **Multi-ambiente** - dev/qa/prod con separación automática por tags
- 🆕 **Drift Detection** - Sistema empresarial de detección y limpieza automática
- � **GitHub Notifications** - Reportes automáticos como comentarios en PR/Issues
- 🔄 **CI/CD Integration** - Deployment automático con verificaciones pre/post
- 🛡️ **Enterprise Safety** - Protección de recursos críticos y thresholds inteligentes

---

## 🏗️ Estructura Organizacional

### Flexibilidad Total para Desarrolladores

Los desarrolladores **crean su propia estructura** como prefieran. El sistema **automáticamente detecta** cualquier archivo JSON de rol:

```
MCI/                        # Estructura principal
├── BI/
│   ├── mi_primer_rol.json          # Tu primer rol IAM
│   └── politicas/                  # Políticas compartidas
│       └── policy-s3-read.json
├── Finanzas/
│   ├── contabilidad/
│   │   └── rol-erp-api-prod.json
│   └── politicas/
│       └── policy-dynamodb-finance.json
└── IT/
    └── infraestructura/
        └── rol-terraform-prod.json
```

### ✅ Ventajas del Enfoque Flexible

- **🆓 Libertad Total**: Cada equipo organiza como quiera
- **🔄 Reutilización**: Carpeta `politicas/` para políticas compartidas  
- **🎯 Detección Automática**: GitHub Actions encuentra todos los `*.json`
- **📊 Sin Restricciones**: Cualquier estructura de carpetas funciona

---

## 🎯 Políticas Genéricas Reutilizables (Sistema MCI-*)

### ✨ **POLÍTICAS V2**: Catálogo Modular ABAC

El repositorio implementa **políticas ABAC** con control basado en tags desde el catálogo V2:

```
catalog/v2/services/
├── s3.yaml                        # Políticas S3 ABAC
│   ├── MCI-S3-TagBased-ReadOnly   # ✅ Acceso por tags coincidentes
│   ├── MCI-S3-TagBased-Write      # ✅ Escritura por tags coincidentes
│   ├── MCI-S3-ReadOnly            # ✅ Lectura básica S3
│   └── MCI-S3-Write               # ✅ Escritura básica S3
└── deployment.yaml                # Políticas deployment
    ├── MCI-Deployment-TerraformCore
    ├── MCI-Deployment-S3Analytics
    └── MCI-Deployment-CloudFormation
```

### 🚀 Uso en Roles

**Referencia las políticas del catálogo V2**:

```json
{
  "role_name": "rol-lambda-api-dev-processor",
  "policies": {
    "aws_managed": [
      "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
    ],
    "custom": [
      "MCI-S3-TagBased-ReadOnly",
      "MCI-Deployment-TerraformCore"
    ]
  }
}
```

### ✅ Ventajas del Sistema V2 ABAC

- **🏷️ Tag-Based Security**: Solo acceso a recursos con tags coincidentes
- **� Catálogo Modular**: Políticas organizadas por servicio
- **🛡️ Zero-Trust**: Principio de menor privilegio automático
- **⚡ Escalabilidad**: Agregar servicios sin modificar código
- **🔧 Governance**: Tags obligatorios para compliance

---

## 🚀 Uso Rápido (Para Desarrolladores)

## 🏁 Setup Inicial (Solo Primera Vez)

**Para nuevos desarrolladores que clonan el repositorio:**

### 1. Clonar y configurar
```bash
git clone https://github.com/ClaroCENAM/mci-aws-iam.git
cd mci-aws-iam
```

### 2. Configurar credenciales AWS
```bash
# Opción A: AWS CLI (Recomendado)
aws configure

# Opción B: Variables de ambiente
export AWS_ACCESS_KEY_ID=tu_access_key
export AWS_SECRET_ACCESS_KEY=tu_secret_key
export AWS_DEFAULT_REGION=us-east-1
```

### 3. Inicializar Terraform (OBLIGATORIO)
```bash
# Opción A: Usando Makefile (Recomendado)
make setup    # ← Un solo comando, hace todo

# Opción B: Manual
cd environments/dev
terraform init    # ← NECESARIO siempre al clonar
terraform plan    # Verificar configuración
```

### 4. ¡Listo para usar!
```bash
# Crear roles interactivamente
python scripts/create_role.py

# O crear manualmente
mkdir -p MCI/TuEquipo
# ... editar archivos JSON
```

### 5. ¡Recibe Notificaciones Automáticas! (Opcional pero Recomendado)
```bash
# NO necesitas configurar nada extra
# El sistema usa las notificaciones GitHub que ya recibes

# Para probar:
# GitHub Actions → Test GitHub Notifications
```

� **Sistema de Notificaciones Inteligente**: Recibe reportes automáticos de drift detection directamente en GitHub como comentarios en PR o Issues. **Cero configuración** - usa las notificaciones que ya tienes.

---

## 🔄 Uso Diario (Desarrolladores Existentes)

### 1. Crear tu primer rol

```bash
# Opción 1: Usar script interactivo (Recomendado)
python scripts/create_role.py

# Opción 2: Crear manualmente
mkdir -p MCI/TuEquipo
cd MCI/TuEquipo
cp ../BI/mi_primer_rol.json mi-nuevo-rol.json
```

### 2. Editar configuración

```json
{
  "role_name": "rol-lambda-api-dev-processor",
  "description": "Mi rol para función Lambda",
  "trust_policy": {
    "Version": "2012-10-17",
    "Statement": [{
      "Effect": "Allow",
      "Principal": { "Service": "lambda.amazonaws.com" },
      "Action": "sts:AssumeRole"
    }]
  },
  "policies": {
    "aws_managed": [
      "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
    ],
    "custom": [
      "MCI-S3-TagBased-ReadOnly",
      "MCI-Deployment-TerraformCore"
    ]
  },
  "tags": {
    "ambiente": "dev",
    "pais": "GT",
    "direccion": "TICenam",
    "gerencia": "IT",
    "cuenta": "Desarrollo",
    "modulo": "Aplicacion",
    "alcance_sox": "No",
    "propietario": "TuNombre",
    "proveedor": "Interno",
    "layer": "api",
    "dominio": "Microservicios",
    "subdominio": "Auth",
    "aplicacion": "user-auth-api",
    "soporte": "DevOps",
    "contacto": "tu-email@empresa.com",
    "proyecto": "AuthMicroservice",
    "creado_por": "TuNombre",
    "ciclo_vida": "Creacion",
    "version": "1.0.0"
  }
}
```

### 3. Commit y Deploy

```bash
git add .
git commit -m "feat: agregar rol lambda processor"
git push origin dev
```

**¡Eso es todo!** 🎉 GitHub Actions automáticamente:
- ✅ Valida tu configuración
- ✅ Planifica los cambios
- ✅ Despliega a AWS  
- ✅ Verifica el resultado

---

## 🛠️ Configuración Inicial (Solo Administradores)

### 1. Setup AWS (Una sola vez)

```bash
# Para Windows
.\setup-aws-admin.bat

# Para Linux/Mac  
./setup-aws-admin.sh
```

Esto crea automáticamente:
- ✅ Bucket S3 para estado de Terraform
- ✅ Tabla DynamoDB para locks
- ✅ Rol IAM para GitHub Actions con OIDC
- ✅ Políticas y permisos necesarios

### 2. Configurar GitHub Secrets

**Repository Settings → Secrets and variables → Actions:**

| Secret Name | Value |
|-------------|-------|
| `AWS_ROLE_ARN` | `arn:aws:iam::ACCOUNT:role/github-actions-iam-deployment-role` |

### 3. ¡Listo para usar! 

Los desarrolladores ya pueden crear roles sin necesidad de AWS CLI, Terraform, o Python instalados.

---

## 🏢 Arquitectura Empresarial

### 🔍 Sistema de Drift Detection

**Detección inteligente de recursos huérfanos y discrepancias**:

```
Pre-Deployment     │ Deployment      │ Post-Deployment
                   │                 │
┌─────────────────┐ │ ┌─────────────┐ │ ┌─────────────────┐
│ • Scan AWS      │ │ │ • Apply TF  │ │ │ • Verify State  │
│ • Find Orphans  │─┼▶│ • Clean Up  │─┼▶│ • Send Report   │
│ • Generate      │ │ │ • Deploy    │ │ │ • Email Alerts  │
│   Cleanup       │ │ │             │ │ │                 │
└─────────────────┘ │ └─────────────┘ │ └─────────────────┘
```

### � Sistema de Notificaciones

**Reportes automáticos directamente en GitHub**:

| Tipo | Ubicación | Notificación | Configuración |
|------|-----------|--------------|---------------|
| � **PR Comments** | Comentarios en Pull Request | ✅ Automática GitHub | ✅ Cero configuración |
| 📋 **Issues** | Nuevo Issue en repositorio | ✅ Automática GitHub | ✅ Cero configuración |
| 🔍 **Artifacts** | Archivos descargables | ✅ En workflow | ✅ Siempre disponible |

### 🛡️ Protecciones Empresariales

- **Recursos protegidos**: Roles/políticas críticos nunca se eliminan
- **Thresholds inteligentes**: Límites automáticos para prevenir errores masivos
- **Auditoría completa**: Logs detallados de todas las operaciones
- **Rollback automático**: Reversión en caso de fallos críticos

---

## 🔧 Convenciones

### Nombres de Roles
```
rol-[servicio]-[layer]-[ambiente]-[nombre]
```

**Ejemplos:**
- `rol-lambda-api-dev-processor`
- `rol-s3-data-qa-analytics`
- `rol-glue-etl-prod-transformer`

### Tags Obligatorios (19 total)
```json
{
  "ambiente": "dev|qa|prod",
  "pais": "GT|SV|NI|HN|CR|RG", 
  "direccion": "Tecnologia",
  "gerencia": "IT",
  "cuenta": "Desarrollo",
  "modulo": "Aplicacion|DB|POC",
  "alcance_sox": "Si|No",
  "propietario": "NombreApellido",
  "proveedor": "Interno|Externo",
  "layer": "api|data|infrastructure",
  "dominio": "Microservicios",
  "subdominio": "Auth",
  "aplicacion": "user-auth-api", 
  "soporte": "DevOps",
  "contacto": "email@empresa.com",
  "proyecto": "ProjectName",
  "creado_por": "NombreApellido",
  "ciclo_vida": "Creacion|Actualizacion|Eliminacion",
  "version": "1.0.0"
}
```

### Políticas Personalizadas

**RECOMENDADO**: Usar las políticas genéricas `MCI-*` (ver sección anterior)

**Para casos especiales**, crear políticas custom:
```json
# Archivo: politicas/policy-s3-read.json
{
  "Version": "2012-10-17",
  "Statement": [{
    "Effect": "Allow",
    "Action": ["s3:GetObject", "s3:ListBucket"],
    "Resource": ["arn:aws:s3:::mi-bucket/*"]
  }]
}
```

### Scripts Auxiliares

**Generador Interactivo de Roles**:
```bash
python scripts/create_role.py
```

El script te guía paso a paso:
- ✅ Selecciona dirección (TICenam como opción principal)
- ✅ Configura proyecto y proveedor
- ✅ Formatea nombres automáticamente (Darwin Lopez → DarwinLopez)
- ✅ Aplica convenciones de naming
- ✅ Crea archivo JSON listo para usar

---

## 📋 Pipeline de Deployment

### Estados del Workflow

1. **🔍 Validate** - Validación de archivos JSON y convenciones
2. **📋 Plan** - Terraform plan y previsualización de cambios  
3. **🚀 Deploy** - Creación/actualización de recursos en AWS
4. **✅ Verify** - Verificación de deployment exitoso

### Triggers Automáticos

- **Push a `dev`** → Deploy a ambiente dev
- **Push a `qa`** → Deploy a ambiente qa  
- **Push a `main`** → Deploy a ambiente prod
- **Manual trigger** → Deploy a ambiente seleccionado

### Duración Esperada
- **Validación**: ~30 segundos
- **Plan**: ~2-3 minutos
- **Deploy**: ~3-4 minutos
- **Verify**: ~1-2 minutos
- **Total**: ~6-9 minutos

---

## 🆘 Solución de Problemas

### ❌ "Tag obligatorio faltante"
```bash
Tags obligatorios faltantes: alcance_sox, propietario
```
**Solución**: Completar todos los 19 tags en el archivo JSON.

### ❌ "Nombre de rol inválido" 
```bash
# ❌ Incorrecto
rol-Lambda-API-dev-processor

# ✅ Correcto
rol-lambda-api-dev-processor  
```

### ❌ "Backend configuration failed"
```bash
# Verificar configuración AWS
aws sts get-caller-identity
```

### ❌ "Policy not found"
```bash
# Verificar que el archivo de política existe
ls politicas/policy-s3-read.json
```

---

## 🎯 Casos de Uso Comunes

### Lambda Function con MCI-* Policies
```json
{
  "role_name": "rol-lambda-api-dev-auth",
  "trust_policy": {
    "Statement": [{
      "Principal": { "Service": "lambda.amazonaws.com" }
    }]
  },
  "policies": {
    "aws_managed": [
      "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
    ],
    "custom": [
      "MCI-S3-TagBased-ReadOnly",
      "MCI-Deployment-TerraformCore"
    ]
  }
}
```

### EC2 Instance con Políticas Genéricas
```json
{
  "role_name": "rol-ec2-web-prod-server",
  "trust_policy": {
    "Statement": [{
      "Principal": { "Service": "ec2.amazonaws.com" }
    }]
  },
  "policies": {
    "aws_managed": [
      "arn:aws:iam::aws:policy/CloudWatchAgentServerPolicy"
    ],
    "custom": [
      "MCI-S3-TagBased-Write",
      "MCI-Deployment-TerraformCore"
    ]
  }
}
```

### Glue ETL Job con DynamoDB
```json
{
  "role_name": "rol-glue-etl-dev-processor",
  "trust_policy": {
    "Statement": [{
      "Principal": { "Service": "glue.amazonaws.com" }
    }]
  },
  "policies": {
    "aws_managed": [
      "arn:aws:iam::aws:policy/service-role/AWSGlueServiceRole"
    ],
    "custom": [
      "MCI-S3-TagBased-Write",
      "MCI-Deployment-S3Analytics"
    ]
  }
}
```

---

## 🏆 Beneficios

### ✅ Para Desarrolladores
- **Sin dependencias locales** - Todo funciona vía GitHub Actions
- **Generación automática** - Solo editar JSON y hacer commit
- **Validación continua** - Detecta errores antes del deploy
- **Templates reutilizables** - Copiar y adaptar roles existentes

### ✅ Para DevOps
- **CI/CD completo** - Deploy automático en 3 ambientes
- **Estado centralizado** - Backend S3 con locks DynamoDB
- **Rollback seguro** - Historial completo en Git + Terraform
- **Monitoreo** - Logs detallados de cada deployment

### ✅ Para Seguridad  
- **Tags obligatorios** - Trazabilidad completa de recursos
- **Naming convention** - Identificación clara y consistente
- **Principio de menor privilegio** - Validaciones automáticas
- **Auditabilidad** - Cada cambio documentado y versionado

---

## 📚 Documentación Adicional

- [📖 Convenciones Detalladas](docs/CONVENTIONS.md)
- [🚀 Guía de Despliegue](docs/DEPLOYMENT.md) 
- [⚙️ Configuración Completa](docs/SETUP.md)
- [🔧 Quick Start](QUICK-START.md)

---

## 🤝 Contribuir

1. Fork el repositorio
2. Crear rama feature (`git checkout -b feature/nueva-funcionalidad`)
3. Commit cambios (`git commit -m 'feat: agregar nueva funcionalidad'`)
4. Push a la rama (`git push origin feature/nueva-funcionalidad`)
5. Crear Pull Request

---

## 📄 Licencia

Este proyecto está bajo la Licencia MIT - ver [LICENSE](LICENSE) para detalles.

---

## 🏷️ Versión

**v2.2.0** - Catálogo V2 modular ABAC + limpieza de legacy

**Última actualización**: Septiembre 2025

### 🆕 Novedades v2.2.0
- ✅ **Catálogo V2 Modular**: Políticas organizadas por servicio en YAML
- ✅ **Políticas ABAC Reales**: Tag-based access control funcional
- ✅ **Limpieza Legacy**: Eliminadas referencias a policies.yaml V1
- ✅ **Scripts Modernizados**: Solo soportan catálogo V2
