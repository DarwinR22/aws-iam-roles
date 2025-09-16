#!/bin/bash
# ==============================================================================
# Script de validación pre-commit para recursos IAM
# ==============================================================================

set -e

# Colores para output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Función para imprimir mensajes
print_info() {
    echo -e "${BLUE}ℹ️  $1${NC}"
}

print_success() {
    echo -e "${GREEN}✅ $1${NC}"
}

print_warning() {
    echo -e "${YELLOW}⚠️  $1${NC}"
}

print_error() {
    echo -e "${RED}❌ $1${NC}"
}

# Función para validar Terraform
validate_terraform() {
    local path=$1
    print_info "Validando sintaxis de Terraform..."
    
    if command -v terraform &> /dev/null; then
        terraform fmt -check=true -diff=true "$path"
        terraform validate "$path"
        print_success "Validación de Terraform completada"
    else
        print_warning "Terraform no está instalado, saltando validación de sintaxis"
    fi
}

# Función para validar archivos modificados
validate_changed_files() {
    print_info "Validando archivos modificados..."
    
    # Obtener archivos modificados
    if git rev-parse --is-inside-work-tree &> /dev/null; then
        changed_files=$(git diff --cached --name-only --diff-filter=ACM | grep -E '\.(tf|tfvars)$' || true)
    else
        print_warning "No es un repositorio Git, validando todos los archivos .tf"
        changed_files=$(find . -name "*.tf" -o -name "*.tfvars")
    fi
    
    if [ -z "$changed_files" ]; then
        print_info "No hay archivos Terraform modificados"
        return 0
    fi
    
    print_info "Archivos a validar:"
    echo "$changed_files" | sed 's/^/  - /'
    
    # Validar cada archivo con el script Python
    local has_errors=false
    for file in $changed_files; do
        if [ -f "$file" ]; then
            print_info "Validando $file..."
            if python3 scripts/validate_iam.py "$file"; then
                print_success "✓ $file"
            else
                print_error "✗ $file"
                has_errors=true
            fi
        fi
    done
    
    if [ "$has_errors" = true ]; then
        print_error "Errores de validación encontrados"
        return 1
    fi
    
    print_success "Todos los archivos pasaron la validación"
    return 0
}

# Función para validar estructura de directorios
validate_structure() {
    print_info "Validando estructura de directorios..."
    
    local required_dirs=(
        "gerencias"
        "modules"
        "templates"
        "scripts"
        "environments"
        ".github/workflows"
    )
    
    local missing_dirs=()
    for dir in "${required_dirs[@]}"; do
        if [ ! -d "$dir" ]; then
            missing_dirs+=("$dir")
        fi
    done
    
    if [ ${#missing_dirs[@]} -ne 0 ]; then
        print_error "Directorios faltantes:"
        printf '  - %s\n' "${missing_dirs[@]}"
        return 1
    fi
    
    print_success "Estructura de directorios válida"
    return 0
}

# Función para validar convención de nombres de archivos
validate_file_naming() {
    print_info "Validando convención de nombres de archivos..."
    
    # Buscar archivos .tf que no sigan la convención
    local invalid_files=()
    
    # Los archivos en gerencias/ deben ser descriptivos y en kebab-case
    while IFS= read -r -d '' file; do
        filename=$(basename "$file" .tf)
        if [[ ! "$filename" =~ ^[a-z0-9-]+$ ]]; then
            invalid_files+=("$file")
        fi
    done < <(find gerencias/ -name "*.tf" -print0 2>/dev/null || true)
    
    if [ ${#invalid_files[@]} -ne 0 ]; then
        print_error "Archivos con nombres inválidos (deben usar kebab-case):"
        printf '  - %s\n' "${invalid_files[@]}"
        return 1
    fi
    
    print_success "Convención de nombres de archivos válida"
    return 0
}

# Función para verificar ejemplos de tags
validate_tag_examples() {
    print_info "Validando ejemplos de tags..."
    
    local tag_example_file="scripts/tag_examples.json"
    
    if [ -f "$tag_example_file" ]; then
        python3 scripts/validate_iam.py --tags-file "$tag_example_file" .
    else
        print_warning "Archivo de ejemplos de tags no encontrado: $tag_example_file"
    fi
}

# Función principal
main() {
    print_info "🔍 Iniciando validación de recursos IAM..."
    echo
    
    local exit_code=0
    
    # Ejecutar validaciones
    validate_structure || exit_code=1
    echo
    
    validate_file_naming || exit_code=1
    echo
    
    validate_changed_files || exit_code=1
    echo
    
    # Solo validar Terraform si estamos en un directorio específico
    if [ -f "main.tf" ] || [ -f "variables.tf" ]; then
        validate_terraform . || exit_code=1
        echo
    fi
    
    validate_tag_examples || exit_code=1
    echo
    
    # Resultado final
    if [ $exit_code -eq 0 ]; then
        print_success "🎉 Todas las validaciones pasaron exitosamente!"
        echo
        print_info "El código está listo para ser desplegado."
    else
        print_error "💥 Algunas validaciones fallaron."
        echo
        print_info "Por favor corrija los errores antes de hacer commit/push."
    fi
    
    exit $exit_code
}

# Ejecutar si es llamado directamente
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi
