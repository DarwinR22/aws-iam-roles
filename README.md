<div align="center">

# 🚀 MCI AWS IAM - Arquitectura Empresarial

### *Gestión empresarial de IAM con Control de Acceso Basado en Atributos (ABAC)*
<!-- v2.2.0 - Security hardening implemented -->

[![Terraform](https://img.shields.io/badge/Terraform-1.6+-623CE4?style=for-the-badge&logo=terraform&logoColor=white)](https://www.terraform.io/)
[![AWS](https://img.shields.io/badge/AWS-IAM-FF9900?style=for-the-badge&logo=amazon-aws&logoColor=white)](https://aws.amazon.com/iam/)
[![GitHub Actions](https://img.shields.io/badge/GitHub_Actions-CI%2FCD-2088FF?style=for-the-badge&logo=github-actions&logoColor=white)](https://github.com/features/actions)
[![License](https://img.shields.io/badge/License-MIT-green?style=for-the-badge)](LICENSE)

[![IAM CI/CD](https://img.shields.io/github/actions/workflow/status/ClaroCENAM/mci-aws-iam/generate-iam.yml?branch=dev&label=IAM%20CI%2FCD&style=flat-square&logo=terraform&logoColor=white)](https://github.com/ClaroCENAM/mci-aws-iam/actions/workflows/generate-iam.yml)
[![Last Commit](https://img.shields.io/github/last-commit/ClaroCENAM/mci-aws-iam/dev?style=flat-square&logo=github)](https://github.com/ClaroCENAM/mci-aws-iam/commits/dev)
[![Repo Size](https://img.shields.io/github/repo-size/ClaroCENAM/mci-aws-iam?style=flat-square&logo=github)](https://github.com/ClaroCENAM/mci-aws-iam)
[![Code Quality](https://img.shields.io/badge/code%20quality-enterprise-brightgreen?style=flat-square&logo=codacy)](https://github.com/ClaroCENAM/mci-aws-iam)


---

### 🎯 Gobernanza automatizada • 🔐 Seguridad empresarial • 🏷️ Control basado en tags • 🚀 CI/CD completo

</div>

---

## ✨ Novedades Destacadas

<table>
<tr>
<td width="33%" align="center">
<h3>🎯 Preview Mejorado</h3>
<p><strong>Tablas HTML Profesionales</strong></p>
<p>Visualiza cambios de Terraform con formato profesional, badges visuales (➕🛠️♻️❌), truncamiento inteligente y tooltips</p>
</td>
<td width="33%" align="center">
<h3>🔐 Encriptación KMS</h3>
<p><strong>Seguridad Empresarial</strong></p>
<p>Claves administradas por el cliente aseguran locks de DynamoDB y estado en S3 con rotación automática</p>
</td>
<td width="33%" align="center">
<h3>🎯 Detección de Drift</h3>
<p><strong>Inteligente y Segura</strong></p>
<p>Diferencia entre recursos CI/CD (auto-limpieza) vs manuales (solo reporte) para máxima seguridad</p>
</td>
</tr>
</table>
---

## 🏗️ Visión General de la Arquitectura

<div align="center">

**Arquitectura ABAC basada en tags con confianza cero para gestión empresarial de IAM**

*Gobernanza automatizada • Cumplimiento integral • Seguridad por diseño*

📖 **[Ver Estrategia ABAC Completa](docs/ABAC-STRATEGY.md)** - Políticas genéricas modulares a largo plazo

</div>

### 📦 Estructura del Repositorio

```
📦 mci-aws-iam/
├── 🧱 policy_lib/          # Bloques de construcción ABAC (S3, DynamoDB, Lambda)
├── 📋 catalog/             # Fuente única de verdad (roles.yaml, policies.yaml)
├── 🏢 gerencias/           # Estructura organizacional con roles
├── 🔧 modules/             # Módulos Terraform empresariales
├── 🌍 environments/        # Configuraciones por ambiente (dev/qa/prod)
├── 🛡️ guardrails/          # Validación de seguridad y cumplimiento
├── ⚙️ ci/                  # Workflows de GitHub Actions
├── 📝 docs/                # Documentación empresarial
└── 🚀 scripts/             # Scripts de automatización y creación de roles
```

### 🎯 Características Principales

<table>
<tr>
<td width="50%">

#### 🏷️ Políticas ABAC Basadas en Tags
Control de acceso auto-escalable que se ajusta dinámicamente según los tags de recursos

#### 🔍 Detección Inteligente de Estructura
Descubrimiento automático de roles y políticas en la organización

#### 📊 Gobernanza de 25+ Tags Obligatorios
Cumplimiento completo con trazabilidad total de recursos

</td>
<td width="50%">

#### 🧩 Bloques de Construcción Reutilizables
Políticas MCI pre-construidas listas para usar

#### 🌍 Soporte Multi-Ambiente
Flujos de trabajo separados para dev/qa/prod

#### 🎯 Preview Visual Mejorado
Tablas HTML profesionales con detección inteligente de cambios

</td>
</tr>
</table>

---

## ✅ Estado del Proyecto

<div align="center">

### 🎉 Repositorio Listo para Producción

**Arquitectura empresarial basada en tags 100% operativa**

</div>

<table>
<tr>
<td width="33%" align="center">
<h4>⚙️ CI/CD Completo</h4>
<p>Validación → Plan → Deploy → Verificación automática</p>
</td>
<td width="33%" align="center">
<h4>💾 Backend S3/DynamoDB</h4>
<p>Estado centralizado con locks distribuidos</p>
</td>
<td width="33%" align="center">
<h4>🏷️ Políticas Tag-Based</h4>
<p>Escalamiento automático inteligente</p>
</td>
</tr>
<tr>
<td width="33%" align="center">
<h4>🔍 Auto-descubrimiento</h4>
<p>Detección automática de roles/políticas</p>
</td>
<td width="33%" align="center">
<h4>🌍 Multi-ambiente</h4>
<p>Separación dev/qa/prod por tags</p>
</td>
<td width="33%" align="center">
<h4>🆕 Detección de Drift</h4>
<p>Sistema empresarial de limpieza</p>
</td>
</tr>
<tr>
<td width="33%" align="center">
<h4>📊 Notificaciones GitHub</h4>
<p>Reportes en PR/Issues automáticos</p>
</td>
<td width="33%" align="center">
<h4>🛡️ Seguridad Empresarial</h4>
<p>Protección de recursos críticos</p>
</td>
<td width="33%" align="center">
<h4>🎯 Preview Mejorado</h4>
<p>Tablas HTML con badges visuales</p>
</td>
</tr>
</table>

---

## � Preview Inteligente de Planes Terraform

<div align="center">

### 🌟 Sistema de Visualización Profesional

*Visualiza cambios de Terraform con formato empresarial y detección inteligente*

</div>

### ✨ Características del Preview

<table>
<tr>
<td width="50%">

#### 📊 Tablas HTML Estructuradas
Formato profesional con columnas organizadas:
- 🏷️ **Tipo** - Tipo de operación
- 📋 **Atributo** - Propiedad modificada
- ⬅️ **Valor Anterior** - Estado actual
- ➡️ **Valor Nuevo** - Estado futuro

#### 🎨 Badges Visuales
Indicadores claros por operación:
- ➕ `CREATE` - Recursos nuevos
- 🛠️ `UPDATE` - Modificaciones
- ♻️ `REPLACE` - Reemplazos
- ❌ `DESTROY` - Eliminaciones

</td>
<td width="50%">

#### � Detección Inteligente
- Diferencia cambios funcionales vs cosméticos
- Detecta automáticamente timestamps sin impacto
- Resalta cambios críticos

#### 📏 Formato Optimizado
- Truncamiento a 80 caracteres
- Tooltips descriptivos
- Contador de recursos
- Detalles expandibles con plan completo

</td>
</tr>
</table>

### 📸 Ejemplo Visual

<div align="center">

```
📊 Vista Previa de Cambios en aws_iam_role.github_deployment

🏷️ Tipo      📋 Atributo           ⬅️ Valor Anterior      ➡️ Valor Nuevo
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
UPDATE 🛠️    description          "Rol v1.0.8"          "Rol v2.0.0 mejorado"
UPDATE 🛠️    tags.version         "1.0.8"               "2.0.0"
CREATE ➕    tags.criticidad      (nuevo)               "Alta"

💡 3 cambios detectados | Revisión recomendada antes de aplicar
```

</div>

### 🎯 Escenarios de Visualización

| Escenario | Visualización | Ejemplo |
|-----------|--------------|---------|
| ✅ **Sin Cambios** | Mensaje simple | `✅ Sin cambios pendientes` |
| ⚠️ **Solo Timestamps** | Ultra-simplificado | `⚠️ Cambios detectados (sin impacto funcional)` |
| 🔍 **Cambios Funcionales** | Tabla HTML completa | Ver ejemplo arriba |
| 📊 **Múltiples Recursos** | Tabla agrupada + contador | `📊 5 recursos | 2 CREATE, 3 UPDATE` |

---

## 🏗️ Estructura Organizacional

<div align="center">

### 🎯 Flexibilidad Total para Desarrolladores

*Crea tu propia estructura • Detección automática • Sin restricciones*

</div>

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

### 🔍 Sistema de Detección de Drift

**Detección inteligente de recursos huérfanos y discrepancias**:

```
Pre-Despliegue     │ Despliegue      │ Post-Despliegue
                   │                 │
┌─────────────────┐ │ ┌─────────────┐ │ ┌─────────────────┐
│ • Escanear AWS  │ │ │ • Aplicar TF│ │ │ • Verificar     │
│ • Buscar        │ │ │ • Limpiar   │ │ │   Estado        │
│   Huérfanos     │─┼▶│ • Desplegar │─┼▶│ • Enviar Reporte│
│ • Generar       │ │ │             │ │ │ • Alertas       │
│   Limpieza      │ │ │             │ │ │                 │
└─────────────────┘ │ └─────────────┘ │ └─────────────────┘
```

### 📊 Sistema de Notificaciones

**Reportes automáticos directamente en GitHub**:

| Tipo | Ubicación | Notificación | Configuración |
|------|-----------|--------------|---------------|
| 💬 **Comentarios en PR** | Comentarios en Pull Request | ✅ Automática GitHub | ✅ Cero configuración |
| 📋 **Issues** | Nuevo Issue en repositorio | ✅ Automática GitHub | ✅ Cero configuración |
| 🔍 **Artefactos** | Archivos descargables | ✅ En workflow | ✅ Siempre disponible |

### 🛡️ Protecciones Empresariales

- **Recursos protegidos**: Roles/políticas críticos nunca se eliminan
- **Límites inteligentes**: Límites automáticos para prevenir errores masivos
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

1. **🔍 Validar** - Validación de archivos y convenciones
2. **📋 Planificar** - Terraform plan y previsualización de cambios con tablas HTML
3. **🚀 Desplegar** - Creación/actualización de recursos en AWS
4. **✅ Verificar** - Verificación de deployment exitoso

### Activadores Automáticos

- **Push a `dev`** → Deploy a ambiente dev
- **Push a `qa`** → Deploy a ambiente qa  
- **Push a `main`** → Deploy a ambiente prod
- **Trigger manual** → Deploy a ambiente seleccionado

### Duración Esperada
- **Validación**: ~30 segundos
- **Planificación**: ~2-3 minutos (incluye generación de preview con tabla HTML)
- **Despliegue**: ~3-4 minutos
- **Verificación**: ~1-2 minutos
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
- **Generación automática** - Solo editar archivos y hacer commit
- **Validación continua** - Detecta errores antes del deploy
- **Templates reutilizables** - Copiar y adaptar roles existentes
- **Preview visual mejorado** - Tablas HTML profesionales muestran exactamente qué cambiará

### ✅ Para DevOps
- **CI/CD completo** - Deploy automático en 3 ambientes
- **Estado centralizado** - Backend S3 con locks DynamoDB
- **Rollback seguro** - Historial completo en Git + Terraform
- **Monitoreo** - Logs detallados de cada deployment
- **Visualización clara** - Preview con badges y tooltips para revisión rápida

### ✅ Para Seguridad  
- **Tags obligatorios** - Trazabilidad completa de recursos
- **Convención de nombres** - Identificación clara y consistente
- **Principio de menor privilegio** - Validaciones automáticas
- **Auditabilidad** - Cada cambio documentado y versionado
- **Detección de drift** - Identificación automática de cambios no autorizados

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

**v2.3.0** - Preview mejorado con visualización profesional + Catálogo V2 modular ABAC

**Última actualización**: Octubre 2025

### 🆕 Novedades v2.3.0
- 🎯 **Preview Mejorado**: Tablas HTML profesionales con badges visuales (➕🛠️♻️❌)
- 📊 **Visualización Inteligente**: Detecta cambios funcionales vs cosméticos (timestamps)
- 🎨 **Truncamiento y Tooltips**: Valores largos truncados a 80 caracteres con información adicional
- 📈 **Contador de Recursos**: Resumen automático por tipo de operación
- ✅ **Catálogo V2 Modular**: Políticas organizadas por servicio en YAML
- ✅ **Políticas ABAC Reales**: Tag-based access control funcional
- ✅ **Limpieza Legacy**: Eliminadas referencias a policies.yaml V1
- ✅ **Scripts Modernizados**: Solo soportan catálogo V2
