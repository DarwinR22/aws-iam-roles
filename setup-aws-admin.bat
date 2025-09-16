@echo off
REM =============================================================================
REM Setup Inicial AWS - Solo para Administradores (Windows)
REM =============================================================================
REM Este script configura los recursos AWS necesarios para que el repositorio
REM funcione completamente via GitHub Actions. Los desarrolladores NO necesitan
REM herramientas locales instaladas.
REM
REM SOLO EJECUTAR UNA VEZ por cuenta AWS

echo 🚀 Configurando recursos AWS para repositorio IAM...
echo ==================================================

REM =============================================================================
REM Variables de configuración
REM =============================================================================
set AWS_PROFILE=default
set AWS_REGION=us-east-1
set ENVIRONMENT=dev

REM Obtener información de la cuenta
for /f "tokens=*" %%i in ('aws sts get-caller-identity --profile %AWS_PROFILE% --query Account --output text 2^>nul') do set ACCOUNT_ID=%%i
if "%ACCOUNT_ID%"=="" (
    echo ❌ Error: No se pudo obtener información de la cuenta AWS
    echo Verifica tus credenciales AWS
    pause
    exit /b 1
)

echo ✅ Conectado a cuenta AWS: %ACCOUNT_ID%
echo 📍 Región: %AWS_REGION%
echo 🏷️  Ambiente: %ENVIRONMENT%

REM =============================================================================
REM 1. Crear bucket S3 para Terraform state
REM =============================================================================
echo.
echo 1️⃣  Configurando bucket S3 para estado de Terraform...

set BUCKET_NAME=mci-terraform-state-%ENVIRONMENT%-%ACCOUNT_ID%

REM Verificar si el bucket existe
aws s3 ls s3://%BUCKET_NAME% --profile %AWS_PROFILE% >nul 2>&1
if %errorlevel% equ 0 (
    echo ✅ Bucket S3 ya existe: %BUCKET_NAME%
) else (
    echo ⚠️  Creando bucket S3: %BUCKET_NAME%
    
    REM Crear bucket
    if "%AWS_REGION%"=="us-east-1" (
        aws s3 mb s3://%BUCKET_NAME% --profile %AWS_PROFILE%
    ) else (
        aws s3 mb s3://%BUCKET_NAME% --region %AWS_REGION% --profile %AWS_PROFILE%
    )
    
    REM Habilitar versionado
    aws s3api put-bucket-versioning --bucket %BUCKET_NAME% --versioning-configuration Status=Enabled --profile %AWS_PROFILE%
    
    REM Habilitar encriptación
    aws s3api put-bucket-encryption --bucket %BUCKET_NAME% --server-side-encryption-configuration "{\"Rules\":[{\"ApplyServerSideEncryptionByDefault\":{\"SSEAlgorithm\":\"AES256\"}}]}" --profile %AWS_PROFILE%
    
    REM Bloquear acceso público
    aws s3api put-public-access-block --bucket %BUCKET_NAME% --public-access-block-configuration BlockPublicAcls=true,IgnorePublicAcls=true,BlockPublicPolicy=true,RestrictPublicBuckets=true --profile %AWS_PROFILE%
    
    echo ✅ Bucket S3 creado y configurado: %BUCKET_NAME%
)

REM =============================================================================
REM 2. Crear tabla DynamoDB para locks
REM =============================================================================
echo.
echo 2️⃣  Configurando tabla DynamoDB para locks...

set TABLE_NAME=terraform-locks-%ENVIRONMENT%

REM Verificar si la tabla existe
aws dynamodb describe-table --table-name %TABLE_NAME% --profile %AWS_PROFILE% >nul 2>&1
if %errorlevel% equ 0 (
    echo ✅ Tabla DynamoDB ya existe: %TABLE_NAME%
) else (
    echo ⚠️  Creando tabla DynamoDB: %TABLE_NAME%
    
    aws dynamodb create-table --table-name %TABLE_NAME% --attribute-definitions AttributeName=LockID,AttributeType=S --key-schema AttributeName=LockID,KeyType=HASH --billing-mode PAY_PER_REQUEST --region %AWS_REGION% --profile %AWS_PROFILE%
    
    echo ✅ Tabla DynamoDB creada: %TABLE_NAME%
)

REM =============================================================================
REM 3. Crear usuario IAM para GitHub Actions
REM =============================================================================
echo.
echo 3️⃣  Configurando usuario IAM para GitHub Actions...

set IAM_USER=github-actions-iam-%ENVIRONMENT%

REM Verificar si el usuario existe
aws iam get-user --user-name %IAM_USER% --profile %AWS_PROFILE% >nul 2>&1
if %errorlevel% equ 0 (
    echo ✅ Usuario IAM ya existe: %IAM_USER%
) else (
    echo ⚠️  Creando usuario IAM: %IAM_USER%
    
    REM Crear usuario
    aws iam create-user --user-name %IAM_USER% --profile %AWS_PROFILE%
    
    REM Crear política personalizada
    set POLICY_NAME=GitHubActionsIAMPolicy-%ENVIRONMENT%
    
    REM Crear archivo de política temporal
    (
    echo {
    echo     "Version": "2012-10-17",
    echo     "Statement": [
    echo         {
    echo             "Effect": "Allow",
    echo             "Action": [
    echo                 "iam:*"
    echo             ],
    echo             "Resource": "*"
    echo         },
    echo         {
    echo             "Effect": "Allow",
    echo             "Action": [
    echo                 "s3:GetObject",
    echo                 "s3:PutObject",
    echo                 "s3:DeleteObject",
    echo                 "s3:ListBucket"
    echo             ],
    echo             "Resource": [
    echo                 "arn:aws:s3:::%BUCKET_NAME%",
    echo                 "arn:aws:s3:::%BUCKET_NAME%/*"
    echo             ]
    echo         },
    echo         {
    echo             "Effect": "Allow",
    echo             "Action": [
    echo                 "dynamodb:GetItem",
    echo                 "dynamodb:PutItem",
    echo                 "dynamodb:DeleteItem"
    echo             ],
    echo             "Resource": "arn:aws:dynamodb:%AWS_REGION%:%ACCOUNT_ID%:table/%TABLE_NAME%"
    echo         },
    echo         {
    echo             "Effect": "Allow",
    echo             "Action": [
    echo                 "sts:GetCallerIdentity"
    echo             ],
    echo             "Resource": "*"
    echo         }
    echo     ]
    echo }
    ) > github-actions-policy.json
    
    REM Crear la política
    aws iam create-policy --policy-name %POLICY_NAME% --policy-document file://github-actions-policy.json --profile %AWS_PROFILE%
    
    REM Adjuntar política al usuario
    aws iam attach-user-policy --user-name %IAM_USER% --policy-arn arn:aws:iam::%ACCOUNT_ID%:policy/%POLICY_NAME% --profile %AWS_PROFILE%
    
    REM Crear access keys
    echo ⚠️  Creando Access Keys para GitHub Actions...
    aws iam create-access-key --user-name %IAM_USER% --profile %AWS_PROFILE% > credentials.json
    
    REM Extraer credenciales (requiere PowerShell para JSON parsing)
    echo.
    echo 🔑 CREDENCIALES PARA GITHUB ACTIONS:
    echo ======================================
    echo.
    echo ⚠️  IMPORTANTE: Configura estos valores en GitHub Settings ^> Secrets and variables ^> Actions
    echo.
    echo Secrets:
    powershell -Command "$json = Get-Content credentials.json | ConvertFrom-Json; Write-Host 'AWS_ACCESS_KEY_ID_%ENVIRONMENT%=' $json.AccessKey.AccessKeyId -NoNewline"
    echo.
    powershell -Command "$json = Get-Content credentials.json | ConvertFrom-Json; Write-Host 'AWS_SECRET_ACCESS_KEY_%ENVIRONMENT%=' $json.AccessKey.SecretAccessKey -NoNewline"
    echo.
    echo.
    
    REM Limpiar archivos temporales
    del github-actions-policy.json
    del credentials.json
    
    echo ✅ Usuario IAM creado: %IAM_USER%
)

REM =============================================================================
REM 4. Generar información para GitHub Variables
REM =============================================================================
echo.
echo 4️⃣  Información para GitHub Repository Variables...
echo.
echo 📋 VARIABLES PARA GITHUB ACTIONS:
echo ==================================
echo TERRAFORM_STATE_BUCKET_%ENVIRONMENT%=%BUCKET_NAME%
echo TERRAFORM_LOCK_TABLE_%ENVIRONMENT%=%TABLE_NAME%
echo AWS_REGION=%AWS_REGION%
echo.

REM =============================================================================
REM 5. Crear archivo de configuración de referencia
REM =============================================================================
echo.
echo 5️⃣  Creando archivo de configuración de referencia...

(
echo # =============================================================================
echo # Configuración AWS para ambiente: %ENVIRONMENT%
echo # =============================================================================
echo # Generado: %date% %time%
echo # Cuenta AWS: %ACCOUNT_ID%
echo # Región: %AWS_REGION%
echo.
echo # Recursos creados:
echo S3_BUCKET=%BUCKET_NAME%
echo DYNAMODB_TABLE=%TABLE_NAME%
echo IAM_USER=%IAM_USER%
echo.
echo # Para configurar en GitHub Actions:
echo # 1. Repository Settings ^> Secrets and variables ^> Actions
echo # 2. Agregar estos Secrets:
echo #    AWS_ACCESS_KEY_ID_%ENVIRONMENT%=^<access_key_mostrado_arriba^>
echo #    AWS_SECRET_ACCESS_KEY_%ENVIRONMENT%=^<secret_key_mostrado_arriba^>
echo # 
echo # 3. Agregar estas Variables:
echo #    TERRAFORM_STATE_BUCKET_%ENVIRONMENT%=%BUCKET_NAME%
echo #    TERRAFORM_LOCK_TABLE_%ENVIRONMENT%=%TABLE_NAME%
echo #    AWS_REGION=%AWS_REGION%
echo.
echo # Para verificar la configuración:
echo # aws s3 ls s3://%BUCKET_NAME% --profile %AWS_PROFILE%
echo # aws dynamodb describe-table --table-name %TABLE_NAME% --profile %AWS_PROFILE%
echo # aws iam get-user --user-name %IAM_USER% --profile %AWS_PROFILE%
) > aws-config-%ENVIRONMENT%.txt

echo ✅ Configuración guardada en: aws-config-%ENVIRONMENT%.txt

REM =============================================================================
REM RESUMEN FINAL
REM =============================================================================
echo.
echo ==================================================
echo 🎉 ¡CONFIGURACIÓN AWS COMPLETADA!
echo ==================================================
echo.
echo 📋 Recursos creados en cuenta %ACCOUNT_ID%:
echo    ✅ S3 Bucket: %BUCKET_NAME%
echo    ✅ DynamoDB Table: %TABLE_NAME%
echo    ✅ IAM User: %IAM_USER%
echo.
echo 🔧 Próximos pasos:
echo    1. Configurar credenciales en GitHub Actions (mostradas arriba)
echo    2. Configurar variables en GitHub Repository
echo    3. Los desarrolladores ya pueden usar el repositorio sin instalar nada
echo.
echo 📁 Archivos generados:
echo    - aws-config-%ENVIRONMENT%.txt (configuración de referencia)
echo.
echo ✅ ¡Los desarrolladores ahora pueden hacer git clone y usar el repositorio!
echo ✅ Todo se ejecutará automáticamente vía GitHub Actions
echo.
pause
