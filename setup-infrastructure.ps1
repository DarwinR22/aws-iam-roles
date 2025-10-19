# Script de configuración de infraestructura para Darwin's AWS IAM Roles
# Crea S3 bucket y DynamoDB table para el state de Terraform

Write-Host "🚀 Configurando infraestructura para Darwin's AWS IAM Roles..." -ForegroundColor Green

# Variables
$BUCKET_NAME = "darwin-aws-iam-tfstate-bucket"
$DYNAMODB_TABLE = "darwin-terraform-lock"
$REGION = "us-east-1"
$ACCOUNT_ID = "051963532279"

Write-Host "📋 Configuración:" -ForegroundColor Yellow
Write-Host "  Bucket S3: $BUCKET_NAME" -ForegroundColor White
Write-Host "  Tabla DynamoDB: $DYNAMODB_TABLE" -ForegroundColor White
Write-Host "  Región: $REGION" -ForegroundColor White
Write-Host "  Account ID: $ACCOUNT_ID" -ForegroundColor White
Write-Host ""

# Verificar credenciales
Write-Host "🔐 Verificando credenciales AWS..." -ForegroundColor Cyan
try {
    $identity = aws sts get-caller-identity | ConvertFrom-Json
    Write-Host "✅ Credenciales válidas - Usuario: $($identity.Arn)" -ForegroundColor Green
} catch {
    Write-Host "❌ Error: Credenciales AWS no configuradas correctamente" -ForegroundColor Red
    exit 1
}

# Verificar si el bucket ya existe
Write-Host "📦 Verificando bucket S3..." -ForegroundColor Cyan
$bucketExists = $false
try {
    aws s3 head-bucket --bucket $BUCKET_NAME 2>$null
    if ($LASTEXITCODE -eq 0) {
        Write-Host "✅ Bucket S3 '$BUCKET_NAME' ya existe" -ForegroundColor Green
        $bucketExists = $true
    }
} catch {
    Write-Host "📦 Bucket S3 no existe, se creará..." -ForegroundColor Yellow
}

# Crear bucket S3 si no existe
if (-not $bucketExists) {
    try {
        Write-Host "📦 Creando bucket S3: $BUCKET_NAME" -ForegroundColor Cyan
        aws s3 mb "s3://$BUCKET_NAME" --region $REGION
        if ($LASTEXITCODE -eq 0) {
            Write-Host "✅ Bucket S3 creado exitosamente" -ForegroundColor Green
            
            # Habilitar versionado
            Write-Host "🔄 Habilitando versionado en el bucket..." -ForegroundColor Cyan
            aws s3api put-bucket-versioning --bucket $BUCKET_NAME --versioning-configuration Status=Enabled
            if ($LASTEXITCODE -eq 0) {
                Write-Host "✅ Versionado habilitado" -ForegroundColor Green
            } else {
                Write-Host "⚠️  Advertencia: No se pudo habilitar versionado" -ForegroundColor Yellow
            }
        } else {
            Write-Host "❌ Error creando bucket S3" -ForegroundColor Red
        }
    } catch {
        Write-Host "❌ Error: No se pudo crear el bucket S3" -ForegroundColor Red
    }
}

# Verificar si la tabla DynamoDB ya existe
Write-Host "🗃️  Verificando tabla DynamoDB..." -ForegroundColor Cyan
$tableExists = $false
try {
    $tableStatus = aws dynamodb describe-table --table-name $DYNAMODB_TABLE --region $REGION 2>$null | ConvertFrom-Json
    if ($tableStatus.Table.TableStatus -eq "ACTIVE") {
        Write-Host "✅ Tabla DynamoDB '$DYNAMODB_TABLE' ya existe y está activa" -ForegroundColor Green
        $tableExists = $true
    }
} catch {
    Write-Host "🗃️  Tabla DynamoDB no existe, se creará..." -ForegroundColor Yellow
}

# Crear tabla DynamoDB si no existe
if (-not $tableExists) {
    try {
        Write-Host "🗃️  Creando tabla DynamoDB: $DYNAMODB_TABLE" -ForegroundColor Cyan
        aws dynamodb create-table --table-name $DYNAMODB_TABLE --attribute-definitions AttributeName=LockID,AttributeType=S --key-schema AttributeName=LockID,KeyType=HASH --provisioned-throughput ReadCapacityUnits=5,WriteCapacityUnits=5 --region $REGION
        
        if ($LASTEXITCODE -eq 0) {
            Write-Host "✅ Tabla DynamoDB creada exitosamente" -ForegroundColor Green
            Write-Host "⏳ Esperando que la tabla esté activa..." -ForegroundColor Cyan
            
            # Esperar a que la tabla esté activa
            do {
                Start-Sleep -Seconds 10
                $tableStatus = aws dynamodb describe-table --table-name $DYNAMODB_TABLE --region $REGION | ConvertFrom-Json
                Write-Host "   Estado actual: $($tableStatus.Table.TableStatus)" -ForegroundColor Yellow
            } while ($tableStatus.Table.TableStatus -ne "ACTIVE")
            
            Write-Host "✅ Tabla DynamoDB está activa y lista para usar" -ForegroundColor Green
        } else {
            Write-Host "❌ Error creando tabla DynamoDB" -ForegroundColor Red
            Write-Host "💡 Esto puede deberse a permisos insuficientes. Puedes crear la tabla manualmente en la consola de AWS." -ForegroundColor Yellow
        }
    } catch {
        Write-Host "❌ Error: No se pudo crear la tabla DynamoDB" -ForegroundColor Red
        Write-Host "💡 Puedes crear la tabla manualmente en la consola de AWS con estos parámetros:" -ForegroundColor Yellow
        Write-Host "   - Nombre: $DYNAMODB_TABLE" -ForegroundColor White
        Write-Host "   - Partition key: LockID (String)" -ForegroundColor White
        Write-Host "   - Read/Write capacity: 5/5" -ForegroundColor White
    }
}

Write-Host ""
Write-Host "📋 Configuración del backend de Terraform:" -ForegroundColor Yellow
Write-Host "terraform {" -ForegroundColor White
Write-Host "  backend `"s3`" {" -ForegroundColor White
Write-Host "    bucket         = `"$BUCKET_NAME`"" -ForegroundColor White
Write-Host "    key            = `"iam-management/terraform.tfstate`"" -ForegroundColor White
Write-Host "    region         = `"$REGION`"" -ForegroundColor White
Write-Host "    dynamodb_table = `"$DYNAMODB_TABLE`"" -ForegroundColor White
Write-Host "    encrypt        = true" -ForegroundColor White
Write-Host "  }" -ForegroundColor White
Write-Host "}" -ForegroundColor White

Write-Host ""
Write-Host "🎉 Configuración de infraestructura completada!" -ForegroundColor Green
Write-Host "📝 Próximos pasos:" -ForegroundColor Yellow
Write-Host "   1. Actualizar backend.tf con la configuración mostrada arriba" -ForegroundColor White
Write-Host "   2. Ejecutar terraform init para inicializar el backend" -ForegroundColor White
Write-Host "   3. Configurar secretos en GitHub Actions si es necesario" -ForegroundColor White