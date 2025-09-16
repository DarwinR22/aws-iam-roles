# 📚 Guía de Uso del Repositorio IAM

Esta guía te muestra cómo usar el repositorio para crear y gestionar roles IAM paso a paso.

## 🎯 Casos de Uso Comunes

### 1. Crear Rol para Lambda Function
### 2. Crear Rol para Glue ETL Job  
### 3. Crear Rol para EC2 Instance
### 4. Crear Rol con Políticas Personalizadas

---

## 🚀 Caso 1: Rol para Lambda Function

### Paso 1: Definir la Configuración

Crear archivo `lambda-config.json`:

```json
{
  "servicio": "lambda",
  "layer": "api",
  "ambiente": "dev",
  "nombre": "procesadorPagos",
  "description": "Rol para función Lambda que procesa pagos en línea",
  "policies": {
    "aws_managed": [
      "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
    ],
    "inline": {
      "Version": "2012-10-17",
      "Statement": [
        {
          "Effect": "Allow",
          "Action": [
            "dynamodb:GetItem",
            "dynamodb:PutItem",
            "dynamodb:UpdateItem"
          ],
          "Resource": "arn:aws:dynamodb:*:*:table/payments"
        }
      ]
    }
  },
  "tags": {
    "pais": "GT",
    "direccion": "Gerencia de Tecnología",
    "gerencia": "Desarrollo de Aplicaciones",
    "modulo": "Aplicación",
    "alcance_sox": "Sí",
    "propietario": "María García",
    "proveedor": "Inhouse",
    "dominio": "FinTech",
    "subdominio": "Pagos",
    "aplicacion": "PAYMENT-PROCESSOR-V2",
    "soporte": "Equipo Backend",
    "contacto": "backend-team@empresa.com",
    "proyecto": "PROJ-2024-PAGOS",
    "creado_por": "maria.garcia@empresa.com",
    "ciclo_vida": "Implementación",
    "version": "1.0.0"
  }
}
```

### Paso 2: Generar el Rol

```bash
# Generar estructura y archivos
python3 scripts/generate_role.py lambda-config.json \
  --gerencia tecnologia \
  --area aplicaciones
```

### Paso 3: Completar Variables

```bash
cd gerencias/tecnologia/aplicaciones
cp terraform.tfvars.example terraform.tfvars

# Editar terraform.tfvars
nano terraform.tfvars
```

Contenido de `terraform.tfvars`:
```hcl
# Configuración del ambiente
ambiente     = "dev"
aws_region   = "us-east-1"
account_name = "dev-applications-account"

# Información del responsable
pais             = "GT"
propietario      = "María García"
soporte_email    = "backend-team@empresa.com"
proyecto_codigo  = "PROJ-2024-PAGOS"
creado_por      = "maria.garcia@empresa.com"
ciclo_vida      = "Implementación"
version         = "1.0.0"
```

### Paso 4: Validar y Desplegar

```bash
# Validar localmente
./scripts/validate.sh

# Crear rama y commit
git checkout -b feature/rol-lambda-pagos
git add .
git commit -m "feat: agregar rol Lambda para procesador de pagos"
git push origin feature/rol-lambda-pagos

# Crear Pull Request a develop → despliega a DEV
```

---

## 🔄 Caso 2: Rol para Glue ETL Job

### Configuración Específica

```json
{
  "servicio": "glue",
  "layer": "data-analytics",
  "ambiente": "qa",
  "nombre": "transformadorVentas",
  "description": "Rol para job de Glue que transforma datos de ventas",
  "policies": {
    "aws_managed": [
      "arn:aws:iam::aws:policy/service-role/AWSGlueServiceRole",
      "arn:aws:iam::aws:policy/AmazonS3FullAccess"
    ]
  },
  "tags": {
    "pais": "CR",
    "direccion": "Gerencia de Datos",
    "gerencia": "Analytics & BI",
    "modulo": "Aplicación",
    "alcance_sox": "No",
    "propietario": "Carlos Rodríguez",
    "proveedor": "Inhouse",
    "dominio": "Data",
    "subdominio": "ETL",
    "aplicacion": "SALES-DATA-PIPELINE",
    "soporte": "Equipo Data Engineering",
    "contacto": "data-eng@empresa.com",
    "proyecto": "PROJ-2024-ANALYTICS",
    "creado_por": "carlos.rodriguez@empresa.com",
    "ciclo_vida": "Creación",
    "version": "1.0.0"
  }
}
```

---

## 🖥️ Caso 3: Rol para EC2 Instance

### Configuración con Políticas Personalizadas

```json
{
  "servicio": "ec2",
  "layer": "infrastructure",
  "ambiente": "prod",
  "nombre": "webServer",
  "description": "Rol para instancias EC2 que hospedan aplicaciones web",
  "policies": {
    "aws_managed": [
      "arn:aws:iam::aws:policy/CloudWatchAgentServerPolicy"
    ],
    "inline": {
      "Version": "2012-10-17",
      "Statement": [
        {
          "Effect": "Allow",
          "Action": [
            "s3:GetObject"
          ],
          "Resource": "arn:aws:s3:::mi-bucket-config/*"
        },
        {
          "Effect": "Allow",
          "Action": [
            "ssm:GetParameter",
            "ssm:GetParameters"
          ],
          "Resource": "arn:aws:ssm:*:*:parameter/app/*"
        }
      ]
    }
  },
  "tags": {
    "pais": "SV",
    "direccion": "Gerencia de Infraestructura",
    "gerencia": "Cloud Operations",
    "modulo": "Aplicación",
    "alcance_sox": "Sí",
    "propietario": "Ana López",
    "proveedor": "Inhouse",
    "dominio": "Infrastructure",
    "subdominio": "Compute",
    "aplicacion": "WEB-FRONTEND-PROD",
    "soporte": "Equipo DevOps",
    "contacto": "devops@empresa.com",
    "proyecto": "PROJ-2024-FRONTEND",
    "creado_por": "ana.lopez@empresa.com",
    "ciclo_vida": "MonitoreoYMantenimiento",
    "version": "2.1.0"
  }
}
```

---

## 🔧 Flujos de Trabajo Avanzados

### 1. Crear Múltiples Roles Relacionados

```bash
# Crear varios roles para un mismo proyecto
python3 scripts/generate_role.py lambda-api-config.json --gerencia tecnologia --area backend
python3 scripts/generate_role.py lambda-worker-config.json --gerencia tecnologia --area backend
python3 scripts/generate_role.py dynamodb-config.json --gerencia tecnologia --area databases

# Todos en el mismo commit
git add .
git commit -m "feat: agregar roles completos para sistema de pagos"
```

### 2. Actualizar Rol Existente

```bash
# Editar archivo .tf existente
cd gerencias/tecnologia/aplicaciones
nano procesador-pagos.tf

# Agregar nueva política
# Actualizar versión en tags
# Commit cambios
git add .
git commit -m "feat: agregar permisos SNS a rol procesador-pagos"
```

### 3. Promoción de Ambiente

```bash
# DEV → QA
git checkout qa
git merge develop
git push origin qa

# QA → PROD (requiere PR y aprobación)
git checkout -b promote/qa-to-prod
git merge qa
# Actualizar archivos .tfvars para prod si es necesario
git push origin promote/qa-to-prod
# Crear PR a main
```

---

## 🔍 Validaciones y Testing

### Validación Local Completa

```bash
# Validar sintaxis de Terraform
terraform fmt -check=true -recursive .

# Validar convenciones y tags
./scripts/validate.sh

# Validar rol específico
python3 scripts/validate_iam.py gerencias/tecnologia/aplicaciones/procesador-pagos.tf

# Validar nombre de rol
python3 scripts/validate_iam.py --role-name "rol-lambda-api-dev-procesadorPagos"
```

### Testing en DEV

```bash
# Después del despliegue, verificar en AWS
aws iam get-role --role-name rol-lambda-api-dev-procesadorPagos --profile dev

# Verificar políticas adjuntas
aws iam list-attached-role-policies --role-name rol-lambda-api-dev-procesadorPagos --profile dev

# Verificar tags
aws iam list-role-tags --role-name rol-lambda-api-dev-procesadorPagos --profile dev
```

---

## 🚨 Manejo de Errores Comunes

### Error: "Tag obligatorio faltante"

```bash
# Error
❌ Tags obligatorios faltantes: alcance_sox, propietario

# Solución
✅ Completar todos los 19 tags obligatorios en la configuración JSON
```

### Error: "Nombre de rol inválido"

```bash
# Error  
❌ rol-Lambda-API-dev-processor

# Solución
✅ rol-lambda-api-dev-processor
```

### Error: "Backend configuration failed"

```bash
# Verificar que el bucket S3 existe
aws s3 ls s3://tu-empresa-terraform-state-dev --profile dev

# Verificar variables en GitHub
# TERRAFORM_STATE_BUCKET_DEV debe coincidir con el bucket real
```

---

## 📋 Checklist de Verificación

Antes de hacer commit, verificar:

- ✅ **Convención de nombres** seguida correctamente
- ✅ **Todos los 19 tags** completados
- ✅ **Validaciones locales** pasadas
- ✅ **Archivos tfvars** configurados
- ✅ **Descripción clara** del rol
- ✅ **Políticas mínimas** necesarias (principio de menor privilegio)
- ✅ **Mensaje de commit** descriptivo

---

## 🎯 Mejores Prácticas

### 1. Principio de Menor Privilegio
- Solo otorgar permisos específicos necesarios
- Evitar políticas `*` en producción
- Revisar permisos periódicamente

### 2. Organización
- Agrupar roles relacionados en la misma área
- Usar nombres descriptivos y consistentes
- Documentar propósito de cada rol

### 3. Seguridad
- Siempre completar alcance SOX para PROD
- Usar MFA cuando sea requerido
- Rotar credenciales regularmente

### 4. Versionado
- Incrementar versión al hacer cambios
- Documentar cambios significativos
- Mantener historial en commits

---

## 📞 Obtener Ayuda

### Documentación
- [Convenciones](CONVENTIONS.md) - Reglas y estándares
- [Despliegue](DEPLOYMENT.md) - Guía de despliegue
- [Setup](SETUP.md) - Configuración inicial

### Soporte
- **Equipo DevOps**: devops@empresa.com
- **Equipo Seguridad**: security@empresa.com  
- **Issues GitHub**: Crear issue con detalles del problema

¡Listo para crear tu primer rol IAM! 🚀
