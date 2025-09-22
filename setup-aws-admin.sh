#!/bin/bash
# =============================================================================
# Setup Inicial AWS - Solo para Administradores
# =============================================================================
# Este script configura los recursos AWS necesarios para que el repositorio
# funcione completamente via GitHub Actions. Los desarrolladores NO necesitan
# herramientas locales instaladas.
#
# SOLO EJECUTAR UNA VEZ por cuenta AWS

echo "🚀 Configurando recursos AWS para repositorio IAM..."
echo "=================================================="

# =============================================================================
# Variables de configuracion
# =============================================================================
AWS_PROFILE="default"  # Cambiar si usas un perfil especifico
AWS_REGION="us-east-1"  # Cambiar segun tu region
ENVIRONMENT="dev"       # dev, qa, prod

# Obtener informacion de la cuenta
ACCOUNT_ID=$(aws sts get-caller-identity --profile $AWS_PROFILE --query Account --output text)
if [ $? -ne 0 ]; then
    echo "❌ Error: No se pudo obtener informacion de la cuenta AWS"
    echo "Verifica tus credenciales AWS"
    exit 1
fi

echo "✅ Conectado a cuenta AWS: $ACCOUNT_ID"
echo "📍 Region: $AWS_REGION"
echo "🏷️  Ambiente: $ENVIRONMENT"

# =============================================================================
# 1. Crear bucket S3 para Terraform state
# =============================================================================
echo ""
echo "1️⃣  Configurando bucket S3 para estado de Terraform..."

BUCKET_NAME="mci-terraform-state-${ENVIRONMENT}-${ACCOUNT_ID}"

# Verificar si el bucket existe
if aws s3 ls "s3://$BUCKET_NAME" --profile $AWS_PROFILE >/dev/null 2>&1; then
    echo "✅ Bucket S3 ya existe: $BUCKET_NAME"
else
    echo "⚠️  Creando bucket S3: $BUCKET_NAME"
    
    # Crear bucket
    if [ "$AWS_REGION" = "us-east-1" ]; then
        aws s3 mb "s3://$BUCKET_NAME" --profile $AWS_PROFILE
    else
        aws s3 mb "s3://$BUCKET_NAME" --region $AWS_REGION --profile $AWS_PROFILE
    fi
    
    # Habilitar versionado
    aws s3api put-bucket-versioning \
        --bucket $BUCKET_NAME \
        --versioning-configuration Status=Enabled \
        --profile $AWS_PROFILE
    
    # Habilitar encriptacion
    aws s3api put-bucket-encryption \
        --bucket $BUCKET_NAME \
        --server-side-encryption-configuration '{
            "Rules": [
                {
                    "ApplyServerSideEncryptionByDefault": {
                        "SSEAlgorithm": "AES256"
                    }
                }
            ]
        }' \
        --profile $AWS_PROFILE
    
    # Bloquear acceso publico
    aws s3api put-public-access-block \
        --bucket $BUCKET_NAME \
        --public-access-block-configuration \
            BlockPublicAcls=true,IgnorePublicAcls=true,BlockPublicPolicy=true,RestrictPublicBuckets=true \
        --profile $AWS_PROFILE
    
    echo "✅ Bucket S3 creado y configurado: $BUCKET_NAME"
fi

# =============================================================================
# 2. Crear tabla DynamoDB para locks
# =============================================================================
echo ""
echo "2️⃣  Configurando tabla DynamoDB para locks..."

TABLE_NAME="terraform-locks-${ENVIRONMENT}"

# Verificar si la tabla existe
if aws dynamodb describe-table --table-name $TABLE_NAME --profile $AWS_PROFILE >/dev/null 2>&1; then
    echo "✅ Tabla DynamoDB ya existe: $TABLE_NAME"
else
    echo "⚠️  Creando tabla DynamoDB: $TABLE_NAME"
    
    aws dynamodb create-table \
        --table-name $TABLE_NAME \
        --attribute-definitions AttributeName=LockID,AttributeType=S \
        --key-schema AttributeName=LockID,KeyType=HASH \
        --billing-mode PAY_PER_REQUEST \
        --region $AWS_REGION \
        --profile $AWS_PROFILE
    
    echo "✅ Tabla DynamoDB creada: $TABLE_NAME"
fi

# =============================================================================
# 3. Crear usuario IAM para GitHub Actions
# =============================================================================
echo ""
echo "3️⃣  Configurando usuario IAM para GitHub Actions..."

IAM_USER="github-actions-iam-${ENVIRONMENT}"

# Verificar si el usuario existe
if aws iam get-user --user-name $IAM_USER --profile $AWS_PROFILE >/dev/null 2>&1; then
    echo "✅ Usuario IAM ya existe: $IAM_USER"
else
    echo "⚠️  Creando usuario IAM: $IAM_USER"
    
    # Crear usuario
    aws iam create-user --user-name $IAM_USER --profile $AWS_PROFILE
    
    # Crear politica personalizada para el usuario
    POLICY_NAME="GitHubActionsIAMPolicy-${ENVIRONMENT}"
    
    cat > github-actions-policy.json << EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": [
                "iam:*"
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
                "arn:aws:s3:::${BUCKET_NAME}",
                "arn:aws:s3:::${BUCKET_NAME}/*"
            ]
        },
        {
            "Effect": "Allow",
            "Action": [
                "dynamodb:GetItem",
                "dynamodb:PutItem",
                "dynamodb:DeleteItem"
            ],
            "Resource": "arn:aws:dynamodb:${AWS_REGION}:${ACCOUNT_ID}:table/${TABLE_NAME}"
        },
        {
            "Effect": "Allow",
            "Action": [
                "sts:GetCallerIdentity"
            ],
            "Resource": "*"
        }
    ]
}
EOF

    # Crear la politica
    aws iam create-policy \
        --policy-name $POLICY_NAME \
        --policy-document file://github-actions-policy.json \
        --profile $AWS_PROFILE
    
    # Adjuntar politica al usuario
    aws iam attach-user-policy \
        --user-name $IAM_USER \
        --policy-arn "arn:aws:iam::${ACCOUNT_ID}:policy/${POLICY_NAME}" \
        --profile $AWS_PROFILE
    
    # Crear access keys
    echo "⚠️  Creando Access Keys para GitHub Actions..."
    CREDENTIALS=$(aws iam create-access-key --user-name $IAM_USER --profile $AWS_PROFILE --output json)
    
    ACCESS_KEY_ID=$(echo $CREDENTIALS | jq -r '.AccessKey.AccessKeyId')
    SECRET_ACCESS_KEY=$(echo $CREDENTIALS | jq -r '.AccessKey.SecretAccessKey')
    
    echo "✅ Usuario IAM creado: $IAM_USER"
    echo ""
    echo "🔑 CREDENCIALES PARA GITHUB ACTIONS:"
    echo "======================================"
    echo "AWS_ACCESS_KEY_ID_${ENVIRONMENT^^}=${ACCESS_KEY_ID}"
    echo "AWS_SECRET_ACCESS_KEY_${ENVIRONMENT^^}=${SECRET_ACCESS_KEY}"
    echo ""
    echo "⚠️  IMPORTANTE: Guarda estas credenciales de forma segura"
    echo "📋 Configuralas en GitHub Settings > Secrets and variables > Actions"
    
    # Limpiar archivo temporal
    rm github-actions-policy.json
fi

# =============================================================================
# 4. Generar informacion para GitHub Variables
# =============================================================================
echo ""
echo "4️⃣  Informacion para GitHub Repository Variables..."
echo ""
echo "📋 VARIABLES PARA GITHUB ACTIONS:"
echo "=================================="
echo "TERRAFORM_STATE_BUCKET_${ENVIRONMENT^^}=${BUCKET_NAME}"
echo "TERRAFORM_LOCK_TABLE_${ENVIRONMENT^^}=${TABLE_NAME}"
echo "AWS_REGION=${AWS_REGION}"
echo ""

# =============================================================================
# 5. Crear archivo de configuracion de referencia
# =============================================================================
echo ""
echo "5️⃣  Creando archivo de configuracion de referencia..."

cat > "aws-config-${ENVIRONMENT}.txt" << EOF
# =============================================================================
# Configuracion AWS para ambiente: ${ENVIRONMENT}
# =============================================================================
# Generado: $(date)
# Cuenta AWS: ${ACCOUNT_ID}
# Region: ${AWS_REGION}

# Recursos creados:
S3_BUCKET=${BUCKET_NAME}
DYNAMODB_TABLE=${TABLE_NAME}
IAM_USER=${IAM_USER}

# Para configurar en GitHub Actions:
# 1. Repository Settings > Secrets and variables > Actions
# 2. Agregar estos Secrets:
#    AWS_ACCESS_KEY_ID_${ENVIRONMENT^^}=<access_key_mostrado_arriba>
#    AWS_SECRET_ACCESS_KEY_${ENVIRONMENT^^}=<secret_key_mostrado_arriba>
# 
# 3. Agregar estas Variables:
#    TERRAFORM_STATE_BUCKET_${ENVIRONMENT^^}=${BUCKET_NAME}
#    TERRAFORM_LOCK_TABLE_${ENVIRONMENT^^}=${TABLE_NAME}
#    AWS_REGION=${AWS_REGION}

# Para verificar la configuracion:
# aws s3 ls s3://${BUCKET_NAME} --profile ${AWS_PROFILE}
# aws dynamodb describe-table --table-name ${TABLE_NAME} --profile ${AWS_PROFILE}
# aws iam get-user --user-name ${IAM_USER} --profile ${AWS_PROFILE}
EOF

echo "✅ Configuracion guardada en: aws-config-${ENVIRONMENT}.txt"

# =============================================================================
# RESUMEN FINAL
# =============================================================================
echo ""
echo "=================================================="
echo "🎉 ¡CONFIGURACIoN AWS COMPLETADA!"
echo "=================================================="
echo ""
echo "📋 Recursos creados en cuenta ${ACCOUNT_ID}:"
echo "   ✅ S3 Bucket: ${BUCKET_NAME}"
echo "   ✅ DynamoDB Table: ${TABLE_NAME}"
echo "   ✅ IAM User: ${IAM_USER}"
echo ""
echo "🔧 Proximos pasos:"
echo "   1. Configurar credenciales en GitHub Actions (mostradas arriba)"
echo "   2. Configurar variables en GitHub Repository"
echo "   3. Los desarrolladores ya pueden usar el repositorio sin instalar nada"
echo ""
echo "📁 Archivos generados:"
echo "   - aws-config-${ENVIRONMENT}.txt (configuracion de referencia)"
echo ""
echo "✅ ¡Los desarrolladores ahora pueden hacer git clone y usar el repositorio!"
echo "✅ Todo se ejecutara automaticamente via GitHub Actions"
echo ""
