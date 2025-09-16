# 📘 Guía de Convenciones

## 🧾 Convención de Nombres para Roles IAM

### Formato Obligatorio
```
rol-[servicio]-[layer]-[ambiente]-[nombre]
```

### Componentes

#### 1. Prefijo
- **Valor**: `rol`
- **Descripción**: Prefijo fijo que identifica el recurso como un rol IAM

#### 2. Servicio
- **Descripción**: Servicio AWS principal que usará el rol
- **Valores válidos**:
  - `s3` - Amazon Simple Storage Service
  - `lambda` - AWS Lambda
  - `glue` - AWS Glue
  - `ec2` - Amazon Elastic Compute Cloud
  - `ecs` - Amazon Elastic Container Service
  - `rds` - Amazon Relational Database Service
  - `dynamodb` - Amazon DynamoDB
  - `sns` - Amazon Simple Notification Service
  - `sqs` - Amazon Simple Queue Service
  - `kinesis` - Amazon Kinesis
  - `redshift` - Amazon Redshift
  - `emr` - Amazon Elastic MapReduce
  - `apigateway` - Amazon API Gateway

#### 3. Layer
- **Descripción**: Capa o layer arquitectónica del sistema
- **Formato**: kebab-case (minúsculas con guiones)
- **Ejemplos**:
  - `data-analytics` - Capa de análisis de datos
  - `api` - Capa de API/servicios
  - `frontend` - Capa de presentación
  - `etl` - Extract, Transform, Load
  - `machine-learning` - Aprendizaje automático
  - `infrastructure` - Infraestructura
  - `security` - Seguridad
  - `monitoring` - Monitoreo

#### 4. Ambiente
- **Descripción**: Ambiente de despliegue
- **Valores válidos**:
  - `dev` - Desarrollo
  - `qa` - Quality Assurance
  - `prod` - Producción
  - `poc` - Proof of Concept

#### 5. Nombre
- **Descripción**: Nombre específico y descriptivo del rol
- **Formato**: camelCase o kebab-case
- **Características**:
  - Descriptivo y específico
  - Máximo 64 caracteres total para el rol completo
  - Solo letras, números y guiones

### Ejemplos Válidos

```bash
# Rol para Glue ETL que transforma datos de ventas en desarrollo
rol-glue-data-analytics-dev-transformadorVentas

# Rol para Lambda API que procesa trabajos en producción
rol-lambda-api-prod-jobProcessor

# Rol para S3 que maneja bitácoras en QA
rol-s3-data-analytics-qa-bitacora

# Rol para EC2 que ejecuta servidor web en desarrollo
rol-ec2-infrastructure-dev-webServer

# Rol para DynamoDB en capa de API para desarrollo
rol-dynamodb-api-dev-userDatabase

# Rol para Redshift en analytics para producción
rol-redshift-data-analytics-prod-dataWarehouse
```

### Ejemplos Inválidos

```bash
# ❌ Sin prefijo 'rol'
lambda-api-prod-processor

# ❌ Servicio inválido
rol-mysql-api-prod-processor

# ❌ Ambiente inválido
rol-lambda-api-production-processor

# ❌ Uso de mayúsculas
rol-Lambda-API-prod-Processor

# ❌ Espacios en lugar de guiones
rol-lambda-api service-prod-processor

# ❌ Caracteres especiales
rol-lambda-api-prod-processor@v1

# ❌ Nombre vacío
rol-lambda-api-prod-
```

## 🏷️ Convención de Tags Obligatorios

### Lista Completa de Tags

| # | Tag | Tipo | Valores Válidos | Obligatorio | Ejemplo |
|---|-----|------|-----------------|-------------|---------|
| 1 | `Ambiente` | Enumerado | `dev`, `qa`, `prod`, `poc` | ✅ | `dev` |
| 2 | `País` | Enumerado | `GT`, `SV`, `NI`, `HN`, `CR`, `RG` | ✅ | `GT` |
| 3 | `Dirección` | Texto | Cualquier texto | ✅ | `Gerencia de TI - Data Analytics` |
| 4 | `Gerencia` | Texto | Cualquier texto | ✅ | `Data Analytics & AI` |
| 5 | `Cuenta` | Texto | Cualquier texto | ✅ | `dev-analytics-account` |
| 6 | `Módulo` | Enumerado | `Aplicación`, `DB`, `POC` | ✅ | `Aplicación` |
| 7 | `Alcance SOX` | Enumerado | `Sí`, `No` | ✅ | `No` |
| 8 | `Propietario` | Texto | Cualquier texto | ✅ | `Juan Pérez` |
| 9 | `Proveedor` | Enumerado | `Inhouse`, `Tercero` | ✅ | `Inhouse` |
| 10 | `Layer` | Texto | Cualquier texto | ✅ | `Data Analytics` |
| 11 | `Dominio` | Texto | Cualquier texto | ✅ | `Analytics` |
| 12 | `Subdominio` | Texto | Cualquier texto | ✅ | `ETL` |
| 13 | `Aplicación` | Texto | Cualquier texto | ✅ | `VENTAS-ETL-PROCESSOR` |
| 14 | `Name` | Texto | Nombre del recurso | ✅ | `rol-glue-etl-dev-ventas` |
| 15 | `Soporte` | Texto | Cualquier texto | ✅ | `Equipo Data Engineering` |
| 16 | `Contacto` | Email | Email válido | ✅ | `data-engineering@empresa.com` |
| 17 | `Proyecto` | Texto | Cualquier texto | ✅ | `PROJ-2024-ANALYTICS` |
| 18 | `Fecha de Creación` | Fecha | YYYY-MM-DD | ✅ | `2024-03-15` |
| 19 | `Creado Por` | Texto | Cualquier texto | ✅ | `juan.perez@empresa.com` |
| 20 | `Tipo de Recurso` | Texto | Tipo de recurso AWS | ✅ | `IAM Role` |
| 21 | `Ciclo de Vida` | Enumerado | Ver valores válidos* | ✅ | `Implementación` |
| 22 | `Versión` | Versión | Formato semántico | ✅ | `1.0.0` |

*Valores válidos para Ciclo de Vida:
- `Creación`
- `Implementación`
- `MonitoreoYMantenimiento`
- `Optimización`
- `Decommission`

### Ejemplo Completo de Tags

```hcl
tags = {
  ambiente     = "dev"
  pais         = "GT"
  direccion    = "Gerencia de TI - Data Analytics"
  gerencia     = "Data Analytics & AI"
  cuenta       = "dev-analytics-account"
  modulo       = "Aplicación"
  alcance_sox  = "No"
  propietario  = "Juan Pérez"
  proveedor    = "Inhouse"
  layer        = "Data Analytics"
  dominio      = "Analytics"
  subdominio   = "ETL"
  aplicacion   = "VENTAS-ETL-PROCESSOR"
  soporte      = "Equipo Data Engineering"
  contacto     = "data-engineering@empresa.com"
  proyecto     = "PROJ-2024-ANALYTICS"
  creado_por   = "juan.perez@empresa.com"
  ciclo_vida   = "Implementación"
  version      = "1.0.0"
}
```

## 📁 Convención de Estructura de Directorios

### Jerarquía Obligatoria
```
gerencias/
└── [nombre-gerencia]/
    └── [nombre-area]/
        ├── [archivo-rol].tf
        ├── variables.tf
        ├── terraform.tfvars
        └── outputs.tf (opcional)
```

### Nombres de Directorios
- **Formato**: kebab-case (minúsculas con guiones)
- **Sin espacios ni caracteres especiales**
- **Descriptivos y concisos**

### Ejemplos de Estructura

```
gerencias/
├── data-analytics/
│   ├── etl/
│   │   ├── transformador-ventas.tf
│   │   ├── procesador-logs.tf
│   │   ├── variables.tf
│   │   └── terraform.tfvars
│   ├── machine-learning/
│   │   ├── modelo-prediccion.tf
│   │   ├── variables.tf
│   │   └── terraform.tfvars
│   └── reporting/
├── aplicaciones/
│   ├── backend/
│   │   ├── api-usuarios.tf
│   │   ├── procesador-pagos.tf
│   │   └── variables.tf
│   ├── frontend/
│   │   ├── web-app.tf
│   │   └── variables.tf
│   └── mobile/
├── infraestructura/
│   ├── redes/
│   │   ├── vpc-management.tf
│   │   └── variables.tf
│   ├── seguridad/
│   │   ├── security-scanner.tf
│   │   └── variables.tf
│   └── monitoreo/
└── bases-datos/
    ├── transaccional/
    ├── analytics/
    └── cache/
```

## 📝 Convención de Nombres de Archivos

### Archivos de Terraform

#### Roles IAM
- **Formato**: `[descripcion-funcional].tf`
- **Ejemplos**:
  - `transformador-ventas.tf`
  - `procesador-pagos.tf`
  - `api-usuarios.tf`
  - `modelo-prediccion.tf`

#### Archivos Estándar
- `variables.tf` - Variables del módulo
- `outputs.tf` - Outputs del módulo (opcional)
- `terraform.tfvars` - Valores de variables
- `[ambiente].tfvars` - Valores específicos por ambiente

### Reglas de Nomenclatura
1. **Solo minúsculas**
2. **Guiones para separar palabras**
3. **Descriptivo y específico**
4. **Sin abreviaciones confusas**
5. **Máximo 50 caracteres**

## 🔄 Convención de Ramas Git

### Ramas Principales

| Rama | Propósito | Ambiente | Protección |
|------|-----------|----------|------------|
| `main` | Producción | PROD | ✅ Protegida |
| `qa` | Quality Assurance | QA | ✅ Protegida |
| `develop` | Desarrollo | DEV | ⚠️ Semi-protegida |

### Ramas de Feature

#### Formato
```
feature/[tipo]-[descripcion-breve]
```

#### Tipos
- `feat` - Nueva funcionalidad
- `fix` - Corrección de errores
- `refactor` - Refactorización
- `docs` - Documentación
- `chore` - Tareas de mantenimiento

#### Ejemplos
```bash
feature/feat-rol-lambda-pagos
feature/fix-tags-validacion
feature/refactor-modulo-iam
feature/docs-guia-usuarios
feature/chore-cleanup-dev
```

## 💬 Convención de Commits

### Formato
```
[tipo]([scope]): [descripción]

[cuerpo opcional]

[footer opcional]
```

### Tipos
- `feat` - Nueva funcionalidad
- `fix` - Corrección de errores
- `docs` - Cambios en documentación
- `style` - Formato, sin cambios de lógica
- `refactor` - Refactorización de código
- `test` - Agregar o modificar tests
- `chore` - Tareas de mantenimiento

### Ejemplos
```bash
feat(iam): agregar rol para Lambda API de pagos

fix(validation): corregir validación de tags SOX

docs(readme): actualizar guía de inicio rápido

refactor(modules): simplificar módulo iam-role

chore(deps): actualizar versión de Terraform a 1.6.0
```

## ⚠️ Validaciones Automáticas

### Pre-commit
- Validación de sintaxis de Terraform
- Verificación de convención de nombres
- Validación de tags obligatorios
- Formato de código (`terraform fmt`)

### Pull Request
- Todas las validaciones de pre-commit
- Plan de Terraform
- Análisis de seguridad (Checkov, TFSec)
- Revisión de código obligatoria

### Pre-deployment
- Validación específica por ambiente
- Verificaciones adicionales para PROD
- Confirmación de tags SOX para PROD

Esta guía de convenciones asegura la consistencia, mantenibilidad y escalabilidad del repositorio de gestión IAM.
