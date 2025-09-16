# 🎯 Configuración del Repositorio IAM - Escenario GitHub Actions

## 🚀 **Setup Completo - Solo para Administradores**

### **1. Configurar AWS (Una sola vez)**

**Solo el administrador necesita ejecutar esto:**

```bash
# Para Linux/Mac
./setup-aws-admin.sh

# Para Windows  
setup-aws-admin.bat
```

Esto crea automáticamente:
- ✅ Bucket S3 para estado de Terraform
- ✅ Tabla DynamoDB para locks
- ✅ Usuario IAM para GitHub Actions
- ✅ Políticas y permisos necesarios
- ✅ Access Keys para GitHub

### **2. Configurar GitHub Repository**

**Configurar Secrets** (Settings → Secrets and variables → Actions):
```
AWS_ACCESS_KEY_ID_DEV=AKIA...
AWS_SECRET_ACCESS_KEY_DEV=...
```

**Configurar Variables**:
```
TERRAFORM_STATE_BUCKET_DEV=mci-terraform-state-dev-123456789
TERRAFORM_LOCK_TABLE_DEV=terraform-locks-dev
AWS_REGION=us-east-1
```

---

## 👨‍💻 **Para Desarrolladores - Sin Instalaciones**

### **Prerequisitos ÚNICOS:**
- ✅ Git (para commits)
- ✅ Editor de texto/VS Code
- ❌ NO necesitas AWS CLI
- ❌ NO necesitas Terraform
- ❌ NO necesitas Python

### **Flujo de Trabajo Completo:**

#### **Paso 1: Clonar repositorio**
```bash
git clone https://github.com/ClaroCENAM/mci-aws-iam.git
cd mci-aws-iam
```

#### **Paso 2: Crear archivo JSON de configuración**
```json
// mi-rol-lambda.json
{
  "servicio": "lambda",
  "layer": "api",
  "ambiente": "dev",
  "nombre": "procesadorPagos", 
  "description": "Rol para Lambda que procesa pagos",
  "policies": {
    "aws_managed": [
      "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
    ]
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

#### **Paso 3: Commit y Push**
```bash
git add mi-rol-lambda.json
git commit -m "feat: agregar rol Lambda para procesador de pagos"
git push origin develop
```

#### **Paso 4: GitHub Actions se ejecuta automáticamente**
```
✅ Validación automática
✅ Generación de código Terraform  
✅ Despliegue a DEV
✅ Notificación de resultados
```

#### **Paso 5: Promoción entre ambientes**
```bash
# Para QA
git checkout qa
git merge develop
git push origin qa
# → GitHub Actions despliega a QA

# Para PROD (requiere PR y aprobación)
git checkout -b promote/release-v1.2.0
git merge qa
git push origin promote/release-v1.2.0
# → Crear PR a main → Aprobación manual → Despliegue a PROD
```

---

## 🔄 **Workflows Automáticos**

### **En cada Push a develop:**
1. **Validación** (`validate.yml`)
   - Sintaxis JSON
   - Tags obligatorios (19)
   - Convención de nombres
   - Políticas de seguridad

2. **Despliegue** (`deploy.yml`)
   - Generación automática de Terraform
   - Terraform plan
   - Terraform apply
   - Notificación de resultados

### **En cada Pull Request:**
- Validación completa sin despliegue
- Plan de cambios para revisión
- Comentarios automáticos en PR

---

## 📋 **Ejemplos Listos para Usar**

### **Lambda Function**
```json
{
  "servicio": "lambda",
  "layer": "api",
  "policies": {
    "aws_managed": ["arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"]
  }
}
```

### **Glue ETL Job**
```json
{
  "servicio": "glue",
  "layer": "data-analytics", 
  "policies": {
    "aws_managed": [
      "arn:aws:iam::aws:policy/service-role/AWSGlueServiceRole",
      "arn:aws:iam::aws:policy/AmazonS3ReadOnlyAccess"
    ]
  }
}
```

### **EC2 Instance Profile**
```json
{
  "servicio": "ec2",
  "layer": "infrastructure",
  "policies": {
    "aws_managed": ["arn:aws:iam::aws:policy/CloudWatchAgentServerPolicy"],
    "inline": {
      "Version": "2012-10-17",
      "Statement": [
        {
          "Effect": "Allow",
          "Action": ["s3:GetObject"],
          "Resource": "arn:aws:s3:::mi-bucket/*"
        }
      ]
    }
  }
}
```

---

## 🛡️ **Validaciones Automáticas**

### **Convención de Nombres:**
- ✅ Patrón: `rol-[servicio]-[layer]-[ambiente]-[nombre]`
- ✅ Solo letras minúsculas, números y guiones
- ✅ Máximo 64 caracteres

### **Tags Obligatorios (19):**
```
pais, direccion, gerencia, modulo, alcance_sox,
propietario, proveedor, dominio, subdominio, aplicacion,
soporte, contacto, proyecto, creado_por, ciclo_vida, version
```

### **Políticas de Seguridad:**
- ✅ No políticas con `*` en producción
- ✅ Principio de menor privilegio
- ✅ Validación de ARNs de políticas AWS

---

## 🎉 **Beneficios del Escenario B**

### **Para Desarrolladores:**
- ❌ Cero instalaciones locales
- ✅ Solo Git + JSON + Commits
- ✅ Feedback inmediato en GitHub
- ✅ Rollback automático si hay errores

### **Para DevOps:**
- ✅ Control total vía GitHub Actions
- ✅ Auditabilidad completa
- ✅ Estado centralizado en S3
- ✅ Logs detallados de cada cambio

### **Para Seguridad:**
- ✅ Validaciones automáticas
- ✅ Tags obligatorios
- ✅ Revisión de código vía PRs
- ✅ Principio de menor privilegio

---

## 🚨 **Solución de Problemas**

### **Error: "Workflow failed"**
1. Revisar logs en GitHub Actions
2. Verificar sintaxis JSON
3. Validar todos los 19 tags

### **Error: "Access denied"**
1. Verificar AWS credentials en GitHub Secrets
2. Verificar políticas del usuario IAM
3. Verificar permisos en bucket S3

### **Error: "Role name invalid"**
1. Usar solo letras minúsculas en servicio/layer/ambiente
2. Mantener nombre descriptivo pero corto
3. Seguir patrón exacto: `rol-servicio-layer-ambiente-nombre`

---

## 📞 **Soporte**

- **GitHub Issues**: Para reportar problemas técnicos
- **Documentación**: `docs/` para guías detalladas  
- **Equipo DevOps**: devops@empresa.com
- **Equipo Seguridad**: security@empresa.com

---

## 🎯 **¡Listo para producir!**

El repositorio está configurado para que **cualquier desarrollador** pueda:

1. **Clonar** el repositorio
2. **Crear** archivo JSON de configuración
3. **Hacer commit** y push
4. **Obtener** rol IAM desplegado automáticamente

**Sin instalar nada más que Git.** 🚀
