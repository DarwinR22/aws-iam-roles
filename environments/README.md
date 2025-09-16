# 🛠️ Configuración de Pre-commit

Este archivo configura hooks de pre-commit para validar automáticamente el código antes de hacer commit.

## Instalación

```bash
# Instalar pre-commit
pip install pre-commit

# Instalar hooks en el repositorio
pre-commit install
```

## Hooks Configurados

- **terraform_fmt**: Formatea automáticamente código Terraform
- **terraform_validate**: Valida sintaxis de Terraform
- **custom_iam_validation**: Ejecuta validaciones personalizadas de IAM
- **check-yaml**: Valida sintaxis de archivos YAML
- **check-json**: Valida sintaxis de archivos JSON
- **trailing-whitespace**: Elimina espacios en blanco al final
- **end-of-file-fixer**: Asegura nueva línea al final de archivos

## Configuración

El archivo `.pre-commit-config.yaml` contiene toda la configuración necesaria.
