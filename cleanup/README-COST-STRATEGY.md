# 🧹 SGSI Cost Optimization & Cleanup Strategy

## 💰 **Problema**: Costos AWS Inesperados
El proyecto SGSI puede generar costos significativos si se dejan recursos activos 24/7, especialmente:
- **NAT Gateways**: ~$45/mes cada uno (ALTO COSTO)
- **EC2 Instances**: ~$30/mes cada una
- **Load Balancers**: ~$22/mes cada uno
- **RDS Databases**: ~$15-50/mes cada una

## ✅ **Solución**: Limpieza Inteligente

### **🎯 Estrategia de 3 Niveles**

#### **1. MINIMAL CLEANUP** (Recomendado para uso diario)
```powershell
.\scripts\quick-cleanup.ps1
```
- ✅ **Elimina**: Solo NAT Gateways (~$45-90/mes ahorro)
- ✅ **Preserva**: Todo lo demás
- ✅ **Tiempo**: 30 segundos
- ✅ **Recreación**: `terraform apply` (5 minutos)

#### **2. MODERATE CLEANUP** (Fin de semana)
```powershell
.\scripts\sgsi-cleanup.ps1 -CleanupScope moderate -DryRun:$false
```
- ✅ **Elimina**: NAT Gateways + Load Balancers (~$70-150/mes ahorro)
- ✅ **Preserva**: EC2 (solo las detiene), VPC, IAM
- ✅ **Tiempo**: 2-3 minutos
- ✅ **Recreación**: `terraform apply` (10 minutos)

#### **4. NUCLEAR CLEANUP** 💥 (Eliminar TODO lo costoso)
```powershell
.\scripts\nuclear-cleanup.ps1 -DryRun:$false
```
- 💥 **Elimina**: ABSOLUTAMENTE TODO lo que genere costo
- ✅ **Preserva**: Solo IAM, VPC base, Terraform state
- ✅ **Tiempo**: 2-5 minutos
- ✅ **Ahorro**: 100% de costos AWS (excepto storage mínimo)
- ✅ **Recreación**: `terraform apply` (15-20 minutos)

#### **5. ONE-LINER NUCLEAR** ⚡ (Super rápido)
```powershell
.\scripts\one-liner-nuclear.ps1
```
- ⚡ **Elimina**: TODO en 30 segundos
- 🚀 **Uso**: Final del día, vacaciones, emergencias

---

## 🚀 **Recursos SIN COSTO** (Nunca se eliminan)

### **IAM (Gratis)**
- ✅ Roles y Policies
- ✅ OIDC Providers
- ✅ Users y Groups

### **VPC Base (Gratis)**
- ✅ VPC y Subnets
- ✅ Security Groups
- ✅ Route Tables
- ✅ Internet Gateway

### **Terraform State (Gratis en free tier)**
- ✅ S3 Bucket (terraform-state-bucket-*)
- ✅ DynamoDB Table (terraform-locks)

---

## 💸 **Recursos COSTOSOS** (Se eliminan según scope)

### **ALTO COSTO** ($45+ /mes)
- 🔥 **NAT Gateways** (prioridad #1 para eliminar)
- 🔥 **RDS Instances**
- 🔥 **EC2 Instances grandes**

### **MEDIO COSTO** ($15-30 /mes)
- 🟡 **Application Load Balancers**
- 🟡 **EC2 Instances pequeñas**
- 🟡 **VPC Endpoints**

### **BAJO COSTO** ($1-10 /mes)
- 🟢 **Elastic IPs no asociadas**
- 🟢 **EBS Volumes**
- 🟢 **Lambda Functions** (bajo uso)

---

## 📋 **Rutina Recomendada**

### **Desarrollo Diario**
```powershell
# Al terminar el día
.\scripts\quick-cleanup.ps1

# Al comenzar el día siguiente
terraform apply
```

### **Fin de Semana**
```powershell
# Viernes tarde
.\scripts\sgsi-cleanup.ps1 -CleanupScope moderate -DryRun:$false

# Lunes mañana
terraform apply
```

### **Emergencia/Vacaciones (NUCLEAR)**
```powershell
# Al salir (elimina TODO lo costoso)
.\scripts\nuclear-cleanup.ps1 -DryRun:$false

# Al regresar (recrear desde cero)
terraform apply
```

---

## 🛡️ **Protecciones Integradas**

### **Verificaciones de Seguridad**
- ✅ Confirma cuenta AWS correcta
- ✅ Muestra costo estimado ANTES de eliminar
- ✅ Requiere confirmación explícita
- ✅ Modo Dry Run por defecto

### **Preservación Automática**
- ✅ IAM nunca se toca (sin costo)
- ✅ Terraform state siempre preservado
- ✅ VPC base mantenida (recreación rápida)
- ✅ Logs y configuraciones preservados

---

## 📊 **Monitoreo de Costos**

### **AWS Cost Explorer**
- 📈 Revisar cada 2-3 días
- 📈 Configurar alertas >$20/mes
- 📈 Filtrar por tags del proyecto

### **Costos Objetivo SGSI**
- 🎯 **Desarrollo activo**: <$30/mes
- 🎯 **Desarrollo pausado**: <$5/mes
- 🎯 **Solo preservación**: $0/mes

---

## 🚀 **Comandos Rápidos**

```powershell
# Ver qué recursos costosos hay (simulación)
.\scripts\nuclear-cleanup.ps1 -DryRun:$true

# Limpieza rápida diaria (solo NAT Gateways)
.\scripts\quick-cleanup.ps1

# NUCLEAR - Eliminar TODO lo costoso
.\scripts\nuclear-cleanup.ps1 -DryRun:$false

# One-liner súper rápido
.\scripts\one-liner-nuclear.ps1

# Recrear infraestructura completa
terraform apply

# Ver estado actual
terraform show

# Planear cambios
terraform plan
```

---

## 🎓 **Para Proyecto Universitario**

### **Estrategia Académica**
1. **Documentar todo** el proceso de limpieza/recreación
2. **Demostrar** cost optimization como parte del SGSI
3. **Incluir** monitoreo de costos en la documentación
4. **Evidenciar** buenas prácticas de DevOps

### **Compliance SGSI**
- ✅ **ISO 27001**: Gestión eficiente de recursos
- ✅ **NIST CSF**: Cost-effective security controls
- ✅ **Zero Trust**: Minimal infrastructure footprint
- ✅ **DevOps**: Infrastructure as Code + automation

¡Esta estrategia te permite mantener costos bajo control mientras desarrollas tu proyecto SGSI! 🎯