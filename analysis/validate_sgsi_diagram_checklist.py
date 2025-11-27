#!/usr/bin/env python3
"""
📊 SGSI Diagram Validation Checklist

Valida que el diagrama de arquitectura SGSI cumpla con todos los requerimientos
académicos para ISO 27001/27002, NIST CSF, Zero Trust, y ITIL/COBIT.
"""

import json
from datetime import datetime
from pathlib import Path

class SGSIDiagramValidator:
    """Validador de diagramas SGSI para proyectos académicos"""
    
    def __init__(self):
        self.checklist = {
            "infrastructure_layers": {
                "name": "🏗️ Capas de Infraestructura (5 Layers)",
                "weight": 25,
                "items": {
                    "layer1_foundation": {
                        "name": "Layer 1 - Foundation (IAM)",
                        "required_elements": [
                            "IAM Roles (github-actions, glue-service, etc.)",
                            "OIDC Provider para GitHub Actions",
                            "Políticas IAM con least privilege",
                            "Trust relationships",
                            "Cross-account access controls"
                        ],
                        "status": "unknown"
                    },
                    "layer2_network": {
                        "name": "Layer 2 - Network",
                        "required_elements": [
                            "VPC con subnets públicas/privadas/database",
                            "Security Groups con reglas restrictivas",
                            "NACLs (Network ACLs)",
                            "Internet Gateway y NAT Gateway",
                            "Route Tables",
                            "VPC Flow Logs",
                            "Route53 (DNS)",
                            "VPN/DirectConnect (híbrido)"
                        ],
                        "status": "unknown"
                    },
                    "layer3_compute": {
                        "name": "Layer 3 - Compute",
                        "required_elements": [
                            "Application Load Balancer (ALB)",
                            "Auto Scaling Groups (ASG)",
                            "EC2 Instances con roles IAM",
                            "RDS Database con Multi-AZ",
                            "Lambda Functions",
                            "Launch Templates",
                            "Target Groups"
                        ],
                        "status": "unknown"
                    },
                    "layer4_storage": {
                        "name": "Layer 4 - Storage",
                        "required_elements": [
                            "S3 Buckets con encryption",
                            "EFS File Systems",
                            "AWS Backup Vault",
                            "Lifecycle policies",
                            "Cross-region replication",
                            "Versioning y MFA Delete"
                        ],
                        "status": "unknown"
                    },
                    "layer5_observability": {
                        "name": "Layer 5 - Observability",
                        "required_elements": [
                            "CloudTrail (auditoría)",
                            "CloudWatch (monitoring)",
                            "GuardDuty (IDS/IPS)",
                            "Security Hub (SIEM)",
                            "AWS Config (compliance)",
                            "SNS Notifications",
                            "CloudWatch Dashboards",
                            "Alarms y métricas"
                        ],
                        "status": "unknown"
                    }
                }
            },
            "security_controls": {
                "name": "🛡️ Controles de Seguridad SGSI",
                "weight": 30,
                "items": {
                    "ids_ips": {
                        "name": "IDS/IPS (GuardDuty)",
                        "required_elements": [
                            "GuardDuty habilitado",
                            "Threat Intelligence feeds",
                            "Malware detection",
                            "Suspicious network activity detection",
                            "Integration con Security Hub"
                        ],
                        "status": "unknown"
                    },
                    "siem": {
                        "name": "SIEM (Security Hub)",
                        "required_elements": [
                            "Security Hub centralizado",
                            "Multi-account aggregation",
                            "Compliance standards (CIS, PCI DSS, AWS Foundational)",
                            "Custom insights",
                            "Integration con third-party tools"
                        ],
                        "status": "unknown"
                    },
                    "zero_trust": {
                        "name": "Zero Trust Architecture",
                        "required_elements": [
                            "Network segmentation (DMZ, App, DB tiers)",
                            "Identity verification en cada layer",
                            "Least privilege access",
                            "Continuous monitoring",
                            "Encrypted communications",
                            "Multi-factor authentication"
                        ],
                        "status": "unknown"
                    },
                    "encryption": {
                        "name": "Encryption (At Rest & In Transit)",
                        "required_elements": [
                            "KMS key management",
                            "S3 encryption (SSE-S3, SSE-KMS)",
                            "RDS encryption",
                            "EBS encryption",
                            "TLS/SSL en tránsito",
                            "VPN/DirectConnect encryption"
                        ],
                        "status": "unknown"
                    }
                }
            },
            "compliance_frameworks": {
                "name": "📋 Frameworks de Compliance",
                "weight": 25,
                "items": {
                    "iso27001": {
                        "name": "ISO 27001/27002",
                        "required_elements": [
                            "Information Security Policy",
                            "Risk Assessment Framework",
                            "Access Control (A.9)",
                            "Cryptography (A.10)",
                            "Network Security (A.13)",
                            "Incident Management (A.16)",
                            "Business Continuity (A.17)"
                        ],
                        "status": "unknown"
                    },
                    "nist_csf": {
                        "name": "NIST Cybersecurity Framework",
                        "required_elements": [
                            "Identify (ID) - Asset inventory",
                            "Protect (PR) - Access controls",
                            "Detect (DE) - Security monitoring",
                            "Respond (RS) - Incident response",
                            "Recover (RC) - Business continuity"
                        ],
                        "status": "unknown"
                    },
                    "itil_cobit": {
                        "name": "ITIL/COBIT",
                        "required_elements": [
                            "Service Management processes",
                            "Change Management",
                            "Configuration Management",
                            "Incident Management",
                            "Problem Management",
                            "Performance Management"
                        ],
                        "status": "unknown"
                    }
                }
            },
            "technical_documentation": {
                "name": "📚 Documentación Técnica",
                "weight": 20,
                "items": {
                    "architecture_clarity": {
                        "name": "Claridad de Arquitectura",
                        "required_elements": [
                            "Componentes claramente etiquetados",
                            "Flujos de datos visibles",
                            "Separación de responsabilidades",
                            "Escalabilidad demostrada",
                            "Puntos de integración definidos"
                        ],
                        "status": "unknown"
                    },
                    "security_boundaries": {
                        "name": "Límites de Seguridad",
                        "required_elements": [
                            "DMZ claramente definida",
                            "Application tier separado",
                            "Database tier aislado",
                            "Management/Admin networks",
                            "Trust boundaries marcados"
                        ],
                        "status": "unknown"
                    },
                    "data_flows": {
                        "name": "Flujos de Datos",
                        "required_elements": [
                            "User traffic flows",
                            "Administrative access paths",
                            "Backup/replication flows",
                            "Log aggregation paths",
                            "Monitoring data flows",
                            "Emergency access paths"
                        ],
                        "status": "unknown"
                    },
                    "compliance_mapping": {
                        "name": "Mapeo de Compliance",
                        "required_elements": [
                            "ISO 27001 controls mapeados",
                            "NIST CSF functions identificadas",
                            "Zero Trust principles aplicados",
                            "Audit trails visibles",
                            "Compliance automation mostrada"
                        ],
                        "status": "unknown"
                    }
                }
            }
        }

    def print_header(self, text: str) -> None:
        """Imprime header con formato"""
        print(f"\n{'='*80}")
        print(f"  {text}")
        print(f"{'='*80}")

    def print_section(self, text: str) -> None:
        """Imprime sección con formato"""
        print(f"\n{'-'*60}")
        print(f"  {text}")
        print(f"{'-'*60}")

    def print_success(self, text: str) -> None:
        """Imprime mensaje de éxito"""
        print(f"✅ {text}")

    def print_warning(self, text: str) -> None:
        """Imprime mensaje de advertencia"""
        print(f"⚠️  {text}")

    def print_error(self, text: str) -> None:
        """Imprime mensaje de error"""
        print(f"❌ {text}")

    def generate_checklist(self) -> None:
        """Genera checklist completo para validación manual del diagrama"""
        self.print_header("📊 SGSI DIAGRAM VALIDATION CHECKLIST")
        
        print("\n🎯 **INSTRUCCIONES:**")
        print("   1. Abre tu diagrama 'Diagrama sin título.drawio.png'")
        print("   2. Revisa cada elemento en esta lista")
        print("   3. Marca ✅ si está presente, ❌ si falta, ⚠️ si está parcial")
        print("   4. Usa esta validación para completar tu diagrama académico")
        
        total_weight = 0
        
        for category_key, category in self.checklist.items():
            self.print_section(f"{category['name']} (Peso: {category['weight']}%)")
            total_weight += category['weight']
            
            for item_key, item in category['items'].items():
                print(f"\n🔸 **{item['name']}**")
                print("   Elementos requeridos:")
                
                for i, element in enumerate(item['required_elements'], 1):
                    print(f"   {i:2d}. [ ] {element}")
        
        print(f"\n📊 **PESO TOTAL:** {total_weight}%")
        
        # Generar sección de gaps actuales basada en validación previa
        self.print_section("🚨 GAPS CRÍTICOS IDENTIFICADOS (de validación previa)")
        
        critical_gaps = [
            "❌ Layer 3 (Compute): 0% deployado - ALB, ASG, RDS, Lambda faltantes",
            "❌ GuardDuty (IDS/IPS): No habilitado - Requerido para detección de amenazas",
            "❌ Security Hub (SIEM): No habilitado - Requerido para centralización de seguridad",
            "❌ AWS Config: No configurado - Requerido para compliance continuo",
            "⚠️  Layer 2 (Network): 75% completo - Faltan NACLs, Route53, VPN/DirectConnect",
            "⚠️  Layer 4 (Storage): 50% completo - S3 básico, falta EFS, Backup Vault",
            "⚠️  Layer 5 (Observability): CloudTrail parcial, falta monitoreo completo"
        ]
        
        for gap in critical_gaps:
            print(f"   {gap}")
        
        # Recomendaciones específicas
        self.print_section("💡 RECOMENDACIONES PARA COMPLETAR DIAGRAMA")
        
        recommendations = [
            "1. **Agregar Layer 3 completo:** Mostrar ALB → ASG → EC2 + RDS cluster",
            "2. **Incluir servicios de seguridad:** GuardDuty, Security Hub, Config claramente visibles",
            "3. **Definir zonas de seguridad:** DMZ (pública), App (privada), DB (aislada)",
            "4. **Mostrar flujos de datos:** User → ALB → App → DB con puntos de control",
            "5. **Agregar conectividad híbrida:** VPN/DirectConnect para requisitos enterprise",
            "6. **Incluir backup/DR:** Backup Vault, cross-region replication",
            "7. **Mapear compliance:** Etiquetar componentes con ISO 27001, NIST CSF",
            "8. **Mostrar monitoreo:** CloudWatch, logs, alarms, dashboards",
            "9. **Encryption en tránsito:** TLS/SSL paths claramente marcados",
            "10. **Zero Trust boundaries:** Trust verification en cada hop"
        ]
        
        for rec in recommendations:
            print(f"   {rec}")
        
        # Generar template de documentación
        self.generate_documentation_template()

    def generate_documentation_template(self) -> None:
        """Genera template de documentación académica"""
        self.print_section("📝 TEMPLATE DE DOCUMENTACIÓN ACADÉMICA")
        
        template = """
## SGSI Infrastructure Architecture Documentation

### 1. Executive Summary
- **Project:** SGSI Implementation for Academic Compliance
- **Standards:** ISO 27001/27002, NIST CSF, Zero Trust, ITIL/COBIT
- **Deployment Status:** [ACTUALIZAR DESPUÉS DE VALIDATION]
- **Compliance Level:** [ACTUALIZAR DESPUÉS DE VALIDATION]

### 2. Architecture Overview
#### 2.1 Five-Layer Architecture
- **Layer 1 - Foundation:** IAM, OIDC, Security Policies
- **Layer 2 - Network:** VPC, Security Groups, Zero Trust Segmentation
- **Layer 3 - Compute:** ALB, ASG, EC2, RDS, Lambda
- **Layer 4 - Storage:** S3, EFS, Backup, Lifecycle Management
- **Layer 5 - Observability:** CloudTrail, GuardDuty, Security Hub, Config

#### 2.2 Security Controls Matrix
| Control Type | Technology | ISO 27001 | NIST CSF | Status |
|--------------|------------|-----------|----------|---------|
| IDS/IPS | GuardDuty | A.12.6 | DE.CM | [STATUS] |
| SIEM | Security Hub | A.16.1 | DE.AE | [STATUS] |
| Access Control | IAM + OIDC | A.9.1 | PR.AC | [STATUS] |
| Encryption | KMS | A.10.1 | PR.DS | [STATUS] |
| Monitoring | CloudWatch | A.12.4 | DE.CM | [STATUS] |
| Backup | AWS Backup | A.17.1 | RC.RP | [STATUS] |

### 3. Compliance Mapping
#### 3.1 ISO 27001/27002 Controls
- **A.9 Access Control:** IAM roles, OIDC, least privilege
- **A.10 Cryptography:** KMS, encryption at rest/transit
- **A.12 Operations Security:** CloudTrail, monitoring, logging
- **A.13 Communications Security:** VPC, Security Groups, TLS
- **A.16 Incident Management:** Security Hub, GuardDuty, alarms
- **A.17 Business Continuity:** Multi-AZ, backup, disaster recovery

#### 3.2 NIST Cybersecurity Framework
- **Identify:** Asset inventory, risk assessment via AWS Config
- **Protect:** Access controls, data protection, security training
- **Detect:** GuardDuty, Security Hub, CloudWatch monitoring
- **Respond:** Automated incident response, playbooks
- **Recover:** Backup strategies, disaster recovery procedures

### 4. Technical Implementation
[INCLUIR DETALLES TÉCNICOS DE CADA LAYER]

### 5. Risk Assessment
[MATRIZ DE RIESGOS Y CONTROLES]

### 6. Future Improvements
[ROADMAP DE MEJORAS]
        """
        
        print(template)
        
        print("\n🎯 **PRÓXIMOS PASOS:**")
        next_steps = [
            "1. Completar diagrama con elementos faltantes",
            "2. Ejecutar deployment de Layer 3 (Compute)",
            "3. Habilitar GuardDuty y Security Hub",
            "4. Configurar AWS Config para compliance",
            "5. Actualizar documentación con resultados reales",
            "6. Generar reporte final de compliance SGSI"
        ]
        
        for step in next_steps:
            print(f"   {step}")

def main():
    """Función principal"""
    validator = SGSIDiagramValidator()
    validator.generate_checklist()
    
    print(f"\n{'='*80}")
    print("📊 CHECKLIST GENERADO EXITOSAMENTE")
    print("🎯 Usa esta guía para completar tu diagrama SGSI académico")
    print(f"{'='*80}\n")

if __name__ == "__main__":
    main()