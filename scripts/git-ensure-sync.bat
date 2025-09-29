@echo off
setlocal ENABLEDELAYEDEXPANSION

set BRANCH=%1
if "%BRANCH%"=="" for /f "delims=" %%b in ('git rev-parse --abbrev-ref HEAD') do set BRANCH=%%b
set REMOTE=%2
if "%REMOTE%"=="" set REMOTE=origin

echo 🔍 Verificando sincronizacion con %REMOTE%/%BRANCH% ...

REM Obtener refs
git fetch --quiet %REMOTE% %BRANCH%
for /f "delims=" %%h in ('git rev-parse %BRANCH%') do set LOCAL=%%h
for /f "delims=" %%h in ('git rev-parse %REMOTE%/%BRANCH%') do set REMOTE_HASH=%%h
for /f "delims=" %%h in ('git merge-base %BRANCH% %REMOTE%/%BRANCH%') do set BASE=%%h

if "%LOCAL%"=="%REMOTE_HASH%" (
  echo ✅ La rama local esta sincronizada con %REMOTE%/%BRANCH%
  exit /b 0
) else if "%LOCAL%"=="%BASE%" (
  echo ⬇️ Falta hacer pull (la rama remota tiene commits nuevos)
  echo     Ejecuta: git pull --ff-only %REMOTE% %BRANCH%
  exit /b 2
) else if "%REMOTE_HASH%"=="%BASE%" (
  echo ⬆️ La rama local tiene commits que no estan en remoto (push pendiente)
  echo     Ejecuta: git push %REMOTE% %BRANCH%
  exit /b 3
) else (
  echo ⚠️ Historial divergente: se requiere reconciliar (rebase recomendado)
  echo     Sugerido: git fetch %REMOTE% ^&^& git rebase %REMOTE%/%BRANCH%
  exit /b 4
)
