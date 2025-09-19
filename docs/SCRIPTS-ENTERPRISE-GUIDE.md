# 🛠️ Scripts Enterprise IAM - Guía de Uso

## 📋 **Scripts Disponibles**

### **1. 🏗️ create_role_enterprise.py**
**Propósito:** Crear nuevos roles con arquitectura enterprise
**Características:**
- ✅ Building blocks MCI
- ✅ S3 granular por bucket/path
- ✅ Tags automáticos por área
- ✅ Interfaz interactiva escalable

### **2. 🔧 edit_role_enterprise.py**
**Propósito:** Editar roles existentes con navegación escalable
**Características:**
- ✅ Navegación por áreas de negocio
- ✅ Edición de building blocks
- ✅ Gestión S3 granular
- ✅ Tags y metadata

### **3. 🔄 migrate_to_enterprise.py**
**Propósito:** Migrar roles legacy a arquitectura enterprise
**Características:**
- ✅ Conversión automática de políticas
- ✅ Backup antes de migración
- ✅ Reporte detallado
- ✅ Modo interactivo/automático

---

## 🚀 **Guía de Uso: Crear Rol Enterprise**

### **Paso 1: Ejecutar Script**
```bash
cd scripts
python create_role_enterprise.py
```

### **Paso 2: Seleccionar Área**
```
🏢 PASO 1: Selección de Área de Negocio
   [1] ventas
   [2] marketing  
   [3] finanzas
   [4] 🆕 Crear nueva área

👉 Selecciona opción [1-4]: 1
```

### **Paso 3: Detalles del Rol**
```
👤 PASO 2: Detalles del Rol en ventas
👉 Nombre del rol (sin prefijos): analista
👉 Descripción del rol: Analista de ventas con acceso a reportes

✅ Rol a crear: rol-ventas-analista
```

### **Paso 4: Building Blocks**
```
🧱 PASO 3: Building Blocks MCI
🔹 S3:
   [1] MCI-S3-ReadOnly - Lectura global en S3
   [2] MCI-S3-Write - Escritura global en S3

👉 Selecciona S3 [números separados por coma]: 1

🔹 DynamoDB:
   [3] MCI-DynamoDB-ReadOnly - Lectura en DynamoDB
   [4] MCI-DynamoDB-Write - Escritura en DynamoDB

👉 Selecciona DynamoDB: 3
```

### **Paso 5: S3 Granular (Opcional)**
```
🔐 PASO 4: S3 Granular (Opcional)
👉 ¿Agregar acceso S3 específico? [y/n]: y

🪣 Configurar acceso S3:
👉 Nombre del bucket: mci-data-lake
👉 Prefijo/ruta: ventas/reportes
👉 Selecciona [1-2]: 1 (Solo lectura)

✅ S3 configurado: mci-data-lake/ventas/reportes (readonly)
```

### **Resultado:**
```
🎉 ROL ENTERPRISE CREADO EXITOSAMENTE
📁 Archivo: gerencias/ventas/rol-ventas-analista.json
🧱 Building Blocks MCI:
   ✅ MCI-S3-ReadOnly
   ✅ MCI-DynamoDB-ReadOnly
🔐 Configuraciones S3:
   ✅ mci-data-lake/ventas/reportes (readonly)
```

---

## 🔧 **Guía de Uso: Editar Rol**

### **Paso 1: Ejecutar Editor**
```bash
python edit_role_enterprise.py
```

### **Paso 2: Navegación Escalable**
```
🏢 NAVEGACIÓN POR ÁREAS DE NEGOCIO
   [1] VENTAS (5 roles)
   [2] MARKETING (3 roles)
   [3] FINANZAS (8 roles)

👉 Selecciona área [1-3]: 1

📁 ROLES EN VENTAS:
   [1] rol-ventas-analista
   [2] rol-ventas-manager
   [3] rol-ventas-director

👉 Selecciona rol [1-3]: 1
```

### **Paso 3: Ver Resumen Enterprise**
```
📋 RESUMEN ENTERPRISE: rol-ventas-analista
🏢 Área: ventas
🧱 BUILDING BLOCKS MCI:
   ✅ MCI-S3-ReadOnly - Lectura global en S3
   ✅ MCI-DynamoDB-ReadOnly - Lectura en DynamoDB
🔐 S3 GRANULAR:
   ✅ ventas_reportes
🏷️ TAGS AUTOMÁTICOS POR ÁREA:
   • Area: ventas
   • Propietario: [configurado en area-metadata.tfvars]
```

### **Paso 4: Opciones de Edición**
```
🔧 OPCIONES DE EDICIÓN ENTERPRISE
   [1] 🧱 Editar Building Blocks MCI
   [2] 🔐 Gestionar S3 Granular
   [3] ☁️ Editar Políticas AWS
   [4] 🏷️ Editar Tags del Rol
   [5] 📝 Cambiar Descripción
   [6] 💾 Guardar y Salir
```

---

## 🔄 **Guía de Uso: Migración**

### **Paso 1: Ejecutar Migrador**
```bash
python migrate_to_enterprise.py
```

### **Paso 2: Seleccionar Modo**
```
🔄 MIGRADOR ENTERPRISE IAM
   [1] Interactiva (recomendado)
   [2] Automática

👉 Selecciona [1-2]: 1
```

### **Paso 3: Proceso de Migración**
```
✅ Backup creado en: backup_migration
📊 Encontrados 12 roles para analizar

🔄 Migrando: rol-ventas-old-policy
📁 Área: ventas
🧱 Building blocks sugeridos: ['MCI-S3-ReadOnly', 'MCI-DynamoDB-ReadOnly']
🔐 Políticas S3 específicas encontradas: ['policy-s3-ventas-specific']
👉 ¿Convertir a S3 granular? [y/n]: y
✅ S3 granular configurado: ['s3-ventas-specific']
✅ Migrado exitosamente
```

### **Paso 4: Reporte de Migración**
```
🎉 MIGRACIÓN COMPLETADA
📊 10/12 roles migrados exitosamente
💾 Backup disponible en: backup_migration
📋 Reporte generado: migration_report.md
```

---

## 📝 **Estructura de Archivos Generados**

### **Rol Enterprise Típico:**
```json
{
  "role_name": "rol-ventas-analista",
  "description": "Analista de ventas con acceso a reportes",
  "trust_policy": {
    "Version": "2012-10-17",
    "Statement": [
      {
        "Effect": "Allow",
        "Principal": {"AWS": "arn:aws:iam::ACCOUNT_ID:root"},
        "Action": "sts:AssumeRole"
      }
    ]
  },
  "policies": {
    "mci_generic": [
      "MCI-S3-ReadOnly",
      "MCI-DynamoDB-ReadOnly"
    ],
    "s3_granular": [
      "ventas-reportes"
    ],
    "aws_managed": [
      "arn:aws:iam::aws:policy/ReadOnlyAccess"
    ]
  },
  "tags": {
    "RoleType": "Application",
    "CreatedBy": "IAMGenerator",
    "CreatedDate": "2025-09-19",
    "Nivel": "Standard"
  }
}
```

### **Configuración S3 en area-metadata.tfvars:**
```hcl
s3_path_policies = {
  "ventas-reportes" = {
    bucket_name = "mci-data-lake"
    path_prefix = "ventas/reportes"
    access_type = "readonly"
    description = "Acceso ventas a mci-data-lake/ventas/reportes"
  }
}
```

---

## 🎯 **Mejores Prácticas**

### **✅ Nomenclatura de Roles:**
```
✅ rol-area-funcion          # rol-ventas-analista
✅ rol-area-nivel-funcion    # rol-it-senior-developer
✅ rol-area-proyecto         # rol-marketing-campaign2025
```

### **✅ Building Blocks:**
- **Solo lectura:** `MCI-S3-ReadOnly` + `MCI-DynamoDB-ReadOnly`
- **Desarrollador:** `MCI-S3-Write` + `MCI-Lambda-Invoke`
- **Analista:** `MCI-S3-ReadOnly` + específicos S3 granular
- **Manager:** Building blocks múltiples según área

### **✅ S3 Granular:**
```
✅ ventas-reportes           # bucket/area-tipo
✅ marketing-campaigns       # bucket/funcion
✅ finanzas-auditoria-2025   # bucket/funcion-periodo
```

### **❌ Anti-Patterns:**
```
❌ policy-custom-user-specific     # Muy específico
❌ rol-juan-personal-access        # Nombramiento personal
❌ temp-role-delete-later          # Temporal sin governance
```

---

## 🚀 **Workflow Completo**

### **Para Nuevos Roles:**
```bash
# 1. Crear rol
python create_role_enterprise.py

# 2. Commit
git add .
git commit -m "feat: add rol-area-funcion with building blocks"
git push

# 3. GitHub Actions despliega automáticamente
```

### **Para Roles Existentes:**
```bash
# 1. Editar rol
python edit_role_enterprise.py

# 2. Commit cambios
git add .
git commit -m "feat: update rol-X with new building blocks"
git push
```

### **Para Migración Masiva:**
```bash
# 1. Migrar arquitectura
python migrate_to_enterprise.py

# 2. Revisar migration_report.md

# 3. Commit migración
git add .
git commit -m "feat: migrate to enterprise architecture"
git push
```

---

## 🎉 **¡Scripts Enterprise Listos!**

**🏗️ Tu flujo enterprise está completo:**
- ✅ **Creación** escalable con building blocks
- ✅ **Edición** con navegación por áreas
- ✅ **Migración** automática desde legacy
- ✅ **S3 granular** por bucket/path
- ✅ **Tags automáticos** por área
- ✅ **Documentación** completa

**🚀 Próximo paso:** ¡Probar creando un rol enterprise!
