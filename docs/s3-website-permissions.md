# S3 Website Configuration Permissions - Deployment Only

## 📋 Overview

Se agregaron permisos `s3:GetBucketWebsite` y `s3:PutBucketWebsite` **SOLO a las políticas de deployment** para habilitar la gestión de configuraciones de website estático durante el proceso de despliegue.

## 🎯 Permiso Agregado

- **s3:GetBucketWebsite**: Permite leer la configuración de website del bucket durante deployment
- **s3:PutBucketWebsite**: Permite configurar un bucket como website estático durante deployment

## 📁 Archivos Modificados

### ✅ **policy_lib/deployment/main.tf** (ÚNICAMENTE)
- ✅ `TerraformStateBackend` - Agregado `s3:GetBucketWebsite`
- ✅ `S3AnalyticsFullDeployment` - Agregado `s3:GetBucketWebsite` y `s3:PutBucketWebsite`

### ❌ **NO Modificados (políticas de usuario regular)**
- ❌ `policy_lib/s3/main.tf` - SIN cambios
- ❌ `policy_lib/s3/path_based_read_write.tf` - SIN cambios

## 🔧 Casos de Uso - Solo para Deployment

### 1. **Deployment de Website Estático via Terraform**
```terraform
resource "aws_s3_bucket_website_configuration" "example" {
  bucket = aws_s3_bucket.example.id

  index_document {
    suffix = "index.html"
  }

  error_document {
    key = "error.html"
  }
}
```

### 2. **CI/CD Pipeline Website Deployment**
- Deploy de aplicaciones SPA via GitHub Actions
- Configuración automática de websites durante deployment
- Setup de buckets analytics con hosting estático

### 3. **Terraform State Management**
- Leer configuraciones existentes de website durante plan
- Gestión de estado de buckets configurados como websites

## 🛡️ Consideraciones de Seguridad

### ✅ **Solo para Deployment Roles**
- Permiso restringido a roles de deployment únicamente
- NO disponible para usuarios finales o roles de aplicación
- Requiere tags de deployment apropiados

### ❌ **NO para Usuarios Regulares**
- Usuarios regulares NO pueden configurar websites
- Solo pueden leer/escribir contenido según políticas ABAC
- Website configuration es responsabilidad del equipo de deployment

## 📊 Impacto en Políticas Existentes

### **Tag-Based Policies**
```terraform
# Antes
actions = ["s3:ListBucket", "s3:GetBucketLocation"]

# Después  
actions = ["s3:ListBucket", "s3:GetBucketLocation", "s3:GetBucketWebsite"]
```

### **Deployment Policies**
```terraform
# Analytics Deployment - Nuevo
"s3:GetBucketWebsite",
"s3:PutBucketWebsite",  # Para configurar websites en buckets analytics
```

## 🔄 Próximos Pasos

1. **Testing**: Validar permisos en entorno dev
2. **Documentation**: Actualizar guías de usuario
3. **Monitoring**: Verificar uso correcto en CloudTrail
4. **Rollout**: Deploy a QA y luego producción

## 📝 Changelog

- **2025-09-23**: Initial implementation
  - Added `s3:GetBucketWebsite` to read policies
  - Added `s3:PutBucketWebsite` to deployment policies
  - Updated all S3 policy building blocks
  - Documented security implications and use cases