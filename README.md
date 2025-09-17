# 🚀 Repositorio IAM AWS - Gestión de Roles y Políticas

[![GitHub Actions](https://img.shields.io/badge/CI%2FCD-GitHub%20Actions-blue?logo=github-actions)](https://github.com/ClaroCENAM/mci-aws-iam/actions)
[![Terraform](https://img.shields.io/badge/Infrastructure-Terraform-purple?logo=terraform)](https://terraform.io)
[![AWS](https://img.shields.io/badge/Cloud-AWS-orange?logo=amazon-aws)](https://aws.amazon.com)

> **Sistema completo de gestión IAM** con **despliegue automático**, **validación continua** y **estructura organizacional flexible**.

## ✅ Estado del Proyecto

**Repositorio FUNCIONAL** - Pipeline de deployment completo operativo:

- ✅ **CI/CD Completo** - Validación → Plan → Deploy → Verificación automática
- ✅ **Backend S3/DynamoDB** - Estado centralizado y locks de Terraform
- ✅ **Validación Estricta** - 19 tags obligatorios + convenciones de naming
- ✅ **Auto-discovery** - Encuentra automáticamente archivos de roles/políticas
- ✅ **Multi-ambiente** - dev/qa/prod con variables independientes

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

## 🚀 Uso Rápido (Para Desarrolladores)

### 1. Crear tu primer rol

```bash
# Crear estructura
mkdir -p MCI/TuEquipo
cd MCI/TuEquipo

# Crear rol (copia y edita)
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
    "custom": ["policy-s3-read"]
  },
  "tags": {
    "ambiente": "dev",
    "pais": "GT",
    "direccion": "Tecnologia",
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

### Lambda Function
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
    ]
  }
}
```

### EC2 Instance
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
    "custom": ["policy-s3-read"]
  }
}
```

### Glue ETL Job
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

**v2.0.0** - Pipeline unificado con auto-discovery y OIDC authentication

**Última actualización**: Septiembre 2025
