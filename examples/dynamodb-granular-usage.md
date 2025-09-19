# DynamoDB Granular Access - Guía de Uso

## Configuración de Políticas DynamoDB Granulares

Esta guía explica cómo configurar acceso granular a tablas específicas de DynamoDB usando el sistema de building blocks empresarial.

## 1. Configurar Políticas en area-metadata.tfvars

```hcl
# Políticas específicas por tabla DynamoDB
dynamodb_table_policies = {
  "UserProfiles" = {
    table_name  = "mci-user-profiles"
    access_type = "write"
    description = "Política para acceso completo a tabla de perfiles de usuario"
  }
  "AuditLogs" = {
    table_name  = "mci-audit-logs"
    access_type = "readonly"
    description = "Política para acceso de solo lectura a tabla de logs de auditoría"
  }
  "TransactionHistory" = {
    table_name  = "mci-transaction-history"
    access_type = "readonly"
    description = "Política para acceso de solo lectura a historial de transacciones"
  }
}
```

## 2. Configurar Roles con Acceso Granular

### Ejemplo: Role de Microservicio de Usuarios

```hcl
locals {
  roles = {
    "user-service-role" = {
      role_name   = "MCI-UserService-Role"
      description = "Role para microservicio de gestión de usuarios"
      
      trust_policy = {
        Version = "2012-10-17"
        Statement = [{
          Effect = "Allow"
          Principal = {
            Service = "lambda.amazonaws.com"
          }
          Action = "sts:AssumeRole"
        }]
      }
      
      policies = {
        # Building blocks básicos
        mci_managed = [
          "MCI-Lambda-Invoke"
        ]
        
        # Acceso granular a DynamoDB
        dynamodb_granular = [
          "UserProfiles"  # Acceso completo a tabla de perfiles
        ]
      }
      
      tags = merge(local.area_tags["it"], {
        Service     = "UserManagement"
        Environment = "production"
      })
    }
  }
}
```

### Ejemplo: Role de Auditoría

```hcl
"audit-service-role" = {
  role_name   = "MCI-AuditService-Role"
  description = "Role para servicio de auditoría"
  
  trust_policy = {
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Principal = {
        Service = "lambda.amazonaws.com"
      }
      Action = "sts:AssumeRole"
    }]
  }
  
  policies = {
    # Building blocks básicos
    mci_managed = [
      "MCI-Lambda-Invoke"
    ]
    
    # Acceso de solo lectura a múltiples tablas
    dynamodb_granular = [
      "AuditLogs",
      "TransactionHistory"
    ]
  }
  
  tags = merge(local.area_tags["auditoria"], {
    Service     = "AuditingSystem"
    Environment = "production"
  })
}
```

## 3. Políticas Generadas

### Para acceso ReadOnly:
- **Política**: `MCI-DynamoDB-Table-AuditLogs`
- **Permisos**: GetItem, Query, Scan, BatchGetItem
- **Recurso**: `arn:aws:dynamodb:us-east-1:123456789012:table/mci-audit-logs*`

### Para acceso Write:
- **Política**: `MCI-DynamoDB-Table-UserProfiles`
- **Permisos**: Todos los permisos CRUD
- **Recurso**: `arn:aws:dynamodb:us-east-1:123456789012:table/mci-user-profiles*`

## 4. Recursos Incluidos en Políticas Granulares

Las políticas granulares incluyen acceso a:
- Tabla principal
- Índices secundarios globales (GSI)
- Índices secundarios locales (LSI)
- Streams de DynamoDB

## 5. Tipos de Acceso Disponibles

### `readonly`
- GetItem
- Query
- Scan
- BatchGetItem
- DescribeTable

### `write`
- Todos los permisos de readonly
- PutItem
- UpdateItem
- DeleteItem
- BatchWriteItem

## 6. Comandos para Aplicar

```bash
# Validar configuración
terraform validate

# Ver plan de ejecución
terraform plan -var-file="area-metadata.tfvars"

# Aplicar cambios
terraform apply -var-file="area-metadata.tfvars"
```

## 7. Verificar Políticas Creadas

```bash
# Listar políticas DynamoDB granulares
aws iam list-policies --query 'Policies[?starts_with(PolicyName, `MCI-DynamoDB-Table`)].{Name:PolicyName,Arn:Arn}'

# Ver detalles de una política específica
aws iam get-policy-version --policy-arn "arn:aws:iam::123456789012:policy/MCI-DynamoDB-Table-UserProfiles" --version-id v1
```

## 8. Mejores Prácticas

1. **Principio de Menor Privilegio**: Usar `readonly` cuando sea posible
2. **Nomenclatura Clara**: Nombres de tabla descriptivos
3. **Separación por Ambiente**: Diferentes tablas por DEV/QA/PROD
4. **Documentación**: Describir el propósito de cada política
5. **Revisión Regular**: Auditar permisos periódicamente

## 9. Integración con Scripts Empresariales

Los scripts `create_role_enterprise.py` y `edit_role_enterprise.py` serán actualizados para soportar selección de políticas DynamoDB granulares de manera interactiva.
