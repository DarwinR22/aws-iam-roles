# Script para limpiar políticas IAM con nomenclatura anterior
# Ejecutar SOLO después de verificar que las nuevas políticas MCI funcionan correctamente

param(
    [switch]$DryRun = $false,  # Por defecto solo muestra, no elimina
    [switch]$Force = $false    # Requerido para eliminar realmente
)

Write-Host "🧹 Script de Limpieza de Políticas IAM Antiguas" -ForegroundColor Cyan
Write-Host "=============================================" -ForegroundColor Cyan

if ($DryRun -or -not $Force) {
    Write-Host "⚠️  MODO DRY-RUN: Solo mostrando políticas a eliminar" -ForegroundColor Yellow
    Write-Host "   Use -Force para eliminar realmente" -ForegroundColor Yellow
    Write-Host ""
}

# Patrones de políticas a eliminar (sin prefijo MCI y con sufijos aleatorios)
$policyPatterns = @(
    "githubactions-basepermissions-*",
    "githubactions-iammanagement-*", 
    "githubactions-terraformbackend-*"
)

# Políticas nuevas que deben mantenerse (ahora usando AWS managed policies)
$keepPolicies = @(
    "custom-app-permissions",
    "custom-deployment-permissions",
    "custom-backend-permissions"
)

Write-Host "🔍 Buscando políticas con nomenclatura anterior..." -ForegroundColor Blue

foreach ($pattern in $policyPatterns) {
    Write-Host "   Buscando: $pattern" -ForegroundColor Gray
    
    # Buscar políticas que coincidan con el patrón
    $policies = aws iam list-policies --query "Policies[?starts_with(PolicyName, '$($pattern.Replace('*', ''))')].{Name:PolicyName,Arn:Arn}" --output json | ConvertFrom-Json
    
    if ($policies) {
        foreach ($policy in $policies) {
            # Verificar que no sea una política que debemos mantener
            if ($policy.Name -notin $keepPolicies) {
                Write-Host "📋 Encontrada: $($policy.Name)" -ForegroundColor Red
                
                if ($Force -and -not $DryRun) {
                    try {
                        Write-Host "   🗑️  Eliminando..." -ForegroundColor Red
                        aws iam delete-policy --policy-arn $policy.Arn
                        Write-Host "   ✅ Eliminada exitosamente" -ForegroundColor Green
                    }
                    catch {
                        Write-Host "   ❌ Error al eliminar: $_" -ForegroundColor Red
                    }
                } else {
                    Write-Host "   ⏭️  Se eliminaría con -Force" -ForegroundColor Yellow
                }
            }
        }
    }
}

Write-Host ""
Write-Host "🔍 Verificando políticas MCI actuales..." -ForegroundColor Blue
foreach ($keep in $keepPolicies) {
    $exists = aws iam get-policy --policy-arn "arn:aws:iam::393209814297:policy/$keep" --output json 2>$null
    if ($exists) {
        Write-Host "✅ $keep - EXISTE" -ForegroundColor Green
    } else {
        Write-Host "❌ $keep - NO ENCONTRADA" -ForegroundColor Red
    }
}

Write-Host ""
if ($DryRun -or -not $Force) {
    Write-Host "💡 Para ejecutar la limpieza real:" -ForegroundColor Cyan
    Write-Host "   .\cleanup-old-policies.ps1 -Force" -ForegroundColor White
} else {
    Write-Host "🎉 Limpieza completada!" -ForegroundColor Green
}