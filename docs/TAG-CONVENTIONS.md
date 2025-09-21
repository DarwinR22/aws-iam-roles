# 🏷️ Convenciones de Tags - MCI AWS IAM

## Descripción

Este documento establece convenciones estrictas de nombres de tags para prevenir errores de deployment de AWS IAM debido a claves de tags duplicadas o conflictivas.

## Categorías de Tags

### 🔧 Tags del Sistema (Auto-generados)
Estos tags son agregados automáticamente por Terraform y NO deben incluirse en archivos JSON de roles:

```json
{
  "Name": "rol-name",
  "Tipo de Recurso": "IAM Role", 
  "Fecha de Creacion": "2025-09-20",
  "PolicyType": "Role",
  "ManagedBy": "Terraform"
}
```

### 🏢 Tags de Negocio (Obligatorios en JSON)
Estos tags deben estar presentes en cada archivo JSON de rol:

```json
{
  "Equipo": "BI-Team",           // Equipo responsable del rol
  "Ambiente": "dev",             // Ambiente: dev, qa, prod
  "Proyecto": "DataAnalytics"    // Identificador de proyecto
}
```

### 📊 Optional Business Tags
Additional tags that can be included:

```json
{
  "BusinessUnit": "MCI",                    // Business unit/gerencia
  "ServiceType": "lambda-function",         // Type of service
  "ApplicationName": "bi-data-processor",   // Application name
  "BillingCode": "CC-BI-001",              // Cost center for billing
  "DataClassification": "internal",         // Data sensitivity level
  "Owner": "DarwinLopez"                   // Business owner
}
```

## 🚫 Forbidden Tag Names

Never use these tag names as they conflict with system tags or AWS reserved words:

- `Environment`, `environment`, `ENVIRONMENT` (conflicts with AWS)
- `Team`, `team` (conflicts with system logic)
- `Area`, `area` (conflicts with auto-mapping)
- `CostCenter`, `costcenter` (conflicts with billing logic)
- `Propietario`, `propietario` (use `Owner` instead)
- `Ambiente`, `ambiente` (use `DeploymentStage` instead)
- `Equipo`, `equipo` (use `BusinessTeam` instead)

## 🎯 Naming Best Practices

1. **PascalCase**: Use PascalCase for all tag names (e.g., `BusinessTeam`, `ProjectCode`)
2. **English Only**: Use English for tag names to avoid encoding issues
3. **Descriptive**: Make tag names self-explanatory
4. **Consistent**: Use the same tag names across all roles
5. **No Spaces**: Avoid spaces in tag names (use hyphen in values if needed)

## 🔍 Validation

Terraform includes automatic validation to prevent:
- Missing required tags
- Case-insensitive duplicate tags
- Conflicting tag names

## 📝 Examples

### ✅ Correct Role Tags
```json
{
  "role_name": "rol-bi-analytics-dev-processor",
  "tags": {
    "BusinessTeam": "BI-Analytics",
    "DeploymentStage": "development", 
    "ProjectCode": "DataAnalytics",
    "BusinessUnit": "MCI",
    "ServiceType": "lambda-function",
    "ApplicationName": "bi-data-processor",
    "BillingCode": "CC-BI-001",
    "DataClassification": "internal",
    "Owner": "DarwinLopez"
  }
}
```

### ❌ Incorrect Role Tags
```json
{
  "tags": {
    "Team": "BI-Team",           // ❌ Conflicts with system tag
    "Ambiente": "dev",           // ❌ Spanish, use DeploymentStage
    "environment": "development" // ❌ Case conflict with Environment
  }
}
```

## 🔄 Migration Guide

If you have existing roles with old tag names:

1. Update tag names to follow new conventions
2. Run `terraform plan` to verify no conflicts
3. Test deployment in development environment first
4. Update documentation and team guidelines

---

**Note**: These conventions are enforced by Terraform validation and will cause deployment failures if not followed.