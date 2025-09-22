#!/bin/bash
# Script para configurar hooks automaticos de Terraform

echo "🔧 Configurando hooks de Git para auto-inicializacion de Terraform..."

# Crear post-checkout hook
cat > .git/hooks/post-checkout << 'EOF'
#!/bin/bash
# Auto-inicializar Terraform despues de checkout

if [ -f "environments/dev/main.tf" ] && [ ! -d "environments/dev/.terraform" ]; then
    echo "🚀 Auto-inicializando Terraform..."
    cd environments/dev
    terraform init -input=false -backend=true
    echo "✅ Terraform inicializado automaticamente"
fi
EOF

# Hacer ejecutable
chmod +x .git/hooks/post-checkout

echo "✅ Hook configurado. Terraform se inicializara automaticamente despues de 'git checkout'"
echo "📝 Para configurar manualmente: bash scripts/setup-hooks.sh"
