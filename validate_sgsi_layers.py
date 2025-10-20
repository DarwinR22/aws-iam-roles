#!/usr/bin/env python3
"""
SGSI Infrastructure Validation Script
====================================

Valida el estado de los 5 layers de la infraestructura SGSI desplegada en AWS.
Genera reportes detallados en múltiples formatos.

Usage:
    python validate_sgsi_layers.py
    python validate_sgsi_layers.py --layer 3
    python validate_sgsi_layers.py --format json
    python validate_sgsi_layers.py --format html
"""

import json
import subprocess
import sys
import argparse
from datetime import datetime
from typing import Dict, List, Any, Optional
import logging

# Configuración de colores para terminal
class Colors:
    GREEN = '\033[92m'
    RED = '\033[91m'
    YELLOW = '\033[93m'
    BLUE = '\033[94m'
    MAGENTA = '\033[95m'
    CYAN = '\033[96m'
    WHITE = '\033[97m'
    BOLD = '\033[1m'
    END = '\033[0m'

class SGSIValidator:
    def __init__(self):
        self.total_resources = 0
        self.valid_resources = 0
        self.validation_results = {}
        self.account_id = None
        
        # Configurar logging
        logging.basicConfig(
            level=logging.INFO,
            format='%(asctime)s - %(levelname)s - %(message)s'
        )
        self.logger = logging.getLogger(__name__)

    def print_header(self, message: str):
        """Imprime un header con formato"""
        print(f"\n{Colors.MAGENTA}{Colors.BOLD}🔍 {message}{Colors.END}")
        print(f"{Colors.MAGENTA}{'='*len(message)}{Colors.END}")

    def print_success(self, message: str):
        """Imprime mensaje de éxito"""
        print(f"{Colors.GREEN}✅ {message}{Colors.END}")

    def print_error(self, message: str):
        """Imprime mensaje de error"""
        print(f"{Colors.RED}❌ {message}{Colors.END}")

    def print_warning(self, message: str):
        """Imprime mensaje de advertencia"""
        print(f"{Colors.YELLOW}⚠️ {message}{Colors.END}")

    def print_info(self, message: str):
        """Imprime mensaje informativo"""
        print(f"{Colors.CYAN}ℹ️ {message}{Colors.END}")

    def run_aws_command(self, command: List[str]) -> Optional[Dict]:
        """Ejecuta un comando AWS CLI y retorna el resultado JSON"""
        try:
            result = subprocess.run(
                command, 
                capture_output=True, 
                text=True, 
                check=True
            )
            return json.loads(result.stdout) if result.stdout.strip() else None
        except subprocess.CalledProcessError as e:
            self.logger.debug(f"AWS command failed: {' '.join(command)}")
            return None
        except json.JSONDecodeError:
            self.logger.debug(f"Failed to parse JSON from: {' '.join(command)}")
            return None

    def test_aws_connection(self) -> bool:
        """Verifica la conexión a AWS"""
        self.print_header("VERIFICANDO CONEXIÓN AWS")
        
        identity = self.run_aws_command(['aws', 'sts', 'get-caller-identity'])
        if identity:
            self.account_id = identity.get('Account')
            self.print_success(f"Conectado a AWS Account: {self.account_id}")
            self.print_success(f"Usuario/Role: {identity.get('Arn')}")
            return True
        else:
            self.print_error("No se pudo conectar a AWS. Verifica tus credenciales.")
            return False

    def validate_layer1_foundation(self) -> Dict[str, Any]:
        """Valida Layer 1: Foundation (IAM) - ACTUALIZADO PARA 100% COMPLIANCE"""
        self.print_header("LAYER 1 - FOUNDATION (IAM) - Enhanced Security")
        
        layer1 = {
            "name": "Foundation",
            "resources": {},
            "compliance": {},
            "status": "unknown"
        }
        
        # ====================================================================
        # 1. VERIFICAR ROL PRINCIPAL
        # ====================================================================
        role_data = self.run_aws_command([
            'aws', 'iam', 'get-role', 
            '--role-name', 'github-actions-deployment-role'
        ])
        
        if role_data:
            role = role_data['Role']
            layer1['resources']['role'] = {
                "name": "github-actions-deployment-role",
                "status": "✅ Existe",
                "last_used": role.get('RoleLastUsed', {}).get('LastUsedDate'),
                "arn": role['Arn']
            }
            self.print_success("Rol principal: github-actions-deployment-role")
            self.valid_resources += 1
        else:
            layer1['resources']['role'] = {
                "name": "github-actions-deployment-role",
                "status": "❌ No existe"
            }
            self.print_error("Rol principal no encontrado")
        
        self.total_resources += 1
        
        # ====================================================================
        # 2. VERIFICAR POLÍTICAS IAM (9 políticas consolidadas)
        # ====================================================================
        policies = [
            "dev-github-deployment-iam",
            "dev-github-deployment-network", 
            "dev-github-deployment-cloudwatch",
            "dev-github-deployment-monitoring",
            "dev-github-deployment-deployment",
            "dev-github-deployment-application",
            "dev-github-deployment-database",
            "dev-github-deployment-storage",
            "dev-github-deployment-glue"
        ]
        
        layer1['resources']['policies'] = {}
        for policy_name in policies:
            policy_arn = f"arn:aws:iam::{self.account_id}:policy/{policy_name}"
            policy_data = self.run_aws_command([
                'aws', 'iam', 'get-policy',
                '--policy-arn', policy_arn
            ])
            
            if policy_data:
                policy = policy_data['Policy']
                layer1['resources']['policies'][policy_name] = {
                    "status": "✅ Existe",
                    "arn": policy['Arn'],
                    "attachment_count": policy['AttachmentCount']
                }
                self.print_success(f"Política: {policy_name}")
                self.valid_resources += 1
            else:
                layer1['resources']['policies'][policy_name] = {
                    "status": "❌ No existe"
                }
                self.print_error(f"Política no encontrada: {policy_name}")
            
            self.total_resources += 1
        
        # ====================================================================
        # 3. VERIFICAR IAM ACCESS ANALYZER (NUEVO - 100% COMPLIANCE)
        # ====================================================================
        self.print_info("Verificando IAM Access Analyzer...")
        analyzers_data = self.run_aws_command([
            'aws', 'accessanalyzer', 'list-analyzers'
        ])
        
        if analyzers_data and analyzers_data.get('analyzers'):
            # Buscar analyzer de este environment
            env_analyzer = None
            for analyzer in analyzers_data['analyzers']:
                if 'sgsi' in analyzer['name'].lower() or 'dev' in analyzer['name'].lower():
                    env_analyzer = analyzer
                    break
            
            if env_analyzer:
                layer1['resources']['iam_access_analyzer'] = {
                    "name": env_analyzer['name'],
                    "arn": env_analyzer['arn'],
                    "type": env_analyzer['type'],
                    "status": "✅ Configurado",
                    "created": env_analyzer['createdAt']
                }
                self.print_success(f"Access Analyzer: {env_analyzer['name']} ({env_analyzer['type']})")
                self.valid_resources += 1
                
                # Compliance ISO 27001 A.9.1.1
                layer1['compliance']['ISO_27001_A911'] = "✅ Access control policy (Access Analyzer)"
            else:
                layer1['resources']['iam_access_analyzer'] = {
                    "status": "⚠️ Analyzer genérico encontrado, no específico de SGSI"
                }
                self.print_warning("Access Analyzer: No hay analyzer específico de SGSI")
                layer1['compliance']['ISO_27001_A911'] = "⚠️ Parcial"
        else:
            layer1['resources']['iam_access_analyzer'] = {
                "status": "❌ No configurado"
            }
            self.print_error("IAM Access Analyzer: No configurado")
            layer1['compliance']['ISO_27001_A911'] = "❌ No cumple"
        
        self.total_resources += 1
        
        # ====================================================================
        # 4. VERIFICAR PASSWORD POLICY (NUEVO - 100% COMPLIANCE)
        # ====================================================================
        self.print_info("Verificando Password Policy...")
        password_policy = self.run_aws_command([
            'aws', 'iam', 'get-account-password-policy'
        ])
        
        if password_policy and 'PasswordPolicy' in password_policy:
            policy = password_policy['PasswordPolicy']
            
            # Validar compliance NIST 800-63B
            compliant = (
                policy.get('MinimumPasswordLength', 0) >= 14 and
                policy.get('RequireUppercaseCharacters', False) and
                policy.get('RequireLowercaseCharacters', False) and
                policy.get('RequireNumbers', False) and
                policy.get('RequireSymbols', False) and
                policy.get('MaxPasswordAge', 0) <= 90 and
                policy.get('PasswordReusePrevention', 0) >= 12
            )
            
            layer1['resources']['password_policy'] = {
                "min_length": policy.get('MinimumPasswordLength'),
                "complexity": "✅ Completa" if all([
                    policy.get('RequireUppercaseCharacters'),
                    policy.get('RequireLowercaseCharacters'),
                    policy.get('RequireNumbers'),
                    policy.get('RequireSymbols')
                ]) else "⚠️ Parcial",
                "max_age_days": policy.get('MaxPasswordAge'),
                "reuse_prevention": policy.get('PasswordReusePrevention'),
                "status": "✅ NIST 800-63B Compliant" if compliant else "⚠️ Requiere ajustes",
                "compliance_score": 100 if compliant else 70
            }
            
            if compliant:
                self.print_success(f"Password Policy: NIST 800-63B compliant ({policy.get('MinimumPasswordLength')} chars, {policy.get('MaxPasswordAge')} días)")
                self.valid_resources += 1
                layer1['compliance']['ISO_27001_A943'] = "✅ Password management (NIST compliant)"
                layer1['compliance']['NIST_PR_AC1'] = "✅ Identity and credentials management"
            else:
                self.print_warning("Password Policy: Configurada pero no completamente conforme a NIST")
                layer1['compliance']['ISO_27001_A943'] = "⚠️ Password management (Requiere ajustes)"
                layer1['compliance']['NIST_PR_AC1'] = "⚠️ Parcial"
        else:
            layer1['resources']['password_policy'] = {
                "status": "❌ No configurada"
            }
            self.print_error("Password Policy: No configurada")
            layer1['compliance']['ISO_27001_A943'] = "❌ No cumple"
            layer1['compliance']['NIST_PR_AC1'] = "❌ No cumple"
        
        self.total_resources += 1
        
        # ====================================================================
        # 5. VERIFICAR KMS KEYS (Encryption Management)
        # ====================================================================
        self.print_info("Verificando KMS Keys...")
        kms_keys = self.run_aws_command([
            'aws', 'kms', 'list-keys'
        ])
        
        if kms_keys and kms_keys.get('Keys'):
            customer_keys = []
            for key in kms_keys['Keys'][:10]:  # Limitar a primeras 10 keys
                key_metadata = self.run_aws_command([
                    'aws', 'kms', 'describe-key',
                    '--key-id', key['KeyId']
                ])
                if key_metadata and key_metadata['KeyMetadata'].get('KeyManager') == 'CUSTOMER':
                    customer_keys.append(key_metadata['KeyMetadata'])
            
            if customer_keys:
                layer1['resources']['kms_keys'] = {
                    "count": len(customer_keys),
                    "status": f"✅ {len(customer_keys)} Customer Managed Keys",
                    "keys": [{"KeyId": k['KeyId'], "State": k['KeyState']} for k in customer_keys[:3]]
                }
                self.print_success(f"KMS Keys: {len(customer_keys)} Customer Managed Keys encontradas")
                self.valid_resources += 1
                layer1['compliance']['ISO_27001_A101'] = "✅ Cryptography (KMS)"
            else:
                layer1['resources']['kms_keys'] = {
                    "count": 0,
                    "status": "⚠️ Solo AWS Managed Keys"
                }
                self.print_warning("KMS Keys: Solo AWS Managed Keys (considerar Customer Managed)")
                layer1['compliance']['ISO_27001_A101'] = "⚠️ Usar CMKs"
        else:
            layer1['resources']['kms_keys'] = {
                "status": "❌ No accesible"
            }
            self.print_error("KMS Keys: No se pudieron listar")
            layer1['compliance']['ISO_27001_A101'] = "❌ No verificado"
        
        self.total_resources += 1
        
        # ====================================================================
        # 6. VERIFICAR BACKEND TERRAFORM (S3)
        # ====================================================================
        bucket_check = subprocess.run(
            ['aws', 's3', 'ls', 's3://terraform-state-bucket-051963532279/'],
            capture_output=True, text=True
        )
        
        if bucket_check.returncode == 0:
            layer1['resources']['terraform_backend'] = {
                "s3_bucket": "✅ terraform-state-bucket-051963532279",
                "status": "Activo"
            }
            self.print_success("Backend S3: terraform-state-bucket-051963532279")
            self.valid_resources += 1
        else:
            layer1['resources']['terraform_backend'] = {
                "status": "❌ Bucket no accesible"
            }
            self.print_error("Backend S3 no accesible")
        
        self.total_resources += 1
        
        # ====================================================================
        # 7. VERIFICAR DYNAMODB LOCKS
        # ====================================================================
        table_data = self.run_aws_command([
            'aws', 'dynamodb', 'describe-table',
            '--table-name', 'terraform-locks',
            '--region', 'us-east-1'
        ])
        
        if table_data:
            table = table_data['Table']
            layer1['resources']['dynamodb_locks'] = {
                "table": "✅ terraform-locks",
                "status": table['TableStatus'],
                "item_count": table['ItemCount']
            }
            self.print_success(f"DynamoDB Locks: terraform-locks ({table['TableStatus']})")
            self.valid_resources += 1
        else:
            layer1['resources']['dynamodb_locks'] = {
                "status": "❌ Tabla no encontrada"
            }
            self.print_error("Tabla DynamoDB locks no encontrada")
        
        self.total_resources += 1
        
        # ====================================================================
        # CALCULAR COMPLIANCE GENERAL DE LAYER 1
        # ====================================================================
        compliance_count = sum(1 for v in layer1['compliance'].values() if "✅" in v)
        total_compliance = len(layer1['compliance'])
        if total_compliance > 0:
            layer1['compliance_score'] = f"{(compliance_count / total_compliance) * 100:.0f}%"
        else:
            layer1['compliance_score'] = "0%"
        
        self.print_info(f"Compliance Score Layer 1: {layer1['compliance_score']}")
        
        return layer1

    def validate_layer2_network(self) -> Dict[str, Any]:
        """Valida Layer 2: Network (VPC) - SGSI Academic Project Requirements + Enhanced Modules"""
        self.print_header("LAYER 2 - NETWORK (Enhanced: VPC + NAT HA + Flow Logs + NACLs + Endpoints)")
        
        layer2 = {
            "name": "Network",
            "resources": {},
            "status": "unknown",
            "sgsi_compliance": {}
        }
        
        # 1. VERIFICAR VPC + SUBNETS (Segmentación de red y DMZ)
        vpcs_data = self.run_aws_command([
            'aws', 'ec2', 'describe-vpcs',
            '--filters', 'Name=cidr-block,Values=10.0.0.0/16'
        ])
        
        if vpcs_data and vpcs_data['Vpcs']:
            vpc = vpcs_data['Vpcs'][0]
            layer2['resources']['vpc'] = {
                "vpc_id": vpc['VpcId'],
                "cidr_block": vpc['CidrBlock'],
                "state": vpc['State'],
                "status": f"✅ {vpc['VpcId']} ({vpc['CidrBlock']})"
            }
            self.print_success(f"VPC: {vpc['VpcId']} - {vpc['CidrBlock']}")
            self.valid_resources += 1
            
            # Verificar subnets (DMZ + Private tiers)
            subnets_data = self.run_aws_command([
                'aws', 'ec2', 'describe-subnets',
                '--filters', f'Name=vpc-id,Values={vpc["VpcId"]}'
            ])
            
            if subnets_data:
                subnets = subnets_data['Subnets']
                layer2['resources']['subnets'] = {
                    "total": len(subnets),
                    "dmz_count": 0,
                    "private_count": 0,
                    "details": []
                }
                
                for subnet in subnets:
                    subnet_name = ""
                    for tag in subnet.get('Tags', []):
                        if tag['Key'] == 'Name':
                            subnet_name = tag['Value']
                            break
                    
                    if 'dmz' in subnet_name.lower() or 'public' in subnet_name.lower():
                        layer2['resources']['subnets']['dmz_count'] += 1
                    elif 'private' in subnet_name.lower():
                        layer2['resources']['subnets']['private_count'] += 1
                    
                    layer2['resources']['subnets']['details'].append({
                        "subnet_id": subnet['SubnetId'],
                        "name": subnet_name,
                        "cidr_block": subnet['CidrBlock'],
                        "availability_zone": subnet['AvailabilityZone'],
                        "state": subnet['State'],
                        "type": "DMZ" if 'dmz' in subnet_name.lower() or 'public' in subnet_name.lower() else "Private"
                    })
                    self.print_success(f"Subnet: {subnet['SubnetId']} - {subnet['CidrBlock']} [{subnet['AvailabilityZone']}] ({subnet_name})")
                    self.valid_resources += 1
                    self.total_resources += 1
                    
                # Evaluar segmentación SGSI
                dmz_ok = layer2['resources']['subnets']['dmz_count'] >= 2
                private_ok = layer2['resources']['subnets']['private_count'] >= 4
                layer2['sgsi_compliance']['network_segmentation'] = "✅ Completo" if (dmz_ok and private_ok) else "⚠️ Parcial"
        else:
            layer2['resources']['vpc'] = {"status": "❌ VPC no encontrada"}
            self.print_error("VPC con CIDR 10.0.0.0/16 no encontrada")
        
        self.total_resources += 1
        
        # 2. VERIFICAR SECURITY GROUPS (Firewalls nivel aplicación)
        sg_data = self.run_aws_command([
            'aws', 'ec2', 'describe-security-groups',
            '--filters', 'Name=group-name,Values=sgsi*'
        ])
        
        if sg_data and sg_data['SecurityGroups']:
            sgs = sg_data['SecurityGroups']
            layer2['resources']['security_groups'] = {
                "total": len(sgs),
                "details": []
            }
            
            required_sgs = ['alb', 'web', 'app', 'db', 'mgmt']
            found_sgs = []
            
            for sg in sgs:
                sg_type = "Unknown"
                for req_sg in required_sgs:
                    if req_sg in sg['GroupName'].lower():
                        sg_type = req_sg.upper()
                        found_sgs.append(req_sg)
                        break
                
                layer2['resources']['security_groups']['details'].append({
                    "group_id": sg['GroupId'],
                    "group_name": sg['GroupName'],
                    "description": sg['Description'],
                    "type": sg_type,
                    "rules_count": len(sg.get('IpPermissions', []))
                })
                self.print_success(f"Security Group: {sg['GroupName']} ({sg['GroupId']}) - {sg_type} Tier")
                self.valid_resources += 1
                self.total_resources += 1
            
            # Evaluar cobertura de Security Groups
            sg_coverage = len(set(found_sgs)) / len(required_sgs) * 100
            layer2['sgsi_compliance']['security_groups'] = f"✅ {sg_coverage:.0f}% cobertura" if sg_coverage >= 80 else f"⚠️ {sg_coverage:.0f}% cobertura"
        else:
            layer2['resources']['security_groups'] = {"status": "❌ Security Groups no encontrados"}
            layer2['sgsi_compliance']['security_groups'] = "❌ No implementado"
            self.print_error("Security Groups SGSI no encontrados")
        
        # 3. VERIFICAR NACLS (Network Access Control Lists)
        nacl_data = self.run_aws_command([
            'aws', 'ec2', 'describe-network-acls',
            '--filters', f'Name=vpc-id,Values={vpc["VpcId"]}' if vpcs_data and vpcs_data['Vpcs'] else 'Name=tag:Name,Values=sgsi*'
        ])
        
        if nacl_data and nacl_data['NetworkAcls']:
            custom_nacls = [nacl for nacl in nacl_data['NetworkAcls'] if not nacl.get('IsDefault', True)]
            if custom_nacls:
                layer2['resources']['nacls'] = {
                    "total": len(custom_nacls),
                    "status": f"✅ {len(custom_nacls)} NACLs personalizados"
                }
                layer2['sgsi_compliance']['nacls'] = "✅ Implementado"
                self.print_success(f"NACLs: {len(custom_nacls)} personalizados encontrados")
                self.valid_resources += 1
            else:
                layer2['resources']['nacls'] = {"status": "⚠️ Solo NACL por defecto"}
                layer2['sgsi_compliance']['nacls'] = "⚠️ Solo por defecto"
                self.print_warning("NACLs: Solo se encontró el NACL por defecto")
        else:
            layer2['resources']['nacls'] = {"status": "❌ No se pudieron verificar"}
            layer2['sgsi_compliance']['nacls'] = "❌ No verificado"
            self.print_error("No se pudieron verificar NACLs")
        
        self.total_resources += 1
        
        # 4. VERIFICAR ROUTE53 (DNS)
        route53_data = self.run_aws_command([
            'aws', 'route53', 'list-hosted-zones'
        ])
        
        if route53_data and route53_data['HostedZones']:
            sgsi_zones = [zone for zone in route53_data['HostedZones'] if 'sgsi' in zone['Name'].lower()]
            if sgsi_zones:
                layer2['resources']['route53'] = {
                    "zones": len(sgsi_zones),
                    "status": f"✅ {len(sgsi_zones)} zonas DNS"
                }
                layer2['sgsi_compliance']['dns'] = "✅ Implementado"
                self.print_success(f"Route53: {len(sgsi_zones)} zonas DNS del proyecto")
                self.valid_resources += 1
            else:
                layer2['resources']['route53'] = {"status": "⚠️ Sin zonas SGSI específicas"}
                layer2['sgsi_compliance']['dns'] = "⚠️ Sin zonas del proyecto"
                self.print_warning("Route53: Sin zonas DNS específicas del proyecto SGSI")
        else:
            layer2['resources']['route53'] = {"status": "❌ Route53 no configurado"}
            layer2['sgsi_compliance']['dns'] = "❌ No implementado"
            self.print_error("Route53: No configurado")
        
        self.total_resources += 1
        
        # 5. VERIFICAR VPN/DIRECTCONNECT
        vpn_data = self.run_aws_command([
            'aws', 'ec2', 'describe-vpn-connections'
        ])
        
        dx_data = self.run_aws_command([
            'aws', 'directconnect', 'describe-connections'
        ])
        
        has_vpn = vpn_data and vpn_data['VpnConnections']
        has_dx = dx_data and dx_data['connections']
        
        if has_vpn or has_dx:
            connectivity_type = []
            if has_vpn:
                connectivity_type.append(f"VPN ({len(vpn_data['VpnConnections'])})")
            if has_dx:
                connectivity_type.append(f"DirectConnect ({len(dx_data['connections'])})")
            
            layer2['resources']['hybrid_connectivity'] = {
                "types": connectivity_type,
                "status": f"✅ {' + '.join(connectivity_type)}"
            }
            layer2['sgsi_compliance']['hybrid_connectivity'] = "✅ Implementado"
            self.print_success(f"Conectividad híbrida: {' + '.join(connectivity_type)}")
            self.valid_resources += 1
        else:
            layer2['resources']['hybrid_connectivity'] = {"status": "❌ Sin conectividad híbrida"}
            layer2['sgsi_compliance']['hybrid_connectivity'] = "❌ No implementado"
            self.print_error("Conectividad híbrida: No configurada (VPN/DirectConnect)")
        
        self.total_resources += 1
        
        # 6. VERIFICAR VPC FLOW LOGS
        flowlogs_data = self.run_aws_command([
            'aws', 'logs', 'describe-log-groups',
            '--log-group-name-prefix', '/aws/vpc/flowlogs'
        ])
        
        if flowlogs_data and flowlogs_data['logGroups']:
            flowlog = flowlogs_data['logGroups'][0]
            retention_days = flowlog.get('retentionInDays', 'No definido')
            layer2['resources']['vpc_flow_logs'] = {
                "log_group": flowlog['logGroupName'],
                "retention": f"{retention_days} días" if isinstance(retention_days, int) else retention_days,
                "status": f"✅ Habilitado ({retention_days} días retención)"
            }
            layer2['sgsi_compliance']['flow_logs'] = f"✅ Habilitado ({retention_days} días)"
            self.print_success(f"VPC Flow Logs: {flowlog['logGroupName']} - Retención: {retention_days} días")
            self.valid_resources += 1
        else:
            layer2['resources']['vpc_flow_logs'] = {"status": "❌ No configurado"}
            layer2['sgsi_compliance']['flow_logs'] = "❌ No implementado"
            self.print_error("VPC Flow Logs: No configurado")
        
        self.total_resources += 1
        
        # 7. VERIFICAR NAT GATEWAYS (High Availability)
        nat_data = self.run_aws_command([
            'aws', 'ec2', 'describe-nat-gateways',
            '--filter', 'Name=state,Values=available'
        ])
        
        if nat_data and nat_data['NatGateways']:
            nat_gateways = [ng for ng in nat_data['NatGateways'] if any(tag.get('Key') == 'Name' and 'sgsi' in tag.get('Value', '').lower() for tag in ng.get('Tags', []))]
            if len(nat_gateways) >= 2:
                azs = list(set([ng['SubnetId'] for ng in nat_gateways]))
                public_ips = [ng['NatGatewayAddresses'][0]['PublicIp'] for ng in nat_gateways if ng.get('NatGatewayAddresses')]
                layer2['resources']['nat_gateways'] = {
                    "count": len(nat_gateways),
                    "availability_zones": len(azs),
                    "public_ips": public_ips,
                    "status": f"✅ Multi-AZ ({len(nat_gateways)} NAT Gateways en {len(azs)} AZs)"
                }
                layer2['sgsi_compliance']['nat_gateway_ha'] = f"✅ Multi-AZ ({len(nat_gateways)} NAT Gateways)"
                self.print_success(f"NAT Gateways: {len(nat_gateways)} en {len(azs)} AZs - IPs: {', '.join(public_ips)}")
                self.valid_resources += 1
            elif len(nat_gateways) == 1:
                layer2['resources']['nat_gateways'] = {
                    "count": 1,
                    "status": "⚠️ Solo 1 NAT Gateway (sin HA)"
                }
                layer2['sgsi_compliance']['nat_gateway_ha'] = "⚠️ Sin Alta Disponibilidad"
                self.print_warning("NAT Gateways: Solo 1 encontrado (recomendado 2+ para HA)")
            else:
                layer2['resources']['nat_gateways'] = {"status": "❌ No configurado"}
                layer2['sgsi_compliance']['nat_gateway_ha'] = "❌ No implementado"
                self.print_error("NAT Gateways: No encontrados")
        else:
            layer2['resources']['nat_gateways'] = {"status": "❌ No configurado"}
            layer2['sgsi_compliance']['nat_gateway_ha'] = "❌ No implementado"
            self.print_error("NAT Gateways: No configurado")
        
        self.total_resources += 1
        
        # 8. VERIFICAR VPC ENDPOINTS (S3, DynamoDB)
        endpoints_data = self.run_aws_command([
            'aws', 'ec2', 'describe-vpc-endpoints',
            '--filters', f'Name=vpc-id,Values={vpc["VpcId"]}' if vpcs_data and vpcs_data['Vpcs'] else 'Name=tag:Name,Values=sgsi*'
        ])
        
        if endpoints_data and endpoints_data['VpcEndpoints']:
            gateway_endpoints = [ep for ep in endpoints_data['VpcEndpoints'] if ep['VpcEndpointType'] == 'Gateway']
            interface_endpoints = [ep for ep in endpoints_data['VpcEndpoints'] if ep['VpcEndpointType'] == 'Interface']
            
            services = [ep['ServiceName'].split('.')[-1] for ep in gateway_endpoints]
            
            if len(gateway_endpoints) >= 2 and 's3' in services and 'dynamodb' in services:
                layer2['resources']['vpc_endpoints'] = {
                    "gateway": len(gateway_endpoints),
                    "interface": len(interface_endpoints),
                    "services": services,
                    "status": f"✅ Gateway Endpoints ({', '.join(services)})"
                }
                layer2['sgsi_compliance']['vpc_endpoints'] = f"✅ Gateway Endpoints ({len(gateway_endpoints)})"
                self.print_success(f"VPC Endpoints: {len(gateway_endpoints)} Gateway ({', '.join(services)}), {len(interface_endpoints)} Interface")
                self.valid_resources += 1
            elif len(gateway_endpoints) > 0:
                layer2['resources']['vpc_endpoints'] = {
                    "gateway": len(gateway_endpoints),
                    "status": f"⚠️ {len(gateway_endpoints)} Gateway Endpoints (recomendado: S3 + DynamoDB)"
                }
                layer2['sgsi_compliance']['vpc_endpoints'] = "⚠️ Implementación parcial"
                self.print_warning(f"VPC Endpoints: {len(gateway_endpoints)} encontrados (recomendado: S3 + DynamoDB)")
            else:
                layer2['resources']['vpc_endpoints'] = {"status": "❌ No configurado"}
                layer2['sgsi_compliance']['vpc_endpoints'] = "❌ No implementado"
                self.print_error("VPC Endpoints: No configurados")
        else:
            layer2['resources']['vpc_endpoints'] = {"status": "❌ No configurado"}
            layer2['sgsi_compliance']['vpc_endpoints'] = "❌ No implementado"
            self.print_error("VPC Endpoints: No configurados")
        
        self.total_resources += 1
        
        # EVALUAR COMPLIANCE GENERAL LAYER 2
        compliance_scores = []
        for key, value in layer2['sgsi_compliance'].items():
            if "✅" in value:
                compliance_scores.append(100)
            elif "⚠️" in value:
                compliance_scores.append(70)
            else:
                compliance_scores.append(0)
        
        overall_compliance = sum(compliance_scores) / len(compliance_scores) if compliance_scores else 0
        layer2['sgsi_compliance']['overall'] = f"{overall_compliance:.0f}%"
        
        return layer2

    def validate_layer3_compute(self) -> Dict[str, Any]:
        """Valida Layer 3: Compute (ALB, ASG, RDS, Lambda)"""
        self.print_header("LAYER 3 - COMPUTE (ALB, ASG, RDS, Lambda)")
        
        layer3 = {
            "name": "Compute",
            "resources": {},
            "status": "unknown"
        }
        
        # Verificar Application Load Balancer (DESHABILITADO - restricción cuenta AWS)
        # Buscar cualquier ALB con 'sgsi' en el nombre
        alb_data = self.run_aws_command([
            'aws', 'elbv2', 'describe-load-balancers'
        ])
        
        alb_found = False
        if alb_data and alb_data.get('LoadBalancers'):
            for alb in alb_data['LoadBalancers']:
                if 'sgsi' in alb['LoadBalancerName'].lower():
                    layer3['resources']['alb'] = {
                        "name": alb['LoadBalancerName'],
                        "arn": alb['LoadBalancerArn'],
                        "state": alb['State']['Code'],
                        "type": alb['Type'],
                        "scheme": alb['Scheme'],
                        "status": f"✅ {alb['LoadBalancerName']} ({alb['State']['Code']})"
                    }
                    self.print_success(f"ALB: {alb['LoadBalancerName']} - {alb['State']['Code']}")
                    self.valid_resources += 1
                    alb_found = True
                    break
        
        if not alb_found:
            layer3['resources']['alb'] = {"status": "⚠️ ALB no desplegado (restricción cuenta AWS)"}
            self.print_warning("ALB: No desplegado - restricción de cuenta AWS Academy")
        
        self.total_resources += 1
        
        # Verificar Auto Scaling Group
        asg_data = self.run_aws_command([
            'aws', 'autoscaling', 'describe-auto-scaling-groups',
            '--auto-scaling-group-names', 'sgsi-dev-asg'
        ])
        
        if asg_data and asg_data['AutoScalingGroups']:
            asg = asg_data['AutoScalingGroups'][0]
            instance_count = len(asg['Instances'])
            layer3['resources']['asg'] = {
                "name": asg['AutoScalingGroupName'],
                "min_size": asg['MinSize'],
                "max_size": asg['MaxSize'],
                "desired_capacity": asg['DesiredCapacity'],
                "instances": instance_count,
                "status": f"✅ {asg['AutoScalingGroupName']} ({instance_count}/{asg['DesiredCapacity']} instances)"
            }
            self.print_success(f"ASG: {asg['AutoScalingGroupName']} - {instance_count}/{asg['DesiredCapacity']} instances")
            self.valid_resources += 1
        else:
            layer3['resources']['asg'] = {"status": "❌ ASG no encontrado"}
            self.print_error("ASG sgsi-dev-asg no encontrado")
        
        self.total_resources += 1
        
        # Verificar RDS Database
        rds_data = self.run_aws_command([
            'aws', 'rds', 'describe-db-instances',
            '--db-instance-identifier', 'sgsi-dev-db'
        ])
        
        if rds_data and rds_data['DBInstances']:
            db = rds_data['DBInstances'][0]
            layer3['resources']['rds'] = {
                "db_instance_identifier": db['DBInstanceIdentifier'],
                "engine": f"{db['Engine']} {db['EngineVersion']}",
                "db_instance_class": db['DBInstanceClass'],
                "db_instance_status": db['DBInstanceStatus'],
                "allocated_storage": db['AllocatedStorage'],
                "multi_az": db.get('MultiAZ', False),
                "encrypted": db.get('StorageEncrypted', False),
                "status": f"✅ {db['DBInstanceIdentifier']} ({db['DBInstanceStatus']}) - Multi-AZ: {db.get('MultiAZ', False)}"
            }
            self.print_success(f"RDS: {db['DBInstanceIdentifier']} - {db['Engine']} {db['EngineVersion']} [{db['DBInstanceStatus']}] Multi-AZ: {db.get('MultiAZ', False)}")
            self.valid_resources += 1
        else:
            layer3['resources']['rds'] = {"status": "❌ RDS no encontrado"}
            self.print_error("RDS sgsi-dev-db no encontrado")
        
        self.total_resources += 1
        
        # Verificar Lambda Function
        lambda_data = self.run_aws_command([
            'aws', 'lambda', 'get-function',
            '--function-name', 'sgsi-api-handler'
        ])
        
        if lambda_data:
            config = lambda_data['Configuration']
            layer3['resources']['lambda'] = {
                "function_name": config['FunctionName'],
                "runtime": config['Runtime'],
                "state": config['State'],
                "last_modified": config['LastModified'],
                "status": f"✅ {config['FunctionName']} ({config['State']})"
            }
            self.print_success(f"Lambda: {config['FunctionName']} - {config['Runtime']} [{config['State']}]")
            self.valid_resources += 1
        else:
            layer3['resources']['lambda'] = {"status": "❌ Lambda no encontrado"}
            self.print_error("Lambda sgsi-api-handler no encontrado")
        
        self.total_resources += 1
        
        return layer3

    def validate_layer4_storage(self) -> Dict[str, Any]:
        """Valida Layer 4: Storage (S3, EFS, Backup)"""
        self.print_header("LAYER 4 - STORAGE (S3, EFS, Backup)")
        
        layer4 = {
            "name": "Storage",
            "resources": {},
            "status": "unknown"
        }
        
        # ==================== S3 BUCKETS ====================
        buckets_data = self.run_aws_command(['aws', 's3api', 'list-buckets'])
        
        if buckets_data:
            all_buckets = buckets_data['Buckets']
            sgsi_buckets = [b for b in all_buckets if 'sgsi-dev' in b['Name'].lower()]
            
            layer4['resources']['s3_buckets'] = {
                "total": len(sgsi_buckets),
                "details": []
            }
            
            for bucket in sgsi_buckets:
                # Verificar versioning
                versioning = self.run_aws_command([
                    'aws', 's3api', 'get-bucket-versioning',
                    '--bucket', bucket['Name']
                ])
                
                # Verificar encryption
                encryption = self.run_aws_command([
                    'aws', 's3api', 'get-bucket-encryption',
                    '--bucket', bucket['Name']
                ])
                
                bucket_info = {
                    "name": bucket['Name'],
                    "versioning": versioning.get('Status', 'Disabled') if versioning else 'Disabled',
                    "encrypted": encryption is not None,
                    "status": f"✅ {bucket['Name']}"
                }
                
                layer4['resources']['s3_buckets']['details'].append(bucket_info)
                self.print_success(f"S3: {bucket['Name']} (Versioning: {bucket_info['versioning']}, Encrypted: {bucket_info['encrypted']})")
                self.valid_resources += 1
                self.total_resources += 1
        
        # ==================== EFS ====================
        efs_data = self.run_aws_command([
            'aws', 'efs', 'describe-file-systems',
            '--query', 'FileSystems[?contains(to_string(Tags[?Key==`Name`].Value), `sgsi`)]'
        ])
        
        if efs_data and isinstance(efs_data, list) and len(efs_data) > 0:
            for fs in efs_data:
                # Verificar mount targets
                mount_targets = self.run_aws_command([
                    'aws', 'efs', 'describe-mount-targets',
                    '--file-system-id', fs['FileSystemId']
                ])
                
                num_mount_targets = len(mount_targets.get('MountTargets', [])) if mount_targets else 0
                
                layer4['resources']['efs'] = {
                    "file_system_id": fs['FileSystemId'],
                    "encrypted": fs.get('Encrypted', False),
                    "performance_mode": fs.get('PerformanceMode', 'unknown'),
                    "throughput_mode": fs.get('ThroughputMode', 'unknown'),
                    "mount_targets": num_mount_targets,
                    "lifecycle_policies": len(fs.get('LifeCyclePolicies', [])),
                    "status": f"✅ {fs['FileSystemId']} - Multi-AZ: {num_mount_targets > 1}"
                }
                
                self.print_success(f"EFS: {fs['FileSystemId']} ({fs.get('PerformanceMode')}, {num_mount_targets} mount targets, Encrypted: {fs.get('Encrypted')})")
                self.valid_resources += 1
                self.total_resources += 1
        else:
            layer4['resources']['efs'] = {"status": "❌ EFS no encontrado"}
            self.print_error("EFS sgsi-dev-efs no encontrado")
        
        # ==================== AWS BACKUP ====================
        # Verificar Backup Vault
        backup_vault_data = self.run_aws_command([
            'aws', 'backup', 'list-backup-vaults'
        ])
        
        if backup_vault_data and backup_vault_data.get('BackupVaultList'):
            sgsi_vaults = [v for v in backup_vault_data['BackupVaultList'] if 'sgsi-dev-vault' in v['BackupVaultName']]
            
            if sgsi_vaults:
                vault = sgsi_vaults[0]
                
                # Verificar Backup Plan
                backup_plans = self.run_aws_command([
                    'aws', 'backup', 'list-backup-plans'
                ])
                
                plan_count = 0
                if backup_plans and backup_plans.get('BackupPlansList'):
                    sgsi_plans = [p for p in backup_plans['BackupPlansList'] if 'sgsi-dev-plan' in p['BackupPlanName']]
                    plan_count = len(sgsi_plans)
                
                layer4['resources']['backup'] = {
                    "vault_name": vault['BackupVaultName'],
                    "vault_arn": vault['BackupVaultArn'],
                    "recovery_points": vault.get('NumberOfRecoveryPoints', 0),
                    "encrypted": vault.get('EncryptionKeyArn') is not None or vault.get('Encrypted', False),
                    "backup_plans": plan_count,
                    "status": f"✅ {vault['BackupVaultName']} ({vault.get('NumberOfRecoveryPoints', 0)} recovery points)"
                }
                
                self.print_success(f"AWS Backup: {vault['BackupVaultName']} ({plan_count} plan(s), {vault.get('NumberOfRecoveryPoints', 0)} recovery points)")
                self.valid_resources += 1
                self.total_resources += 1
            else:
                layer4['resources']['backup'] = {"status": "❌ Backup Vault no encontrado"}
                self.print_error("AWS Backup Vault sgsi-dev-vault no encontrado")
        else:
            layer4['resources']['backup'] = {"status": "❌ AWS Backup no configurado"}
            self.print_error("AWS Backup no configurado")
        
        return layer4

    def validate_layer5_observability(self) -> Dict[str, Any]:
        """Valida Layer 5: Observability (SIEM, Monitoring, Detection) - SGSI Requirements"""
        self.print_header("LAYER 5 - OBSERVABILITY (SIEM + IDS/IPS + Monitoring)")
        
        layer5 = {
            "name": "Observability",
            "resources": {},
            "status": "unknown",
            "sgsi_compliance": {}
        }
        
        # Verificar CloudWatch Log Groups
        log_groups_data = self.run_aws_command([
            'aws', 'logs', 'describe-log-groups',
            '--log-group-name-prefix', '/aws/lambda/sgsi'
        ])
        
        if log_groups_data and log_groups_data['logGroups']:
            layer5['resources']['cloudwatch_logs'] = {
                "total": len(log_groups_data['logGroups']),
                "details": []
            }
            
            for lg in log_groups_data['logGroups']:
                layer5['resources']['cloudwatch_logs']['details'].append({
                    "log_group_name": lg['logGroupName'],
                    "creation_time": lg['creationTime'],
                    "stored_bytes": lg.get('storedBytes', 0),
                    "status": "✅ Activo"
                })
                self.print_success(f"CloudWatch Logs: {lg['logGroupName']}")
                self.valid_resources += 1
                self.total_resources += 1
        
        # Verificar CloudTrail
        trails_data = self.run_aws_command(['aws', 'cloudtrail', 'describe-trails'])
        
        if trails_data and trails_data['trailList']:
            layer5['resources']['cloudtrail'] = {
                "total": len(trails_data['trailList']),
                "details": []
            }
            
            for trail in trails_data['trailList']:
                status_data = self.run_aws_command([
                    'aws', 'cloudtrail', 'get-trail-status',
                    '--name', trail['Name']
                ])
                
                is_logging = status_data.get('IsLogging', False) if status_data else False
                
                layer5['resources']['cloudtrail']['details'].append({
                    "name": trail['Name'],
                    "s3_bucket_name": trail.get('S3BucketName'),
                    "is_logging": is_logging,
                    "status": "✅ Activo" if is_logging else "⚠️ Inactivo"
                })
                status_text = "Logging" if is_logging else "Not Logging"
                self.print_success(f"CloudTrail: {trail['Name']} - {status_text}")
                self.valid_resources += 1
                self.total_resources += 1
        
        # VERIFICAR GUARDDUTY (IDS/IPS) - Requerimiento SGSI
        detectors_data = self.run_aws_command(['aws', 'guardduty', 'list-detectors'])
        
        if detectors_data and detectors_data['DetectorIds']:
            layer5['resources']['guardduty'] = {
                "total": len(detectors_data['DetectorIds']),
                "details": []
            }
            
            for detector_id in detectors_data['DetectorIds']:
                detector_data = self.run_aws_command([
                    'aws', 'guardduty', 'get-detector',
                    '--detector-id', detector_id
                ])
                
                if detector_data:
                    layer5['resources']['guardduty']['details'].append({
                        "detector_id": detector_id,
                        "status": detector_data.get('Status'),
                        "service_role": detector_data.get('ServiceRole'),
                        "finding_frequency": detector_data.get('FindingPublishingFrequency')
                    })
                    self.print_success(f"GuardDuty: {detector_id} - {detector_data.get('Status')}")
                    self.valid_resources += 1
                    self.total_resources += 1
            
            layer5['sgsi_compliance']['ids_ips'] = "✅ GuardDuty habilitado (IDS/IPS)"
        else:
            layer5['resources']['guardduty'] = {"status": "❌ GuardDuty no habilitado"}
            layer5['sgsi_compliance']['ids_ips'] = "❌ Sin IDS/IPS (Requerido por SGSI)"
            self.print_error("GuardDuty: No habilitado (requerido para IDS/IPS)")
        
        # VERIFICAR AWS SECURITY HUB (SIEM centralizado) - Requerimiento SGSI
        securityhub_data = self.run_aws_command(['aws', 'securityhub', 'describe-hub'])
        
        if securityhub_data:
            layer5['resources']['security_hub'] = {
                "hub_arn": securityhub_data.get('HubArn'),
                "status": "✅ Security Hub habilitado",
                "subscribed_at": securityhub_data.get('SubscribedAt')
            }
            layer5['sgsi_compliance']['siem'] = "✅ Security Hub (SIEM)"
            self.print_success("Security Hub: Habilitado (SIEM centralizado)")
            self.valid_resources += 1
        else:
            layer5['resources']['security_hub'] = {"status": "❌ Security Hub no habilitado"}
            layer5['sgsi_compliance']['siem'] = "❌ Sin SIEM centralizado (Requerido por SGSI)"
            self.print_error("Security Hub: No habilitado (requerido para SIEM)")
        
        self.total_resources += 1
        
        # VERIFICAR AWS CONFIG (Compliance monitoring) - Requerimiento SGSI
        config_data = self.run_aws_command(['aws', 'configservice', 'describe-configuration-recorders'])
        
        if config_data and config_data['ConfigurationRecorders']:
            active_recorders = [r for r in config_data['ConfigurationRecorders'] if r.get('recordingGroup', {}).get('allSupported', False)]
            if active_recorders:
                layer5['resources']['aws_config'] = {
                    "recorders": len(active_recorders),
                    "status": f"✅ {len(active_recorders)} Config Recorders activos"
                }
                layer5['sgsi_compliance']['compliance_monitoring'] = "✅ AWS Config habilitado"
                self.print_success(f"AWS Config: {len(active_recorders)} recorders activos")
                self.valid_resources += 1
            else:
                layer5['resources']['aws_config'] = {"status": "⚠️ Config sin grabación completa"}
                layer5['sgsi_compliance']['compliance_monitoring'] = "⚠️ Config parcial"
                self.print_warning("AWS Config: Sin grabación completa de recursos")
        else:
            layer5['resources']['aws_config'] = {"status": "❌ AWS Config no configurado"}
            layer5['sgsi_compliance']['compliance_monitoring'] = "❌ Sin monitoreo compliance (Requerido por SGSI)"
            self.print_error("AWS Config: No configurado")
        
        self.total_resources += 1
        
        # EVALUAR COMPLIANCE GENERAL LAYER 5 PARA SGSI
        compliance_items = layer5.get('sgsi_compliance', {})
        if compliance_items:
            compliance_scores = []
            for key, value in compliance_items.items():
                if "✅" in str(value):
                    compliance_scores.append(100)
                elif "⚠️" in str(value):
                    compliance_scores.append(70)
                else:
                    compliance_scores.append(0)
            
            overall_compliance = sum(compliance_scores) / len(compliance_scores) if compliance_scores else 0
            layer5['sgsi_compliance']['overall'] = f"{overall_compliance:.0f}%"
        
        return layer5

    def generate_summary(self):
        """Genera resumen de la validación con enfoque SGSI"""
        self.print_header("RESUMEN DE VALIDACIÓN SGSI")
        
        success_rate = (self.valid_resources / self.total_resources * 100) if self.total_resources > 0 else 0
        
        print(f"\n{Colors.YELLOW}📊 ESTADÍSTICAS GENERALES:{Colors.END}")
        print(f"   Total Recursos Verificados: {self.total_resources}")
        print(f"{Colors.GREEN}   Recursos Válidos: {self.valid_resources}{Colors.END}")
        print(f"{Colors.RED}   Recursos con Problemas: {self.total_resources - self.valid_resources}{Colors.END}")
        
        color = Colors.GREEN if success_rate >= 80 else Colors.YELLOW if success_rate >= 60 else Colors.RED
        print(f"{color}   Tasa de Éxito: {success_rate:.2f}%{Colors.END}")
        
        print(f"\n{Colors.YELLOW}🏗️ ESTADO POR LAYER:{Colors.END}")
        for layer_key in sorted(self.validation_results.keys()):
            layer = self.validation_results[layer_key]
            resource_count = len(layer['resources'])
            
            # Mostrar compliance SGSI si está disponible
            sgsi_info = ""
            if 'sgsi_compliance' in layer and 'overall' in layer['sgsi_compliance']:
                compliance_pct = layer['sgsi_compliance']['overall']
                compliance_color = Colors.GREEN if '100%' in compliance_pct or '90%' in compliance_pct or '80%' in compliance_pct else Colors.YELLOW if '70%' in compliance_pct or '60%' in compliance_pct else Colors.RED
                sgsi_info = f" {compliance_color}(SGSI: {compliance_pct}){Colors.END}"
            
            print(f"   {layer_key} ({layer['name']}): {resource_count} recursos verificados{sgsi_info}")
        
        # RESUMEN ESPECÍFICO SGSI
        print(f"\n{Colors.CYAN}🎓 COMPLIANCE PROYECTO SGSI ACADÉMICO:{Colors.END}")
        print(f"   {Colors.BOLD}Requerimientos evaluados:{Colors.END}")
        
        sgsi_requirements = {
            "Segmentación de red y DMZ": False,
            "Security Groups (Firewall)": False, 
            "Firewalls NGFW/IDS/IPS": False,
            "SIEM (Herramientas monitoreo)": False,
            "IAM y Zero Trust": False,
            "Redundancia y HA": False
        }
        
        # Evaluar cada requerimiento
        for layer_key, layer in self.validation_results.items():
            if 'sgsi_compliance' in layer:
                compliance = layer['sgsi_compliance']
                
                if layer_key == 'layer1':
                    sgsi_requirements["IAM y Zero Trust"] = True
                elif layer_key == 'layer2':
                    if 'network_segmentation' in compliance and '✅' in str(compliance.get('network_segmentation', '')):
                        sgsi_requirements["Segmentación de red y DMZ"] = True
                    if 'security_groups' in compliance and '✅' in str(compliance.get('security_groups', '')):
                        sgsi_requirements["Security Groups (Firewall)"] = True
                elif layer_key == 'layer5':
                    if 'ids_ips' in compliance and '✅' in str(compliance.get('ids_ips', '')):
                        sgsi_requirements["Firewalls NGFW/IDS/IPS"] = True
                    if 'siem' in compliance and '✅' in str(compliance.get('siem', '')):
                        sgsi_requirements["SIEM (Herramientas monitoreo)"] = True
        
        # Mostrar resultados SGSI
        sgsi_completed = 0
        for requirement, status in sgsi_requirements.items():
            icon = "✅" if status else "❌"
            color = Colors.GREEN if status else Colors.RED
            print(f"   {color}{icon} {requirement}{Colors.END}")
            if status:
                sgsi_completed += 1
        
        sgsi_percentage = (sgsi_completed / len(sgsi_requirements)) * 100
        sgsi_color = Colors.GREEN if sgsi_percentage >= 80 else Colors.YELLOW if sgsi_percentage >= 60 else Colors.RED
        print(f"\n   {sgsi_color}📈 Compliance SGSI General: {sgsi_percentage:.0f}% ({sgsi_completed}/{len(sgsi_requirements)} requisitos){Colors.END}")
        
        # Recomendaciones
        if sgsi_percentage < 100:
            print(f"\n{Colors.YELLOW}💡 RECOMENDACIONES PARA COMPLETAR SGSI:{Colors.END}")
            if not sgsi_requirements["Firewalls NGFW/IDS/IPS"]:
                print(f"   • Habilitar GuardDuty para cumplir con IDS/IPS")
            if not sgsi_requirements["SIEM (Herramientas monitoreo)"]:
                print(f"   • Habilitar Security Hub para SIEM centralizado")
            if sgsi_completed == 0:
                print(f"   • Desplegar Layer 3 (Compute) y Layer 5 (Observability)")
                print(f"   • Completar configuraciones de seguridad pendientes")

    def save_json_report(self, filename: str):
        """Guarda reporte en formato JSON"""
        report = {
            "timestamp": datetime.now().isoformat(),
            "account_id": self.account_id,
            "total_resources": self.total_resources,
            "valid_resources": self.valid_resources,
            "success_rate": (self.valid_resources / self.total_resources * 100) if self.total_resources > 0 else 0,
            "layers": self.validation_results
        }
        
        with open(filename, 'w', encoding='utf-8') as f:
            json.dump(report, f, indent=2, default=str)
        
        self.print_success(f"Reporte JSON generado: {filename}")

    def save_html_report(self, filename: str):
        """Guarda reporte en formato HTML"""
        success_rate = (self.valid_resources / self.total_resources * 100) if self.total_resources > 0 else 0
        
        html_content = f"""
<!DOCTYPE html>
<html>
<head>
    <title>SGSI Infrastructure Validation Report</title>
    <meta charset="utf-8">
    <style>
        body {{ font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif; margin: 0; padding: 20px; background: #f5f5f5; }}
        .header {{ background: #2c3e50; color: white; padding: 30px; border-radius: 10px; margin-bottom: 30px; }}
        .header h1 {{ margin: 0; font-size: 2.5em; }}
        .stats {{ display: flex; gap: 20px; margin: 20px 0; }}
        .stat-box {{ background: white; padding: 20px; border-radius: 8px; box-shadow: 0 2px 4px rgba(0,0,0,0.1); flex: 1; }}
        .layer {{ margin: 20px 0; padding: 20px; background: white; border-radius: 8px; box-shadow: 0 2px 4px rgba(0,0,0,0.1); }}
        .layer h3 {{ margin-top: 0; color: #2c3e50; border-bottom: 2px solid #3498db; padding-bottom: 10px; }}
        .success {{ color: #27ae60; }}
        .error {{ color: #e74c3c; }}
        .warning {{ color: #f39c12; }}
        .resource {{ margin: 10px 0; padding: 10px; background: #f8f9fa; border-left: 4px solid #3498db; }}
    </style>
</head>
<body>
    <div class="header">
        <h1>🔍 SGSI Infrastructure Validation Report</h1>
        <p><strong>Generated:</strong> {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}</p>
        <p><strong>AWS Account:</strong> {self.account_id}</p>
        <p><strong>Success Rate:</strong> {success_rate:.2f}%</p>
    </div>
    
    <div class="stats">
        <div class="stat-box">
            <h3>Total Resources</h3>
            <p style="font-size: 2em; margin: 0; color: #3498db;">{self.total_resources}</p>
        </div>
        <div class="stat-box">
            <h3>Valid Resources</h3>
            <p style="font-size: 2em; margin: 0; color: #27ae60;">{self.valid_resources}</p>
        </div>
        <div class="stat-box">
            <h3>Issues</h3>
            <p style="font-size: 2em; margin: 0; color: #e74c3c;">{self.total_resources - self.valid_resources}</p>
        </div>
    </div>
    
    <div class="content">
"""
        
        for layer_key in sorted(self.validation_results.keys()):
            layer = self.validation_results[layer_key]
            html_content += f"""
        <div class="layer">
            <h3>{layer_key.upper()}: {layer['name']}</h3>
"""
            
            for resource_name, resource_data in layer['resources'].items():
                status = resource_data.get('status', 'Unknown')
                html_content += f"""
            <div class="resource">
                <strong>{resource_name.replace('_', ' ').title()}:</strong> {status}
            </div>
"""
            
            html_content += "        </div>\n"
        
        html_content += """
    </div>
</body>
</html>
"""
        
        with open(filename, 'w', encoding='utf-8') as f:
            f.write(html_content)
        
        self.print_success(f"Reporte HTML generado: {filename}")

    def validate_layers(self, specific_layer: Optional[int] = None):
        """Ejecuta la validación de layers"""
        print(f"\n{'='*60}")
        print(f"{Colors.BOLD}{Colors.WHITE}🔍 VALIDACIÓN SGSI - INFRASTRUCTURE AS CODE{Colors.END}")
        print(f"{'='*60}")
        print(f"📅 Fecha: {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}")
        print(f"🌍 Region: us-east-1")
        print(f"{'='*60}")
        
        # Verificar conexión AWS
        if not self.test_aws_connection():
            return False
        
        # Reset contadores
        self.total_resources = 0
        self.valid_resources = 0
        self.validation_results = {}
        
        # Validar layers según parámetro
        if specific_layer is None:
            # Validar todos los layers
            self.validation_results['layer1'] = self.validate_layer1_foundation()
            self.validation_results['layer2'] = self.validate_layer2_network()
            self.validation_results['layer3'] = self.validate_layer3_compute()
            self.validation_results['layer4'] = self.validate_layer4_storage()
            self.validation_results['layer5'] = self.validate_layer5_observability()
        else:
            # Validar layer específico
            if specific_layer == 1:
                self.validation_results['layer1'] = self.validate_layer1_foundation()
            elif specific_layer == 2:
                self.validation_results['layer2'] = self.validate_layer2_network()
            elif specific_layer == 3:
                self.validation_results['layer3'] = self.validate_layer3_compute()
            elif specific_layer == 4:
                self.validation_results['layer4'] = self.validate_layer4_storage()
            elif specific_layer == 5:
                self.validation_results['layer5'] = self.validate_layer5_observability()
        
        # Generar resumen
        self.generate_summary()
        
        print(f"\n{'='*60}")
        print(f"{Colors.GREEN}{Colors.BOLD}✅ VALIDACIÓN COMPLETADA{Colors.END}")
        print(f"{'='*60}\n")
        
        return True


def main():
    parser = argparse.ArgumentParser(description='Valida la infraestructura SGSI en AWS')
    parser.add_argument('--layer', type=int, choices=[1, 2, 3, 4, 5], 
                       help='Layer específico a validar (1-5)')
    parser.add_argument('--format', choices=['console', 'json', 'html'], 
                       default='console', help='Formato de salida')
    
    args = parser.parse_args()
    
    validator = SGSIValidator()
    
    # Ejecutar validación
    if not validator.validate_layers(args.layer):
        sys.exit(1)
    
    # Generar reportes según formato
    timestamp = datetime.now().strftime('%Y%m%d_%H%M%S')
    
    if args.format == 'json':
        validator.save_json_report(f'sgsi_validation_{timestamp}.json')
    elif args.format == 'html':
        validator.save_html_report(f'sgsi_validation_{timestamp}.html')


if __name__ == '__main__':
    main()