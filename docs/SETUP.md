# ⚙️ Guía Completa de Configuración

Esta guía te ayudará a configurar completamente el repositorio de gestión IAM desde cero.

## 🎯 Pre-requisitos

### Herramientas Requeridas
- **Git** (v2.30+)
- **Terraform** (v1.6.0+)
- **Python** (v3.8+)
- **AWS CLI** (v2.0+)
- **Cuenta GitHub** con permisos de administrador en el repositorio

### Conocimientos Necesarios
- Conceptos básicos de AWS IAM
- Uso básico de Terraform
- Flujo de trabajo con Git/GitHub

## 🔧 Configuración de AWS

### 1. Preparar Cuentas AWS

Necesitarás **3 cuentas AWS separadas** (recomendado) o al menos **1 cuenta con separación por regiones/tags**:

```bash
# Estructura recomendada:
# - Cuenta DEV:  123456789012
# - Cuenta QA:   234567890123  
# - Cuenta PROD: 345678901234
```

### 2. Crear Usuario IAM para GitHub Actions

En **cada cuenta AWS**, crear un usuario IAM con los siguientes permisos:

```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "iam:CreateRole",
        "iam:DeleteRole",
        "iam:GetRole",
        "iam:ListRoles",
        "iam:UpdateRole",
        "iam:AttachRolePolicy",
        "iam:DetachRolePolicy",
        "iam:ListAttachedRolePolicies",
        "iam:CreatePolicy",
        "iam:DeletePolicy",
        "iam:GetPolicy",
        "iam:ListPolicies",
        "iam:CreatePolicyVersion",
        "iam:DeletePolicyVersion",
        "iam:ListPolicyVersions",
        "iam:PutRolePolicy",
        "iam:DeleteRolePolicy",
        "iam:GetRolePolicy",
        "iam:ListRolePolicies",
        "iam:TagRole",
        "iam:UntagRole",
        "iam:ListRoleTags"
      ],
      "Resource": "*"
    },
    {
      "Effect": "Allow",
      "Action": [
        "s3:GetObject",
        "s3:PutObject",
        "s3:DeleteObject",
        "s3:ListBucket"
      ],
      "Resource": [
        "arn:aws:s3:::TU-BUCKET-TERRAFORM-STATE-*",
        "arn:aws:s3:::TU-BUCKET-TERRAFORM-STATE-*/*"
      ]
    }
  ]
}
```

### 3. Crear Buckets S3 para Estado de Terraform

**En cada cuenta AWS**:

```bash
# Para DEV
aws s3 mb s3://tu-empresa-terraform-state-dev --region us-east-1

# Para QA
aws s3 mb s3://tu-empresa-terraform-state-qa --region us-east-1

# Para PROD  
aws s3 mb s3://tu-empresa-terraform-state-prod --region us-east-1
```

### 4. Configurar Versionado y Cifrado

```bash
# Habilitar versionado (para cada bucket)
aws s3api put-bucket-versioning \
  --bucket tu-empresa-terraform-state-dev \
  --versioning-configuration Status=Enabled

# Habilitar cifrado
aws s3api put-bucket-encryption \
  --bucket tu-empresa-terraform-state-dev \
  --server-side-encryption-configuration '{
    "Rules": [{
      "ApplyServerSideEncryptionByDefault": {
        "SSEAlgorithm": "AES256"
      }
    }]
  }'

# Repetir para QA y PROD
```

## 🐙 Configuración de GitHub

### 1. Secrets del Repositorio

Ve a **Settings → Secrets and Variables → Actions** y configura:

```bash
# Secrets para DEV
AWS_ACCESS_KEY_ID_DEV=AKIA...
AWS_SECRET_ACCESS_KEY_DEV=wJalrXUtn...

# Secrets para QA
AWS_ACCESS_KEY_ID_QA=AKIA...
AWS_SECRET_ACCESS_KEY_QA=wJalrXUtn...

# Secrets para PROD
AWS_ACCESS_KEY_ID_PROD=AKIA...
AWS_SECRET_ACCESS_KEY_PROD=wJalrXUtn...

# Opcional: Si usas Assume Role
AWS_ROLE_ARN_DEV=arn:aws:iam::123456789012:role/github-actions-role
AWS_ROLE_ARN_QA=arn:aws:iam::234567890123:role/github-actions-role
AWS_ROLE_ARN_PROD=arn:aws:iam::345678901234:role/github-actions-role
```

### 2. Variables del Repositorio

En **Settings → Secrets and Variables → Actions → Variables**:

```bash
# Regiones AWS
AWS_REGION_DEV=us-east-1
AWS_REGION_QA=us-east-1
AWS_REGION_PROD=us-east-1

# Buckets de Terraform State
TERRAFORM_STATE_BUCKET_DEV=tu-empresa-terraform-state-dev
TERRAFORM_STATE_BUCKET_QA=tu-empresa-terraform-state-qa
TERRAFORM_STATE_BUCKET_PROD=tu-empresa-terraform-state-prod
```

### 3. Configurar Protección de Ramas

Ve a **Settings → Branches** y configura:

#### Para rama `main` (PROD):
- ✅ **Require a pull request before merging**
- ✅ **Require approvals** (mínimo 2)
- ✅ **Dismiss stale PR approvals when new commits are pushed**
- ✅ **Require review from code owners**
- ✅ **Require status checks to pass before merging**
- ✅ **Require up-to-date branches before merging**
- ✅ **Include administrators**

#### Para rama `qa`:
- ✅ **Require a pull request before merging**
- ✅ **Require approvals** (mínimo 1)
- ✅ **Require status checks to pass before merging**

#### Para rama `develop`:
- ✅ **Require a pull request before merging**
- ✅ **Require status checks to pass before merging**

### 4. Configurar Environments

Ve a **Settings → Environments** y crea:

#### Environment: `dev`
- **Deployment branches**: `develop`
- **Environment secrets**: (si necesitas secrets específicos)

#### Environment: `qa`  
- **Deployment branches**: `qa`
- **Required reviewers**: Al menos 1 persona

#### Environment: `prod`
- **Deployment branches**: `main`  
- **Required reviewers**: Al menos 2 personas (incluir equipo de seguridad)
- **Wait timer**: 5 minutos (opcional)

## 🏢 Configuración Organizacional

### 1. Definir Estructura de Gerencias

Edita el archivo `environments/common.tfvars` con tu estructura:

```hcl
# Información de tu organización
organization = "Tu Empresa"
company_code = "TU-CODE"

# Cuentas AWS reales
aws_accounts = {
  dev  = "123456789012"  # Tu cuenta DEV real
  qa   = "234567890123"  # Tu cuenta QA real  
  prod = "345678901234"  # Tu cuenta PROD real
}

# Buckets reales
terraform_state_buckets = {
  dev  = "tu-empresa-terraform-state-dev"
  qa   = "tu-empresa-terraform-state-qa"  
  prod = "tu-empresa-terraform-state-prod"
}
```

### 2. Personalizar Tags Corporativos

```hcl
corporate_tags = {
  Organization = "Tu Empresa"
  Company      = "Tu Empresa S.A."
  ManagedBy    = "Terraform"
  Repository   = "tu-repo-iam"
}
```

### 3. Ajustar Países y Regiones

```hcl
naming_standards = {
  allowed_countries = ["GT", "SV", "NI", "HN", "CR", "RG", "MX", "CO"]  # Agregar los que necesites
  # ... resto de configuración
}
```

## 🔧 Configuración Local

### 1. Clonar y Configurar Repositorio

```bash
# Clonar repositorio
git clone https://github.com/tu-org/tu-repo-iam.git
cd tu-repo-iam

# Configurar Python
python3 -m venv venv
source venv/bin/activate  # En Windows: venv\Scripts\activate
pip install -r requirements.txt  # Si existe

# Hacer scripts ejecutables (en Linux/Mac)
chmod +x scripts/*.sh
chmod +x scripts/*.py
```

### 2. Configurar Pre-commit (Opcional pero Recomendado)

```bash
# Instalar pre-commit
pip install pre-commit

# Instalar hooks
pre-commit install

# Probar hooks
pre-commit run --all-files
```

### 3. Configurar AWS CLI Local

```bash
# Configurar perfil para cada ambiente
aws configure --profile dev
aws configure --profile qa  
aws configure --profile prod

# Probar conectividad
aws sts get-caller-identity --profile dev
aws sts get-caller-identity --profile qa
aws sts get-caller-identity --profile prod
```

## ✅ Verificación de Configuración

### 1. Test de Conectividad AWS

```bash
# Probar que puedes listar roles en cada cuenta
aws iam list-roles --profile dev --query 'Roles[0].RoleName'
aws iam list-roles --profile qa --query 'Roles[0].RoleName'  
aws iam list-roles --profile prod --query 'Roles[0].RoleName'
```

### 2. Test de Buckets S3

```bash
# Probar acceso a buckets de estado
aws s3 ls s3://tu-empresa-terraform-state-dev --profile dev
aws s3 ls s3://tu-empresa-terraform-state-qa --profile qa
aws s3 ls s3://tu-empresa-terraform-state-prod --profile prod
```

### 3. Test de Validaciones

```bash
# Probar script de validación
python3 scripts/validate_iam.py --role-name "rol-lambda-api-dev-test"

# Probar validación completa
./scripts/validate.sh
```

### 4. Test de GitHub Actions

```bash
# Crear rama de prueba
git checkout -b test/configuracion
echo "# Test" > test.md
git add test.md
git commit -m "test: verificar configuración"
git push origin test/configuracion

# Crear PR y verificar que los workflows corren correctamente
```

## 🚨 Solución de Problemas Comunes

### Error: "Bucket does not exist"
- Verificar que los buckets S3 existen en las cuentas correctas
- Verificar nombres de buckets en variables de GitHub

### Error: "Access Denied" en AWS
- Verificar que las credenciales son correctas
- Verificar que el usuario IAM tiene los permisos necesarios
- Verificar que las cuentas AWS son correctas

### Error: "Workflow failed"
- Verificar que todos los secrets están configurados
- Verificar que las variables de repositorio son correctas
- Revisar logs detallados en GitHub Actions

## 📞 Soporte

Si tienes problemas con la configuración:

1. **Revisar logs** de GitHub Actions
2. **Verificar documentación** de AWS y Terraform
3. **Contactar equipo** de DevOps/Infraestructura
4. **Crear issue** en el repositorio con detalles del error

## 🎯 Siguiente Paso

Una vez completada la configuración, ve a la [Guía de Uso](USAGE.md) para crear tu primer rol IAM.
