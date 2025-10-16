# Script para agregar tag "Proposito: DataLake" a los buckets DataLake en DEV
# Ejecutar con: .\scripts\add-proposito-tag-datalake.ps1

param(
    [Parameter(Mandatory=$false)]
    [string]$Profile = "darkh",
    
    [Parameter(Mandatory=$false)]
    [string]$Region = "us-east-1"
)

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "AGREGAR TAG 'Proposito' A BUCKETS DATALAKE" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# Buckets DataLake en DEV
$buckets = @(
    "s3-data-analytics-raw-dev-datalake",
    "s3-data-analytics-standard-dev-datalake",
    "s3-data-analytics-analytics-dev-datalake"
)

function Add-PropositoTag {
    param(
        [string]$BucketName
    )
    
    Write-Host "📦 Procesando: $BucketName" -ForegroundColor Yellow
    
    try {
        # Obtener tags actuales
        Write-Host "   → Obteniendo tags actuales..." -ForegroundColor Gray
        $currentTagsJson = aws s3api get-bucket-tagging `
            --bucket $BucketName `
            --profile $Profile `
            --region $Region 2>&1
        
        if ($LASTEXITCODE -ne 0) {
            Write-Host "   ⚠️  No tiene tags actuales o error: $currentTagsJson" -ForegroundColor Yellow
            $tagSet = @()
        } else {
            $currentTags = $currentTagsJson | ConvertFrom-Json
            $tagSet = $currentTags.TagSet
        }
        
        # Verificar si ya tiene el tag Proposito
        $hasProposito = $tagSet | Where-Object { $_.Key -eq "Proposito" }
        
        if ($hasProposito) {
            Write-Host "   ℹ️  Ya tiene tag 'Proposito' con valor: $($hasProposito.Value)" -ForegroundColor Cyan
            Write-Host "   → Actualizando a 'DataLake'..." -ForegroundColor Gray
            # Remover el tag viejo
            $tagSet = $tagSet | Where-Object { $_.Key -ne "Proposito" }
        }
        
        # Agregar nuevo tag Proposito
        $tagSet += @{
            Key = "Proposito"
            Value = "DataLake"
        }
        
        # Crear objeto de tags
        $newTags = @{
            TagSet = $tagSet
        } | ConvertTo-Json -Depth 10 -Compress
        
        # Aplicar tags
        Write-Host "   → Aplicando tag 'Proposito: DataLake'..." -ForegroundColor Gray
        aws s3api put-bucket-tagging `
            --bucket $BucketName `
            --tagging $newTags `
            --profile $Profile `
            --region $Region
        
        if ($LASTEXITCODE -eq 0) {
            Write-Host "   ✅ Tag agregado correctamente" -ForegroundColor Green
        } else {
            Write-Host "   ❌ Error al aplicar tags" -ForegroundColor Red
        }
        
    } catch {
        Write-Host "   ❌ Error: $_" -ForegroundColor Red
    }
    
    Write-Host ""
}

# Procesar cada bucket
foreach ($bucket in $buckets) {
    Add-PropositoTag -BucketName $bucket
}

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "✅ PROCESO COMPLETADO" -ForegroundColor Green
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "Verificar tags con:" -ForegroundColor Yellow
Write-Host "  aws s3api get-bucket-tagging --bucket s3-data-analytics-raw-dev-datalake --profile darkh | ConvertFrom-Json | Select-Object -ExpandProperty TagSet | Where-Object {`$_.Key -eq 'Proposito'}" -ForegroundColor White
