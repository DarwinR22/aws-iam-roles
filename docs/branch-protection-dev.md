# 🌿 CONFIGURACIÓN BRANCH PROTECTION - RAMA DEV

## Ve a: GitHub.com → Settings → Branches → Add protection rule

### Branch name pattern: dev

### ✅ CONFIGURACIÓN PARA DEV (Desarrollo con PR obligatorio):

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

#### 5. Allow force pushes
   ✅ Activar (útil para desarrollo)

#### 6. Allow deletions  
   ✅ Activar (para cleanup de development)

---

## ¿Cómo funciona DEV con PR?

### Flujo de trabajo en DEV:
```bash
# 1. Crear rama feature desde dev
git checkout dev
git pull origin dev
git checkout -b feature/nueva-politica-s3

# 2. Hacer cambios
# Editar archivos...
git add .
git commit -m "feat: Add new S3 policy for development"

# 3. Push de la rama feature
git push origin feature/nueva-politica-s3

# 4. Crear PR en GitHub:
#    - De: feature/nueva-politica-s3 
#    - A: dev
#    - Asignar reviewer del equipo

# 5. Esperar aprobación de:
#    - César, Darwin, Jorge o Osmar
#    - GitHub Actions (validate)

# 6. Hacer merge una vez aprobado
```

### Validaciones que aplican en DEV:
- ✅ Pull Request obligatorio
- ✅ Al menos 1 aprobación del equipo (CODEOWNERS)
- ✅ GitHub Actions debe pasar (validate job)
- ✅ Conversaciones resueltas
- ✅ Rama actualizada antes de merge

### Ventajas para DEV:
- 🔍 Revisión de código entre el equipo
- 📚 Aprendizaje mutuo
- 🐛 Detección temprana de errores
- 📋 Historial claro de cambios
