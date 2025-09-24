# 🤖 GitHub Actions Role - Documentación

## 📋 **Rol Actual en Uso**

### **Información del Rol:**
- **Nombre:** `github-actions-iam-deployment-role`
- **ARN:** `arn:aws:iam::393209814297:role/github-actions-iam-deployment-role`
- **Creado:** 16 de septiembre de 2025
- **Método:** Consola AWS (manual)
- **Estado:** ✅ **ACTIVO**

### **Trust Policy:**
```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Federated": "arn:aws:iam::393209814297:oidc-provider/token.actions.githubusercontent.com"
      },
      "Action": "sts:AssumeRoleWithWebIdentity",
      "Condition": {
        "StringEquals": {
          "token.actions.githubusercontent.com:aud": "sts.amazonaws.com"
        },
        "StringLike": {
          "token.actions.githubusercontent.com:sub": "repo:ClaroCENAM/*"
        }
      }
    }
  ]
}
```

### **Políticas Adjuntadas:**
1. `MCI-Deployment-TerraformCore` - Core Terraform operations
2. `MCI-Deployment-S3Analytics` - S3 analytics management  
3. `MCI-Deployment-Logs` - CloudWatch Logs
4. `MCI-Deployment-Lambda` - Lambda functions
5. `MCI-Deployment-DynamoDB` - DynamoDB operations
6. `MCI-Deployment-CloudFormation` - CloudFormation stacks

### **Tags del Rol:**
```json
{
  "Pais": "rg",
  "Gerencia": "MCI", 
  "Ambiente": "dev",
  "Direccion": "TIRegional",
  "Modulo": "IAM",
  "Alcance SOX": "No",
  "Propietario": "DarwinLopez",
  "Proveedor": "InHouse",
  "Layer": "Devops",
  "Dominio": "BusinessIntelligence",
  "Subdominio": "Analytics",
  "Aplicacion": "CICD",
  "Name": "github-actions-iam-deployment-role",
  "Soporte": "darwin.lopez@claro.com.gt",
  "Contacto": "darwin.lopez@claro.com.gt",
  "Creado Por": "DarwinLopez",
  "Tipo de Recurso": "IAMRole",
  "Ciclo de Vida": "Creacion",
  "Versión": "v1.0.0",
  "Fecha de Creacion": "2025-09-16"
}
```

## 🔍 **Verificación del Rol:**

### **Comando para verificar el rol:**
```bash
aws iam get-role --role-name github-actions-iam-deployment-role
```

### **Comando para ver políticas adjuntadas:**
```bash
aws iam list-attached-role-policies --role-name github-actions-iam-deployment-role
```

## ⚠️ **Notas Importantes:**

### **🚫 NO Modificar Manualmente**
Este rol es **crítico** para el funcionamiento del CI/CD. Cambios manuales pueden romper los deployments.

### **🔄 Modificaciones**
Para cambios en permisos, modificar las políticas en `policy_lib/deployment/` y dejar que Terraform las actualice automáticamente.

### **🛡️ Seguridad**
- Solo puede ser asumido por GitHub Actions del repositorio `ClaroCENAM/*`
- Limitado a operaciones IAM específicas mediante conditions ABAC
- Auditado automáticamente por CloudTrail

---

**✅ Este rol está documentado pero NO gestionado por este repositorio Terraform.**