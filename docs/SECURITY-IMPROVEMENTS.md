# 🛡️ Mejoras de Seguridad - Roles de Deployment

## 📋 Resumen de Cambios (v2.1.0)

Se implementaron **3 mejoras críticas de seguridad** en el rol de GitHub Actions:

### ✅ Mejora 1: Restricción a Repositorio Específico
**Antes:**
```yaml
repositories:
  - "repo:ClaroCENAM/*"  # ❌ Cualquier repo de la org
```

**Después:**
```yaml
repositories:
  - "repo:ClaroCENAM/mci-aws-iam"  # ✅ Solo este repo
```

**Impacto:** Previene que otros repositorios de la organización asuman este rol.

---

### ✅ Mejora 2: Restricción por Branch (Multi-Cuenta)
**Concepto:** Cada cuenta AWS solo acepta su rama correspondiente.

#### 🔵 Cuenta DEV (393209814297)
```yaml
conditions:
  - test: "StringLike"
    variable: "token.actions.githubusercontent.com:sub"
    values: 
      - "repo:ClaroCENAM/mci-aws-iam:ref:refs/heads/dev"
      - "repo:ClaroCENAM/mci-aws-iam:pull_request"  # Para preview en PRs
```

#### 🟡 Cuenta QA (873152456645)
```yaml
conditions:
  - test: "StringLike"
    variable: "token.actions.githubusercontent.com:sub"
    values: 
      - "repo:ClaroCENAM/mci-aws-iam:ref:refs/heads/qa"
      - "repo:ClaroCENAM/mci-aws-iam:pull_request"  # Para preview en PRs
```

#### 🔴 Cuenta PROD (331355389575)
```yaml
conditions:
  - test: "StringLike"
    variable: "token.actions.githubusercontent.com:sub"
    values: 
      - "repo:ClaroCENAM/mci-aws-iam:ref:refs/heads/main"
      # ⚠️ NO incluir pull_request en producción
```

**Impacto:** 
- ✅ Rama `dev` solo puede desplegar a cuenta DEV
- ✅ Rama `qa` solo puede desplegar a cuenta QA
- ✅ Rama `main` solo puede desplegar a cuenta PROD
- ❌ Rama `feature/test` no puede desplegar a ninguna cuenta

---

### ✅ Mejora 3: Protección Contra Auto-Eliminación
```yaml
- name: "github-deployment-protection"
  inline_policy:
    statements:
      - sid: "DenyDeleteSelfRole"
        effect: "Deny"
        actions:
          - "iam:DeleteRole"
          - "iam:DeleteRolePolicy"
          - "iam:DetachRolePolicy"
          - "iam:UpdateAssumeRolePolicy"
        resources:
          - "arn:aws:iam::${account_id}:role/github-actions-iam-deployment-role"
```

**Impacto:** El rol no puede eliminarse a sí mismo, previniendo lockouts accidentales.

---

## 🚀 Cómo Aplicar en Otras Cuentas

### Paso 1: Identificar tus Cuentas AWS
```bash
# Cuenta DEV
Account ID: 393209814297
Rama: dev
Estado: ✅ Ya actualizado

# Cuenta QA
Account ID: 873152456645
Rama: qa
Estado: ✅ Archivo creado (github-deployment-role-qa.yaml)

# Cuenta PROD
Account ID: 331355389575
Rama: main
Estado: ✅ Archivo creado (github-deployment-role-prod.yaml)
```

### Paso 2: Archivos Creados ✅

Los archivos ya están creados y configurados:

#### QA (873152456645)
- ✅ Archivo: `definitions/roles/github-deployment-role-qa.yaml`
- ✅ Account ID: 873152456645
- ✅ Rama: `qa`
- ✅ Tags: Ambiente="QA"
- ✅ Pull Requests: Permitido

#### PROD (331355389575)
- ✅ Archivo: `definitions/roles/github-deployment-role-prod.yaml`
- ✅ Account ID: 331355389575
- ✅ Rama: `main`
- ✅ Tags: Ambiente="PROD", SOX="Si"
- ⚠️ Pull Requests: Bloqueado (seguridad)

### Paso 3: Desplegar en Cada Cuenta

```bash
# 1. Desplegar en DEV (ya hecho)
git checkout dev
git push origin dev

# 2. Desplegar en QA
git checkout qa
# Asegurarse que github-deployment-role-qa.yaml existe
git push origin qa

# 3. Desplegar en PROD
git checkout main
# Asegurarse que github-deployment-role-prod.yaml existe
git push origin main
```

---

## 🧪 Cómo Probar las Restricciones

### Test 1: Rama Incorrecta
```bash
# Crear rama de prueba
git checkout -b feature/test-security

# Intentar desplegar
git push origin feature/test-security

# Resultado esperado: ❌ Error de autenticación OIDC
# "Error: Not authorized to perform sts:AssumeRoleWithWebIdentity"
```

### Test 2: Repo Incorrecto
```bash
# Desde otro repositorio de ClaroCENAM
# Intentar usar el mismo rol ARN

# Resultado esperado: ❌ Error de autenticación
# "Error: Subject claim does not match expected value"
```

### Test 3: Auto-Eliminación
```bash
# En el workflow, agregar:
# - aws iam delete-role --role-name github-actions-iam-deployment-role

# Resultado esperado: ❌ Access Denied
# "Error: User is not authorized to perform: iam:DeleteRole"
```

---

## 📊 Matriz de Acceso

| Rama | Cuenta DEV | Cuenta QA | Cuenta PROD |
|------|------------|-----------|-------------|
| `dev` | ✅ Permitido | ❌ Denegado | ❌ Denegado |
| `qa` | ❌ Denegado | ✅ Permitido | ❌ Denegado |
| `main` | ❌ Denegado | ❌ Denegado | ✅ Permitido |
| `feature/*` | ❌ Denegado | ❌ Denegado | ❌ Denegado |
| `hotfix/*` | ❌ Denegado | ❌ Denegado | ❌ Denegado |

---

## 🔍 Verificación Post-Deployment

### Verificar Trust Policy
```bash
# En cada cuenta
aws iam get-role --role-name github-actions-iam-deployment-role \
  --query 'Role.AssumeRolePolicyDocument' \
  --output json

# Verificar que contenga:
# - "token.actions.githubusercontent.com:sub": "repo:ClaroCENAM/mci-aws-iam:ref:refs/heads/[RAMA]"
```

### Verificar Deny Policy
```bash
aws iam list-role-policies --role-name github-actions-iam-deployment-role

# Debe incluir: github-deployment-protection
```

---

## 📝 Checklist de Implementación

### Cuenta DEV (393209814297)
- [x] Restricción a repo específico
- [x] Restricción a rama `dev`
- [x] Protección auto-eliminación
- [x] Archivo actualizado: `github-deployment-role.yaml`
- [ ] Desplegar desde rama `dev`
- [ ] Verificar trust policy

### Cuenta QA (873152456645)
- [x] Crear `github-deployment-role-qa.yaml`
- [x] Cambiar account_id a 873152456645
- [x] Cambiar rama a `qa`
- [x] Actualizar tags (Ambiente: QA)
- [x] Incluir pull_request para preview
- [ ] Desplegar desde rama `qa`
- [ ] Verificar trust policy
- [ ] Probar acceso desde rama `dev` (debe fallar)

### Cuenta PROD (331355389575)
- [x] Crear `github-deployment-role-prod.yaml`
- [x] Cambiar account_id a 331355389575
- [x] Cambiar rama a `main`
- [x] Remover `pull_request` de conditions
- [x] Actualizar tags (Ambiente: PROD, SOX: Si)
- [x] Risk level: Critical
- [ ] Desplegar desde rama `main`
- [ ] Verificar trust policy
- [ ] Probar acceso desde rama `dev` (debe fallar)
- [ ] Probar acceso desde rama `qa` (debe fallar)

---

## 🚨 Troubleshooting

### Error: "Subject claim does not match"
**Causa:** La rama actual no coincide con la permitida en el trust policy.

**Solución:** Verificar que estás en la rama correcta:
```bash
git branch --show-current
# Debe ser: dev (para cuenta DEV), qa (para QA), main (para PROD)
```

### Error: "Access Denied" al eliminar rol
**Causa:** La protección anti-eliminación está funcionando (esto es correcto).

**Solución:** Si realmente necesitas eliminar el rol:
1. Desde la consola AWS (no desde GitHub Actions)
2. Primero eliminar la inline policy `github-deployment-protection`
3. Luego eliminar el rol

### Error: "Role already exists"
**Causa:** El rol ya existe en la cuenta.

**Solución:** 
```bash
# Opción 1: Actualizar el rol existente (recomendado)
terraform apply

# Opción 2: Eliminar y recrear (solo si es necesario)
aws iam delete-role --role-name github-actions-iam-deployment-role
```

---

## 📚 Referencias

- [GitHub OIDC Documentation](https://docs.github.com/en/actions/deployment/security-hardening-your-deployments/about-security-hardening-with-openid-connect)
- [AWS IAM Trust Policies](https://docs.aws.amazon.com/IAM/latest/UserGuide/id_roles_create_for-idp_oidc.html)
- [Terraform AWS Provider - IAM Role](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role)

---

**Versión:** 2.1.0  
**Fecha:** 2025-10-09  
**Autor:** DevOps Team  
**Revisado por:** Security Team
