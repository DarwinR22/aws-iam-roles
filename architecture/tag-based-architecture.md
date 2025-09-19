# 🎯 Nueva Arquitectura IAM MCI - Tag-Based Policies

## 🚀 **CAMBIO ARQUITECTURAL IMPLEMENTADO**

### **Problema Anterior:**
- ❌ 1 política por tabla DynamoDB → 200 políticas para 200 tablas
- ❌ 1 política por bucket S3 → Mantenimiento manual insostenible
- ❌ Sin separación automática por equipos/entornos
- ❌ Sin gobernanza de tags obligatorios

### **Solución Nueva:**
- ✅ **1 política por equipo** → Acceso automático basado en tags
- ✅ **Escalabilidad infinita** → Nueva tabla con tags correctos = acceso automático
- ✅ **Separación automática** → Tags separan equipos/entornos/proyectos
- ✅ **Gobernanza integrada** → Niega acceso a recursos sin tags

## 🏗️ **ARQUITECTURA HÍBRIDA DEFINITIVA**

```
📦 MCI IAM Architecture
├── 🧱 Building Blocks (MCI-*)
│   ├── MCI-S3-ReadOnly.json           → Para acceso básico S3
│   ├── MCI-DynamoDB-Write.json        → Para acceso básico DynamoDB
│   └── MCI-Lambda-Invoke.json         → Para invocar Lambdas
│
├── 🏷️ Tag-Based Policies (NUEVO)
│   ├── MCI-S3-TagBased-ReadOnly.json       → Acceso S3 por tags
│   ├── MCI-S3-TagBased-Write.json          → Acceso S3 escritura por tags
│   ├── MCI-DynamoDB-TagBased-ReadOnly.json → Acceso DynamoDB por tags
│   └── MCI-DynamoDB-TagBased-Write.json    → Acceso DynamoDB escritura por tags
│
└── 🎯 Granular (Solo emergencias)
    ├── MCI-S3-Path-*.json            → Para casos críticos específicos
    └── MCI-DynamoDB-Table-*.json     → Para compliance extremo
```

## 🏷️ **SISTEMA DE TAGS OBLIGATORIOS**

### **Tags Requeridos para TODOS los recursos:**
```hcl
# DynamoDB Tables
Equipo           = "BI-Team"              # ¿Quién es dueño?
Ambiente         = "dev"                  # dev/qa/prod
Proyecto         = "DataAnalytics"        # ¿A qué proyecto pertenece?
CentroCosto      = "CC-BI-001"           # Para billing
Propietario      = "darwin.lopez@mci.com" # Email responsable
DataClassification = "internal"           # public/internal/confidential

# S3 Buckets
Equipo           = "Development-Team"
Ambiente         = "prod"
Proyecto         = "WebApps"
CentroCosto      = "CC-DEV-002"
Propietario      = "cesar.calmo@mci.com"
DataRetention    = "7years"              # Política de retención
Encryption       = "AES256"              # Tipo de encriptación
```

## 🎯 **EJEMPLOS DE USO**

### **Caso 1: Equipo BI necesita acceso a datos**

**ANTES (Manual):**
```hcl
# Crear política específica para cada tabla
MCI-DynamoDB-Table-UserEvents
MCI-DynamoDB-Table-ProductCatalog  
MCI-DynamoDB-Table-SalesData
# ... 50 políticas más
```

**AHORA (Automático):**
```hcl
# 1 sola política basada en tags
"bi-team-dynamodb-read" = {
  policy_template = "MCI-DynamoDB-TagBased-ReadOnly"
  team_name      = "BI-Team"
  environment    = "prod"
  project_name   = "DataAnalytics"
}

# Automáticamente da acceso a TODAS las tablas con:
# Equipo = "BI-Team" AND Ambiente = "prod" AND Proyecto = "DataAnalytics"
```

### **Caso 2: Nueva tabla DynamoDB**

**ANTES:**
1. Crear tabla
2. Crear política específica
3. Actualizar rol
4. Deployar Terraform

**AHORA:**
1. Crear tabla con tags correctos:
```hcl
resource "aws_dynamodb_table" "new_analytics_table" {
  name = "user-behavior-analytics"
  
  tags = {
    Equipo    = "BI-Team"
    Ambiente  = "prod" 
    Proyecto  = "DataAnalytics"
    # ... otros tags obligatorios
  }
}
```
2. ✅ **¡ACCESO AUTOMÁTICO!** El equipo BI ya puede accederla

### **Caso 3: Separación por entornos**

```hcl
# Equipo Development - Solo DEV
"dev-team-write-dev" = {
  team_name   = "Development-Team"
  environment = "dev"          # Solo acceso a recursos DEV
  project_name = "WebApps"
}

# Equipo Database - Solo PROD readonly
"db-team-read-prod" = {
  team_name   = "Database-Team" 
  environment = "prod"         # Solo acceso a recursos PROD
  project_name = "*"           # Todos los proyectos
}
```

## 🛡️ **GOBERNANZA AUTOMÁTICA**

### **Protecciones Integradas:**

1. **Niega acceso a recursos sin tags:**
```json
{
  "Sid": "DenyUntaggedTables",
  "Effect": "Deny",
  "Action": "*",
  "Resource": "arn:aws:dynamodb:*:*:table/*",
  "Condition": {
    "Null": {
      "aws:ResourceTag/Equipo": "true"
    }
  }
}
```

2. **Separa automáticamente por ambiente:**
```json
{
  "Sid": "DenyWrongEnvironment",
  "Effect": "Deny", 
  "Action": "*",
  "Resource": "arn:aws:dynamodb:*:*:table/*",
  "Condition": {
    "StringNotEquals": {
      "aws:ResourceTag/Ambiente": "${environment}"
    }
  }
}
```

## 📊 **ESCALABILIDAD COMPROBADA**

| Escenario | Políticas Antes | Políticas Ahora | Reducción |
|-----------|----------------|-----------------|-----------|
| 200 tablas DynamoDB | 200 | 4 (por equipo) | **98%** |
| 50 buckets S3 | 50 | 4 (por equipo) | **92%** |
| 10 equipos × 3 ambientes | 600 | 12 | **98%** |

## 🔧 **MIGRACIÓN GRADUAL**

### **Fase 1: Building Blocks (✅ Hecho)**
- Políticas MCI-* genéricas funcionando

### **Fase 2: Tag-Based Policies (✅ Implementado)**
- Políticas basadas en tags
- Gobernanza automática
- Validación de tags

### **Fase 3: Migración de Roles**
```hcl
# Cambiar de:
"policies": {
  "custom": ["MCI-DynamoDB-Table-UserEvents", "MCI-DynamoDB-Table-Sales"]
}

# A:
"policies": {
  "tag_based": ["bi-team-dynamodb-read"]
}
```

### **Fase 4: Deprecación Granular**
- Mantener solo para compliance crítico
- Migrar gradualmente a tag-based

## 📝 **CONFIGURACIÓN RECOMENDADA**

### **Variables en `team-tag-policies.tfvars`:**
```hcl
team_tag_policies = {
  "bi-team-dynamodb-read" = {
    policy_template = "MCI-DynamoDB-TagBased-ReadOnly"
    team_name      = "BI-Team"
    environment    = "prod"
    project_name   = "DataAnalytics"
    description    = "Acceso de lectura DynamoDB para equipo BI"
  }
}
```

### **Rol usando tag-based policies:**
```json
{
  "role_name": "rol-bi-analytics-prod",
  "policies": {
    "aws_managed": ["AWSLambdaBasicExecutionRole"],
    "mci_managed": ["MCI-Lambda-Invoke"],
    "tag_based": ["bi-team-dynamodb-read", "bi-team-s3-read"]
  }
}
```

## 🚀 **BENEFICIOS INMEDIATOS**

1. **Escalabilidad Infinita**: Nueva tabla = acceso automático
2. **Separación Automática**: Tags separan equipos/entornos
3. **Menos Mantenimiento**: 98% menos políticas
4. **Gobernanza Integrada**: Sin tags = sin acceso
5. **Cost Allocation**: Tags facilitan billing por equipo
6. **Auditoría Simplificada**: Permisos basados en tags organizacionales

## ⚡ **PRÓXIMOS PASOS**

1. ✅ Crear ejemplos de recursos con tags correctos
2. ✅ Actualizar scripts de creación de roles
3. ✅ Documentar proceso de migración
4. ⏳ Migrar roles existentes gradualmente
5. ⏳ Crear alertas para recursos sin tags

---

**🎯 RESULTADO**: De 200+ políticas individuales a 4 políticas inteligentes que escalan automáticamente.
