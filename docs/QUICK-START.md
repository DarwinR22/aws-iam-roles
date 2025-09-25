# 🚀 Configuración Rápida - Lista de Verificación

## ✅ Para el administrador del repositorio (tú):

### 1. **Preparar Cuentas AWS**
- [ ] Crear 3 cuentas AWS: `dev`, `qa`, `prod`
- [ ] Configurar AWS Organizations (opcional pero recomendado)
- [ ] Obtener credenciales administrativas para cada cuenta

### 2. **Configurar GitHub Repository** 
- [ ] Crear usuarios IAM para CI/CD en cada cuenta AWS
- [ ] Configurar secrets en GitHub Actions:
  - `AWS_ACCESS_KEY_ID_DEV`
  - `AWS_SECRET_ACCESS_KEY_DEV` 
  - `AWS_ACCESS_KEY_ID_QA`
  - `AWS_SECRET_ACCESS_KEY_QA`
  - `AWS_ACCESS_KEY_ID_PROD`
  - `AWS_SECRET_ACCESS_KEY_PROD`
- [ ] Configurar variables en GitHub Actions:
  - `AWS_REGION=us-east-1`
  - `TERRAFORM_LOCK_TABLE=terraform-locks`

---

## 🔧 Para cualquier usuario que haga clone:

### **Paso Único - Ejecutar Script de Setup**

#### En Windows:
```powershell
# Clonar repositorio
git clone https://github.com/ClaroCENAM/mci-aws-iam.git
cd mci-aws-iam

# Ejecutar configuración automática
./setup-dev.bat
```

#### En Linux/Mac:
```bash
# Clonar repositorio  
git clone https://github.com/ClaroCENAM/mci-aws-iam.git
cd mci-aws-iam

# Hacer ejecutable y correr
chmod +x setup-dev.sh
./setup-dev.sh
```

### **¿Qué hace el script automáticamente?**

✅ **Verifica prerequisitos**: AWS CLI, Terraform, Python, Git  
✅ **Configura perfil AWS**: Solicita credenciales para cuenta DEV  
✅ **Crea bucket S3**: Para almacenar estado de Terraform  
✅ **Crea tabla DynamoDB**: Para locks de Terraform  
✅ **Genera archivos config**: `.env.dev`, `.gitignore`, templates  
✅ **Configura permisos**: Scripts ejecutables  

### **Verificar instalación:**
```bash
# Windows
validate-setup.bat

# Linux/Mac  
./validate-setup.sh
```

---

## 🎯 Uso Inmediato - Crear primer rol

Una vez configurado, crear un rol es súper simple:

### 1. **Crear archivo de configuración:**
```json
{
  "servicio": "lambda",
  "layer": "api", 
  "ambiente": "dev",
  "nombre": "miPrimeraFuncion",
  "description": "Mi primera función Lambda",
  "policies": {
    "aws_managed": [
      "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
    ]
  },
  "tags": {
    "pais": "GT",
    "direccion": "Gerencia de Tecnología",
    "gerencia": "Desarrollo",
    "modulo": "Aplicación", 
    "alcance_sox": "No",
    "propietario": "Juan Pérez",
    "proveedor": "Inhouse",
    "dominio": "Applications",
    "subdominio": "API",
    "aplicacion": "MY-FIRST-APP",
    "soporte": "Equipo DevOps",
    "contacto": "devops@empresa.com",
    "proyecto": "PROJ-2025-DEMO",
    "creado_por": "juan.perez@empresa.com",
    "ciclo_vida": "Implementación",
    "version": "1.0.0"
  }
}
```

### 2. **Generar rol:**
```bash
python scripts/generate_role.py mi-config.json \
  --gerencia tecnologia \
  --area desarrollo
```

### 3. **Configurar y desplegar:**
```bash
cd gerencias/tecnologia/desarrollo
cp terraform.tfvars.example terraform.tfvars
# Editar terraform.tfvars con tus datos

terraform init
terraform plan
terraform apply
```

**¡Listo!** Tu rol `rol-lambda-api-dev-miPrimeraFuncion` está creado en AWS.

---

## 📋 Requisitos de Usuario

### **Credenciales necesarias:**
- AWS Access Key ID para cuenta DEV
- AWS Secret Access Key para cuenta DEV
- Región AWS (recomendado: `us-east-1`)

### **Software requerido:**
- AWS CLI v2.0+
- Terraform v1.6.0+
- Python 3.8+
- Git

### **Permisos AWS necesarios:**
- Crear y gestionar roles IAM
- Crear y gestionar buckets S3
- Crear y gestionar tablas DynamoDB
- AssumeRole en recursos creados

---

## 🆘 Solución de Problemas

### Error: "AWS CLI not found"
```bash
# Instalar AWS CLI
# Windows: https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html
# Mac: brew install awscli
# Linux: sudo apt install awscli
```

### Error: "Terraform not found"
```bash
# Instalar Terraform
# https://terraform.io/downloads
```

### Error: "Access Denied"
```bash
# Verificar credenciales
aws sts get-caller-identity --profile dev

# Verificar permisos IAM necesarios
```

### Error: "Bucket already exists"
```bash
# El script maneja esto automáticamente
# Si persiste, usar bucket name único
```

---

## 📞 Soporte

- **Documentación completa**: `docs/`
- **Scripts de validación**: `validate-setup.sh` / `validate-setup.bat`
- **Ejemplos detallados**: `docs/USAGE.md`
- **Convenciones**: `docs/CONVENTIONS.md`

---

## 🎉 ¡Listo!

Con estos scripts, **cualquier persona** puede clonar el repo y estar funcionando en **menos de 5 minutos**.

**Solo necesita ejecutar un comando y seguir las instrucciones.**
