@echo off
REM Script simplificado para inicialización de Terraform (Windows)
REM Uso: scripts\init.bat [environment]
REM Ejemplo: scripts\init.bat dev

setlocal enabledelayedexpansion

set ENVIRONMENT=%1
if "%ENVIRONMENT%"=="" set ENVIRONMENT=dev

echo 🚀 Inicializando Terraform para ambiente: %ENVIRONMENT%

cd /d "%~dp0..\generated"

REM Verificar que existe la configuración de backend
if not exist "..\config\backend.hcl" (
    echo ❌ Error: No se encontró config\backend.hcl
    exit /b 1
)

REM Inicializar Terraform con backend dinámico
echo 📦 Ejecutando terraform init...
terraform init -backend-config="..\config\backend.hcl" -var="environment=%ENVIRONMENT%"

if %ERRORLEVEL% NEQ 0 (
    echo ❌ Error en terraform init
    exit /b 1
)

echo ✅ Terraform inicializado correctamente para %ENVIRONMENT%
echo 💡 Próximos pasos:
echo    - terraform plan -var="environment=%ENVIRONMENT%"
echo    - terraform apply -var="environment=%ENVIRONMENT%"