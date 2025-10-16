# 📋 Políticas de Ejecución ABAC (Genéricas y Reutilizables)

Políticas genéricas con Attribute-Based Access Control (ABAC) para **cualquier servicio AWS**: Lambda, Glue, ECS, Batch, etc.

**📖 Ver estrategia completa:** [ABAC-STRATEGY.md](../../../docs/ABAC-STRATEGY.md)

## 🎯 Patrón ABAC

Estas políticas permiten que **un solo rol Lambda** sirva a **múltiples funciones**, diferenciadas únicamente por **tags**.

### Ventajas:
- ✅ **Escalabilidad**: Un rol para todas las Lambdas
- ✅ **Seguridad automática**: Lambda solo accede a recursos con sus mismos tags
- ✅ **Menos gestión**: No crear rol nuevo por cada Lambda

---

## 📄 Políticas Disponibles

### **Amazon S3**

#### 1. `mci-aws-s3-read.yaml` ✨ NUEVA
**Propósito:** Lectura en buckets S3 con ABAC

**Control ABAC:**
- Solo buckets con mismo `Cuenta` (dev/qa/prod)
- Solo buckets con mismo `Proposito` (DataLake, Reporting, etc)

**Usado por:** Glue, Lambda, ECS, cualquier servicio que necesite leer S3

#### 2. `mci-aws-s3-write.yaml` ✨ NUEVA
**Propósito:** Escritura en buckets S3 con ABAC

**Control ABAC:**
- Solo buckets con mismo `Cuenta` y `Proposito`
- Incluye permisos de delete para sobrescritura

**Usado por:** Glue, Lambda, ECS

---

### **AWS Glue**

#### 3. `mci-aws-glue-catalog-read.yaml` ✨ NUEVA
**Propósito:** Lectura del Glue Data Catalog

**Control ABAC:**
- Solo databases/tables con mismo `Cuenta`

**Usado por:** Glue Jobs, Athena, Lambda Analytics

#### 4. `mci-aws-glue-catalog-write.yaml` ✨ NUEVA
**Propósito:** Escritura en Glue Data Catalog

**Control ABAC:**
- Solo databases/tables con mismo `Cuenta`
- Incluye create, update, delete

**Usado por:** Glue Jobs, Glue Crawlers

---

### **Amazon DynamoDB**

#### 5. `mci-aws-dynamodb-read.yaml` ✨ NUEVA
**Propósito:** Lectura en tablas DynamoDB

**Control ABAC:**
- Solo tablas con mismo `Cuenta`

**Usado por:** Lambda, Glue (para tracking/metadatos)

---

### **AWS KMS**

#### 6. `mci-aws-kms-decrypt.yaml` ✨ NUEVA
**Propósito:** Descifrado con KMS

**Control ABAC:**
- Solo KMS keys con mismo `Cuenta`

**Usado por:** Cualquier servicio que lea/escriba S3 encriptado

---

### **Amazon CloudWatch**

#### 7. `mci-aws-cloudwatch-logs.yaml` ✨ ACTUALIZADA
**Propósito:** Escritura de logs en CloudWatch

**Control ABAC:**
- Solo log groups con mismo `Cuenta`

**Usado por:** Lambda, Glue, ECS, Batch, cualquier servicio AWS

---

## 📝 Nota Importante

Estas son políticas **genéricas y reutilizables**. No crear políticas específicas por tipo de recurso (ej: mci-aws-s3-datalake-read, mci-aws-s3-reports-read).

**Una política = Un servicio AWS**. El control de acceso se hace vía tags ABAC (`Cuenta` + `Proposito`).

---

## 🏗️ Cómo Usar

### Paso 1: Crear rol que combine políticas necesarias

```yaml
# Ejemplo: definitions/roles/mci-glue-service-role.yaml
role:
  name: "mci-glue-service-role"
  trust_policy:
    - service: "glue.amazonaws.com"
  
  policy_modules:
    - name: "mci-aws-s3-read"
      file: "mci-aws-s3-read.yaml"
      folder: "execution"
    - name: "mci-aws-s3-write"
      file: "mci-aws-s3-write.yaml"
      folder: "execution"
    - name: "mci-aws-glue-catalog-read"
      file: "mci-aws-glue-catalog-read.yaml"
      folder: "execution"
    - name: "mci-aws-cloudwatch-logs"
      file: "mci-aws-cloudwatch-logs.yaml"
      folder: "execution"
  
  tags:
    Cuenta: "clarohn-data-analytics-dev"
    Proposito: "DataLake"
      file: "lambda-sns-publish.yaml"
    - name: "lambda-cloudtrail-read"
      file: "lambda-cloudtrail-read.yaml"
  
  tags:
    Gerencia: "MCI"
    Area: "DevOps"
    Ambiente: "DEV"
```

### Paso 2: Desplegar rol vía Terraform
El workflow de GitHub Actions generará y aplicará el rol.

### Paso 3: Usar rol en Lambda (en otro repo)

```ini
# variables-iam-security-monitor.env
lambda_role_arn = arn:aws:iam::393209814297:role/lambda-execution-role

# Tags específicos de esta Lambda (definen accesos)
Gerencia = MCI
Area = DevOps
Ambiente = DEV
Dominio = Security  # Le da acceso a CloudTrail
```

---

## 🔒 Matriz de Permisos ABAC

| Recurso | Tags Requeridos | Resultado |
|---------|-----------------|-----------|
| **S3 Bucket** | `Cuenta` + `Proposito` match | ✅ Puede acceder |
| **Glue Database/Table** | `Cuenta` match | ✅ Puede acceder |
| **DynamoDB Table** | `Cuenta` match | ✅ Puede acceder |
| **KMS Key** | `Cuenta` match | ✅ Puede usar |
| **CloudWatch Log Group** | `Cuenta` match | ✅ Puede escribir |
| **Recurso sin tags** | N/A | ❌ Denegado |
| **Recurso con tags diferentes** | No match | ❌ Denegado |

---

## 📊 Ejemplo Completo: Glue Job con ABAC

### Glue Role Tags:
```yaml
Cuenta: clarohn-data-analytics-dev
Proposito: DataLake
```

### Puede acceder a:

✅ **S3 Bucket DataLake:**
```
s3-data-analytics-raw-dev-datalake
Tags: Cuenta=clarohn-data-analytics-dev, Proposito=DataLake
```

✅ **Glue Database:**
```
glue_catalog_database: analytics_dev
Tags: Cuenta=clarohn-data-analytics-dev
```

✅ **DynamoDB Table:**
```
dynamodb-db-dev-glue-tracking
Tags: Cuenta=clarohn-data-analytics-dev
```

### NO puede acceder a:

❌ **S3 Bucket de Reports:**
```
s3-data-analytics-reports-dev
Tags: Cuenta=clarohn-data-analytics-dev, Proposito=Reporting
```

❌ **S3 Bucket de PROD:**
```
s3-data-analytics-raw-prod-datalake
Tags: Cuenta=clarohn-data-analytics-prod, Proposito=DataLake
```

---

## 🚀 Escalabilidad

Con este patrón ABAC:

| Roles | Políticas Genéricas | Recursos AWS |
|-------|---------------------|--------------|
| 1 Glue Role | 7 políticas | Acceso ilimitado con tags correctos |
| 10 Glue Roles | 7 políticas | Acceso ilimitado con tags correctos |
| 100 Roles diversos | 12 políticas | Acceso ilimitado con tags correctos |

**Sin ABAC necesitarías:**
- 100 roles diferentes
- 500+ políticas hardcodeadas
- Mantenimiento constante

---

## 📝 Notas

- Las políticas se generan automáticamente como módulos Terraform
- Los tags se validan en tiempo de ejecución por AWS IAM
- Si no hay match de tags, la solicitud es **denegada automáticamente**
- Funciona para Lambda, Glue, ECS, Batch, cualquier servicio AWS

---

## 🔗 Referencias

- [Definición de roles](../roles/)
- [Políticas de deployment](../deployment/)
- [Documentación ABAC AWS](https://docs.aws.amazon.com/IAM/latest/UserGuide/introduction_attribute-based-access-control.html)
