# Makefile para gestión simplificada de Terraform
# Uso: make setup, make plan, make apply

.PHONY: help setup init plan apply clean

# Variables
TF_DIR := environments/dev
AWS_REGION := us-east-1

help: ## Mostrar ayuda
	@echo "🚀 Comandos disponibles:"
	@echo "  make setup  - Configuración inicial (recomendado para nuevos desarrolladores)"
	@echo "  make init   - Inicializar Terraform"
	@echo "  make plan   - Ver cambios planeados"
	@echo "  make apply  - Aplicar cambios"
	@echo "  make clean  - Limpiar archivos temporales"

setup: ## Configuración inicial completa
	@echo "🔧 Configuración inicial del repositorio..."
	@echo "📍 Verificando credenciales AWS..."
	@aws sts get-caller-identity > /dev/null 2>&1 || (echo "❌ Credenciales AWS no configuradas. Ejecuta: aws configure" && exit 1)
	@echo "✅ Credenciales AWS verificadas"
	@echo "🚀 Inicializando Terraform..."
	@cd $(TF_DIR) && terraform init -backend=true -input=false
	@echo "✅ Repositorio listo para usar"
	@echo ""
	@echo "🎯 Próximos pasos:"
	@echo "  - make plan     # Ver qué se va a crear"
	@echo "  - make apply    # Aplicar cambios"

init: ## Inicializar Terraform
	@cd $(TF_DIR) && terraform init -backend=true -input=false

plan: init ## Planificar cambios
	@cd $(TF_DIR) && terraform plan

apply: init ## Aplicar cambios
	@cd $(TF_DIR) && terraform apply

clean: ## Limpiar archivos temporales
	@echo "🧹 Limpiando archivos temporales..."
	@rm -rf $(TF_DIR)/.terraform
	@rm -f $(TF_DIR)/.terraform.lock.hcl
	@echo "✅ Limpieza completada"
