# 🧪 CONFIGURACIÓN BRANCH PROTECTION - RAMA QA

## Ve a: GitHub.com → Settings → Branches → Add protection rule

### Branch name pattern: qa

### ✅ CONFIGURACIÓN PARA QA (Testing - Intermedia):

#### 1. Require a pull request before merging
   ✅ Require approvals: 1
   ✅ Dismiss stale reviews when new commits are pushed
   ✅ Require review from code owners

#### 2. Require status checks to pass before merging
   ✅ Require branches to be up to date before merging
   ✅ Status checks a seleccionar:
      - validate (del GitHub Actions)

#### 3. Require conversation resolution before merging
   ✅ Activar

#### 4. Restrict pushes that create files larger than 100MB
   ✅ Activar

#### 5. Do not allow force pushes
   ✅ Activar (más control en QA)

#### 6. Allow deletions  
   ❌ Desactivar (proteger QA)

---

## ¿Cómo funciona QA?

### Flujo típico hacia QA:
```bash
# 1. Desde DEV crear PR hacia QA
git checkout qa
git pull origin qa
git checkout -b release/v1.2.0

# 2. Mergear cambios desde dev
git merge dev

# 3. Hacer ajustes específicos para QA si necesario
git add .
git commit -m "chore: Prepare release v1.2.0 for QA"

# 4. Push y crear PR
git push origin release/v1.2.0

# 5. PR: release/v1.2.0 → qa
# 6. Review y aprobación
# 7. Merge a QA
```

### Validaciones en QA:
- ✅ Pull Request obligatorio
- ✅ Al menos 1 aprobación del equipo
- ✅ GitHub Actions (validate + posibles tests adicionales)
- ✅ No force pushes (estabilidad)
- ✅ No deletions accidentales

### Características de QA:
- 🧪 Ambiente de testing
- 📋 Validación antes de producción  
- 🔒 Más restrictivo que DEV
- ⚡ Menos restrictivo que PROD
