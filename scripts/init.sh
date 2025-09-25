#!/bin/bash
# Script simplificado para inicialización de Terraform
# Uso: ./scripts/init.sh [environment]
# Ejemplo: ./scripts/init.sh dev

set -e

ENVIRONMENT=${1:-dev}
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(dirname "$SCRIPT_DIR")"

echo "🚀 Inicializando Terraform para ambiente: $ENVIRONMENT"

cd "$REPO_ROOT/generated"

# Verificar que existe la configuración de backend
if [ ! -f "../config/backend.hcl" ]; then
    echo "❌ Error: No se encontró config/backend.hcl"
    exit 1
fi

# Inicializar Terraform con backend dinámico
echo "📦 Ejecutando terraform init..."
terraform init -backend-config="../config/backend.hcl" -var="environment=$ENVIRONMENT"

echo "✅ Terraform inicializado correctamente para $ENVIRONMENT"
echo "💡 Próximos pasos:"
echo "   - terraform plan -var=\"environment=$ENVIRONMENT\""
echo "   - terraform apply -var=\"environment=$ENVIRONMENT\""