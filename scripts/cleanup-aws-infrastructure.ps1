#!/usr/bin/env powershell
# AWS Infrastructure Cleanup Script
# Elimina recursos de compute y network, mantiene IAM y S3 backend
# Uso: .\cleanup-aws-infrastructure.ps1 -Region us-east-1 -Confirm

param(
    [string]$Region = "us-east-1",
    [switch]$Confirm = $false,
    [switch]$DryRun = $false
)

Write-Host "🧹 AWS Infrastructure Cleanup Script" -ForegroundColor Yellow
Write-Host "====================================" -ForegroundColor Yellow
Write-Host "Region: $Region" -ForegroundColor Cyan
Write-Host "Dry Run: $DryRun" -ForegroundColor Cyan
Write-Host ""

# Función para confirmar acción
function Confirm-Action {
    param([string]$Message)
    if ($DryRun) {
        Write-Host "[DRY RUN] $Message" -ForegroundColor Green
        return $false
    }
    if ($Confirm) {
        return $true
    }
    $response = Read-Host "$Message (y/N)"
    return ($response -eq 'y' -or $response -eq 'Y')
}

# Función para ejecutar comando AWS CLI
function Invoke-AWSCommand {
    param([string]$Command, [string]$Description)
    
    Write-Host "🔍 Checking: $Description..." -ForegroundColor Cyan
    
    if ($DryRun) {
        Write-Host "[DRY RUN] Would execute: $Command" -ForegroundColor Yellow
        return
    }
    
    try {
        $result = Invoke-Expression $Command
        if ($LASTEXITCODE -eq 0) {
            Write-Host "✅ $Description" -ForegroundColor Green
            return $result
        } else {
            Write-Host "⚠️ Failed: $Description" -ForegroundColor Yellow
        }
    }
    catch {
        Write-Host "❌ Error: $Description - $($_.Exception.Message)" -ForegroundColor Red
    }
}

Write-Host "🔍 PASO 1: Identificando recursos a eliminar..." -ForegroundColor Yellow
Write-Host ""

# 1. Listar EC2 Instances
Write-Host "📋 EC2 Instances:" -ForegroundColor Magenta
aws ec2 describe-instances --region $Region --query "Reservations[].Instances[?State.Name=='running'].InstanceId" --output table

# 2. Listar Load Balancers
Write-Host "📋 Load Balancers:" -ForegroundColor Magenta
aws elbv2 describe-load-balancers --region $Region --query "LoadBalancers[].LoadBalancerName" --output table

# 3. Listar RDS Instances
Write-Host "📋 RDS Instances:" -ForegroundColor Magenta
aws rds describe-db-instances --region $Region --query "DBInstances[].DBInstanceIdentifier" --output table

# 4. Listar VPCs (excepto default)
Write-Host "📋 VPCs (no default):" -ForegroundColor Magenta
aws ec2 describe-vpcs --region $Region --query "Vpcs[?IsDefault==false].VpcId" --output table

# 5. Listar Security Groups (excepto default)
Write-Host "📋 Security Groups (no default):" -ForegroundColor Magenta
aws ec2 describe-security-groups --region $Region --query "SecurityGroups[?GroupName!='default'].GroupId" --output table

# 6. Listar NAT Gateways
Write-Host "📋 NAT Gateways:" -ForegroundColor Magenta
aws ec2 describe-nat-gateways --region $Region --query "NatGateways[?State=='available'].NatGatewayId" --output table

# 7. Listar Elastic IPs no asociadas
Write-Host "📋 Elastic IPs (no asociadas):" -ForegroundColor Magenta
aws ec2 describe-addresses --region $Region --query "Addresses[?AssociationId==null].AllocationId" --output table

Write-Host ""
Write-Host "🚨 RECURSOS QUE SE MANTENDRÁN:" -ForegroundColor Green
Write-Host "✅ IAM Roles y Policies" -ForegroundColor Green
Write-Host "✅ S3 Bucket: terraform-state-bucket-*" -ForegroundColor Green
Write-Host "✅ DynamoDB: terraform-locks" -ForegroundColor Green
Write-Host "✅ VPC Default" -ForegroundColor Green
Write-Host ""

if (-not (Confirm-Action "¿Continuar con la eliminación de recursos?")) {
    Write-Host "❌ Operación cancelada por el usuario" -ForegroundColor Yellow
    exit 0
}

Write-Host ""
Write-Host "🗑️ PASO 2: Eliminando recursos..." -ForegroundColor Yellow
Write-Host ""

# ORDEN DE ELIMINACIÓN (importante para evitar dependencias)

# 1. Terminar EC2 Instances
Write-Host "1️⃣ Terminando EC2 Instances..." -ForegroundColor Cyan
$runningInstances = aws ec2 describe-instances --region $Region --query "Reservations[].Instances[?State.Name=='running'].InstanceId" --output text
if ($runningInstances) {
    $instanceIds = $runningInstances -split "\s+"
    foreach ($instanceId in $instanceIds) {
        if (Confirm-Action "Terminar EC2 Instance: $instanceId") {
            Invoke-AWSCommand "aws ec2 terminate-instances --region $Region --instance-ids $instanceId" "Terminando $instanceId"
        }
    }
    
    # Esperar a que terminen las instancias
    if (-not $DryRun -and $runningInstances) {
        Write-Host "⏳ Esperando que terminen las instancias..." -ForegroundColor Yellow
        aws ec2 wait instance-terminated --region $Region --instance-ids $instanceIds
    }
}

# 2. Eliminar Load Balancers
Write-Host "2️⃣ Eliminando Load Balancers..." -ForegroundColor Cyan
$albArns = aws elbv2 describe-load-balancers --region $Region --query "LoadBalancers[].LoadBalancerArn" --output text
if ($albArns) {
    $albList = $albArns -split "\s+"
    foreach ($albArn in $albList) {
        if (Confirm-Action "Eliminar ALB: $albArn") {
            Invoke-AWSCommand "aws elbv2 delete-load-balancer --region $Region --load-balancer-arn $albArn" "Eliminando ALB"
        }
    }
}

# 3. Eliminar RDS Instances
Write-Host "3️⃣ Eliminando RDS Instances..." -ForegroundColor Cyan
$rdsInstanceIds = aws rds describe-db-instances --region $Region --query "DBInstances[].DBInstanceIdentifier" --output text
if ($rdsInstanceIds) {
    $rdsIds = $rdsInstanceIds -split "\s+"
    foreach ($rdsId in $rdsIds) {
        if (Confirm-Action "Eliminar RDS Instance: $rdsId") {
            Invoke-AWSCommand "aws rds delete-db-instance --region $Region --db-instance-identifier $rdsId --skip-final-snapshot" "Eliminando RDS $rdsId"
        }
    }
}

# 4. Eliminar NAT Gateways
Write-Host "4️⃣ Eliminando NAT Gateways..." -ForegroundColor Cyan
$natGatewayIds = aws ec2 describe-nat-gateways --region $Region --query "NatGateways[?State=='available'].NatGatewayId" --output text
if ($natGatewayIds) {
    $natIds = $natGatewayIds -split "\s+"
    foreach ($natId in $natIds) {
        if (Confirm-Action "Eliminar NAT Gateway: $natId") {
            Invoke-AWSCommand "aws ec2 delete-nat-gateway --region $Region --nat-gateway-id $natId" "Eliminando NAT Gateway $natId"
        }
    }
    
    # Esperar a que se eliminen los NAT Gateways
    if (-not $DryRun -and $natGatewayIds) {
        Write-Host "⏳ Esperando que se eliminen los NAT Gateways..." -ForegroundColor Yellow
        Start-Sleep -Seconds 60
    }
}

# 5. Eliminar Elastic IPs no asociadas
Write-Host "5️⃣ Liberando Elastic IPs..." -ForegroundColor Cyan
$allocationIds = aws ec2 describe-addresses --region $Region --query "Addresses[?AssociationId==null].AllocationId" --output text
if ($allocationIds) {
    $eipIds = $allocationIds -split "\s+"
    foreach ($eipId in $eipIds) {
        if (Confirm-Action "Liberar Elastic IP: $eipId") {
            Invoke-AWSCommand "aws ec2 release-address --region $Region --allocation-id $eipId" "Liberando EIP $eipId"
        }
    }
}

# 6. Eliminar Security Groups (excepto default)
Write-Host "6️⃣ Eliminando Security Groups..." -ForegroundColor Cyan
$sgIds = aws ec2 describe-security-groups --region $Region --query "SecurityGroups[?GroupName!='default'].GroupId" --output text
if ($sgIds) {
    $securityGroupIds = $sgIds -split "\s+"
    foreach ($sgId in $securityGroupIds) {
        if (Confirm-Action "Eliminar Security Group: $sgId") {
            Invoke-AWSCommand "aws ec2 delete-security-group --region $Region --group-id $sgId" "Eliminando Security Group $sgId"
        }
    }
}

# 7. Eliminar VPCs (excepto default)
Write-Host "7️⃣ Eliminando VPCs..." -ForegroundColor Cyan
$vpcIds = aws ec2 describe-vpcs --region $Region --query "Vpcs[?IsDefault==false].VpcId" --output text
if ($vpcIds) {
    $vpcIdList = $vpcIds -split "\s+"
    foreach ($vpcId in $vpcIdList) {
        if (Confirm-Action "Eliminar VPC: $vpcId") {
            # Primero eliminar subnets, route tables, etc.
            Write-Host "   🔧 Limpiando dependencias de VPC $vpcId..." -ForegroundColor Gray
            
            # Eliminar subnets
            $subnetIds = aws ec2 describe-subnets --region $Region --filters "Name=vpc-id,Values=$vpcId" --query "Subnets[].SubnetId" --output text
            if ($subnetIds) {
                $subnetList = $subnetIds -split "\s+"
                foreach ($subnetId in $subnetList) {
                    Invoke-AWSCommand "aws ec2 delete-subnet --region $Region --subnet-id $subnetId" "Eliminando subnet $subnetId"
                }
            }
            
            # Eliminar route tables (excepto main)
            $routeTableIds = aws ec2 describe-route-tables --region $Region --filters "Name=vpc-id,Values=$vpcId" --query "RouteTables[?Associations[0].Main==false].RouteTableId" --output text
            if ($routeTableIds) {
                $rtIds = $routeTableIds -split "\s+"
                foreach ($rtId in $rtIds) {
                    Invoke-AWSCommand "aws ec2 delete-route-table --region $Region --route-table-id $rtId" "Eliminando route table $rtId"
                }
            }
            
            # Eliminar Internet Gateway
            $igwIds = aws ec2 describe-internet-gateways --region $Region --filters "Name=attachment.vpc-id,Values=$vpcId" --query "InternetGateways[].InternetGatewayId" --output text
            if ($igwIds) {
                $igwList = $igwIds -split "\s+"
                foreach ($igwId in $igwList) {
                    Invoke-AWSCommand "aws ec2 detach-internet-gateway --region $Region --internet-gateway-id $igwId --vpc-id $vpcId" "Desconectando IGW $igwId"
                    Invoke-AWSCommand "aws ec2 delete-internet-gateway --region $Region --internet-gateway-id $igwId" "Eliminando IGW $igwId"
                }
            }
            
            # Finalmente eliminar VPC
            Invoke-AWSCommand "aws ec2 delete-vpc --region $Region --vpc-id $vpcId" "Eliminando VPC $vpcId"
        }
    }
}

Write-Host ""
Write-Host "🎉 LIMPIEZA COMPLETADA" -ForegroundColor Green
Write-Host "======================" -ForegroundColor Green
Write-Host "✅ Recursos de compute y network eliminados" -ForegroundColor Green
Write-Host "✅ IAM y S3 backend mantenidos intactos" -ForegroundColor Green
Write-Host "🚀 Listo para desplegar Layer 2 desde cero" -ForegroundColor Green
Write-Host ""

# Verificación final
Write-Host "🔍 Verificación final..." -ForegroundColor Yellow
Write-Host "VPCs restantes (solo default debería quedar):"
aws ec2 describe-vpcs --region $Region --query "Vpcs[].{VpcId:VpcId,IsDefault:IsDefault,CidrBlock:CidrBlock}" --output table

Write-Host ""
Write-Host "Security Groups restantes (solo default debería quedar):"
aws ec2 describe-security-groups --region $Region --query "SecurityGroups[].{GroupId:GroupId,GroupName:GroupName}" --output table