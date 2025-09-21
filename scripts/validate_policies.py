#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
POLICY CATALOG VALIDATOR
========================
Validaciones automáticas para el catálogo de políticas empresariales

Validaciones incluidas:
✅ Nombres únicos de políticas
✅ Formato correcto de nombres MCI-*-TagBased-*
✅ Tags obligatorios presentes
✅ Formatos CamelCase en tags
✅ Referencias válidas a policy blocks
✅ Consistencia de metadatos
"""

import yaml
import json
import os
import sys
import re
from typing import Dict, List, Optional, Any, Tuple

class PolicyValidator:
    """Validador completo del catálogo de políticas"""
    
    def __init__(self, catalog_path: str):
        self.catalog_path = catalog_path
        self.policies_data = self._load_catalog()
        self.errors = []
        self.warnings = []
        
    def _load_catalog(self) -> Dict[str, Any]:
        """Cargar catálogo de políticas"""
        try:
            with open(self.catalog_path, 'r', encoding='utf-8') as f:
                return yaml.safe_load(f) or {}
        except Exception as e:
            print(f"❌ Error cargando catálogo: {e}")
            return {}
    
    def _add_error(self, policy_name: str, message: str):
        """Agregar error de validación"""
        self.errors.append(f"❌ {policy_name}: {message}")
    
    def _add_warning(self, policy_name: str, message: str):
        """Agregar advertencia de validación"""
        self.warnings.append(f"⚠️ {policy_name}: {message}")
    
    def validate_policy_name_format(self) -> bool:
        """Validar formato de nombres de políticas"""
        print("🔍 Validando formatos de nombres...")
        
        pattern = r'^MCI-[A-Za-z0-9]+-TagBased-[A-Za-z0-9]+$'
        valid = True
        
        for policy_name in self.policies_data.get('policies', {}):
            if not re.match(pattern, policy_name):
                self._add_error(policy_name, "Formato incorrecto. Debe ser: MCI-Servicio-TagBased-Accion")
                valid = False
        
        return valid
    
    def validate_unique_names(self) -> bool:
        """Validar nombres únicos"""
        print("🔍 Validando nombres únicos...")
        
        policies = self.policies_data.get('policies', {})
        names = list(policies.keys())
        
        if len(names) != len(set(names)):
            self._add_error("GENERAL", "Hay nombres de políticas duplicados")
            return False
        
        return True
    
    def validate_required_tags(self) -> bool:
        """Validar tags obligatorios"""
        print("🔍 Validando tags obligatorios...")
        
        required_tags = [
            'Ambiente', 'País', 'Dirección', 'Gerencia', 'Cuenta',
            'Módulo', 'Alcance SOX', 'Propietario', 'Proveedor',
            'Layer', 'Dominio', 'Subdominio', 'Aplicación', 'Name',
            'Soporte', 'Contacto', 'Proyecto', 'Fechas de Creación',
            'Creado Por', 'Tipo de Recurso', 'Ciclo de Vida',
            'Versión', 'Map-migrated'
        ]
        
        valid = True
        
        for policy_name, policy in self.policies_data.get('policies', {}).items():
            canonical_tags = policy.get('canonical_tags', {})
            
            missing_tags = []
            for tag in required_tags:
                if tag not in canonical_tags:
                    missing_tags.append(tag)
            
            if missing_tags:
                self._add_error(policy_name, f"Faltan tags obligatorios: {', '.join(missing_tags)}")
                valid = False
        
        return valid
    
    def validate_camelcase_tags(self) -> bool:
        """Validar formato CamelCase en tags"""
        print("🔍 Validando formato CamelCase...")
        
        valid = True
        camelcase_pattern = r'^[A-Z][a-zA-Z0-9]*$'
        
        # Tags que pueden tener excepciones al formato
        exceptions = ['Name', 'País', 'Alcance SOX', 'Fechas de Creación', 
                     'Creado Por', 'Tipo de Recurso', 'Ciclo de Vida', 'Map-migrated']
        
        for policy_name, policy in self.policies_data.get('policies', {}).items():
            canonical_tags = policy.get('canonical_tags', {})
            
            for tag_key, tag_value in canonical_tags.items():
                if tag_key in exceptions:
                    continue
                
                if not re.match(camelcase_pattern, str(tag_value)):
                    self._add_warning(policy_name, f"Tag '{tag_key}' no está en CamelCase: '{tag_value}'")
                    valid = False
        
        return valid
    
    def validate_policy_blocks(self) -> bool:
        """Validar referencias a policy blocks"""
        print("🔍 Validando policy blocks...")
        
        valid = True
        
        for policy_name, policy in self.policies_data.get('policies', {}).items():
            policy_document = policy.get('policy_document')
            
            if not policy_document:
                self._add_error(policy_name, "Falta especificar policy_document")
                valid = False
                continue
            
            # Verificar formato del policy block
            if not re.match(r'^[a-z_]+\.[a-z_]+$', policy_document):
                self._add_warning(policy_name, f"Policy block tiene formato inusual: {policy_document}")
    
    def validate_metadata_consistency(self) -> bool:
        """Validar consistencia de metadatos"""
        print("🔍 Validando consistencia de metadatos...")
        
        valid = True
        
        for policy_name, policy in self.policies_data.get('policies', {}).items():
            # Verificar que el Name tag coincida con el nombre de la política
            canonical_tags = policy.get('canonical_tags', {})
            name_tag = canonical_tags.get('Name')
            
            if name_tag != policy_name:
                self._add_error(policy_name, f"Tag 'Name' no coincide: '{name_tag}' vs '{policy_name}'")
                valid = False
            
            # Verificar tipo de política
            policy_type = policy.get('type', '')
            if policy_type not in ['managed', 'inline']:
                self._add_warning(policy_name, f"Tipo de política inusual: '{policy_type}'")
            
            # Verificar descripción presente
            if not policy.get('description'):
                self._add_warning(policy_name, "Falta descripción")
    
    def validate_sox_compliance(self) -> bool:
        """Validar cumplimiento SOX"""
        print("🔍 Validando cumplimiento SOX...")
        
        valid = True
        
        # Acciones que típicamente requieren SOX
        sox_actions = ['write', 'delete', 'create', 'update', 'put']
        
        for policy_name, policy in self.policies_data.get('policies', {}).items():
            canonical_tags = policy.get('canonical_tags', {})
            sox_value = canonical_tags.get('Alcance SOX', 'No')
            
            # Extraer acción del nombre de la política
            action = policy_name.split('-')[-1].lower() if '-' in policy_name else ''
            
            # Verificar si acción de escritura tiene SOX marcado
            if any(sox_action in action for sox_action in sox_actions):
                if sox_value.lower() != 'sí':
                    self._add_warning(policy_name, f"Acción '{action}' debería tener SOX='Sí'")
    
    def validate_service_mapping(self) -> bool:
        """Validar mapeo de servicios a módulos/dominios"""
        print("🔍 Validando mapeo de servicios...")
        
        valid = True
        
        # Mapeos esperados
        service_modules = {
            'S3': 'StorageAccess',
            'DynamoDB': 'DatabaseAccess',
            'Lambda': 'ComputeAccess',
            'SQS': 'MessagingAccess',
            'SNS': 'MessagingAccess',
            'CloudWatch': 'MonitoringAccess',
            'Secrets': 'SecurityAccess'
        }
        
        service_domains = {
            'S3': 'DataAccess',
            'DynamoDB': 'DataAccess',
            'Lambda': 'ComputeAccess',
            'SQS': 'MessagingAccess',
            'SNS': 'MessagingAccess',
            'CloudWatch': 'MonitoringAccess',
            'Secrets': 'SecurityAccess'
        }
        
        for policy_name, policy in self.policies_data.get('policies', {}).items():
            canonical_tags = policy.get('canonical_tags', {})
            
            # Extraer servicio del nombre
            service = policy_name.split('-')[1] if len(policy_name.split('-')) > 1 else 'Unknown'
            
            # Verificar módulo
            expected_module = service_modules.get(service)
            actual_module = canonical_tags.get('Módulo')
            
            if expected_module and actual_module != expected_module:
                self._add_warning(policy_name, 
                    f"Módulo inconsistente. Esperado: '{expected_module}', Actual: '{actual_module}'")
            
            # Verificar dominio
            expected_domain = service_domains.get(service)
            actual_domain = canonical_tags.get('Dominio')
            
            if expected_domain and actual_domain != expected_domain:
                self._add_warning(policy_name, 
                    f"Dominio inconsistente. Esperado: '{expected_domain}', Actual: '{actual_domain}'")
        
        return valid
    
    def run_all_validations(self) -> Tuple[bool, int, int]:
        """Ejecutar todas las validaciones"""
        print("🔍 INICIANDO VALIDACIÓN COMPLETA DEL CATÁLOGO")
        print("=" * 60)
        
        validations = [
            self.validate_unique_names,
            self.validate_policy_name_format,
            self.validate_required_tags,
            self.validate_camelcase_tags,
            self.validate_policy_blocks,
            self.validate_metadata_consistency,
            self.validate_sox_compliance,
            self.validate_service_mapping
        ]
        
        all_passed = True
        
        for validation in validations:
            try:
                result = validation()
                if not result:
                    all_passed = False
            except Exception as e:
                self._add_error("VALIDATION", f"Error en validación: {e}")
                all_passed = False
        
        # Mostrar resultados
        print("\n" + "="*60)
        print("📊 RESULTADOS DE VALIDACIÓN")
        print("="*60)
        
        if self.errors:
            print(f"\n❌ ERRORES CRÍTICOS ({len(self.errors)}):")
            for error in self.errors:
                print(f"   {error}")
        
        if self.warnings:
            print(f"\n⚠️ ADVERTENCIAS ({len(self.warnings)}):")
            for warning in self.warnings:
                print(f"   {warning}")
        
        if not self.errors and not self.warnings:
            print("✅ TODAS LAS VALIDACIONES PASARON")
            print("🎉 El catálogo está en perfecto estado")
        
        print(f"\n📈 RESUMEN:")
        print(f"   📋 Políticas validadas: {len(self.policies_data.get('policies', {}))}")
        print(f"   ❌ Errores: {len(self.errors)}")
        print(f"   ⚠️ Advertencias: {len(self.warnings)}")
        print(f"   ✅ Estado general: {'APROBADO' if not self.errors else 'REQUIERE CORRECCIÓN'}")
        
        return all_passed, len(self.errors), len(self.warnings)

def main():
    """Función principal"""
    catalog_path = os.path.join(os.path.dirname(__file__), '..', 'catalog', 'policies.yaml')
    
    if not os.path.exists(catalog_path):
        print(f"❌ No se encuentra el catálogo: {catalog_path}")
        return 1
    
    validator = PolicyValidator(catalog_path)
    passed, errors, warnings = validator.run_all_validations()
    
    # Código de salida
    if errors > 0:
        return 1  # Errores críticos
    elif warnings > 0:
        return 2  # Solo advertencias
    else:
        return 0  # Todo perfecto

if __name__ == "__main__":
    sys.exit(main())