# ==================================================
# Quick Cost Cleanup - Solo recursos MÁS costosos
# ==================================================
# Elimina rápidamente NAT Gateways (principal fuente de costo)
# Preserva absolutamente todo lo demás

Write-Host "🔥 QUICK CLEANUP - Solo NAT Gateways" -ForegroundColor Red
Write-Host "====================================" -ForegroundColor Red

# Verificar AWS CLI
$awsAccount = aws sts get-caller-identity --query 'Account' --output text 2>$null
if ($LASTEXITCODE -ne 0) {
    Write-Host "❌ Error: AWS CLI no configurado" -ForegroundColor Red
    exit 1
}

Write-Host "✅ AWS Account: $awsAccount" -ForegroundColor Green

# Buscar NAT Gateways
Write-Host "`n🔍 Buscando NAT Gateways activos..."
$natGateways = aws ec2 describe-nat-gateways --region us-east-1 --query 'NatGateways[?State==`available`].[NatGatewayId,Tags[?Key==`Name`].Value|[0]]' --output table

if ($natGateways -match "sgsi|mci|github") {
    Write-Host "💰 NAT Gateways encontrados (≈$45/mes cada uno):" -ForegroundColor Yellow
    Write-Host $natGateways
    
    $confirm = Read-Host "`n¿Eliminar SOLO los NAT Gateways? (y/N)"
    if ($confirm -eq "y" -or $confirm -eq "Y") {
        Write-Host "`n🔥 Eliminando NAT Gateways..." -ForegroundColor Red
        
        # Obtener IDs de NAT Gateways con nuestros tags
        $natIds = aws ec2 describe-nat-gateways --region us-east-1 --query 'NatGateways[?State==`available` && Tags[?Key==`Project` && (Value==`SGSI` || Value==`MCI-IAM`)]].NatGatewayId' --output text
        
        foreach ($natId in $natIds -split "`s+") {
            if ($natId.Trim() -ne "") {
                Write-Host "  Eliminando NAT Gateway: $natId"
                aws ec2 delete-nat-gateway --nat-gateway-id $natId --region us-east-1
            }
        }
        
        Write-Host "`n✅ NAT Gateways eliminados!" -ForegroundColor Green
        Write-Host "💰 Ahorro estimado: ~$45-90/mes" -ForegroundColor Green
        Write-Host "⏰ Los NAT Gateways tardan 5-10 minutos en eliminarse completamente" -ForegroundColor Blue
    } else {
        Write-Host "❌ Operación cancelada" -ForegroundColor Red
    }
} else {
    Write-Host "✅ No hay NAT Gateways activos - No hay costos!" -ForegroundColor Green
}

Write-Host "`n🔒 RECURSOS PRESERVADOS:" -ForegroundColor Green
Write-Host "✅ IAM Roles y Policies" -ForegroundColor Green
Write-Host "✅ VPC, Subnets, Security Groups" -ForegroundColor Green
Write-Host "✅ S3 y DynamoDB (Terraform state)" -ForegroundColor Green
Write-Host "✅ Instancias EC2 (si las hay)" -ForegroundColor Green
Write-Host "✅ Load Balancers (si los hay)" -ForegroundColor Green

Write-Host "`n📋 Para recrear NAT Gateways cuando necesites:" -ForegroundColor Blue
Write-Host "   terraform apply" -ForegroundColor Blue