@echo off
REM =============================================================================
REM Script para actualizar permisos del rol GitHub Actions
REM =============================================================================

setlocal enabledelayedexpansion

REM Configuración
set ROLE_NAME=github-actions-iam-deployment-role
set POLICY_NAME=GitHubActionsIAMDeploymentPolicy
set AWS_ACCOUNT=393209814297
set AWS_REGION=us-east-1

echo 🔐 Actualizando permisos del rol GitHub Actions...
echo 📋 Rol: %ROLE_NAME%
echo 📋 Política: %POLICY_NAME%
echo.

REM Verificar si el rol existe
echo 1️⃣  Verificando rol existente...
aws iam get-role --role-name %ROLE_NAME% >nul 2>&1
if !errorlevel! == 0 (
    echo ✅ Rol encontrado: %ROLE_NAME%
) else (
    echo ❌ Error: Rol no encontrado: %ROLE_NAME%
    echo 💡 Por favor, asegúrate de que el rol existe en la cuenta AWS %AWS_ACCOUNT%
    exit /b 1
)

REM Crear/actualizar la política en línea
echo.
echo 2️⃣  Actualizando política en línea del rol...

aws iam put-role-policy ^
    --role-name %ROLE_NAME% ^
    --policy-name %POLICY_NAME% ^
    --policy-document file://github-actions-role-policy.json

if !errorlevel! == 0 (
    echo ✅ Política actualizada exitosamente
) else (
    echo ❌ Error actualizando la política
    exit /b 1
)

REM Verificar los permisos actualizados
echo.
echo 3️⃣  Verificando política aplicada...
aws iam get-role-policy ^
    --role-name %ROLE_NAME% ^
    --policy-name %POLICY_NAME% ^
    --output table ^
    --query "PolicyDocument.Statement[*].[Effect,Action[0],Resource]"

echo.
echo 🎉 ¡Actualización completada!
echo.
echo 📋 Permisos agregados:
echo    ✅ IAM: CreateRole, DeleteRole, GetRole, etc.
echo    ✅ S3: Acceso completo al bucket s3-data-analytics-raw-dev-tfstate
echo    ✅ DynamoDB: Acceso a tabla dynamodb-db-dev-terraform-lock
echo    ✅ STS: GetCallerIdentity
echo.
echo 🚀 El workflow de GitHub Actions ahora debería funcionar correctamente.
