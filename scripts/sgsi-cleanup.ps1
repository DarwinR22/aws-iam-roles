# ==================================================
# SGSI Cost Cleanup Script
# ==================================================
# Ejecuta limpieza inteligente de recursos AWS para evitar costos
# Preserva: IAM, VPC base, S3/DynamoDB (sin costo)
# Elimina: NAT Gateways, EC2, Load Balancers (alto costo)

param(
    [Parameter(Mandatory=$false)]
    [ValidateSet("minimal", "moderate", "aggressive")]
    [string]$CleanupScope = "minimal",
    
    [Parameter(Mandatory=$false)]
    [switch]$DryRun = $true
)

# Colores para output
$Red = [System.ConsoleColor]::Red
$Green = [System.ConsoleColor]::Green
$Yellow = [System.ConsoleColor]::Yellow
$Blue = [System.ConsoleColor]::Blue

function Write-ColorText {
    param([string]$Text, [System.ConsoleColor]$Color)
    $originalColor = $Host.UI.RawUI.ForegroundColor
    $Host.UI.RawUI.ForegroundColor = $Color
    Write-Host $Text
    $Host.UI.RawUI.ForegroundColor = $originalColor
}

Write-ColorText "🧹 SGSI Infrastructure Cleanup" $Blue
Write-ColorText "================================" $Blue
Write-ColorText "Scope: $CleanupScope" $Yellow
Write-ColorText "Dry Run: $DryRun" $Yellow
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

# Verificar que estamos en la cuenta correcta
if ($awsAccount -ne "051963532279") {
    Write-ColorText "⚠️  ADVERTENCIA: Cuenta AWS diferente a la esperada!" $Yellow
    Write-ColorText "   Esperada: 051963532279" $Yellow
    Write-ColorText "   Actual: $awsAccount" $Yellow
    
    $confirm = Read-Host "¿Continuar de todos modos? (y/N)"
    if ($confirm -ne "y" -and $confirm -ne "Y") {
        Write-ColorText "❌ Operación cancelada" $Red
        exit 1
    }
}

Write-Host ""
Write-ColorText "🔍 ANÁLISIS DE RECURSOS COSTOSOS" $Blue
Write-ColorText "=================================" $Blue

# Función para obtener costo estimado
function Get-ResourceCost {
    param([string]$ResourceType, [int]$Count)
    
    $monthlyCosts = @{
        "NAT Gateway" = 45
        "EC2 t3.medium" = 30
        "Application LB" = 22
        "RDS db.t3.micro" = 15
        "VPC Endpoint" = 7
        "Elastic IP" = 4
    }
    
    if ($monthlyCosts.ContainsKey($ResourceType)) {
        return $monthlyCosts[$ResourceType] * $Count
    }
    return 0
}

# Buscar NAT Gateways
Write-Host "Buscando NAT Gateways..."
$natGateways = aws ec2 describe-nat-gateways --region us-east-1 --query 'NatGateways[?State==`available`].[NatGatewayId,Tags[?Key==`Name`].Value|[0]]' --output text 2>$null
$natCount = ($natGateways -split "`n" | Where-Object { $_ -match "sgsi|mci|github" }).Count
$natCost = Get-ResourceCost "NAT Gateway" $natCount

if ($natCount -gt 0) {
    Write-ColorText "💰 NAT Gateways encontrados: $natCount (≈$$$natCost/mes)" $Red
} else {
    Write-ColorText "✅ No hay NAT Gateways activos" $Green
}

# Buscar instancias EC2
Write-Host "Buscando instancias EC2..."
$ec2Instances = aws ec2 describe-instances --region us-east-1 --filters "Name=instance-state-name,Values=running,stopped" --query 'Reservations[].Instances[?Tags[?Key==`Project` && (Value==`SGSI` || Value==`MCI-IAM`)]].[InstanceId,InstanceType]' --output text 2>$null
$ec2Count = ($ec2Instances -split "`n" | Where-Object { $_.Trim() -ne "" }).Count
$ec2Cost = Get-ResourceCost "EC2 t3.medium" $ec2Count

if ($ec2Count -gt 0) {
    Write-ColorText "💰 Instancias EC2 encontradas: $ec2Count (≈$$$ec2Cost/mes)" $Red
} else {
    Write-ColorText "✅ No hay instancias EC2 activas" $Green
}

# Buscar Load Balancers
Write-Host "Buscando Load Balancers..."
$loadBalancers = aws elbv2 describe-load-balancers --region us-east-1 --query 'LoadBalancers[?contains(LoadBalancerName, `sgsi`) || contains(LoadBalancerName, `mci`)].LoadBalancerName' --output text 2>$null
$lbCount = ($loadBalancers -split "`n" | Where-Object { $_.Trim() -ne "" }).Count
$lbCost = Get-ResourceCost "Application LB" $lbCount

if ($lbCount -gt 0) {
    Write-ColorText "💰 Load Balancers encontrados: $lbCount (≈$$$lbCost/mes)" $Red
} else {
    Write-ColorText "✅ No hay Load Balancers activos" $Green
}

$totalMonthlyCost = $natCost + $ec2Cost + $lbCost

Write-Host ""
Write-ColorText "💵 COSTO TOTAL ESTIMADO: $$$totalMonthlyCost/mes" $(if ($totalMonthlyCost -gt 50) { $Red } elseif ($totalMonthlyCost -gt 20) { $Yellow } else { $Green })

if ($totalMonthlyCost -eq 0) {
    Write-ColorText "🎉 ¡Excelente! No hay recursos costosos activos" $Green
    exit 0
}

Write-Host ""
Write-ColorText "🧹 PLAN DE LIMPIEZA" $Blue
Write-ColorText "==================" $Blue

switch ($CleanupScope) {
    "minimal" {
        Write-ColorText "• Eliminar NAT Gateways únicamente" $Yellow
        Write-ColorText "• Preservar todo lo demás" $Green
        Write-ColorText "• Ahorro estimado: ≈$$$natCost/mes" $Green
    }
    "moderate" {
        Write-ColorText "• Eliminar NAT Gateways y Load Balancers" $Yellow
        Write-ColorText "• Preservar instancias EC2 (solo detener)" $Yellow
        Write-ColorText "• Ahorro estimado: ≈$$($natCost + $lbCost)/mes" $Green
    }
    "aggressive" {
        Write-ColorText "• Eliminar TODOS los recursos costosos" $Red
        Write-ColorText "• NAT Gateways, EC2, Load Balancers, RDS" $Red
        Write-ColorText "• Ahorro estimado: ≈$$$totalMonthlyCost/mes" $Green
    }
}

Write-Host ""
Write-ColorText "🔒 RECURSOS PRESERVADOS (SIN COSTO)" $Green
Write-ColorText "===================================" $Green
Write-ColorText "✅ IAM Roles y Policies" $Green
Write-ColorText "✅ VPC, Subnets, Security Groups" $Green  
Write-ColorText "✅ S3 Bucket (Terraform state)" $Green
Write-ColorText "✅ DynamoDB Table (Terraform locks)" $Green

if ($DryRun) {
    Write-Host ""
    Write-ColorText "🔍 MODO DRY RUN - Solo simulación" $Blue
    Write-ColorText "Para ejecutar realmente: .\sgsi-cleanup.ps1 -CleanupScope $CleanupScope -DryRun:`$false" $Blue
    exit 0
}

Write-Host ""
$confirm = Read-Host "¿Proceder con la limpieza $CleanupScope? (y/N)"
if ($confirm -ne "y" -and $confirm -ne "Y") {
    Write-ColorText "❌ Operación cancelada" $Red
    exit 1
}

Write-Host ""
Write-ColorText "🚀 EJECUTANDO LIMPIEZA..." $Blue

# Cambiar al directorio de cleanup
Set-Location "cleanup"

# Inicializar Terraform
Write-Host "Inicializando Terraform..."
terraform init

# Aplicar limpieza
Write-Host "Aplicando limpieza con scope: $CleanupScope"
terraform apply -var="cleanup_scope=$CleanupScope" -auto-approve

Write-Host ""
Write-ColorText "✅ Limpieza completada!" $Green
Write-ColorText "💰 Ahorro estimado: $$$totalMonthlyCost/mes" $Green
Write-ColorText "📊 Revisar AWS Cost Explorer en 24-48 horas" $Blue