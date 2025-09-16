# � Repositorio IAM AWS - Gestión de Roles y Políticas

## ✅ Estado del Proyecto

**Repositori## 🏗️ Estructura Organizacional

### Flexibilidad Total para Desarrolladores

Los desarrolladores **crean su propia estructura organizacional** como prefieran. El sistema **automáticamente detecta** cualquier archivo JSON de rol:

```
MCI/                        # Los desarrolladores crean estas carpetas
├── BI/
│   ├── mi_primer_rol/
│   │   └── rol-analytics-backend-dev-dashboard.json
│   └── politicas/          # Políticas compartidas de BI
│       ├── politica-s3-read.json
│       └── politica-redshift-query.json
├── Finanzas/
│   ├── contabilidad/
│   │   └── rol-erp-api-prod-invoices.json
│   └── politicas/
│       └── politica-dynamodb-finance.json
└── IT/
    ├── infraestructura/
    │   └── rol-terraform-infrastructure-prod-deploy.json
    └── politicas/
        └── politica-ec2-management.json
```

### ✅ Ventajas del Enfoque Flexible

- **🆓 Libertad Total**: Cada gerencia organiza como quiera
- **🔄 Reutilización**: Carpeta `politicas/` para políticas compartidas
- **🎯 Detección Automática**: GitHub Actions encuentra todos los `*.json` automáticamente
- **📊 Sin Restricciones**: Cualquier estructura de carpetas funciona

### 💡 Ejemplos de Estructuras Válidas

**Opción 1 - Por Gerencia:**
```
MCI/BI/analytics/rol-tableau-dev.json
MCI/BI/politicas/policy-redshift.json
```

**Opción 2 - Por Proyecto:**
```
Proyecto-WebApp/backend/rol-api-prod.json
Proyecto-WebApp/politicas/policy-s3.json
```

**Opción 3 - Flat:**
```
roles/rol-simple-dev.json
politicas/policy-basic.json
```pleto y funcional** - Listo para implementación en tu organización

### 🏗️ Arquitectura Implementada

El repositorio está diseñado para gestionar roles IAM de forma **escalable**, **modular** y **automatizada**, siguiendo las mejores prácticas de Infrastructure as Code:

```
mci-aws-iam/
├── 📁 modules/iam-role/         # Módulo Terraform reutilizable con validaciones 
├── 📁 templates/iam-role-template/  # Templates configurables para roles
├── 📁 scripts/                 # Scripts Python para validación y generación
├── 📁 .github/workflows/       # CI/CD automatizado (3 ambientes)
├── 📁 gerencias/               # Estructura organizacional flexible
└── 📁 docs/                    # Documentación completa
```

### 🎯 Características Principales

✅ **Convención de Nombres**: `rol-[servicio]-[layer]-[ambiente]-[nombre]`  
✅ **19 Tags Obligatorios** con validación estricta  
✅ **3 Ambientes Automatizados**: DEV → QA → PROD  
✅ **Validación Continua** en cada Pull Request  
✅ **Generación Automática** de roles con scripts Python  
✅ **Modularidad Total** - Reutilizable y escalable  
✅ **Documentación Completa** con ejemplos reales  

---

## 🔧 Configuración Inicial

### 1. AWS Setup (Una sola vez)

**Prerequisitos:**
- 3 cuentas AWS (dev, qa, prod) en AWS Organizations
- Permisos de administrador en las 3 cuentas
- AWS CLI v2.0+ instalado

**Pasos:**

1. **Crear S3 Buckets para estado de Terraform:**
```bash
# En cada cuenta
aws s3 mb s3://tu-empresa-terraform-state-dev --profile dev
aws s3 mb s3://tu-empresa-terraform-state-qa --profile qa  
aws s3 mb s3://tu-empresa-terraform-state-prod --profile prod
```

2. **Crear DynamoDB Tables para locks:**
```bash
# En cada cuenta
aws dynamodb create-table \
  --table-name terraform-locks \
  --attribute-definitions AttributeName=LockID,AttributeType=S \
  --key-schema AttributeName=LockID,KeyType=HASH \
  --billing-mode PAY_PER_REQUEST \
  --profile dev
```

3. **Crear IAM Users para GitHub Actions:**
```bash
# Usuario para CI/CD en cada cuenta
aws iam create-user --user-name github-actions-iam --profile dev
aws iam attach-user-policy --user-name github-actions-iam \
  --policy-arn arn:aws:iam::aws:policy/IAMFullAccess --profile dev
```

### 2. GitHub Repository Setup

1. **Configurar Secrets (Repository Settings → Secrets and variables → Actions):**
```
AWS_ACCESS_KEY_ID_DEV=AKIA...
AWS_SECRET_ACCESS_KEY_DEV=...
AWS_ACCESS_KEY_ID_QA=AKIA...
AWS_SECRET_ACCESS_KEY_QA=...
AWS_ACCESS_KEY_ID_PROD=AKIA...
AWS_SECRET_ACCESS_KEY_PROD=...
```

2. **Configurar Variables:**
```
TERRAFORM_STATE_BUCKET_DEV=tu-empresa-terraform-state-dev
TERRAFORM_STATE_BUCKET_QA=tu-empresa-terraform-state-qa
TERRAFORM_STATE_BUCKET_PROD=tu-empresa-terraform-state-prod
TERRAFORM_LOCK_TABLE=terraform-locks
AWS_REGION=us-east-1
```

3. **Activar Branch Protection** (Settings → Branches):
   - Require pull request reviews
   - Require status checks to pass
   - Require up-to-date branches

---

## �️ Estructura Organizacional

### Cómo Organizar tus Roles IAM

Los desarrolladores crean su propia estructura organizacional siguiendo este patrón:

```
gerencias/
└── [nombre-gerencia]/
    ├── politicas/              # 📁 Políticas compartidas de la gerencia
    │   ├── policy-s3-read-access.json
    │   ├── policy-dynamodb-basic.json
    │   └── policy-[nombre].json
    ├── [area-1]/               # 📁 Área funcional (ej: aplicaciones)
    │   ├── rol-[nombre].json   # 🔑 Configuración de rol
    │   └── rol-[otro].json
    ├── [area-2]/               # 📁 Otra área (ej: infraestructura)
    │   └── rol-[nombre].json
    └── [area-n]/
        └── ...
```

### ✅ Ventajas de la Estructura Centralizada

- **🔄 Reutilización**: Las políticas en `politicas/` son compartidas por todas las áreas
- **🎯 Consistencia**: Una sola fuente de verdad para políticas comunes  
- **🛠️ Mantenimiento**: Actualiza una política y afecta todos los roles que la usan
- **📊 Governance**: Fácil auditoría y control de políticas por gerencia

### 💡 Ejemplo Real
```
gerencias/
└── sistemas/
    ├── politicas/
    │   ├── policy-s3-read-access.json     # Para lectura de S3
    │   └── policy-dynamodb-basic.json     # Para DynamoDB básico
    ├── aplicaciones/
    │   └── rol-webapp-backend-dev-api.json   # Usa ambas políticas
    ├── infraestructura/
    │   └── rol-terraform-infrastructure-prod-deploy.json  # Usa policy-s3-read-access
    └── datos/
        └── rol-etl-processor-qa.json      # Usa policy-dynamodb-basic
```

---

## �🎯 Uso Básico - Crear tu primer rol

### Paso a Paso: Tu Primer Rol (Ejemplo MCI/BI)

**1. Crear tu estructura (como quieras):**
```bash
# Los desarrolladores crean sus carpetas
mkdir -p MCI/BI/mi_primer_rol
mkdir -p MCI/BI/politicas
```

**2. Crear política reutilizable:**
```json
# MCI/BI/politicas/politica1.json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "s3:GetObject",
        "s3:ListBucket"
      ],
      "Resource": [
        "arn:aws:s3:::mci-bi-data/*",
        "arn:aws:s3:::mci-bi-data"
      ]
    }
  ]
}
```

**3. Crear configuración de rol:**
```json
# MCI/BI/mi_primer_rol/rol-analytics-backend-dev-dashboard.json
{
  "role_name": "rol-analytics-backend-dev-dashboard",
  "description": "Rol para dashboard de analytics de BI",
  "trust_policy": {
    "Version": "2012-10-17",
    "Statement": [
      {
        "Effect": "Allow",
        "Principal": {
          "Service": "ec2.amazonaws.com"
        },
        "Action": "sts:AssumeRole"
      }
    ]
  },
  "policies": {
    "aws_managed": [
      "arn:aws:iam::aws:policy/CloudWatchAgentServerPolicy"
    ],
    "custom_policies": [
      "../politicas/politica1.json"
    ]
  },
  "tags": {
    "ambiente": "dev",
    "pais": "GT",
    "direccion": "MCI",
    "gerencia": "BI",
    "cuenta": "dev-account",
    "modulo": "Aplicación",
    "alcance_sox": "No",
    "propietario": "Equipo BI",
    "proveedor": "Inhouse",
    "layer": "backend",
    "dominio": "Business Intelligence",
    "subdominio": "Analytics",
    "aplicacion": "dashboard-bi",
    "soporte": "Equipo DevOps",
    "contacto": "bi-team@empresa.com",
    "proyecto": "BI-Dashboard-2025",
    "creado_por": "Ana López",
    "ciclo_vida": "Implementación",
    "version": "1.0.0"
  }
}
```

**4. Commit y Deploy automático:**
```bash
git add MCI/
git commit -m "feat: Add BI analytics role for dashboard"
git push origin feature/bi-analytics-role
  --area aplicaciones
```

**3. Configurar variables del ambiente:**
```bash
cd gerencias/tecnologia/aplicaciones
cp terraform.tfvars.example terraform.tfvars
# Editar terraform.tfvars con valores reales
```

**4. Desplegar usando Git workflow:**
```bash
git checkout -b feature/rol-lambda-pagos
git add .
git commit -m "feat: agregar rol Lambda para procesador de pagos"
git push origin feature/rol-lambda-pagos
# Crear PR a develop → despliega automáticamente a DEV
```

**Resultado:**
- ✅ Rol creado: `rol-lambda-api-dev-procesadorPagos`
- ✅ Políticas adjuntadas automáticamente  
- ✅ 19 tags aplicados y validados
- ✅ Desplegado en DEV automáticamente

---

## 🔄 Flujo de Promoción entre Ambientes

### Estrategia Git-based

```
feature/nueva-funcionalidad → develop → qa → main
     ↓                          ↓       ↓      ↓
   Local                      DEV     QA    PROD
```

**Comandos:**
```bash
# DEV (automático con PR a develop)
git checkout develop
git merge feature/nueva-funcionalidad

# QA (automático con PR a qa)  
git checkout qa
git merge develop

# PROD (requiere aprobación manual)
git checkout -b promote/release-v1.2.0
git merge qa
# Crear PR a main con revisión obligatoria
```

---

## 📋 Ejemplos de Roles Comunes

### 🔥 Lambda Function
```json
{
  "servicio": "lambda",
  "layer": "api",
  "policies": {
    "aws_managed": ["arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"]
  }
}
```

### 📊 Glue ETL Job
```json
{
  "servicio": "glue", 
  "layer": "data-analytics",
  "policies": {
    "aws_managed": [
      "arn:aws:iam::aws:policy/service-role/AWSGlueServiceRole",
      "arn:aws:iam::aws:policy/AmazonS3FullAccess"
    ]
  }
}
```

### 🖥️ EC2 Instance Profile
```json
{
  "servicio": "ec2",
  "layer": "infrastructure", 
  "policies": {
    "aws_managed": ["arn:aws:iam::aws:policy/CloudWatchAgentServerPolicy"],
    "inline": {
      "Version": "2012-10-17",
      "Statement": [...]
    }
  }
}
```

---

## 🛡️ Validaciones Automáticas

### En cada Pull Request:
- ✅ **Sintaxis Terraform** - `terraform validate`
- ✅ **Formato** - `terraform fmt -check`  
- ✅ **Convención de nombres** - Regex validation
- ✅ **Tags obligatorios** - 19 tags requeridos
- ✅ **Escaneo de seguridad** - tfsec/checkov
- ✅ **Plan de cambios** - No destructivo

### Comando de validación local:
```bash
./scripts/validate.sh
```

---

## 🚨 Solución de Problemas Comunes

### ❌ "Tag obligatorio faltante"
```bash
# Error
Tags obligatorios faltantes: alcance_sox, propietario

# Solución  
Completar todos los 19 tags en el archivo JSON de configuración
```

### ❌ "Nombre de rol inválido"
```bash
# ❌ Incorrecto
rol-Lambda-API-dev-processor

# ✅ Correcto  
rol-lambda-api-dev-processor
```

### ❌ "Backend configuration failed"
```bash
# Verificar bucket S3
aws s3 ls s3://tu-empresa-terraform-state-dev --profile dev

# Verificar variable en GitHub
TERRAFORM_STATE_BUCKET_DEV=tu-empresa-terraform-state-dev
```

---

## 📚 Documentación Completa

Para más detalles, consulta:

- **[📖 Setup Guide](docs/SETUP.md)** - Configuración completa de AWS y GitHub
- **[📋 Usage Guide](docs/USAGE.md)** - Casos de uso y ejemplos detallados  
- **[🔧 Conventions](docs/CONVENTIONS.md)** - Reglas y estándares
- **[🚀 Deployment](docs/DEPLOYMENT.md)** - Guía de despliegue
- **[📊 Architecture](docs/ARCHITECTURE.md)** - Diseño y decisiones técnicas

---

## 🤝 Contribuir

### Para desarrolladores:
1. Fork del repositorio
2. Crear rama feature: `git checkout -b feature/mi-mejora`
3. Commit cambios: `git commit -m 'feat: agregar nueva funcionalidad'`
4. Push rama: `git push origin feature/mi-mejora`
5. Crear Pull Request

### Para usuarios finales:
1. Usar script generador para crear roles
2. Seguir convenciones establecidas
3. Validar localmente antes de commit
4. Crear PRs descriptivos

---

## 📞 Soporte

- **Equipo DevOps**: devops@empresa.com
- **Equipo Seguridad**: security@empresa.com
- **GitHub Issues**: Para reportar bugs o solicitar funcionalidades

---

## 🏆 Beneficios Implementados

### ✅ Para Desarrolladores
- **Generación automática** de roles con 1 comando
- **Validación continua** - detecta errores antes del despliegue
- **Templates reutilizables** - no reinventar la rueda
- **Documentación clara** - ejemplos paso a paso

### ✅ Para DevOps  
- **CI/CD completo** - despliegue automático en 3 ambientes
- **Estado centralizado** - Terraform backend en S3
- **Rollback seguro** - historial completo en Git
- **Monitoreo** - logs detallados de cada despliegue

### ✅ Para Seguridad
- **Tags obligatorios** - trazabilidad completa 
- **Naming convention** - identificación clara
- **Principio de menor privilegio** - validaciones incluidas
- **Auditabilidad** - cada cambio está documentado

### ✅ Para Compliance
- **SOX ready** - tag alcance_sox obligatorio
- **Trazabilidad completa** - quién, qué, cuándo, por qué
- **Versionado** - control de cambios semántico
- **Documentación automática** - README por área

---

## 🎉 ¡Tu repositorio está listo!

**Siguiente paso:** Comienza creando tu primer rol con el ejemplo de Lambda Function mostrado arriba.

¿Necesitas ayuda? Revisa la documentación o contacta al equipo de soporte.

**Happy IAM Management! 🔐**
    "creado_por": "maria.garcia@empresa.com",
    "ciclo_vida": "Implementación",
    "version": "1.0.0"
  }
}
EOF

# 2. Generar el rol
python3 scripts/generate_role.py mi-rol-config.json --gerencia aplicaciones --area backend

# 3. Completar variables y desplegar
cd gerencias/aplicaciones/backend
cp terraform.tfvars.example terraform.tfvars
# Editar terraform.tfvars con valores específicos
```

#### Opción B: Manual

1. **Crear directorio y archivo**:
```bash
mkdir -p gerencias/mi-gerencia/mi-area
```

2. **Usar plantilla**:
```hcl
module "mi_rol" {
  source = "../../../templates/iam-role-template"

  servicio  = "lambda"      # s3, lambda, glue, ec2, etc.
  layer     = "api"         # data-analytics, api, frontend, etc.
  ambiente  = "dev"         # dev, qa, prod, poc
  nombre    = "miRol"       # nombre específico
  
  description = "Descripción del rol"
  
  # Políticas AWS gestionadas
  policy_arns = [
    "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
  ]

  # Tags obligatorios (todos requeridos)
  pais         = "GT"
  direccion    = "Mi Dirección"
  gerencia     = "Mi Gerencia"
  # ... resto de tags obligatorios
}
```

### 2. Flujo de Despliegue

```bash
# 1. Validar cambios localmente
./scripts/validate.sh

# 2. Crear Pull Request
git checkout -b feature/nuevo-rol-lambda-api
git add .
git commit -m "feat: agregar rol lambda para API de pagos"
git push origin feature/nuevo-rol-lambda-api

# 3. El sistema automáticamente:
#    - Valida la convención de nombres
#    - Verifica todos los tags obligatorios
#    - Ejecuta plan de Terraform
#    - Ejecuta análisis de seguridad

# 4. Merge a rama correspondiente para desplegar:
#    - merge a 'develop' → despliega a DEV
#    - merge a 'qa' → despliega a QA  
#    - merge a 'main' → despliega a PROD
```

## 🧾 Convención de Nombres

### Formato de Roles IAM
```
rol-[servicio]-[layer]-[ambiente]-[nombre]
```

### Ejemplos Válidos
- `rol-s3-data-analytics-dev-bitacora`
- `rol-lambda-api-prod-jobProcessor`
- `rol-glue-etl-qa-transformadorVentas`
- `rol-ec2-infrastructure-dev-webServer`

### Servicios Soportados
- `s3`, `lambda`, `glue`, `ec2`, `ecs`, `rds`
- `dynamodb`, `sns`, `sqs`, `kinesis`, `redshift`
- `emr`, `apigateway`

### Ambientes Válidos
- `dev` - Desarrollo
- `qa` - Quality Assurance  
- `prod` - Producción
- `poc` - Proof of Concept

## 🏷️ Tags Obligatorios

Todos los recursos IAM **DEBEN** incluir estos 19 tags:

| Tag | Descripción | Valores Válidos | Ejemplo |
|-----|-------------|-----------------|---------|
| `Ambiente` | Ambiente de despliegue | `dev`, `qa`, `prod`, `poc` | `dev` |
| `País` | País de despliegue | `GT`, `SV`, `NI`, `HN`, `CR`, `RG` | `GT` |
| `Dirección` | Dirección solicitante | Texto libre | `Gerencia de TI` |
| `Gerencia` | Gerencia responsable | Texto libre | `Data Analytics & AI` |
| `Cuenta` | Cuenta organizacional | Texto libre | `dev-analytics-account` |
| `Módulo` | Tipo de módulo | `Aplicación`, `DB`, `POC` | `Aplicación` |
| `Alcance SOX` | Bajo alcance SOX | `Sí`, `No` | `No` |
| `Propietario` | Persona responsable | Texto libre | `Juan Pérez` |
| `Proveedor` | Tipo de proveedor | `Inhouse`, `Tercero` | `Inhouse` |
| `Layer` | Capa del sistema | Texto libre | `Data Analytics` |
| `Dominio` | Dominio AMX | Texto libre | `Analytics` |
| `Subdominio` | Subdominio AMX | Texto libre | `ETL` |
| `Aplicación` | ID de aplicación | Texto libre | `VENTAS-ETL-001` |
| `Soporte` | Equipo de soporte | Texto libre | `Equipo Data Engineering` |
| `Contacto` | Email de contacto | Email válido | `data@empresa.com` |
| `Proyecto` | Código de proyecto | Texto libre | `PROJ-2024-ANALYTICS` |
| `Creado Por` | Creador del recurso | Texto libre | `juan.perez@empresa.com` |
| `Ciclo de Vida` | Etapa del ciclo | Ver valores válidos* | `Implementación` |
| `Versión` | Versión del recurso | Formato semántico | `1.0.0` |

*Valores válidos para Ciclo de Vida: `Creación`, `Implementación`, `MonitoreoYMantenimiento`, `Optimización`, `Decommission`

## 🔄 Flujos de CI/CD

### Ramas y Ambientes

| Rama | Ambiente | Trigger | Validaciones |
|------|----------|---------|--------------|
| `develop` | DEV | Push automático | Básicas + Sintaxis |
| `qa` | QA | Push automático | Básicas + Sintaxis + Seguridad |
| `main` | PROD | Push automático | Todas + SOX + Aprobación manual |

### Workflows Disponibles

1. **🔍 Validate** (`.github/workflows/validate.yml`)
   - Validación de sintaxis de Terraform
   - Verificación de convención de nombres
   - Validación de tags obligatorios
   - Análisis de seguridad con Checkov y TFSec

2. **🚀 Deploy** (`.github/workflows/deploy.yml`)
   - Despliegue automático por ambiente
   - Configuración dinámica de backend
   - Reportes de despliegue
   - Notificaciones para PROD

3. **🧹 Cleanup** (`.github/workflows/cleanup.yml`)
   - Limpieza de recursos por ambiente
   - Modo dry-run para revisión
   - Confirmación obligatoria para ejecución

## 🛠️ Scripts Disponibles

### Validación
```bash
# Validar todo el repositorio
./scripts/validate.sh

# Validar archivo específico
python3 scripts/validate_iam.py gerencias/data-analytics/etl/transformador.tf

# Validar nombre de rol
python3 scripts/validate_iam.py --role-name "rol-lambda-api-dev-processor"

# Validar tags desde archivo JSON
python3 scripts/validate_iam.py --tags-file mi-tags.json .
```

### Generación
```bash
# Generar nuevo rol desde configuración
python3 scripts/generate_role.py config.json --gerencia aplicaciones --area backend
```

## 📋 Ejemplos de Uso

### Rol para Glue ETL
```hcl
module "glue_ventas_etl" {
  source = "../../../templates/iam-role-template"

  servicio  = "glue"
  layer     = "data-analytics"
  ambiente  = "prod"
  nombre    = "transformadorVentas"
  
  policy_arns = [
    "arn:aws:iam::aws:policy/service-role/AWSGlueServiceRole",
    "arn:aws:iam::aws:policy/AmazonS3ReadOnlyAccess"
  ]
  
  # Tags obligatorios...
}
```

### Rol para Lambda API
```hcl
module "lambda_api_payments" {
  source = "../../../templates/iam-role-template"

  servicio  = "lambda"
  layer     = "api"
  ambiente  = "prod"
  nombre    = "procesadorPagos"
  
  policy_arns = [
    "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
  ]
  
  inline_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = ["dynamodb:GetItem", "dynamodb:PutItem"]
        Resource = "arn:aws:dynamodb:*:*:table/payments"
      }
    ]
  })
  
  # Tags obligatorios...
}
```

## 🔧 Configuración de Entorno

### Secrets Requeridos en GitHub

Para cada ambiente (`dev`, `qa`, `prod`):

```
AWS_ACCESS_KEY_ID_DEV
AWS_SECRET_ACCESS_KEY_DEV
AWS_ROLE_ARN_DEV (opcional, para assume role)

AWS_ACCESS_KEY_ID_QA
AWS_SECRET_ACCESS_KEY_QA
AWS_ROLE_ARN_QA

AWS_ACCESS_KEY_ID_PROD
AWS_SECRET_ACCESS_KEY_PROD
AWS_ROLE_ARN_PROD
```

### Variables de Repositorio

```
AWS_REGION_DEV=us-east-1
AWS_REGION_QA=us-east-1  
AWS_REGION_PROD=us-east-1

TERRAFORM_STATE_BUCKET_DEV=my-terraform-state-dev
TERRAFORM_STATE_BUCKET_QA=my-terraform-state-qa
TERRAFORM_STATE_BUCKET_PROD=my-terraform-state-prod
```

## 🆘 Solución de Problemas

### Error: "Nombre de rol inválido"
- Verifica que siga el formato: `rol-[servicio]-[layer]-[ambiente]-[nombre]`
- Solo minúsculas, números y guiones permitidos
- El ambiente debe ser: `dev`, `qa`, `prod`, o `poc`

### Error: "Tags obligatorios faltantes"
- Verifica que todos los 19 tags estén presentes
- Ningún tag puede estar vacío
- Revisa los valores válidos para cada tag

### Error: "Política de confianza inválida"
- Asegúrate de que el JSON sea válido
- Verifica que el servicio AWS esté correctamente especificado

### Error de Backend de Terraform
- Verifica que el bucket S3 para el estado exista
- Confirma que las credenciales AWS tengan permisos
- Revisa que la región sea correcta

## 📞 Soporte

- **Equipo Data Engineering**: data-engineering@empresa.com
- **Equipo Backend**: backend-team@empresa.com  
- **Infraestructura**: infraestructura@empresa.com

## 🤝 Contribución

1. Fork el repositorio
2. Crea una rama feature: `git checkout -b feature/nuevo-rol`
3. Sigue las convenciones de nombres y tags
4. Ejecuta validaciones: `./scripts/validate.sh`
5. Crea un Pull Request

## 📄 Licencia

Este proyecto es propiedad de la organización y está sujeto a las políticas internas de desarrollo.

---

**🎯 Objetivo**: Gestión escalable, segura y automatizada de recursos IAM en AWS siguiendo las mejores prácticas y estándares organizacionales.
#   T e s t   t r i g g e r  
 