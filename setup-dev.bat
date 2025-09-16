@echo off
REM =============================================================================
REM Guía para Desarrolladores - Repositorio IAM AWS
REM =============================================================================
REM Los desarrolladores NO necesitan AWS CLI, Terraform o Python instalados
REM Todo funciona automáticamente vía GitHub Actions

echo � ¡Bienvenido al Repositorio IAM AWS!
echo =====================================
echo.
echo 🎯 Este repositorio está configurado para funcionar 100%% automático
echo    Los desarrolladores solo necesitan Git - nada más!
echo.

REM =============================================================================
REM Verificar Git
REM =============================================================================
echo 📋 Verificando prerequisitos mínimos...

git --version >nul 2>&1
if %errorlevel% neq 0 (
    echo ❌ Git no está instalado
    echo Instalar desde: https://git-scm.com/downloads
    pause
    exit /b 1
)
echo ✅ Git encontrado

REM =============================================================================
REM Instrucciones para desarrolladores
REM =============================================================================
echo.
echo 🚀 FLUJO DE TRABAJO PARA DESARROLLADORES:
echo =========================================
echo.
echo 1️⃣  Crear archivo de configuración JSON para tu rol:
echo.
echo     Ejemplo: mi-rol-lambda.json
echo     {
echo       "servicio": "lambda",
echo       "layer": "api", 
echo       "ambiente": "dev",
echo       "nombre": "procesadorPagos",
echo       "description": "Rol para Lambda que procesa pagos",
echo       "policies": {
echo         "aws_managed": [
echo           "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
echo         ]
echo       },
echo       "tags": {
echo         "pais": "GT",
echo         "direccion": "Gerencia de Tecnología",
echo         "gerencia": "Desarrollo de Aplicaciones",
echo         "modulo": "Aplicación",
echo         "alcance_sox": "Sí",
echo         "propietario": "Tu Nombre",
echo         "proveedor": "Inhouse",
echo         "dominio": "FinTech",
echo         "subdominio": "Pagos",
echo         "aplicacion": "MI-APP",
echo         "soporte": "Tu Equipo",
echo         "contacto": "tu-email@empresa.com",
echo         "proyecto": "PROJ-2024-XXX",
echo         "creado_por": "tu-email@empresa.com",
echo         "ciclo_vida": "Implementación",
echo         "version": "1.0.0"
echo       }
echo     }
echo.
echo 2️⃣  Hacer commit y push:
echo.
echo     git add mi-rol-lambda.json
echo     git commit -m "feat: agregar rol Lambda para procesador de pagos"
echo     git push origin develop
echo.
echo 3️⃣  Crear Pull Request a develop
echo     → GitHub Actions desplegará automáticamente a DEV
echo.
echo 4️⃣  Para promover a QA: merge develop → qa
echo     Para promover a PROD: merge qa → main (requiere aprobación)
echo.

REM =============================================================================
REM Recursos disponibles
REM =============================================================================
echo 📚 RECURSOS DISPONIBLES:
echo ========================
echo.
echo 📖 docs/USAGE.md      - Ejemplos detallados
echo 🔧 docs/CONVENTIONS.md - Reglas y estándares  
echo 🚀 docs/DEPLOYMENT.md  - Flujo de despliegue
echo 📋 templates/examples/ - Templates de ejemplo
echo.

REM =============================================================================
REM Verificar configuración del repositorio
REM =============================================================================
echo 🔍 VERIFICANDO CONFIGURACIÓN DEL REPOSITORIO:
echo =============================================

REM Verificar workflows de GitHub Actions
if exist .github\workflows\validate.yml (
    echo ✅ Workflow de validación configurado
) else (
    echo ❌ Workflow de validación faltante
)

if exist .github\workflows\deploy.yml (
    echo ✅ Workflow de despliegue configurado  
) else (
    echo ❌ Workflow de despliegue faltante
)

REM Verificar módulos
if exist modules\iam-role\main.tf (
    echo ✅ Módulo IAM configurado
) else (
    echo ❌ Módulo IAM faltante
)

REM Verificar documentación
if exist docs\USAGE.md (
    echo ✅ Documentación disponible
) else (
    echo ❌ Documentación faltante
)

echo.
echo 🎉 ¡REPOSITORIO LISTO PARA USAR!
echo ================================
echo.
echo ✅ Los desarrolladores solo necesitan:
echo    1. Git (ya verificado)
echo    2. Conocimiento básico de JSON
echo    3. Seguir las convenciones de tags
echo.
echo ✅ TODO se ejecuta automáticamente vía GitHub Actions
echo ✅ NO necesitas instalar AWS CLI, Terraform o Python
echo.
echo 📞 Soporte:
echo    - Documentación: docs/
echo    - GitHub Issues: Para reportar problemas
echo    - Equipo DevOps: devops@empresa.com
echo.
echo 🚀 ¡Comienza creando tu primer rol con el ejemplo JSON de arriba!
echo.
pause

REM =============================================================================
REM 2. CONFIGURAR PERFIL AWS DEV
REM =============================================================================
echo.
echo 2️⃣  Configurando perfil AWS DEV...

REM Verificar si existe perfil dev
aws configure list-profiles | findstr "^dev$" >nul 2>&1
if %errorlevel% neq 0 (
    echo ⚠️  Configurando perfil AWS 'dev'...
    echo.
    echo Necesitas las credenciales de la cuenta DEV:
    echo - AWS Access Key ID
    echo - AWS Secret Access Key
    echo - Región (recomendado: us-east-1^)
    echo.
    
    aws configure --profile dev
    echo ✅ Perfil AWS 'dev' configurado
) else (
    echo ✅ Perfil AWS 'dev' ya existe
)

REM Verificar conexión
echo.
echo Verificando conexión a AWS...
aws sts get-caller-identity --profile dev >nul 2>&1
if %errorlevel% neq 0 (
    echo ❌ No se pudo conectar a AWS con perfil 'dev'
    echo Verifica las credenciales y vuelve a ejecutar el script
    pause
    exit /b 1
)

for /f "tokens=*" %%i in ('aws sts get-caller-identity --profile dev --query Account --output text') do set ACCOUNT_ID=%%i
echo ✅ Conexión exitosa a cuenta AWS: %ACCOUNT_ID%

REM =============================================================================
REM 3. CONFIGURAR REGIÓN
REM =============================================================================
for /f "tokens=*" %%i in ('aws configure get region --profile dev') do set AWS_REGION=%%i
if "%AWS_REGION%"=="" (
    set AWS_REGION=us-east-1
    echo ⚠️  Región no configurada, usando: %AWS_REGION%
)

REM =============================================================================
REM 4. CREAR BUCKET S3 PARA TERRAFORM STATE
REM =============================================================================
echo.
echo 3️⃣  Configurando bucket S3 para Terraform state...

set BUCKET_NAME=mci-terraform-state-dev-%ACCOUNT_ID%

REM Verificar si el bucket existe
aws s3 ls s3://%BUCKET_NAME% --profile dev >nul 2>&1
if %errorlevel% neq 0 (
    echo ⚠️  Creando bucket S3: %BUCKET_NAME%
    
    REM Crear bucket
    if "%AWS_REGION%"=="us-east-1" (
        aws s3 mb s3://%BUCKET_NAME% --profile dev
    ) else (
        aws s3 mb s3://%BUCKET_NAME% --region %AWS_REGION% --profile dev
    )
    
    REM Habilitar versionado
    aws s3api put-bucket-versioning --bucket %BUCKET_NAME% --versioning-configuration Status=Enabled --profile dev
    
    REM Habilitar encriptación
    aws s3api put-bucket-encryption --bucket %BUCKET_NAME% --server-side-encryption-configuration "{\"Rules\":[{\"ApplyServerSideEncryptionByDefault\":{\"SSEAlgorithm\":\"AES256\"}}]}" --profile dev
    
    echo ✅ Bucket S3 creado y configurado: %BUCKET_NAME%
) else (
    echo ✅ Bucket S3 ya existe: %BUCKET_NAME%
)

REM =============================================================================
REM 5. CREAR TABLA DYNAMODB PARA LOCKS
REM =============================================================================
echo.
echo 4️⃣  Configurando tabla DynamoDB para locks de Terraform...

set TABLE_NAME=terraform-locks-dev

REM Verificar si la tabla existe
aws dynamodb describe-table --table-name %TABLE_NAME% --profile dev >nul 2>&1
if %errorlevel% neq 0 (
    echo ⚠️  Creando tabla DynamoDB: %TABLE_NAME%
    
    aws dynamodb create-table --table-name %TABLE_NAME% --attribute-definitions AttributeName=LockID,AttributeType=S --key-schema AttributeName=LockID,KeyType=HASH --billing-mode PAY_PER_REQUEST --region %AWS_REGION% --profile dev
    
    echo ✅ Tabla DynamoDB creada: %TABLE_NAME%
) else (
    echo ✅ Tabla DynamoDB ya existe: %TABLE_NAME%
)

REM =============================================================================
REM 6. CREAR ARCHIVO DE CONFIGURACIÓN LOCAL
REM =============================================================================
echo.
echo 5️⃣  Creando archivo de configuración local...

(
echo # Configuración para ambiente DEV
echo # ================================
echo # Este archivo es generado automáticamente por setup-dev.bat
echo # NO commitear este archivo en Git
echo.
echo # AWS Configuration
echo AWS_PROFILE=dev
echo AWS_REGION=%AWS_REGION%
echo AWS_ACCOUNT_ID=%ACCOUNT_ID%
echo.
echo # Terraform Backend
echo TERRAFORM_STATE_BUCKET=%BUCKET_NAME%
echo TERRAFORM_LOCK_TABLE=%TABLE_NAME%
echo.
echo # Project Settings
echo AMBIENTE=dev
echo PROJECT_NAME=mci-aws-iam
echo.
echo # Generated on: %date% %time%
) > .env.dev

echo ✅ Archivo .env.dev creado

REM Crear .gitignore si no existe
if not exist .gitignore (
    (
    echo # Terraform
    echo *.tfstate
    echo *.tfstate.*
    echo *.tfvars
    echo .terraform/
    echo .terraform.lock.hcl
    echo.
    echo # Environment files
    echo .env*
    echo !.env.example
    echo.
    echo # IDE
    echo .vscode/
    echo .idea/
    echo *.swp
    echo *.swo
    echo.
    echo # OS
    echo .DS_Store
    echo Thumbs.db
    echo.
    echo # Python
    echo __pycache__/
    echo *.pyc
    echo *.pyo
    echo *.pyd
    echo .Python
    echo build/
    echo develop-eggs/
    echo dist/
    echo downloads/
    echo eggs/
    echo .eggs/
    echo lib/
    echo lib64/
    echo parts/
    echo sdist/
    echo var/
    echo wheels/
    echo *.egg-info/
    echo .installed.cfg
    echo *.egg
    echo.
    echo # Logs
    echo *.log
    ) > .gitignore
    echo ✅ .gitignore creado
)

REM =============================================================================
REM 7. CREAR TEMPLATE DE VARIABLES
REM =============================================================================
echo.
echo 6️⃣  Creando template de variables...

(
echo # =============================================================================
echo # Variables de Configuración - Ambiente DEV
echo # =============================================================================
echo # Copiar este archivo a terraform.tfvars y completar los valores
echo.
echo # Configuración AWS
echo aws_region   = "%AWS_REGION%"
echo ambiente     = "dev"
echo account_name = "dev-account"
echo.
echo # Configuración del Backend de Terraform
echo terraform_state_bucket = "%BUCKET_NAME%"
echo terraform_lock_table   = "%TABLE_NAME%"
echo.
echo # Información de Responsables (COMPLETAR^)
echo pais             = "GT"  # GT, CR, SV, HN, NI, PA
echo propietario      = ""    # Nombre del responsable
echo soporte_email    = ""    # Email del equipo de soporte
echo proyecto_codigo  = ""    # Código del proyecto
echo creado_por      = ""     # Email de quien crea el recurso
echo.
echo # Información de Ciclo de Vida
echo ciclo_vida = "Implementación"  # Creación, Implementación, MonitoreoYMantenimiento, Desactivación
echo version    = "1.0.0"          # Versión semántica
echo.
echo # Tags adicionales (opcional^)
echo # custom_tags = {
echo #   "CostCenter" = "CC-12345"
echo #   "Environment" = "development"
echo # }
) > terraform.tfvars.example

echo ✅ Template de variables creado: terraform.tfvars.example

REM =============================================================================
REM 8. CREAR SCRIPT DE VALIDACIÓN PARA WINDOWS
REM =============================================================================
echo.
echo 7️⃣  Creando script de validación...

(
echo @echo off
echo echo 🔍 Validando configuración del repositorio...
echo.
echo REM Validar archivo de configuración
echo if not exist .env.dev (
echo     echo ❌ Archivo .env.dev no encontrado
echo     echo Ejecuta setup-dev.bat primero
echo     pause
echo     exit /b 1
echo ^)
echo.
echo REM Cargar variables
echo for /f "tokens=1,2 delims==" %%%%a in (.env.dev^) do (
echo     if "%%%%a"=="AWS_PROFILE" set AWS_PROFILE=%%%%b
echo     if "%%%%a"=="TERRAFORM_STATE_BUCKET" set TERRAFORM_STATE_BUCKET=%%%%b
echo     if "%%%%a"=="TERRAFORM_LOCK_TABLE" set TERRAFORM_LOCK_TABLE=%%%%b
echo ^)
echo.
echo echo 1. Validando conexión AWS...
echo aws sts get-caller-identity --profile %%AWS_PROFILE%% ^>nul 2^>^&1
echo if %%errorlevel%% neq 0 (
echo     echo ❌ Error de conexión AWS
echo     pause
echo     exit /b 1
echo ^)
echo echo ✅ Conexión AWS exitosa
echo.
echo echo 2. Validando bucket S3...
echo aws s3 ls s3://%%TERRAFORM_STATE_BUCKET%% --profile %%AWS_PROFILE%% ^>nul 2^>^&1
echo if %%errorlevel%% neq 0 (
echo     echo ❌ Bucket S3 no accesible
echo     pause
echo     exit /b 1
echo ^)
echo echo ✅ Bucket S3 accesible
echo.
echo echo 3. Validando tabla DynamoDB...
echo aws dynamodb describe-table --table-name %%TERRAFORM_LOCK_TABLE%% --profile %%AWS_PROFILE%% ^>nul 2^>^&1
echo if %%errorlevel%% neq 0 (
echo     echo ❌ Tabla DynamoDB no accesible
echo     pause
echo     exit /b 1
echo ^)
echo echo ✅ Tabla DynamoDB accesible
echo.
echo echo 4. Validando Python...
echo python -c "import json, re, pathlib" ^>nul 2^>^&1
echo if %%errorlevel%% neq 0 (
echo     echo ❌ Error con Python o librerías
echo     pause
echo     exit /b 1
echo ^)
echo echo ✅ Python y librerías necesarias disponibles
echo.
echo echo.
echo echo 🎉 ¡Configuración válida! El repositorio está listo para usar.
echo echo.
echo echo Para crear tu primer rol:
echo echo 1. python scripts/generate_role.py mi-config.json --gerencia tecnologia --area aplicaciones
echo echo 2. cd gerencias/tecnologia/aplicaciones
echo echo 3. copy terraform.tfvars.example terraform.tfvars
echo echo 4. REM Editar terraform.tfvars con tus valores
echo echo 5. terraform init
echo echo 6. terraform plan
echo pause
) > validate-setup.bat

echo ✅ Script de validación creado: validate-setup.bat

REM =============================================================================
REM FINALIZACIÓN
REM =============================================================================
echo.
echo ================================================
echo 🎉 ¡CONFIGURACIÓN COMPLETA!
echo ================================================
echo.
echo 📋 Resumen de lo configurado:
echo   ✅ Perfil AWS 'dev' configurado
echo   ✅ Bucket S3: %BUCKET_NAME%
echo   ✅ Tabla DynamoDB: %TABLE_NAME%
echo   ✅ Archivo .env.dev creado
echo   ✅ Templates de configuración listos
echo.
echo 🚀 Próximos pasos:
echo   1. Ejecutar: validate-setup.bat
echo   2. Crear tu primer rol con el generador
echo   3. Ver ejemplos en docs/USAGE.md
echo.
echo 📞 Soporte:
echo   - Documentación: docs/
echo   - Script de validación: validate-setup.bat
echo.
echo ✅ ¡El repositorio está listo para usar!
echo.
pause
