# 📦 Legacy Catalog Files

## Overview
Esta carpeta contiene archivos del **catálogo V1 monolítico** que han sido reemplazados por el **catálogo V2 modular**.

## Files

### `policies.yaml`
- **Propósito**: Catálogo monolítico original con todas las políticas
- **Estado**: ❌ **OBSOLETO** - Reemplazado por catálogo V2 modular
- **Migración**: Políticas migradas a `catalog/v2/services/`
- **Uso**: Solo referencia histórica

## Migration to Catalog V2

### ✅ **Migrated Successfully:**
- ✅ **Scripts**: `create_role_scalable.py`, `iam_lint.py`, `generate_docs.py`
- ✅ **Terraform**: `environments/dev/main.tf`
- ✅ **Deployment Policies**: Migradas de JSON a Terraform building blocks
- ✅ **Structure**: Modular por servicio en `/v2/services/`

### 📂 **New Structure:**
```
catalog/
├── v2/                           ✅ ACTIVE
│   ├── index.yaml               # Main index
│   ├── services/
│   │   ├── s3.yaml             # S3 policies
│   │   └── deployment.yaml     # Deployment policies
│   └── building_blocks/
│       └── deployment.yaml     # Technical documentation
└── legacy/                      📦 ARCHIVE
    └── policies.yaml           # This file (V1)
```

## Benefits of V2

✅ **Modular**: Each service in separate file  
✅ **Scalable**: Easy to add new services  
✅ **Building Blocks**: Terraform-native  
✅ **ABAC**: Built-in department/environment variables  
✅ **Versioned**: Per-service change control

## ⚠️ Important

**DO NOT USE** files in this legacy folder. They are maintained only for:
- Historical reference
- Emergency fallback scenarios  
- Migration verification

All production usage should reference **`catalog/v2/`** files.

---
**Migrated**: September 22, 2025  
**Framework**: MCI IAM ABAC Enterprise  
**Version**: 2.0