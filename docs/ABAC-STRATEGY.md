# 🎯 Estrategia ABAC - Políticas Genéricas Modulares

## 📋 Decisión Arquitectónica

**Fecha:** 16 de Octubre 2025  
**Estado:** APROBADO - Estándar a largo plazo  
**Alcance:** Todas las políticas IAM de ejecución

---

## ✅ ESTRATEGIA DEFINITIVA

### **Políticas GENÉRICAS por Servicio AWS (NO por tipo de recurso)**

Creamos **políticas modulares reutilizables** que funcionan para **CUALQUIER recurso del mismo servicio AWS**, controlando el acceso mediante **tags ABAC**.

---

## 🏗️ Arquitectura de Políticas

### **Políticas Core (12 políticas para toda la infraestructura AWS):**

```
definitions/policies/execution/

# Amazon S3
├── mci-aws-s3-read.yaml              # Lee CUALQUIER bucket S3
├── mci-aws-s3-write.yaml             # Escribe en CUALQUIER bucket S3

# Amazon DynamoDB
├── mci-aws-dynamodb-read.yaml        # Lee CUALQUIER tabla DynamoDB
├── mci-aws-dynamodb-write.yaml       # Escribe en CUALQUIER tabla DynamoDB

# AWS Glue
├── mci-aws-glue-catalog-read.yaml    # Lee catálogo Glue
├── mci-aws-glue-catalog-write.yaml   # Escribe en catálogo Glue

# Servicios de Integración
├── mci-aws-sns-publish.yaml          # Publica en CUALQUIER SNS Topic
├── mci-aws-sqs-consume.yaml          # Consume de CUALQUIER SQS Queue
├── mci-aws-eventbridge-put.yaml      # Publica eventos en EventBridge

# Servicios de Seguridad
├── mci-aws-kms-decrypt.yaml          # Descifra con CUALQUIER KMS Key
├── mci-aws-secrets-read.yaml         # Lee CUALQUIER Secret

# Observabilidad
└── mci-aws-cloudwatch-logs.yaml      # Escribe logs en CloudWatch
```

---

## 🎯 Principios ABAC

### **1. Una Política = Un Servicio AWS**

```yaml
❌ MAL - Políticas específicas por recurso:
  - mci-aws-s3-datalake-read.yaml       # Solo buckets *-datalake
  - mci-aws-s3-reports-read.yaml        # Solo buckets *-reports-*
  - mci-aws-s3-logs-read.yaml           # Solo buckets *-logs-*
  
  Problema: Si creas 100 tipos de buckets, necesitas 100 políticas.

✅ BIEN - Política genérica:
  - mci-aws-s3-read.yaml                # TODOS los buckets S3
  
  Ventaja: Una sola política sirve para cualquier bucket.
          El ABAC (tags) controla qué buckets específicos.
```

### **2. Control de Acceso por Tags ABAC**

**Tags de Control de Acceso (obligatorios):**
- `Cuenta`: Segrega por ambiente AWS (clarohn-data-analytics-dev/qa/prod)
- `Dominio`: Segrega por dominio de negocio (DataAnalytics, Security, etc)

**Tags de Metadata (opcionales, no afectan acceso):**
- CreadoPor, Propietario, Proyecto, Layer, etc.

### **3. Ejemplo de Política Genérica:**

```yaml
# mci-aws-s3-read.yaml
policy:
  name: "mci-aws-s3-read"
  description: "Permite lectura en CUALQUIER bucket S3 con control ABAC por Cuenta y Dominio"
  service: "s3"
  version: "1.0.0"
  
  statements:
    - sid: "ReadS3WithABAC"
      effect: "Allow"
      actions:
        - "s3:GetObject"
        - "s3:GetObjectVersion"
        - "s3:ListBucket"
        - "s3:GetBucketLocation"
      resources:
        - "arn:aws:s3:::*"          # Wildcard: TODOS los buckets
        - "arn:aws:s3:::*/*"
      
      abac_conditions:
        - test: "StringEquals"
          variable: "aws:PrincipalTag/Cuenta"
          values: ["${aws:ResourceTag/Cuenta}"]
          note: "Solo accede a buckets de su misma Cuenta (dev/qa/prod)"
        
        - test: "StringEquals"
          variable: "aws:PrincipalTag/Dominio"
          values: ["${aws:ResourceTag/Dominio}"]
          note: "Solo accede a buckets de su mismo Dominio de negocio"
```

---

## 📊 Cómo Funciona el ABAC

### **Escenario: Glue Service Role necesita acceso a S3**

#### **1. Tags en los Buckets:**

```json
Bucket: s3-data-analytics-raw-dev-datalake
{
  "Cuenta": "clarohn-data-analytics-dev",
  "Dominio": "DataAnalytics"
}

Bucket: s3-data-analytics-reports-dev
{
  "Cuenta": "clarohn-data-analytics-dev",
  "Dominio": "DataAnalytics"
}

Bucket: s3-security-logs-dev
{
  "Cuenta": "clarohn-data-analytics-dev",
  "Dominio": "Security"
}

Bucket: s3-data-analytics-raw-prod-datalake
{
  "Cuenta": "clarohn-data-analytics-prod",
  "Dominio": "DataAnalytics"
}
```

#### **2. Tags en el Rol Glue:**

```yaml
# mci-glue-service-role.yaml
tags:
  Cuenta: "clarohn-data-analytics-dev"
  Dominio: "DataAnalytics"
```

#### **3. Política Aplicada:**

```yaml
# mci-glue-service-role.yaml
policy_modules:
  - mci-aws-s3-read        # Política genérica S3
  - mci-aws-s3-write       # Política genérica S3
```

#### **4. Resultado del ABAC:**

```
Glue Role [Cuenta=dev, Dominio=DataAnalytics] intenta acceder:

✅ s3-data-analytics-raw-dev-datalake
   - Cuenta: dev ✅ (match)
   - Dominio: DataAnalytics ✅ (match)
   - RESULTADO: PERMITIDO

✅ s3-data-analytics-reports-dev
   - Cuenta: dev ✅ (match)
   - Dominio: DataAnalytics ✅ (match)
   - RESULTADO: PERMITIDO

❌ s3-security-logs-dev
   - Cuenta: dev ✅ (match)
   - Dominio: Security ❌ (NO match)
   - RESULTADO: DENEGADO

❌ s3-data-analytics-raw-prod-datalake
   - Cuenta: prod ❌ (NO match)
   - Dominio: DataAnalytics ✅ (match)
   - RESULTADO: DENEGADO
```

---

## 🎯 Ventajas de esta Estrategia

### **1. Escalabilidad Infinita**
```
✅ Creas 1 bucket nuevo → Acceso automático (si tiene tags correctos)
✅ Creas 100 buckets nuevos → Acceso automático
✅ Creas nuevo tipo de bucket → Sin cambios en políticas
```

### **2. Mantenimiento Mínimo**
```
✅ 12 políticas sirven para TODA tu infraestructura AWS
✅ Cambias 1 política → Afecta a todos los roles que la usan
✅ No hardcodeas ARNs específicos
```

### **3. Seguridad por Defecto**
```
✅ Sin tags → Sin acceso (Zero Trust)
✅ Tags incorrectos → Sin acceso
✅ Segregación automática por Cuenta (dev/qa/prod)
✅ Segregación automática por Dominio de negocio
```

### **4. Composición Flexible de Roles**
```yaml
# Glue necesita: S3 + Glue Catalog + KMS
mci-glue-service-role:
  - mci-aws-s3-read
  - mci-aws-s3-write
  - mci-aws-glue-catalog-read
  - mci-aws-glue-catalog-write
  - mci-aws-kms-decrypt
  - mci-aws-cloudwatch-logs

# Lambda necesita: S3 read + DynamoDB + SNS
mci-lambda-processor-role:
  - mci-aws-s3-read
  - mci-aws-dynamodb-read
  - mci-aws-dynamodb-write
  - mci-aws-sns-publish
  - mci-aws-cloudwatch-logs
```

---

## ❌ Anti-Patrones (NO HACER)

### **1. Políticas específicas por tipo de recurso**
```yaml
❌ NO CREAR:
  - mci-aws-s3-datalake-read.yaml
  - mci-aws-s3-reports-read.yaml
  - mci-aws-s3-logs-read.yaml
  
Problema: No escalable, requiere crear política nueva por cada tipo.
```

### **2. Hardcodear ARNs específicos**
```yaml
❌ MAL:
resources:
  - "arn:aws:s3:::s3-data-analytics-raw-dev-datalake"
  - "arn:aws:s3:::s3-data-analytics-standard-dev-datalake"

✅ BIEN:
resources:
  - "arn:aws:s3:::*"
conditions:
  - aws:PrincipalTag/Cuenta = aws:ResourceTag/Cuenta
```

### **3. Mezclar múltiples servicios en una política**
```yaml
❌ NO CREAR:
  - mci-glue-full-access.yaml  # Mezcla S3 + Glue + DynamoDB

✅ CREAR:
  - mci-aws-s3-read.yaml       # Solo S3
  - mci-aws-glue-catalog.yaml  # Solo Glue
  - mci-aws-dynamodb-read.yaml # Solo DynamoDB
```

---

## 🏷️ Tag ABAC Propuesto para S3

### Tag obligatorio para control de acceso granular:

- `Cuenta`: Segrega por ambiente AWS (clarohn-data-analytics-dev/qa/prod)
- `Proposito`: Segrega por tipo de bucket (DataLake, Reporting, Logging, Backup, etc)

### Ejemplo de uso:

```json
{
  "Cuenta": "clarohn-data-analytics-dev",
  "Proposito": "DataLake"
}
```

**Valores recomendados para `Proposito`:**
- `DataLake`      → Buckets de datos crudos, estándar, analytics
- `Reporting`     → Buckets de reportes
- `Logging`       → Buckets de logs
- `Backup`        → Buckets de backup
- `Archive`       → Buckets de archivo
- `TempData`      → Buckets temporales

### Ejemplo de política S3 con ABAC:

```yaml
abac_conditions:
  - test: "StringEquals"
    variable: "aws:PrincipalTag/Cuenta"
    values: ["${aws:ResourceTag/Cuenta}"]
    note: "Solo accede a buckets de su misma Cuenta (dev/qa/prod)"
  - test: "StringEquals"
    variable: "aws:PrincipalTag/Proposito"
    values: ["${aws:ResourceTag/Proposito}"]
    note: "Solo accede a buckets del mismo propósito (DataLake, Reporting, etc)"
```

---

## 📚 Referencias

- [AWS ABAC Documentation](https://docs.aws.amazon.com/IAM/latest/UserGuide/introduction_attribute-based-access-control.html)
- [AWS ABAC Workshop](https://catalog.workshops.aws/abac/en-US)
- [ABAC Best Practices](https://docs.aws.amazon.com/IAM/latest/UserGuide/best-practices.html#bp-abac)

---

## 👥 Responsables

- **Arquitecto:** Darwin Lopez
- **Equipo:** DevOps MCI
- **Contacto:** darwin.lopez@claro.com.gt

---

**Última actualización:** 16 de Octubre 2025
