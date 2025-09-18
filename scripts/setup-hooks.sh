#!/bin/bash
# Script para configurar hooks automáticos de Terraform

echo "🔧 Configurando hooks de Git para auto-inicialización de Terraform..."

# Crear post-checkout hook
cat > .git/hooks/post-checkout << 'EOF'
#!/bin/bash
# Auto-inicializar Terraform después de checkout

if [ -f "environments/dev/main.tf" ] && [ ! -d "environments/dev/.terraform" ]; then
    echo "🚀 Auto-inicializando Terraform..."
    cd environments/dev
    terraform init -input=false -backend=true
    echo "✅ Terraform inicializado automáticamente"
fi
EOF

# Hacer ejecutable
chmod +x .git/hooks/post-checkout

echo "✅ Hook configurado. Terraform se inicializará automáticamente después de 'git checkout'"
echo "📝 Para configurar manualmente: bash scripts/setup-hooks.sh"
