#!/bin/bash

# 🔐 Script de validación de usuario autorizado antes de push
# Guardar como: .git/hooks/pre-push

set -e

# Configuración
AUTHORIZED_USERS=(
    "usuario1@company.com"
    "usuario2@company.com" 
    "admin-aws@company.com"
    "devops-team@company.com"
)

CURRENT_USER_EMAIL=$(git config user.email)
CURRENT_USER_NAME=$(git config user.name)

echo "🔍 Validando usuario autorizado para push..."
echo "Usuario: $CURRENT_USER_NAME <$CURRENT_USER_EMAIL>"

# Verificar si el usuario está autorizado
USER_AUTHORIZED=false
for authorized_email in "${AUTHORIZED_USERS[@]}"; do
    if [[ "$CURRENT_USER_EMAIL" == "$authorized_email" ]]; then
        USER_AUTHORIZED=true
        break
    fi
done

if [[ "$USER_AUTHORIZED" == "false" ]]; then
    echo "❌ ERROR: Usuario $CURRENT_USER_EMAIL NO está autorizado para hacer push"
    echo ""
    echo "Usuarios autorizados:"
    printf '   - %s\n' "${AUTHORIZED_USERS[@]}"
    echo ""
    echo "Para solicitar acceso, contacta al equipo de DevOps"
    exit 1
fi

echo "✅ Usuario autorizado. Procediendo con push..."

# Validaciones adicionales para ramas críticas
CURRENT_BRANCH=$(git rev-parse --abbrev-ref HEAD)

if [[ "$CURRENT_BRANCH" == "main" ]]; then
    echo "⚠️  ADVERTENCIA: Push directo a rama main"
    echo "Se recomienda usar Pull Requests para main"
    read -p "¿Estás seguro? (y/N): " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        echo "❌ Push cancelado por el usuario"
        exit 1
    fi
fi

echo "✅ Validaciones completadas. Push autorizado."
