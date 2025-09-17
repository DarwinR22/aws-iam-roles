#!/bin/bash

# =============================================================================
# Script para actualizar permisos del rol GitHub Actions
# =============================================================================

set -e

# Configuración
ROLE_NAME="github-actions-iam-deployment-role"
POLICY_NAME="GitHubActionsIAMDeploymentPolicy"
AWS_ACCOUNT="393209814297"
AWS_REGION="us-east-1"

echo "🔐 Actualizando permisos del rol GitHub Actions..."
echo "📋 Rol: ${ROLE_NAME}"
echo "📋 Política: ${POLICY_NAME}"
echo ""

# Verificar si el rol existe
echo "1️⃣  Verificando rol existente..."
if aws iam get-role --role-name ${ROLE_NAME} > /dev/null 2>&1; then
    echo "✅ Rol encontrado: ${ROLE_NAME}"
else
    echo "❌ Error: Rol no encontrado: ${ROLE_NAME}"
    echo "💡 Por favor, asegúrate de que el rol existe en la cuenta AWS ${AWS_ACCOUNT}"
    exit 1
fi

# Crear/actualizar la política en línea
echo ""
echo "2️⃣  Actualizando política en línea del rol..."

aws iam put-role-policy \
    --role-name ${ROLE_NAME} \
    --policy-name ${POLICY_NAME} \
    --policy-document file://github-actions-role-policy.json

if [ $? -eq 0 ]; then
    echo "✅ Política actualizada exitosamente"
else
    echo "❌ Error actualizando la política"
    exit 1
fi

# Verificar los permisos actualizados
echo ""
echo "3️⃣  Verificando política aplicada..."
aws iam get-role-policy \
    --role-name ${ROLE_NAME} \
    --policy-name ${POLICY_NAME} \
    --output table \
    --query 'PolicyDocument.Statement[*].[Effect,Action[0],Resource]'

echo ""
echo "🎉 ¡Actualización completada!"
echo ""
echo "📋 Permisos agregados:"
echo "   ✅ IAM: CreateRole, DeleteRole, GetRole, etc."
echo "   ✅ S3: Acceso completo al bucket s3-data-analytics-raw-dev-tfstate"
echo "   ✅ DynamoDB: Acceso a tabla dynamodb-db-dev-terraform-lock"
echo "   ✅ STS: GetCallerIdentity"
echo ""
echo "🚀 El workflow de GitHub Actions ahora debería funcionar correctamente."
