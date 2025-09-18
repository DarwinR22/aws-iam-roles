# 🔒 CONFIGURACIÓN BRANCH PROTECTION PARA MAIN (PRODUCCIÓN)

## Ve a: GitHub.com → Settings → Branches → Add protection rule

### Branch name pattern: main

### ✅ CONFIGURACIÓN PARA MAIN (Producción - Máxima Seguridad):

#### 1. Require a pull request before merging
   ✅ Require approvals: 2 (mínimo 2 aprobaciones)
   ✅ Dismiss stale reviews when new commits are pushed
   ✅ Require review from code owners (CRÍTICO)

#### 2. Require status checks to pass before merging
   ✅ Require branches to be up to date before merging
   ✅ Status checks (seleccionar cuando aparezcan):
      - validate (del GitHub Actions)
      - security-scan (si lo tienes)

#### 3. Require conversation resolution before merging
   ✅ Activar

#### 4. Restrictions
   ✅ Restrict pushes that create files larger than 100MB
   ✅ Do not allow bypassing the above settings

#### 5. Do not allow force pushes
   ✅ Activar (CRÍTICO para producción)

#### 6. Do not allow deletions
   ✅ Activar (CRÍTICO para producción)

---

## ¿Qué significa esto para MAIN?

### Para hacer cambios en main AHORA necesitas:
1. Crear PR desde QA hacia main
2. Esperar aprobación de AL MENOS 2 personas del equipo
3. Todos los status checks deben pasar
4. Todas las conversaciones resueltas
5. Solo entonces se puede hacer merge

### Flujo típico hacia PRODUCCIÓN:
```bash
# 1. Crear PR desde QA
git checkout main
git pull origin main
git checkout -b release/prod-v1.2.0

# 2. Mergear desde QA (ya testeado)
git merge qa

# 3. Ajustes finales para PROD si necesario
git add .
git commit -m "chore: Release v1.2.0 to production"

# 4. Push y crear PR crítico
git push origin release/prod-v1.2.0

# 5. PR: release/prod-v1.2.0 → main
# 6. REQUIERE 2 APROBACIONES del equipo
# 7. GitHub Actions debe pasar
# 8. Solo entonces merge a PRODUCCIÓN
```

### Validaciones MÁXIMAS en MAIN:
- ✅ Pull Request obligatorio
- ✅ Mínimo 2 aprobaciones del equipo (CODEOWNERS)
- ✅ GitHub Actions debe pasar
- ✅ Conversaciones resueltas
- ✅ Rama actualizada
- ❌ NO force pushes (protección total)
- ❌ NO deletions (protección total)
