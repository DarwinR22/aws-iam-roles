# 🛑 EC2 INSTANCES PARADAS - COMANDO PARA REACTIVAR

**Fecha**: 26 Noviembre 2025 - 22:40  
**Acción**: EC2 instances paradas para ahorro de costos  
**Instances**: 2x sgsi-dev-web-server

## 📋 INSTANCES PARADAS

| Instance ID | Nombre | Tipo | Estado Anterior | Estado Actual |
|-------------|--------|------|-----------------|---------------|
| i-01de08b3b7745ca64 | sgsi-dev-web-server | t3.micro | running | **stopping** |
| i-08ecab0468f770a08 | sgsi-dev-web-server | t3.micro | running | **stopping** |

## 💰 AHORRO CALCULADO

```
Costo anterior: $2.05/día
Costo con instances stopped: $1.20/día
Ahorro: $0.85/día

Periodo Jueves-Viernes: $0.85 x 2 = $1.70 total
```

## 🚀 COMANDO PARA REACTIVAR EL SÁBADO

```bash
# Levantar instances
aws ec2 start-instances --instance-ids i-01de08b3b7745ca64 i-08ecab0468f770a08

# Verificar estado
aws ec2 describe-instances --instance-ids i-01de08b3b7745ca64 i-08ecab0468f770a08 --query 'Reservations[].Instances[].[InstanceId,State.Name]' --output table

# En 2-3 minutos estarán running y el ALB las detectará automáticamente
```

## ✅ INFRAESTRUCTURA QUE SIGUE FUNCIONANDO

- **RDS PostgreSQL**: ✅ Operativo
- **Application Load Balancer**: ✅ Operativo (sin targets)
- **VPC/Subnets/Security Groups**: ✅ Operativo
- **S3 Buckets**: ✅ Operativo
- **EFS File System**: ✅ Operativo
- **AWS Backup**: ✅ Operativo
- **CloudWatch/CloudTrail**: ✅ Operativo
- **SNS Topics**: ✅ Operativo

## 📊 NUEVO COSTO TOTAL (5 DÍAS)

```
Miércoles (hoy): $2.05
Jueves: $1.20 (stopped)
Viernes: $1.20 (stopped) 
Sábado: $2.05 (running)
Domingo: $2.05 (running)

TOTAL: $8.55 (ahorro de $1.70)
```

## ⚠️ NOTAS IMPORTANTES

1. **EBS Volumes**: Se mantienen y no generan costo (Free Tier)
2. **IP Privadas**: Se conservan - ALB funcionará inmediatamente
3. **Configuración**: Intacta - aplicaciones arrancarán automáticamente
4. **Security Groups**: Sin cambios
5. **Auto Scaling**: Detectará instances stopped, no creará nuevas

---

**🎯 Estrategia perfecta para ahorro inteligente manteniendo toda la infraestructura lista para usar!**