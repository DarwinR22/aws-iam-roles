# CAPA 2: NETWORKING Y SEGMENTACIÓN
# Arquitectura de Red para SGSI

## Objetivo
Implementar una arquitectura de red segmentada que soporte:
- Zero Trust Network Architecture
- Segmentación por capas (DMZ, Private, Database)
- Redundancia y alta disponibilidad
- Cumplimiento con ISO 27001 controles de red

## Componentes a Implementar

### 1. VPC Principal
- CIDR: 10.0.0.0/16 (65,536 IPs)
- Múltiples AZ para resiliencia
- DNS habilitado para resolución interna

### 2. Segmentación de Subnets
```
DMZ (Public Subnets) - 10.0.0.0/20
├── Web Tier (Load Balancers, WAF)
├── NAT Gateways
└── Bastion Hosts (si necesario)

Application Tier (Private Subnets) - 10.0.16.0/20  
├── Web Servers
├── App Servers
└── API Gateways

Database Tier (Private Subnets) - 10.0.32.0/20
├── RDS Instances
├── ElastiCache
└── Data Warehouses

Management Tier (Private Subnets) - 10.0.48.0/20
├── Monitoring Tools
├── Security Tools
└── Admin Servers
```

### 3. Security Groups (Firewalls de Aplicación)
- Web-SG: Solo HTTP/HTTPS desde Internet
- App-SG: Solo tráfico desde Web-SG  
- DB-SG: Solo tráfico desde App-SG
- Mgmt-SG: Acceso administrativo controlado

### 4. Network ACLs (Firewalls de Red)
- Controles adicionales por subnet
- Deny por defecto + Allow específicos
- Logging de tráfico denegado

### 5. VPC Flow Logs
- Monitoreo completo del tráfico
- Detección de anomalías
- Compliance y auditoría

## Principios de Seguridad Aplicados
- **Zero Trust**: Verificar todo tráfico
- **Segmentación**: Aislar por función
- **Menor Privilegio**: Mínimo acceso necesario
- **Defensa en Profundidad**: Múltiples capas
- **Monitoreo Continuo**: Visibilidad total