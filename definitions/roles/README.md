# 🔐 Roles de Deployment - Multi-Cuenta

## 📋 Resumen

Este directorio contiene las definiciones de roles IAM para GitHub Actions deployment en **3 cuentas AWS diferentes**.

## 🏗️ Arquitectura Multi-Cuenta

```
┌─────────────────────────────────────────────────────────────┐
│                    GitHub Repository                         │
│              ClaroCENAM/mci-aws-iam                         │
└─────────────────────────────────────────────────────────────┘
                            │
                ┌───────────┼───────────┐
                │           │           │
        ┌───────▼──┐   ┌───▼──────┐   ┌▼──────────┐
        │ Rama dev │   │ Rama qa  │   │ Rama main │
        └───────┬──┘   └───┬──────┘   └┬──────────┘
                │           │           │
        ┌───────▼──────┐ ┌─▼─────────┐ ┌▼──────────────┐
        │  Cuenta DEV  │ │ Cuenta QA │ │ Cuenta PROD   │
        │ 393209814297 │ │873152456645│ │ 331355389575 │
        └──────────────┘ └───────────┘ └───────────────┘
```

## 📁 Archivos de Configuración

| Archivo | Cuenta AWS | Rama | Pull Requests | SOX |
|---------|------------|------|---------------|-----|
| `github-deployment-role.yaml` | **DEV** (393209814297) | `dev` | ✅ Permitido | No |
| `github-deployment-role-qa.yaml` | **QA** (873152456645) | `qa` | ✅ Permitido | No |
| `github-deployment-role-prod.yaml` | **PROD** (331355389575) | `main` | ❌ Bloqueado | Si |

## 🔒 Restricciones de Seguridad

### 1. Restricción por Repositorio
Todos los roles **solo** aceptan el repositorio específico:
```yaml
repositories:
  - "repo:DarwinR22/aws-iam-roles"  # ✅ Solo este repo
```

### 2. Restricción por Rama (Branch)

#### DEV
```yaml
values: 
  - "repo:DarwinR22/aws-iam-roles:ref:refs/heads/dev"
  - "repo:DarwinR22/aws-iam-roles:pull_request"
```

#### QA
```yaml
values: 
  - "repo:DarwinR22/aws-iam-roles:ref:refs/heads/qa"
  - "repo:DarwinR22/aws-iam-roles:pull_request"
```

#### PROD
```yaml
values: 
  - "repo:DarwinR22/aws-iam-roles:ref:refs/heads/main"
  # ⚠️ NO incluye pull_request por seguridad
```

### 3. Protección Auto-Eliminación
Todos los roles incluyen una política de **deny explícito** para prevenir auto-eliminación:
```yaml
- sid: "DenyDeleteSelfRole"
  effect: "Deny"
  actions:
    - "iam:DeleteRole"
    - "iam:DeleteRolePolicy"
    - "iam:DetachRolePolicy"
    - "iam:UpdateAssumeRolePolicy"
```

## 🚀 Flujo de Deployment

### Desarrollo (DEV)
```bash
# 1. Crear feature branch
git checkout -b feature/nueva-funcionalidad

# 2. Hacer cambios y commit
git add .
git commit -m "feat: nueva funcionalidad"

# 3. Push y crear PR
git push origin feature/nueva-funcionalidad
# Crear PR hacia 'dev'

# 4. Merge a dev → Deploy automático a cuenta DEV
```

### Quality Assurance (QA)
```bash
# 1. Merge de dev a qa
git checkout qa
git merge dev

# 2. Push → Deploy automático a cuenta QA
git push origin qa
```

### Producción (PROD)
```bash
# 1. Merge de qa a main (requiere aprobación)
git checkout main
git merge qa

# 2. Push → Deploy automático a cuenta PROD
git push origin main
```

## 🎯 Matriz de Acceso

| Rama | Cuenta DEV | Cuenta QA | Cuenta PROD |
|------|------------|-----------|-------------|
| `dev` | ✅ | ❌ | ❌ |
| `qa` | ❌ | ✅ | ❌ |
| `main` | ❌ | ❌ | ✅ |
| `feature/*` | ❌ | ❌ | ❌ |
| `hotfix/*` | ❌ | ❌ | ❌ |
| Pull Request | ✅ DEV/QA | ✅ DEV/QA | ❌ |

## 📊 Diferencias por Ambiente

### DEV
- **Risk Level:** High
- **SOX:** No
- **Pull Requests:** ✅ Permitido
- **Session Timeout:** 60 min
- **Propósito:** Desarrollo y pruebas

### QA
- **Risk Level:** High
- **SOX:** No
- **Pull Requests:** ✅ Permitido
- **Session Timeout:** 60 min
- **Propósito:** Testing y validación

### PROD
- **Risk Level:** Critical ⚠️
- **SOX:** Si ✅
- **Pull Requests:** ❌ Bloqueado
- **Session Timeout:** 60 min
- **Propósito:** Producción

## 🛠️ Cómo Desplegar

### Opción 1: Deployment Automático (Recomendado)
```bash
# Push a la rama correspondiente
git push origin dev   # → Despliega a DEV
git push origin qa    # → Despliega a QA
git push origin main  # → Despliega a PROD
```

### Opción 2: Deployment Manual
```bash
# 1. Generar Terraform
python generators/generate_all.py

# 2. Aplicar en la cuenta correspondiente
cd generated/
terraform init
terraform plan
terraform apply
```

## 🔍 Verificación Post-Deployment

### Verificar Trust Policy
```bash
# DEV
aws iam get-role --role-name github-actions-iam-deployment-role \
  --profile dev \
  --query 'Role.AssumeRolePolicyDocument.Statement[0].Condition'

# QA
aws iam get-role --role-name github-actions-iam-deployment-role \
  --profile qa \
  --query 'Role.AssumeRolePolicyDocument.Statement[0].Condition'

# PROD
aws iam get-role --role-name github-actions-iam-deployment-role \
  --profile prod \
  --query 'Role.AssumeRolePolicyDocument.Statement[0].Condition'
```

### Verificar Políticas Inline
```bash
aws iam list-role-policies --role-name github-actions-iam-deployment-role

# Debe incluir: github-deployment-protection
```

## 🚨 Troubleshooting

### Error: "Subject claim does not match"
**Causa:** Rama incorrecta intentando acceder a la cuenta.

**Solución:**
```bash
# Verificar rama actual
git branch --show-current

# Cambiar a la rama correcta
git checkout dev   # Para cuenta DEV
git checkout qa    # Para cuenta QA
git checkout main  # Para cuenta PROD
```

### Error: "Access Denied" en PROD desde PR
**Causa:** Pull requests están bloqueados en producción (esto es correcto).

**Solución:** Hacer merge a `main` primero, luego push.

### Error: "Cannot delete role"
**Causa:** Protección anti-eliminación activa (esto es correcto).

**Solución:** Si realmente necesitas eliminar:
1. Ir a AWS Console
2. Eliminar inline policy `github-deployment-protection`
3. Luego eliminar el rol

## 📚 Referencias

- [Guía de Seguridad](../docs/SECURITY-IMPROVEMENTS.md)
- [Convenciones](../docs/CONVENTIONS.md)
- [Deployment Guide](../docs/DEPLOYMENT.md)

---

**Versión:** 2.1.0  
**Última Actualización:** 2025-10-09  
**Mantenido por:** DevOps Team
