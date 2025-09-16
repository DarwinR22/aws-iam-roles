#!/bin/bash
# =============================================================================
# Script de Configuración Automática - AWS IAM Repository
# =============================================================================
# Este script configura todo lo necesario para usar el repositorio
# Ejecutar: ./setup-dev.sh

set -e  # Salir si hay error

echo "🚀 Configurando Repositorio AWS IAM para DEV..."
echo "================================================"

# Colores para output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# Función para imprimir mensajes
print_step() {
    echo -e "${GREEN}✅ $1${NC}"
}

print_warning() {
    echo -e "${YELLOW}⚠️  $1${NC}"
}

print_error() {
    echo -e "${RED}❌ $1${NC}"
}

# =============================================================================
# 1. VERIFICAR PREREQUISITOS
# =============================================================================
echo ""
echo "1️⃣  Verificando prerequisitos..."

# Verificar AWS CLI
if ! command -v aws &> /dev/null; then
    print_error "AWS CLI no está instalado"
    echo "Instalar desde: https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html"
    exit 1
fi
print_step "AWS CLI encontrado: $(aws --version)"

# Verificar Terraform
if ! command -v terraform &> /dev/null; then
    print_error "Terraform no está instalado"
    echo "Instalar desde: https://terraform.io/downloads"
    exit 1
fi
print_step "Terraform encontrado: $(terraform version | head -n1)"

# Verificar Python
if ! command -v python3 &> /dev/null; then
    print_error "Python 3 no está instalado"
    exit 1
fi
print_step "Python encontrado: $(python3 --version)"

# Verificar Git
if ! command -v git &> /dev/null; then
    print_error "Git no está instalado"
    exit 1
fi
print_step "Git encontrado: $(git --version)"

# =============================================================================
# 2. CONFIGURAR PERFIL AWS DEV
# =============================================================================
echo ""
echo "2️⃣  Configurando perfil AWS DEV..."

# Verificar si existe perfil dev
if aws configure list-profiles | grep -q "^dev$"; then
    print_step "Perfil AWS 'dev' ya existe"
else
    print_warning "Configurando perfil AWS 'dev'..."
    echo ""
    echo "Necesitas las credenciales de la cuenta DEV:"
    echo "- AWS Access Key ID"
    echo "- AWS Secret Access Key"
    echo "- Región (recomendado: us-east-1)"
    echo ""
    
    aws configure --profile dev
    print_step "Perfil AWS 'dev' configurado"
fi

# Verificar conexión
echo ""
echo "Verificando conexión a AWS..."
if aws sts get-caller-identity --profile dev &> /dev/null; then
    ACCOUNT_ID=$(aws sts get-caller-identity --profile dev --query Account --output text)
    print_step "Conexión exitosa a cuenta AWS: $ACCOUNT_ID"
else
    print_error "No se pudo conectar a AWS con perfil 'dev'"
    echo "Verifica las credenciales y vuelve a ejecutar el script"
    exit 1
fi

# =============================================================================
# 3. CREAR BUCKET S3 PARA TERRAFORM STATE
# =============================================================================
echo ""
echo "3️⃣  Configurando bucket S3 para Terraform state..."

# Obtener región configurada
AWS_REGION=$(aws configure get region --profile dev)
if [ -z "$AWS_REGION" ]; then
    AWS_REGION="us-east-1"
    print_warning "Región no configurada, usando: $AWS_REGION"
fi

# Nombre del bucket (debe ser único globalmente)
BUCKET_NAME="mci-terraform-state-dev-$ACCOUNT_ID"

# Verificar si el bucket existe
if aws s3 ls "s3://$BUCKET_NAME" --profile dev &> /dev/null; then
    print_step "Bucket S3 ya existe: $BUCKET_NAME"
else
    print_warning "Creando bucket S3: $BUCKET_NAME"
    
    # Crear bucket
    if [ "$AWS_REGION" = "us-east-1" ]; then
        aws s3 mb "s3://$BUCKET_NAME" --profile dev
    else
        aws s3 mb "s3://$BUCKET_NAME" --region "$AWS_REGION" --profile dev
    fi
    
    # Habilitar versionado
    aws s3api put-bucket-versioning \
        --bucket "$BUCKET_NAME" \
        --versioning-configuration Status=Enabled \
        --profile dev
    
    # Habilitar encriptación
    aws s3api put-bucket-encryption \
        --bucket "$BUCKET_NAME" \
        --server-side-encryption-configuration '{
            "Rules": [
                {
                    "ApplyServerSideEncryptionByDefault": {
                        "SSEAlgorithm": "AES256"
                    }
                }
            ]
        }' \
        --profile dev
    
    print_step "Bucket S3 creado y configurado: $BUCKET_NAME"
fi

# =============================================================================
# 4. CREAR TABLA DYNAMODB PARA LOCKS
# =============================================================================
echo ""
echo "4️⃣  Configurando tabla DynamoDB para locks de Terraform..."

TABLE_NAME="terraform-locks-dev"

# Verificar si la tabla existe
if aws dynamodb describe-table --table-name "$TABLE_NAME" --profile dev &> /dev/null; then
    print_step "Tabla DynamoDB ya existe: $TABLE_NAME"
else
    print_warning "Creando tabla DynamoDB: $TABLE_NAME"
    
    aws dynamodb create-table \
        --table-name "$TABLE_NAME" \
        --attribute-definitions AttributeName=LockID,AttributeType=S \
        --key-schema AttributeName=LockID,KeyType=HASH \
        --billing-mode PAY_PER_REQUEST \
        --region "$AWS_REGION" \
        --profile dev
    
    print_step "Tabla DynamoDB creada: $TABLE_NAME"
fi

# =============================================================================
# 5. CREAR ARCHIVO DE CONFIGURACIÓN LOCAL
# =============================================================================
echo ""
echo "5️⃣  Creando archivo de configuración local..."

# Crear archivo .env para el repositorio
cat > .env.dev << EOF
# Configuración para ambiente DEV
# ================================
# Este archivo es generado automáticamente por setup-dev.sh
# NO commitear este archivo en Git

# AWS Configuration
AWS_PROFILE=dev
AWS_REGION=$AWS_REGION
AWS_ACCOUNT_ID=$ACCOUNT_ID

# Terraform Backend
TERRAFORM_STATE_BUCKET=$BUCKET_NAME
TERRAFORM_LOCK_TABLE=$TABLE_NAME

# Project Settings
AMBIENTE=dev
PROJECT_NAME=mci-aws-iam

# Generated on: $(date)
EOF

print_step "Archivo .env.dev creado"

# Crear .gitignore si no existe
if [ ! -f .gitignore ]; then
    cat > .gitignore << EOF
# Terraform
*.tfstate
*.tfstate.*
*.tfvars
.terraform/
.terraform.lock.hcl

# Environment files
.env*
!.env.example

# IDE
.vscode/
.idea/
*.swp
*.swo

# OS
.DS_Store
Thumbs.db

# Python
__pycache__/
*.pyc
*.pyo
*.pyd
.Python
build/
develop-eggs/
dist/
downloads/
eggs/
.eggs/
lib/
lib64/
parts/
sdist/
var/
wheels/
*.egg-info/
.installed.cfg
*.egg

# Logs
*.log
EOF
    print_step ".gitignore creado"
fi

# =============================================================================
# 6. CREAR SCRIPT DE VALIDACIÓN
# =============================================================================
echo ""
echo "6️⃣  Creando script de validación..."

cat > validate-setup.sh << 'EOF'
#!/bin/bash
# Script para validar que la configuración está correcta

echo "🔍 Validando configuración del repositorio..."

# Cargar variables
if [ -f .env.dev ]; then
    source .env.dev
else
    echo "❌ Archivo .env.dev no encontrado"
    echo "Ejecuta ./setup-dev.sh primero"
    exit 1
fi

# Validar AWS
echo "1. Validando conexión AWS..."
if aws sts get-caller-identity --profile $AWS_PROFILE > /dev/null; then
    echo "✅ Conexión AWS exitosa"
else
    echo "❌ Error de conexión AWS"
    exit 1
fi

# Validar S3
echo "2. Validando bucket S3..."
if aws s3 ls s3://$TERRAFORM_STATE_BUCKET --profile $AWS_PROFILE > /dev/null; then
    echo "✅ Bucket S3 accesible"
else
    echo "❌ Bucket S3 no accesible"
    exit 1
fi

# Validar DynamoDB
echo "3. Validando tabla DynamoDB..."
if aws dynamodb describe-table --table-name $TERRAFORM_LOCK_TABLE --profile $AWS_PROFILE > /dev/null; then
    echo "✅ Tabla DynamoDB accesible"
else
    echo "❌ Tabla DynamoDB no accesible"
    exit 1
fi

# Validar scripts
echo "4. Validando scripts Python..."
if python3 -c "import json, re, pathlib"; then
    echo "✅ Python y librerías necesarias disponibles"
else
    echo "❌ Error con Python o librerías"
    exit 1
fi

echo ""
echo "🎉 ¡Configuración válida! El repositorio está listo para usar."
echo ""
echo "Para crear tu primer rol:"
echo "1. python3 scripts/generate_role.py mi-config.json --gerencia tecnologia --area aplicaciones"
echo "2. cd gerencias/tecnologia/aplicaciones"
echo "3. cp terraform.tfvars.example terraform.tfvars"
echo "4. # Editar terraform.tfvars con tus valores"
echo "5. terraform init"
echo "6. terraform plan"
EOF

chmod +x validate-setup.sh
print_step "Script de validación creado: validate-setup.sh"

# =============================================================================
# 7. CREAR TEMPLATE DE VARIABLES
# =============================================================================
echo ""
echo "7️⃣  Creando template de variables..."

# Crear archivo terraform.tfvars.example global
cat > terraform.tfvars.example << EOF
# =============================================================================
# Variables de Configuración - Ambiente DEV
# =============================================================================
# Copiar este archivo a terraform.tfvars y completar los valores

# Configuración AWS
aws_region   = "$AWS_REGION"
ambiente     = "dev"
account_name = "dev-account"

# Configuración del Backend de Terraform
terraform_state_bucket = "$BUCKET_NAME"
terraform_lock_table   = "$TABLE_NAME"

# Información de Responsables (COMPLETAR)
pais             = "GT"  # GT, CR, SV, HN, NI, PA
propietario      = ""    # Nombre del responsable
soporte_email    = ""    # Email del equipo de soporte
proyecto_codigo  = ""    # Código del proyecto
creado_por      = ""     # Email de quien crea el recurso

# Información de Ciclo de Vida
ciclo_vida = "Implementación"  # Creación, Implementación, MonitoreoYMantenimiento, Desactivación
version    = "1.0.0"          # Versión semántica

# Tags adicionales (opcional)
# custom_tags = {
#   "CostCenter" = "CC-12345"
#   "Environment" = "development"
# }
EOF

print_step "Template de variables creado: terraform.tfvars.example"

# =============================================================================
# 8. CONFIGURAR SCRIPTS EJECUTABLES
# =============================================================================
echo ""
echo "8️⃣  Configurando permisos de scripts..."

chmod +x scripts/*.sh 2>/dev/null || true
chmod +x scripts/*.py 2>/dev/null || true
print_step "Permisos de scripts configurados"

# =============================================================================
# FINALIZACIÓN
# =============================================================================
echo ""
echo "================================================"
echo "🎉 ¡CONFIGURACIÓN COMPLETA!"
echo "================================================"
echo ""
echo "📋 Resumen de lo configurado:"
echo "  ✅ Perfil AWS 'dev' configurado"
echo "  ✅ Bucket S3: $BUCKET_NAME"
echo "  ✅ Tabla DynamoDB: $TABLE_NAME"
echo "  ✅ Archivo .env.dev creado"
echo "  ✅ Templates de configuración listos"
echo ""
echo "🚀 Próximos pasos:"
echo "  1. Ejecutar: ./validate-setup.sh"
echo "  2. Crear tu primer rol con el generador"
echo "  3. Ver ejemplos en docs/USAGE.md"
echo ""
echo "📞 Soporte:"
echo "  - Documentación: docs/"
echo "  - Script de validación: ./validate-setup.sh"
echo ""
print_step "¡El repositorio está listo para usar!"
