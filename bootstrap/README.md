# 🥾 Bootstrap - Infraestructura Base de Terraform

## 🎯 **Propósito**

Esta carpeta contiene la **infraestructura base** necesaria para que el proyecto Terraform funcione con **remote state** y **state locking**.

---

## 🏗️ **¿Qué Despliega?**

### 1. **🔐 KMS Customer Managed Key**
```
Alias: alias/dynamodb-terraform-lock-dev
Purpose: Encriptación de DynamoDB state locking
Rotation: ✅ Automática habilitada
```

### 2. **🗄️ DynamoDB State Lock Table**
```
Nombre: dynamodb-db-dev-terraform-lock
Encryption: ✅ KMS Customer Managed Key
Purpose: Prevenir concurrent Terraform runs
```

### 3. **📊 Recursos Creados**
- **KMS Key:** `fe44eac8-0501-4620-bba9-b0155ed1b1a1`
- **DynamoDB Table:** Para state locking
- **Alias KMS:** `alias/dynamodb-terraform-lock-dev`

---

## 🚀 **Uso (Solo Una Vez)**

### **⚠️ YA ESTÁ DESPLEGADO**
Este bootstrap **ya fue ejecutado** y los recursos están **activos** en AWS.

### **Si necesitas re-desplegar:**
```bash
cd bootstrap/
terraform init
terraform plan
terraform apply
```

---

## 📁 **Archivos**

| Archivo | Propósito |
|---------|-----------|
| `main.tf` | Configuración principal y providers |
| `dynamodb.tf` | KMS key + DynamoDB table |
| `variables.tf` | Variables de configuración |
| `terraform.tfstate` | **State local** (bootstrap exception) |
| `.terraform.lock.hcl` | Provider version locks |

---

## ⚠️ **Consideraciones Críticas**

### **🔒 State Local**
- Bootstrap usa **state local** por necesidad (chicken-and-egg)
- Es la **única excepción** - todo lo demás usa remote state
- **NO migrar** a remote state (causaría loop infinito)

### **💰 Costos**
- **KMS Key:** ~$1/mes
- **DynamoDB:** $0 (On-demand, solo se cobra por uso)
- **Total estimado:** ~$1/mes

### **🛡️ Seguridad**
- KMS key con **least privilege policy**
- DynamoDB encriptada con **Customer Managed Key**
- Cumple con **security compliance** (Checkov)

---

## 🔍 **Verificación**

### **Verificar KMS Key:**
```bash
aws kms describe-key --key-id alias/dynamodb-terraform-lock-dev
```

### **Verificar DynamoDB:**
```bash
aws dynamodb describe-table --table-name dynamodb-db-dev-terraform-lock
```

### **Ver costos:**
```bash
aws ce get-cost-and-usage --time-period Start=2025-09-01,End=2025-09-30 --granularity MONTHLY --metrics BlendedCost --group-by Type=DIMENSION,Key=SERVICE
```

---

## 🚨 **¡NO ELIMINAR!**

### **⛔ Nunca ejecutar:**
```bash
terraform destroy  # ❌ Rompería todo el proyecto
```

### **🔄 Si necesitas cambios:**
1. Hacer cambios en archivos `.tf`
2. Ejecutar `terraform plan` 
3. Revisar cambios cuidadosamente
4. Ejecutar `terraform apply`

---

## 📞 **Soporte**

Si hay problemas con el bootstrap, contactar:
- **Responsable:** Darwin López
- **Email:** darwin.lopez@claro.com.gt

---

**✅ Bootstrap completado exitosamente - No requiere mantenimiento regular**