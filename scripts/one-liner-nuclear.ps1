# NUCLEAR CLEANUP - Una línea para eliminar TODO lo costoso
# Solo copia y pega estos comandos en PowerShell para eliminar TODO

Write-Host "💥 ELIMINACIÓN NUCLEAR EN AWS - TODO LO COSTOSO" -ForegroundColor Red

# NAT Gateways (MÁS COSTOSO - $45/mes cada uno)
Write-Host "🔥 Eliminando NAT Gateways..." -ForegroundColor Red
aws ec2 describe-nat-gateways --region us-east-1 --query 'NatGateways[?State==`available`].NatGatewayId' --output text | ForEach-Object { $ids = $_ -split '\s+'; foreach($id in $ids) { if($id.Trim() -ne '') { aws ec2 delete-nat-gateway --nat-gateway-id $id --region us-east-1 } } }

# Instancias EC2 (ALTO COSTO - $30+/mes cada una)
Write-Host "🔥 Terminando instancias EC2..." -ForegroundColor Red
aws ec2 describe-instances --region us-east-1 --filters "Name=instance-state-name,Values=running,stopped" --query 'Reservations[].Instances[].InstanceId' --output text | ForEach-Object { $ids = $_ -split '\s+'; foreach($id in $ids) { if($id.Trim() -ne '') { aws ec2 terminate-instances --instance-ids $id --region us-east-1 } } }

# Load Balancers (ALTO COSTO - $22/mes cada uno)
Write-Host "🔥 Eliminando Load Balancers..." -ForegroundColor Red
aws elbv2 describe-load-balancers --region us-east-1 --query 'LoadBalancers[].LoadBalancerArn' --output text | ForEach-Object { $arns = $_ -split '\s+'; foreach($arn in $arns) { if($arn.Trim() -ne '') { aws elbv2 delete-load-balancer --load-balancer-arn $arn --region us-east-1 } } }

# RDS Instances (MUY ALTO COSTO - $50+/mes cada una)
Write-Host "🔥 Eliminando instancias RDS..." -ForegroundColor Red
aws rds describe-db-instances --region us-east-1 --query 'DBInstances[].DBInstanceIdentifier' --output text | ForEach-Object { $ids = $_ -split '\s+'; foreach($id in $ids) { if($id.Trim() -ne '') { aws rds delete-db-instance --db-instance-identifier $id --skip-final-snapshot --region us-east-1 } } }

# Elastic IPs no asociadas (MEDIO COSTO - $4/mes cada una)
Write-Host "🟡 Liberando Elastic IPs..." -ForegroundColor Yellow
aws ec2 describe-addresses --region us-east-1 --query 'Addresses[?AssociationId==null].AllocationId' --output text | ForEach-Object { $ids = $_ -split '\s+'; foreach($id in $ids) { if($id.Trim() -ne '') { aws ec2 release-address --allocation-id $id --region us-east-1 } } }

# Volúmenes EBS no asociados (BAJO COSTO - pero se acumula)
Write-Host "🟡 Eliminando volúmenes EBS no asociados..." -ForegroundColor Yellow
aws ec2 describe-volumes --region us-east-1 --filters "Name=status,Values=available" --query 'Volumes[].VolumeId' --output text | ForEach-Object { $ids = $_ -split '\s+'; foreach($id in $ids) { if($id.Trim() -ne '') { aws ec2 delete-volume --volume-id $id --region us-east-1 } } }

Write-Host ""
Write-Host "✅ LIMPIEZA NUCLEAR COMPLETADA!" -ForegroundColor Green
Write-Host "💰 Todos los recursos costosos han sido eliminados" -ForegroundColor Green
Write-Host "🔒 Preservado: IAM, VPC base, S3/DynamoDB state" -ForegroundColor Green
Write-Host "📁 Repositorio: Intacto y sin cambios" -ForegroundColor Green
Write-Host ""
Write-Host "📊 Para revisar costos: AWS Cost Explorer" -ForegroundColor Blue
Write-Host "🚀 Para recrear: terraform apply" -ForegroundColor Blue