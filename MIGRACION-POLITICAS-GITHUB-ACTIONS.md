# Migración de Políticas Inline a Managed
# =======================================

## 📋 Resumen de la Refactorización

Esta refactorización consolida las políticas de GitHub Actions desde un enfoque JSON inline hacia políticas Terraform managed granulares, mejorando la mantenibilidad y claridad arquitectónica.

## 🎯 Problema Identificado

**Arquitectura Dual Confusa:**
- ❌ Política JSON inline en `aws-setup/github-actions-role-policy.json`
- ❌ Políticas Terraform managed en diferentes módulos  
- ❌ Duplicación de permisos y confusión sobre cuáles usar
- ❌ Dificultad para mantener y evolucionar permisos

## ✅ Solución Implementada

### Nueva Estructura Granular

```
policy_lib/github-actions/
├── terraform-backend.tf     # Backend S3/DynamoDB/KMS access
├── iam-management.tf        # IAM roles/policies management  
├── main.tf                 # Managed policies creation
└── variables.tf            # Configuration variables

aws-setup/
├── github-actions-role.tf   # Role with managed policies attached
├── variables.tf            # Setup variables
└── github-actions-role-policy.json  # ⚠️ DEPRECATED - Remover tras migración
```

### Políticas Creadas

#### 1. **MCI-GitHubActions-TerraformBackend**
- **Propósito:** Acceso al backend de Terraform
- **Permisos:** S3 tfstate, DynamoDB locks, KMS encryption
- **Incluye:** Todos los permisos S3 solicitados por Ricardo Brenes

#### 2. **MCI-GitHubActions-IAMManagement**  
- **Propósito:** Gestión de roles y políticas IAM
- **Permisos:** Create/Update/Delete roles y policies managed
- **Scope:** Limitado a paths `/MCI/` y `/GitHubActions/`

## 🔄 Plan de Migración

### Fase 1: ✅ Crear Políticas Managed
- [x] Crear `policy_lib/github-actions/` con políticas granulares
- [x] Incluir **TODOS** los permisos del JSON original
- [x] Agregar permisos S3 adicionales solicitados

### Fase 2: 🚀 Desplegar Nuevo Rol
```bash
# Navegar a aws-setup y aplicar
cd aws-setup
terraform init
terraform plan -var="environment=dev"
terraform apply
```

### Fase 3: 🧹 Limpiar Archivo Legacy
```bash
# Después de validar el nuevo rol
rm github-actions-role-policy.json
```

## 📊 Comparación de Permisos

### Antes (JSON Inline)
```json
{
  "Version": "2012-10-17", 
  "Statement": [/* ~87 líneas monolíticas */]
}
```

### Después (Terraform Managed)
```hcl
# Políticas granulares y reutilizables
module.github_actions_terraform_backend_policy
module.github_actions_iam_management_policy
```

## ✨ Beneficios de la Nueva Arquitectura

### 🎯 **Granularidad**
- Políticas específicas por función (backend vs IAM)
- Más fácil entender el propósito de cada permiso
- Scope limitado y principio de menor privilegio

### 🔧 **Mantenibilidad**  
- Cambios incrementales por política
- Versionado automático con Terraform
- Documentación integrada en código

### 🏗️ **Reutilización**
- Políticas reutilizables en otros roles
- Módulos consistentes con el resto del proyecto
- Patrón escalable para nuevos servicios

### 🛡️ **Seguridad**
- Resource constraints explícitos
- Conditions para KMS ViaService  
- Paths IAM limitados a `/MCI/` y `/GitHubActions/`

## 🎉 Resultado Final

- ✅ **Arquitectura Consolidada:** Solo Terraform managed policies
- ✅ **Funcionalidad Completa:** Todos los permisos originales + nuevos S3
- ✅ **Mejor Organización:** Separación clara por función
- ✅ **Fácil Evolución:** Agregar nuevas políticas es trivial

---
**Próximo paso:** Ejecutar la migración y eliminar el archivo JSON legacy 🚀