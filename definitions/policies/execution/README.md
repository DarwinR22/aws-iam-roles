# 📋 Políticas de Ejecución Lambda (ABAC)

Políticas genéricas con Attribute-Based Access Control (ABAC) para funciones Lambda.

## 🎯 Patrón ABAC

Estas políticas permiten que **un solo rol Lambda** sirva a **múltiples funciones**, diferenciadas únicamente por **tags**.

### Ventajas:
- ✅ **Escalabilidad**: Un rol para todas las Lambdas
- ✅ **Seguridad automática**: Lambda solo accede a recursos con sus mismos tags
- ✅ **Menos gestión**: No crear rol nuevo por cada Lambda

---

## 📄 Políticas Disponibles

### 1. `lambda-cloudwatch-logs.yaml`
**Propósito:** Escribir logs en CloudWatch Logs

**Control ABAC:**
- Lambda solo puede crear log groups con sus mismos tags `Gerencia` y `Ambiente`
- Lambda solo puede escribir en log streams que coincidan con sus tags

**Uso:**
```yaml
# Tags de la Lambda
Gerencia: MCI
Ambiente: DEV

# Solo puede escribir en log groups con:
Gerencia: MCI  ✅
Ambiente: DEV  ✅
```

---

### 2. `lambda-sns-publish.yaml`
**Propósito:** Publicar mensajes en SNS Topics

**Control ABAC:**
- Lambda solo puede publicar en topics con su misma `Gerencia` y `Ambiente`

**Uso:**
```yaml
# Lambda con tags:
Gerencia: MCI
Ambiente: DEV

# Puede publicar en:
arn:aws:sns:us-east-1:123:iam-security-alerts
  Tags: Gerencia=MCI, Ambiente=DEV  ✅

# NO puede publicar en:
arn:aws:sns:us-east-1:123:other-team-alerts
  Tags: Gerencia=TI, Ambiente=DEV  ❌
```

---

### 3. `lambda-cloudtrail-read.yaml`
**Propósito:** Leer eventos de CloudTrail (para Lambdas de monitoreo)

**Control ABAC:**
- Solo Lambdas con `Gerencia: MCI`
- Solo Lambdas con `Dominio: Security` o `Dominio: Serverless`

**Uso:**
```yaml
# Lambda de seguridad IAM:
Gerencia: MCI       ✅
Dominio: Security   ✅
Resultado: PUEDE leer CloudTrail

# Lambda de procesamiento datos:
Gerencia: MCI       ✅
Dominio: DataProcessing  ❌
Resultado: NO puede leer CloudTrail
```

---

## 🏗️ Cómo Usar

### Paso 1: Crear rol genérico (en este repo)

```yaml
# definitions/roles/lambda-execution-role.yaml
role:
  name: "lambda-execution-role"
  trust_policy:
    type: "service"
    service_principal: "lambda.amazonaws.com"
  
  policy_modules:
    - name: "lambda-cloudwatch-logs"
      file: "lambda-cloudwatch-logs.yaml"
    - name: "lambda-sns-publish"
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
| **CloudWatch Log Group** | `Gerencia` + `Ambiente` match | ✅ Puede escribir |
| **SNS Topic** | `Gerencia` + `Ambiente` match | ✅ Puede publicar |
| **CloudTrail** | `Gerencia=MCI` + `Dominio=Security/Serverless` | ✅ Puede leer |
| **Recurso sin tags** | N/A | ❌ Denegado |
| **Recurso con tags diferentes** | No match | ❌ Denegado |

---

## 📊 Ejemplo Completo: Lambda IAM Security Monitor

### Lambda Function Tags:
```yaml
Gerencia: MCI
Area: DevOps
Ambiente: DEV
Dominio: Security
```

### Puede acceder a:

✅ **CloudWatch Log Group:**
```
/aws/lambda/iam-security-monitor-dev
Tags: Gerencia=MCI, Ambiente=DEV
```

✅ **SNS Topic:**
```
arn:aws:sns:us-east-1:393209814297:iam-security-alerts
Tags: Gerencia=MCI, Ambiente=DEV
```

✅ **CloudTrail:**
```
Permisos: LookupEvents, GetEventSelectors
Condición: Gerencia=MCI + Dominio=Security ✅
```

### NO puede acceder a:

❌ **SNS Topic de otro equipo:**
```
arn:aws:sns:us-east-1:393209814297:dataops-alerts
Tags: Gerencia=DataOps, Ambiente=DEV
```

❌ **Log Group sin tags:**
```
/aws/lambda/legacy-function
Sin tags
```

---

## 🚀 Escalabilidad

Con este patrón ABAC:

| Lambdas | Roles Necesarios | Políticas Necesarias |
|---------|------------------|----------------------|
| 1 Lambda | 1 rol | 3 políticas |
| 10 Lambdas | 1 rol | 3 políticas |
| 100 Lambdas | 1 rol | 3 políticas |

**Sin ABAC necesitarías:**
- 100 roles diferentes
- 300 políticas diferentes

---

## 📝 Notas

- Las políticas se generan automáticamente como módulos Terraform
- Los tags se validan en tiempo de ejecución por AWS IAM
- Si no hay match de tags, la solicitud es **denegada automáticamente**
- No requiere cambios de código en la Lambda

---

## 🔗 Referencias

- [Definición de roles](../roles/)
- [Políticas de deployment](../deployment/)
- [Documentación ABAC AWS](https://docs.aws.amazon.com/IAM/latest/UserGuide/introduction_attribute-based-access-control.html)
