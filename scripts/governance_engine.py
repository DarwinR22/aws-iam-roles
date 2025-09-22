#!/usr/bin/env python3
"""
🏛️ IAM Governance Engine
========================

Sistema de governance automático para gestión de roles y políticas por gerencia.
Valida, audita y enforza políticas de cumplimiento automáticamente.

Características:
- Validación automática de roles por gerencia
- Enforcement de límites por área organizacional
- Audit trail automático
- Alertas de compliance
- Auto-remediación de violaciones menores

Uso:
    python scripts/governance_engine.py --audit                    # Auditoría completa
    python scripts/governance_engine.py --gerencia MCI            # Auditar solo MCI
    python scripts/governance_engine.py --enforce                 # Aplicar governance
    python scripts/governance_engine.py --report                  # Generar reporte
"""

import json
import yaml
from pathlib import Path
from datetime import datetime, timedelta
from typing import Dict, List, Tuple
import argparse

class IAMGovernanceEngine:
    def __init__(self, base_path: Path = None):
        self.base_path = base_path or Path(__file__).parent.parent
        self.gerencias_path = self.base_path / "gerencias"
        self.catalog_path = self.base_path / "catalog"
        self.audit_path = self.base_path / "audit"
        
        # Crear directorio de auditoría
        self.audit_path.mkdir(exist_ok=True)
        
        # Configuración de governance por gerencia
        self.governance_rules = {
            'MCI': {
                'max_roles_per_area': 25,
                'max_policies_per_role': 10,
                'required_tags': ['ambiente', 'pais', 'gerencia', 'area', 'Equipo', 'Aplicacion'],
                'allowed_countries': ['gt', 'sv', 'ni', 'cr', 'hn', 'rg'],
                'sox_compliance_required': True,
                'boundary_policy_required': True,
                'max_privilege_duration_days': 90
            },
            'OID': {
                'max_roles_per_area': 15,
                'max_policies_per_role': 8,
                'required_tags': ['ambiente', 'pais', 'gerencia', 'area', 'Equipo'],
                'allowed_countries': ['rg'],
                'sox_compliance_required': False,
                'boundary_policy_required': True,
                'max_privilege_duration_days': 180
            },
            'FINANZAS': {
                'max_roles_per_area': 10,
                'max_policies_per_role': 5,
                'required_tags': ['ambiente', 'pais', 'gerencia', 'area', 'Equipo', 'sox_required'],
                'allowed_countries': ['gt', 'sv', 'ni', 'cr', 'hn'],
                'sox_compliance_required': True,
                'boundary_policy_required': True,
                'max_privilege_duration_days': 30
            }
        }
        
        # Contadores para métricas
        self.audit_results = {
            'violations': [],
            'warnings': [],
            'compliance_score': 0,
            'total_roles': 0,
            'total_policies': 0
        }

    def load_roles_by_gerencia(self) -> Dict[str, List[Dict]]:
        """Cargar todos los roles organizados por gerencia."""
        roles_by_gerencia = {}
        
        if not self.gerencias_path.exists():
            return roles_by_gerencia
        
        for gerencia_path in self.gerencias_path.iterdir():
            if gerencia_path.is_dir():
                gerencia_name = gerencia_path.name
                roles_by_gerencia[gerencia_name] = []
                
                for area_path in gerencia_path.iterdir():
                    if area_path.is_dir():
                        roles_path = area_path / "roles"
                        if roles_path.exists():
                            for role_file in roles_path.glob("*.json"):
                                try:
                                    with open(role_file, 'r', encoding='utf-8') as f:
                                        role_data = json.load(f)
                                    
                                    role_info = {
                                        'file': role_file,
                                        'data': role_data,
                                        'gerencia': gerencia_name,
                                        'area': area_path.name,
                                        'name': role_data.get('role_name', role_file.stem)
                                    }
                                    roles_by_gerencia[gerencia_name].append(role_info)
                                    
                                except Exception as e:
                                    self.log_violation(f"Error cargando rol {role_file}: {e}")
        
        return roles_by_gerencia

    def log_violation(self, message: str, severity: str = "ERROR"):
        """Registrar violación de governance."""
        violation = {
            'timestamp': datetime.now().isoformat(),
            'severity': severity,
            'message': message
        }
        
        if severity == "ERROR":
            self.audit_results['violations'].append(violation)
        else:
            self.audit_results['warnings'].append(violation)
        
        print(f"{'❌' if severity == 'ERROR' else '⚠️'} [{severity}] {message}")

    def validate_gerencia_limits(self, gerencia: str, roles: List[Dict]) -> bool:
        """Validar límites organizacionales por gerencia."""
        if gerencia not in self.governance_rules:
            self.log_violation(f"Gerencia '{gerencia}' no tiene reglas de governance definidas", "WARNING")
            return True
        
        rules = self.governance_rules[gerencia]
        is_compliant = True
        
        # Agrupar roles por área
        roles_by_area = {}
        for role in roles:
            area = role['area']
            if area not in roles_by_area:
                roles_by_area[area] = []
            roles_by_area[area].append(role)
        
        # Validar límites por área
        for area, area_roles in roles_by_area.items():
            if len(area_roles) > rules['max_roles_per_area']:
                self.log_violation(
                    f"Gerencia {gerencia}, Área {area}: {len(area_roles)} roles excede límite de {rules['max_roles_per_area']}"
                )
                is_compliant = False
        
        return is_compliant

    def validate_role_compliance(self, role_info: Dict, gerencia_rules: Dict) -> bool:
        """Validar cumplimiento de un rol individual."""
        role_data = role_info['data']
        role_name = role_info['name']
        is_compliant = True
        
        # Validar tags requeridos
        tags = role_data.get('tags', {})
        for required_tag in gerencia_rules['required_tags']:
            if required_tag not in tags:
                self.log_violation(f"Rol {role_name}: Falta tag requerido '{required_tag}'")
                is_compliant = False
        
        # Validar país permitido
        pais = tags.get('pais', '')
        if pais not in gerencia_rules['allowed_countries']:
            self.log_violation(f"Rol {role_name}: País '{pais}' no permitido para esta gerencia")
            is_compliant = False
        
        # Validar número de políticas
        policies = role_data.get('policies', {})
        total_policies = len(policies.get('aws_managed', [])) + len(policies.get('mci_managed', []))
        
        if total_policies > gerencia_rules['max_policies_per_role']:
            self.log_violation(f"Rol {role_name}: {total_policies} políticas excede límite de {gerencia_rules['max_policies_per_role']}")
            is_compliant = False
        
        # Validar SOX compliance si requerido
        if gerencia_rules['sox_compliance_required']:
            sox_tag = tags.get('Alcance SOX', tags.get('sox_required', 'no'))
            if sox_tag.lower() not in ['si', 'yes', 'true']:
                self.log_violation(f"Rol {role_name}: SOX compliance requerido pero no configurado", "WARNING")
        
        # Validar boundary policy si requerido
        if gerencia_rules['boundary_policy_required']:
            boundary = role_data.get('permissions_boundary')
            if not boundary:
                self.log_violation(f"Rol {role_name}: Boundary policy requerido pero no configurado", "WARNING")
        
        return is_compliant

    def check_role_freshness(self, role_info: Dict, max_days: int) -> bool:
        """Verificar que el rol no sea demasiado antiguo sin revisión."""
        role_data = role_info['data']
        role_name = role_info['name']
        
        # Buscar fecha de última modificación en tags
        tags = role_data.get('tags', {})
        last_modified = tags.get('Fechas de Creacion', tags.get('last_modified'))
        
        if not last_modified:
            self.log_violation(f"Rol {role_name}: No tiene fecha de creación/modificación", "WARNING")
            return False
        
        try:
            # Intentar parsear fecha
            if isinstance(last_modified, str):
                role_date = datetime.strptime(last_modified, '%Y-%m-%d')
            else:
                role_date = datetime.now()  # Fallback
            
            days_old = (datetime.now() - role_date).days
            
            if days_old > max_days:
                self.log_violation(
                    f"Rol {role_name}: {days_old} días sin revisión, excede límite de {max_days} días",
                    "WARNING"
                )
                return False
                
        except Exception as e:
            self.log_violation(f"Rol {role_name}: Error parseando fecha - {e}", "WARNING")
            return False
        
        return True

    def audit_gerencia(self, gerencia: str, roles: List[Dict]) -> Dict:
        """Auditar una gerencia específica."""
        print(f"\n🔍 AUDITANDO GERENCIA: {gerencia}")
        print("=" * 50)
        
        if gerencia not in self.governance_rules:
            print(f"⚠️ No hay reglas de governance para {gerencia}")
            return {'compliant': True, 'violations': 0}
        
        rules = self.governance_rules[gerencia]
        violations_count = len(self.audit_results['violations'])
        
        print(f"📋 Roles encontrados: {len(roles)}")
        print(f"🎯 Reglas aplicables: {len(rules)} configuradas")
        
        # Validar límites organizacionales
        self.validate_gerencia_limits(gerencia, roles)
        
        # Validar cada rol individual
        compliant_roles = 0
        for role_info in roles:
            if self.validate_role_compliance(role_info, rules):
                compliant_roles += 1
            
            # Verificar frescura del rol
            self.check_role_freshness(role_info, rules['max_privilege_duration_days'])
        
        new_violations = len(self.audit_results['violations']) - violations_count
        compliance_rate = (compliant_roles / len(roles)) * 100 if roles else 100
        
        print(f"✅ Roles conformes: {compliant_roles}/{len(roles)} ({compliance_rate:.1f}%)")
        print(f"❌ Nuevas violaciones: {new_violations}")
        
        return {
            'compliant': new_violations == 0,
            'violations': new_violations,
            'compliance_rate': compliance_rate,
            'total_roles': len(roles)
        }

    def audit_all_gerencias(self, target_gerencia: str = None) -> Dict:
        """Auditar todas las gerencias o una específica."""
        print("🏛️ INICIANDO AUDITORÍA DE GOVERNANCE")
        print("=" * 60)
        
        roles_by_gerencia = self.load_roles_by_gerencia()
        audit_summary = {}
        
        for gerencia, roles in roles_by_gerencia.items():
            if target_gerencia and gerencia != target_gerencia:
                continue
            
            audit_summary[gerencia] = self.audit_gerencia(gerencia, roles)
            self.audit_results['total_roles'] += len(roles)
        
        return audit_summary

    def enforce_governance(self, fix_mode: bool = False) -> bool:
        """Aplicar enforcement de governance (remediation automática)."""
        print("\n🛡️ APLICANDO ENFORCEMENT DE GOVERNANCE")
        print("=" * 50)
        
        if not fix_mode:
            print("🔍 MODO SIMULACIÓN: Mostrando acciones que se aplicarían")
        
        roles_by_gerencia = self.load_roles_by_gerencia()
        fixes_applied = 0
        
        for gerencia, roles in roles_by_gerencia.items():
            if gerencia not in self.governance_rules:
                continue
            
            rules = self.governance_rules[gerencia]
            
            for role_info in roles:
                role_data = role_info['data']
                role_file = role_info['file']
                tags = role_data.get('tags', {})
                modified = False
                
                # Auto-fix: Agregar tags faltantes básicos
                for required_tag in rules['required_tags']:
                    if required_tag not in tags:
                        if required_tag == 'Fechas de Creacion':
                            tags[required_tag] = datetime.now().strftime('%Y-%m-%d')
                            modified = True
                            print(f"🔧 {role_info['name']}: Agregado tag '{required_tag}'")
                        elif required_tag == 'gerencia':
                            tags[required_tag] = gerencia.lower()
                            modified = True
                            print(f"🔧 {role_info['name']}: Agregado tag 'gerencia'")
                
                # Auto-fix: Agregar boundary policy si falta
                if rules['boundary_policy_required'] and not role_data.get('permissions_boundary'):
                    boundary_arn = f"arn:aws:iam::393209814297:policy/App-StandardBoundary"
                    role_data['permissions_boundary'] = boundary_arn
                    modified = True
                    print(f"🔧 {role_info['name']}: Agregado boundary policy")
                
                # Guardar cambios si se hicieron modificaciones
                if modified and fix_mode:
                    with open(role_file, 'w', encoding='utf-8') as f:
                        json.dump(role_data, f, indent=2, ensure_ascii=False)
                    fixes_applied += 1
                elif modified:
                    print(f"🔍 Se aplicaría fix en: {role_info['name']}")
        
        print(f"\n✅ Fixes {'aplicados' if fix_mode else 'simulados'}: {fixes_applied}")
        return fixes_applied > 0

    def generate_compliance_report(self) -> str:
        """Generar reporte completo de compliance."""
        report_file = self.audit_path / f"governance_report_{datetime.now().strftime('%Y%m%d_%H%M%S')}.json"
        
        # Calcular score de compliance
        total_issues = len(self.audit_results['violations']) + len(self.audit_results['warnings'])
        max_possible_score = self.audit_results['total_roles'] * 10  # 10 puntos por rol perfecto
        penalty = total_issues * 2  # -2 puntos por cada issue
        
        self.audit_results['compliance_score'] = max(0, max_possible_score - penalty)
        self.audit_results['max_score'] = max_possible_score
        self.audit_results['compliance_percentage'] = (
            (self.audit_results['compliance_score'] / max_possible_score * 100) 
            if max_possible_score > 0 else 100
        )
        
        # Guardar reporte
        with open(report_file, 'w', encoding='utf-8') as f:
            json.dump(self.audit_results, f, indent=2, ensure_ascii=False)
        
        return str(report_file)

    def print_summary(self):
        """Imprimir resumen de governance."""
        print("\n" + "="*60)
        print("📊 RESUMEN DE GOVERNANCE")
        print("="*60)
        
        print(f"🏢 Roles auditados: {self.audit_results['total_roles']}")
        print(f"❌ Violaciones críticas: {len(self.audit_results['violations'])}")
        print(f"⚠️ Advertencias: {len(self.audit_results['warnings'])}")
        
        if 'compliance_percentage' in self.audit_results:
            print(f"📈 Score de compliance: {self.audit_results['compliance_percentage']:.1f}%")
        
        if self.audit_results['violations']:
            print(f"\n❌ VIOLACIONES CRÍTICAS:")
            for violation in self.audit_results['violations'][:5]:  # Mostrar solo primeras 5
                print(f"  • {violation['message']}")
            
            if len(self.audit_results['violations']) > 5:
                print(f"  ... y {len(self.audit_results['violations']) - 5} más")
        
        return len(self.audit_results['violations']) == 0

def main():
    parser = argparse.ArgumentParser(description='IAM Governance Engine')
    parser.add_argument('--audit', action='store_true', help='Ejecutar auditoría completa')
    parser.add_argument('--gerencia', type=str, help='Auditar solo una gerencia específica')
    parser.add_argument('--enforce', action='store_true', help='Aplicar enforcement (auto-remediation)')
    parser.add_argument('--fix', action='store_true', help='Aplicar fixes automáticos (usar con --enforce)')
    parser.add_argument('--report', action='store_true', help='Generar reporte de compliance')
    
    args = parser.parse_args()
    
    engine = IAMGovernanceEngine()
    
    if args.audit or args.gerencia:
        # Ejecutar auditoría
        engine.audit_all_gerencias(args.gerencia)
        
        if args.enforce:
            engine.enforce_governance(args.fix)
        
        if args.report:
            report_file = engine.generate_compliance_report()
            print(f"\n📄 Reporte guardado en: {report_file}")
        
        # Mostrar resumen
        success = engine.print_summary()
        exit(0 if success else 1)
    
    else:
        print("🏛️ IAM Governance Engine")
        print("Use --audit para ejecutar auditoría")
        print("Use --help para ver todas las opciones")

if __name__ == "__main__":
    main()