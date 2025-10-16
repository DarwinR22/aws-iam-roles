# Script para agregar tags ABAC a los buckets del DataLake en DEV
# Ejecutar con: .\scripts\tag-datalake-buckets-dev.ps1

# Variables
$PROFILE = "darkh"
$REGION = "us-east-1"

# Tags comunes para todos los buckets DataLake
$COMMON_TAGS = @"
{
  "TagSet": [
    {"Key": "Dominio", "Value": "DataAnalytics"},
    {"Key": "Subdominio", "Value": "DataLake"},
    {"Key": "Cuenta", "Value": "clarohn-data-analytics-dev"},
    {"Key": "Ambiente", "Value": "DEV"},
    {"Key": "Gerencia", "Value": "MejoraContinuaeInformacion"},
    {"Key": "Proposito", "Value": "DataLakeStorage"},
    {"Key": "TipoRecurso", "Value": "S3Bucket"},
    {"Key": "Proyecto", "Value": "DataLake"},
    {"Key": "Aplicacion", "Value": "Glue"},
    {"Key": "Modulo", "Value": "DataStorage"},
    {"Key": "Propietario", "Value": "JorgeMarioRubioVidal"},
    {"Key": "CreadoPor", "Value": "DarwinLopez"},
    {"Key": "Soporte", "Value": "DarwinLopez"},
    {"Key": "Contacto", "Value": "darwin.lopez@claro.com.gt"},
    {"Key": "Proveedor", "Value": "INHOUSE"},
    {"Key": "Pais", "Value": "GT"},
    {"Key": "Direccion", "Value": "TICENAM"},
    {"Key": "Criticidad", "Value": "Alta"},
    {"Key": "Area", "Value": "MCI"},
    {"Key": "ClasificacionDatos", "Value": "Interno"},
    {"Key": "AlcanceSOX", "Value": "No"},
    {"Key": "CicloDeVida", "Value": "Implementacion"},
    {"Key": "Version", "Value": "1.0"},
    {"Key": "FechaCreacion", "Value": "2025-10-16"},
    {"Key": "Gestionadorloor", "Value": "Terraform"},
    {"Key": "Equipo", "Value": "DevOps"},
    {"Key": "Servicio", "Value": "DataLake"},
    {"Key": "map_migrated", "Value": "migBTC1DHWF13"}
  ]
}
"@

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "TAGUEANDO BUCKETS DATALAKE - DEV" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# Función para agregar tags con Layer específico
function Add-BucketTags {
    param(
        [string]$BucketName,
        [string]$LayerValue
    )
    
    Write-Host "📦 Procesando: $BucketName (Layer: $LayerValue)" -ForegroundColor Yellow
    
    # Parsear JSON común
    $tagsObj = $COMMON_TAGS | ConvertFrom-Json
    
    # Agregar tag Layer específico
    $tagsObj.TagSet += @{"Key" = "Layer"; "Value" = $LayerValue}
    
    # Convertir a JSON
    $finalTags = $tagsObj | ConvertTo-Json -Depth 10 -Compress
    
    # Aplicar tags
    aws s3api put-bucket-tagging `
        --bucket $BucketName `
        --tagging $finalTags `
        --profile $PROFILE `
        --region $REGION
    
    if ($LASTEXITCODE -eq 0) {
        Write-Host "   ✅ Tags aplicados correctamente" -ForegroundColor Green
    } else {
        Write-Host "   ❌ Error al aplicar tags" -ForegroundColor Red
    }
    Write-Host ""
}

# Aplicar tags a cada bucket con su Layer correspondiente
Add-BucketTags -BucketName "s3-data-analytics-raw-dev-datalake" -LayerValue "Raw"
Add-BucketTags -BucketName "s3-data-analytics-standard-dev-datalake" -LayerValue "Standard"
Add-BucketTags -BucketName "s3-data-analytics-analytics-dev-datalake" -LayerValue "Analytics"

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "✅ PROCESO COMPLETADO" -ForegroundColor Green
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "Verificar tags con:" -ForegroundColor Yellow
Write-Host "  aws s3api get-bucket-tagging --bucket s3-data-analytics-raw-dev-datalake --profile darkh" -ForegroundColor White
