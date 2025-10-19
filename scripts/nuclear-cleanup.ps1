# ==================================================
# NUCLEAR CLEANUP - Eliminar TODO lo que genere costo
# ==================================================
# Elimina TODOS los recursos costosos de AWS
# Preserva: Solo IAM (gratis) y Terraform state (gratis)
# NO toca el repositorio - solo AWS

param(
    [Parameter(Mandatory=$false)]
    [switch]$Force = $false,
    
    [Parameter(Mandatory=$false)]
    [switch]$DryRun = $true
)

# Colores
$Red = [System.ConsoleColor]::Red
$Green = [System.ConsoleColor]::Green
$Yellow = [System.ConsoleColor]::Yellow
$Blue = [System.ConsoleColor]::Blue
$Magenta = [System.ConsoleColor]::Magenta

function Write-ColorText {
    param([string]$Text, [System.ConsoleColor]$Color)
    $originalColor = $Host.UI.RawUI.ForegroundColor
    $Host.UI.RawUI.ForegroundColor = $Color
    Write-Host $Text
    $Host.UI.RawUI.ForegroundColor = $originalColor
}

Write-ColorText "💥 NUCLEAR CLEANUP - Eliminar TODO lo costoso" $Red
Write-ColorText "=============================================" $Red
Write-ColorText "⚠️  ADVERTENCIA: Esto eliminará TODOS los recursos que generen costo" $Yellow
Write-ColorText "✅ Preserva: Solo IAM, S3/DynamoDB state (gratis)" $Green
Write-ColorText "🗂️  NO toca: El repositorio queda intacto" $Blue
Write-Host ""

# Verificar AWS CLI
try {
    $awsAccount = aws sts get-caller-identity --query 'Account' --output text 2>$null
    if ($LASTEXITCODE -ne 0) {
        Write-ColorText "❌ Error: AWS CLI no configurado correctamente" $Red
        exit 1
    }
    Write-ColorText "✅ AWS Account: $awsAccount" $Green
} catch {
    Write-ColorText "❌ Error: No se puede acceder a AWS" $Red
    exit 1
}

# Verificar cuenta correcta
if ($awsAccount -ne "051963532279") {
    Write-ColorText "⚠️  ADVERTENCIA: Cuenta AWS diferente a la esperada!" $Yellow
    Write-ColorText "   Esperada: 051963532279" $Yellow
    Write-ColorText "   Actual: $awsAccount" $Yellow
    
    if (-not $Force) {
        $confirm = Read-Host "¿Continuar de todos modos? (y/N)"
        if ($confirm -ne "y" -and $confirm -ne "Y") {
            Write-ColorText "❌ Operación cancelada" $Red
            exit 1
        }
    }
}

Write-Host ""
Write-ColorText "🔍 ESCANEANDO RECURSOS COSTOSOS EN AWS..." $Blue
Write-ColorText "========================================" $Blue

$totalEstimatedMonthlyCost = 0
$resourcesToDelete = @()

# Función para agregar recurso a la lista de eliminación
function Add-ResourceToDelete {
    param([string]$Type, [string]$Id, [string]$Name, [decimal]$MonthlyCost, [string]$DeleteCommand)
    
    $script:resourcesToDelete += [PSCustomObject]@{
        Type = $Type
        Id = $Id
        Name = $Name
        MonthlyCost = $MonthlyCost
        DeleteCommand = $DeleteCommand
    }
    
    $script:totalEstimatedMonthlyCost += $MonthlyCost
}

Write-Host "🔍 Buscando NAT Gateways..."
try {
    $natGateways = aws ec2 describe-nat-gateways --region us-east-1 --query 'NatGateways[?State==`available`].[NatGatewayId,Tags[?Key==`Name`].Value|[0]]' --output text 2>$null
    if ($natGateways) {
        $natLines = $natGateways -split "`n" | Where-Object { $_.Trim() -ne "" }
        foreach ($natLine in $natLines) {
            $parts = $natLine -split "`t"
            $natId = $parts[0].Trim()
            $natName = if ($parts.Length -gt 1) { $parts[1].Trim() } else { "Unnamed" }
            
            if ($natId -match "^nat-") {
                Add-ResourceToDelete "NAT Gateway" $natId $natName 45 "aws ec2 delete-nat-gateway --nat-gateway-id $natId --region us-east-1"
                Write-ColorText "  💰 NAT Gateway: $natId ($natName) - $45/mes" $Red
            }
        }
    }
} catch {
    Write-ColorText "⚠️  Error buscando NAT Gateways: $($_.Exception.Message)" $Yellow
}

Write-Host "🔍 Buscando instancias EC2..."
try {
    $ec2Instances = aws ec2 describe-instances --region us-east-1 --filters "Name=instance-state-name,Values=running,stopped,stopping" --query 'Reservations[].Instances[].[InstanceId,InstanceType,Tags[?Key==`Name`].Value|[0],State.Name]' --output text 2>$null
    if ($ec2Instances) {
        $ec2Lines = $ec2Instances -split "`n" | Where-Object { $_.Trim() -ne "" }
        foreach ($ec2Line in $ec2Lines) {
            $parts = $ec2Line -split "`t"
            $instanceId = $parts[0].Trim()
            $instanceType = $parts[1].Trim()
            $instanceName = if ($parts.Length -gt 2) { $parts[2].Trim() } else { "Unnamed" }
            $instanceState = if ($parts.Length -gt 3) { $parts[3].Trim() } else { "unknown" }
            
            # Estimar costo basado en tipo de instancia
            $monthlyCost = switch ($instanceType) {
                { $_ -like "t3.nano" } { 4 }
                { $_ -like "t3.micro" } { 8 }
                { $_ -like "t3.small" } { 16 }
                { $_ -like "t3.medium" } { 33 }
                { $_ -like "t3.large" } { 66 }
                { $_ -like "m5.*" } { 70 }
                { $_ -like "c5.*" } { 60 }
                default { 30 }  # Estimación conservadora
            }
            
            Add-ResourceToDelete "EC2 Instance" $instanceId "$instanceName ($instanceType)" $monthlyCost "aws ec2 terminate-instances --instance-ids $instanceId --region us-east-1"
            Write-ColorText "  💰 EC2: $instanceId ($instanceName) - $instanceType - $monthlyCost/mes" $Red
        }
    }
} catch {
    Write-ColorText "⚠️  Error buscando EC2: $($_.Exception.Message)" $Yellow
}

Write-Host "🔍 Buscando Load Balancers..."
try {
    $loadBalancers = aws elbv2 describe-load-balancers --region us-east-1 --query 'LoadBalancers[].[LoadBalancerArn,LoadBalancerName,Type]' --output text 2>$null
    if ($loadBalancers) {
        $lbLines = $loadBalancers -split "`n" | Where-Object { $_.Trim() -ne "" }
        foreach ($lbLine in $lbLines) {
            $parts = $lbLine -split "`t"
            $lbArn = $parts[0].Trim()
            $lbName = $parts[1].Trim()
            $lbType = if ($parts.Length -gt 2) { $parts[2].Trim() } else { "application" }
            
            $monthlyCost = switch ($lbType) {
                "application" { 22 }
                "network" { 22 }
                "gateway" { 36 }
                default { 22 }
            }
            
            Add-ResourceToDelete "Load Balancer" $lbArn "$lbName ($lbType)" $monthlyCost "aws elbv2 delete-load-balancer --load-balancer-arn '$lbArn' --region us-east-1"
            Write-ColorText "  💰 Load Balancer: $lbName ($lbType) - $monthlyCost/mes" $Red
        }
    }
} catch {
    Write-ColorText "⚠️  Error buscando Load Balancers: $($_.Exception.Message)" $Yellow
}

Write-Host "🔍 Buscando instancias RDS..."
try {
    $rdsInstances = aws rds describe-db-instances --region us-east-1 --query 'DBInstances[].[DBInstanceIdentifier,DBInstanceClass,DBInstanceStatus]' --output text 2>$null
    if ($rdsInstances) {
        $rdsLines = $rdsInstances -split "`n" | Where-Object { $_.Trim() -ne "" }
        foreach ($rdsLine in $rdsLines) {
            $parts = $rdsLine -split "`t"
            $rdsId = $parts[0].Trim()
            $rdsClass = $parts[1].Trim()
            $rdsStatus = if ($parts.Length -gt 2) { $parts[2].Trim() } else { "unknown" }
            
            # Estimar costo RDS
            $monthlyCost = switch ($rdsClass) {
                { $_ -like "db.t3.micro" } { 15 }
                { $_ -like "db.t3.small" } { 30 }
                { $_ -like "db.t3.medium" } { 60 }
                { $_ -like "db.m5.*" } { 120 }
                default { 50 }
            }
            
            Add-ResourceToDelete "RDS Instance" $rdsId "$rdsId ($rdsClass)" $monthlyCost "aws rds delete-db-instance --db-instance-identifier $rdsId --skip-final-snapshot --region us-east-1"
            Write-ColorText "  💰 RDS: $rdsId ($rdsClass) - $monthlyCost/mes" $Red
        }
    }
} catch {
    Write-ColorText "⚠️  Error buscando RDS: $($_.Exception.Message)" $Yellow
}

Write-Host "🔍 Buscando Elastic IPs..."
try {
    $elasticIPs = aws ec2 describe-addresses --region us-east-1 --query 'Addresses[?AssociationId==null].[AllocationId,PublicIp]' --output text 2>$null
    if ($elasticIPs) {
        $eipLines = $elasticIPs -split "`n" | Where-Object { $_.Trim() -ne "" }
        foreach ($eipLine in $eipLines) {
            $parts = $eipLine -split "`t"
            $allocationId = $parts[0].Trim()
            $publicIp = if ($parts.Length -gt 1) { $parts[1].Trim() } else { "Unknown" }
            
            Add-ResourceToDelete "Elastic IP" $allocationId $publicIp 4 "aws ec2 release-address --allocation-id $allocationId --region us-east-1"
            Write-ColorText "  💰 Elastic IP: $publicIp - $4/mes" $Yellow
        }
    }
} catch {
    Write-ColorText "⚠️  Error buscando Elastic IPs: $($_.Exception.Message)" $Yellow
}

Write-Host "🔍 Buscando volúmenes EBS no asociados..."
try {
    $ebsVolumes = aws ec2 describe-volumes --region us-east-1 --filters "Name=status,Values=available" --query 'Volumes[].[VolumeId,Size,VolumeType]' --output text 2>$null
    if ($ebsVolumes) {
        $ebsLines = $ebsVolumes -split "`n" | Where-Object { $_.Trim() -ne "" }
        foreach ($ebsLine in $ebsLines) {
            $parts = $ebsLine -split "`t"
            $volumeId = $parts[0].Trim()
            $size = if ($parts.Length -gt 1) { [int]$parts[1].Trim() } else { 8 }
            $volumeType = if ($parts.Length -gt 2) { $parts[2].Trim() } else { "gp2" }
            
            # Costo por GB/mes
            $costPerGB = switch ($volumeType) {
                "gp2" { 0.10 }
                "gp3" { 0.08 }
                "io1" { 0.125 }
                "io2" { 0.125 }
                default { 0.10 }
            }
            
            $monthlyCost = [math]::Round($size * $costPerGB, 2)
            
            if ($monthlyCost -gt 1) {  # Solo si cuesta más de $1/mes
                Add-ResourceToDelete "EBS Volume" $volumeId "$size GB ($volumeType)" $monthlyCost "aws ec2 delete-volume --volume-id $volumeId --region us-east-1"
                Write-ColorText "  💰 EBS Volume: $volumeId ($size GB) - $$monthlyCost/mes" $Yellow
            }
        }
    }
} catch {
    Write-ColorText "⚠️  Error buscando EBS Volumes: $($_.Exception.Message)" $Yellow
}

Write-Host ""
Write-ColorText "📊 RESUMEN DE RECURSOS COSTOSOS" $Magenta
Write-ColorText "===============================" $Magenta

if ($resourcesToDelete.Count -eq 0) {
    Write-ColorText "🎉 ¡EXCELENTE! No hay recursos costosos activos" $Green
    Write-ColorText "💰 Costo actual: $0/mes" $Green
    exit 0
}

$resourcesToDelete | Group-Object Type | ForEach-Object {
    $typeCount = $_.Count
    $typeCost = ($_.Group | Measure-Object MonthlyCost -Sum).Sum
    Write-ColorText "  $($_.Name): $typeCount recursos ($$typeCost/mes)" $Red
}

Write-Host ""
Write-ColorText "💵 COSTO TOTAL MENSUAL: $$([math]::Round($totalEstimatedMonthlyCost, 2))" $Red
Write-ColorText "💰 AHORRO AL ELIMINAR: $$([math]::Round($totalEstimatedMonthlyCost, 2))/mes" $Green

if ($DryRun) {
    Write-Host ""
    Write-ColorText "🔍 MODO DRY RUN - Solo simulación" $Blue
    Write-ColorText "Para ejecutar realmente:" $Blue
    Write-ColorText "  .\scripts\nuclear-cleanup.ps1 -DryRun:`$false" $Blue
    Write-Host ""
    Write-ColorText "📋 RECURSOS QUE SE ELIMINARÍAN:" $Yellow
    $resourcesToDelete | ForEach-Object {
        Write-Host "  🗑️  $($_.Type): $($_.Name) ($$($_.MonthlyCost)/mes)"
    }
    exit 0
}

Write-Host ""
Write-ColorText "⚠️  CONFIRMACIÓN REQUERIDA" $Yellow
Write-ColorText "=========================" $Yellow
Write-ColorText "Esto eliminará $($resourcesToDelete.Count) recursos costosos" $Red
Write-ColorText "Ahorro estimado: $$([math]::Round($totalEstimatedMonthlyCost, 2))/mes" $Green
Write-Host ""
Write-ColorText "🔒 RECURSOS QUE NO SE TOCAN:" $Green
Write-ColorText "✅ IAM Roles y Policies (gratis)" $Green
Write-ColorText "✅ VPC, Subnets, Security Groups (gratis)" $Green
Write-ColorText "✅ S3 Bucket terraform state (gratis)" $Green
Write-ColorText "✅ DynamoDB terraform locks (gratis)" $Green
Write-ColorText "✅ Repositorio local (intacto)" $Green

Write-Host ""
if (-not $Force) {
    $confirm = Read-Host "¿PROCEDER con la eliminación nuclear? (ESCRIBIR 'ELIMINAR' para confirmar)"
    if ($confirm -ne "ELIMINAR") {
        Write-ColorText "❌ Operación cancelada" $Red
        exit 1
    }
}

Write-Host ""
Write-ColorText "💥 EJECUTANDO ELIMINACIÓN NUCLEAR..." $Red
Write-ColorText "====================================" $Red

$deletedCount = 0
$errorCount = 0

foreach ($resource in $resourcesToDelete) {
    Write-Host "🗑️  Eliminando $($resource.Type): $($resource.Name)..."
    
    try {
        Invoke-Expression $resource.DeleteCommand
        if ($LASTEXITCODE -eq 0) {
            Write-ColorText "  ✅ Eliminado: $($resource.Name)" $Green
            $deletedCount++
        } else {
            Write-ColorText "  ❌ Error eliminando: $($resource.Name)" $Red
            $errorCount++
        }
    } catch {
        Write-ColorText "  ❌ Error: $($_.Exception.Message)" $Red
        $errorCount++
    }
    
    Start-Sleep -Milliseconds 500  # Pequeña pausa entre eliminaciones
}

Write-Host ""
Write-ColorText "🎯 ELIMINACIÓN COMPLETADA" $Green
Write-ColorText "=========================" $Green
Write-ColorText "✅ Recursos eliminados: $deletedCount" $Green
Write-ColorText "❌ Errores: $errorCount" $(if ($errorCount -gt 0) { $Red } else { $Green })
Write-ColorText "💰 Ahorro estimado: $$([math]::Round($totalEstimatedMonthlyCost, 2))/mes" $Green

Write-Host ""
Write-ColorText "📋 PRÓXIMOS PASOS:" $Blue
Write-ColorText "==================" $Blue
Write-ColorText "1. Revisar AWS Cost Explorer en 24-48 horas" $Blue
Write-ColorText "2. Para recrear infraestructura: terraform apply" $Blue
Write-ColorText "3. El repositorio está intacto - solo AWS fue limpiado" $Blue
Write-ColorText "4. Configurar alertas de billing para el futuro" $Blue

Write-Host ""
Write-ColorText "🛡️  RECORDATORIO: Esta limpieza no afecta el desarrollo" $Green
Write-ColorText "El código, configuraciones y documentación están preservados" $Green