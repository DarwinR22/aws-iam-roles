#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
ENTERPRISE POLICY MANAGEMENT SYSTEM
====================================
Sistema completo CRUD para gestión de políticas IAM
Maneja el catálogo catalog/policies.yaml de forma dinámica

Capacidades:
✅ Crear nuevas políticas
✅ Editar políticas existentes  
✅ Eliminar políticas obsoletas
✅ Listar y buscar políticas
✅ Validar formatos y duplicados
✅ Auto-normalización CamelCase
"""

import yaml
import json
import os
import sys
from datetime import datetime
from typing import Dict, List, Optional, Any
import re

# Configuración de paths
POLICIES_CATALOG = os.path.join(os.path.dirname(__file__), '..', 'catalog', 'policies.yaml')
POLICY_BLOCKS_DIR = os.path.join(os.path.dirname(__file__), '..', 'policy-blocks')

class PolicyManager:
    """Gestor completo de políticas empresariales"""
    
    def __init__(self):
        self.catalog_path = POLICIES_CATALOG
        self.policies_data = self._load_catalog()
        
    def _load_catalog(self) -> Dict[str, Any]:
        """Cargar catálogo de políticas"""
        try:
            if os.path.exists(self.catalog_path):
                with open(self.catalog_path, 'r', encoding='utf-8') as f:
                    return yaml.safe_load(f) or {"policies": {}, "policy_blocks": {}}
            else:
                return {"policies": {}, "policy_blocks": {}}
        except Exception as e:
            print(f"❌ Error cargando catálogo: {e}")
            return {"policies": {}, "policy_blocks": {}}
    
    def _save_catalog(self):
        """Guardar cambios al catálogo"""
        try:
            os.makedirs(os.path.dirname(self.catalog_path), exist_ok=True)
            with open(self.catalog_path, 'w', encoding='utf-8') as f:
                yaml.dump(self.policies_data, f, 
                         default_flow_style=False, 
                         allow_unicode=True, 
                         sort_keys=False,
                         indent=2)
            print(f"✅ Catálogo actualizado: {self.catalog_path}")
        except Exception as e:
            print(f"❌ Error guardando catálogo: {e}")
    
    def normalize_to_camelcase(self, text: str) -> str:
        """Normalizar texto a CamelCase"""
        if not text:
            return text
        
        # Remover caracteres especiales y espacios, dividir por delimitadores
        words = re.split(r'[_\-\s@.]+', str(text).strip())
        words = [word for word in words if word]  # Filtrar vacíos
        
        if not words:
            return text
        
        # Primera palabra capitalizada, resto también
        camel_case = ''.join(word.capitalize() for word in words)
        return camel_case
    
    def _validate_policy_name(self, name: str) -> bool:
        """Validar formato de nombre de política"""
        # MCI-Service-TagBased-Action
        pattern = r'^MCI-[A-Z][a-zA-Z0-9]+-TagBased-[A-Z][a-zA-Z0-9]+$'
        return bool(re.match(pattern, name))
    
    def _get_available_policy_blocks(self) -> List[str]:
        """Obtener bloques de políticas disponibles"""
        blocks = []
        if os.path.exists(POLICY_BLOCKS_DIR):
            for root, dirs, files in os.walk(POLICY_BLOCKS_DIR):
                for file in files:
                    if file.endswith('.tf'):
                        rel_path = os.path.relpath(os.path.join(root, file), POLICY_BLOCKS_DIR)
                        block_name = rel_path.replace('\\', '.').replace('/', '.').replace('.tf', '')
                        blocks.append(block_name)
        return sorted(blocks)
    
    def _generate_canonical_tags(self, policy_name: str, service: str, action: str) -> Dict[str, str]:
        """Generar tags canónicos para nueva política"""
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
        
        sox_required = action.lower() in ['write', 'delete', 'create', 'update', 'put']
        
        return {
            "Ambiente": "Multi",
            "País": "RG",
            "Dirección": "Tecnología",
            "Gerencia": "MCI",
            "Cuenta": "393209814297",
            "Módulo": service_modules.get(service, "GeneralAccess"),
            "Alcance SOX": "Sí" if sox_required else "No",
            "Propietario": "SecurityTeam",
            "Proveedor": "Claro",
            "Layer": "Security",
            "Dominio": service_domains.get(service, "GeneralAccess"),
            "Subdominio": service,
            "Aplicación": "AbacPolicies",
            "Name": policy_name,
            "Soporte": "SecurityTeam",
            "Contacto": "SecurityClaroComm",
            "Proyecto": "AbacFramework",
            "Fechas de Creación": datetime.now().strftime("%Y-%m-%dT%H:%M:%SZ"),
            "Creado Por": "TerraformIac",
            "Tipo de Recurso": "IamPolicy",
            "Ciclo de Vida": "Active",
            "Versión": "2.0",
            "Map-migrated": f"mig_{service.lower()}_policy_{len(self.policies_data['policies']) + 1:03d}"
        }
    
    def list_policies(self, filter_service: Optional[str] = None):
        """Listar todas las políticas con filtros opcionales"""
        policies = self.policies_data.get('policies', {})
        
        if not policies:
            print("📋 No hay políticas registradas")
            return
        
        print(f"\n📋 CATÁLOGO DE POLÍTICAS ({len(policies)} total)")
        print("=" * 70)
        
        for name, policy in policies.items():
            if filter_service and filter_service.lower() not in name.lower():
                continue
                
            description = policy.get('description', 'Sin descripción')
            policy_type = policy.get('type', 'unknown')
            service = name.split('-')[1] if '-' in name else 'Unknown'
            sox = policy.get('canonical_tags', {}).get('Alcance SOX', 'No')
            
            print(f"🔐 {name}")
            print(f"   📝 {description}")
            print(f"   🏷️  Servicio: {service} | Tipo: {policy_type} | SOX: {sox}")
            print(f"   📦 Block: {policy.get('policy_document', 'N/A')}")
            print()
    
    def search_policies(self, query: str):
        """Buscar políticas por nombre, servicio o descripción"""
        query = query.lower()
        results = []
        
        for name, policy in self.policies_data.get('policies', {}).items():
            if (query in name.lower() or 
                query in policy.get('description', '').lower() or
                query in policy.get('policy_document', '').lower()):
                results.append((name, policy))
        
        if not results:
            print(f"🔍 No se encontraron políticas con: '{query}'")
            return
        
        print(f"\n🔍 RESULTADOS DE BÚSQUEDA: '{query}' ({len(results)} encontradas)")
        print("=" * 70)
        
        for name, policy in results:
            print(f"✅ {name}: {policy.get('description', 'Sin descripción')}")
    
    def create_policy(self):
        """Crear nueva política interactivamente"""
        print("\n🆕 CREAR NUEVA POLÍTICA")
        print("=" * 50)
        
        # Inputs del usuario
        print("\n1️⃣ Información básica:")
        service = input("Servicio (ej: S3, DynamoDB, Lambda): ").strip()
        if not service:
            print("❌ El servicio es obligatorio")
            return
        
        action = input("Acción (ej: ReadOnly, Write, Invoke): ").strip()
        if not action:
            print("❌ La acción es obligatoria")
            return
        
        # Generar nombre de política
        service_norm = self.normalize_to_camelcase(service)
        action_norm = self.normalize_to_camelcase(action)
        policy_name = f"MCI-{service_norm}-TagBased-{action_norm}"
        
        # Verificar duplicados
        if policy_name in self.policies_data.get('policies', {}):
            print(f"❌ La política '{policy_name}' ya existe")
            return
        
        print(f"\n📝 Nombre generado: {policy_name}")
        
        description = input("Descripción: ").strip()
        if not description:
            description = f"{service} {action.lower()} access based on matching resource tags with principal tags"
        
        # Mostrar bloques disponibles
        print("\n2️⃣ Bloques de políticas disponibles:")
        available_blocks = self._get_available_policy_blocks()
        
        if available_blocks:
            for i, block in enumerate(available_blocks, 1):
                print(f"   {i}. {block}")
            
            try:
                block_choice = input(f"\nSelecciona bloque (1-{len(available_blocks)}) o escribe uno personalizado: ").strip()
                if block_choice.isdigit() and 1 <= int(block_choice) <= len(available_blocks):
                    policy_document = available_blocks[int(block_choice) - 1]
                else:
                    policy_document = block_choice
            except:
                policy_document = f"{service.lower()}.{service.lower()}_tag_based_{action.lower()}"
        else:
            policy_document = input("Bloque de política (ej: s3.s3_tag_based_read): ").strip()
            if not policy_document:
                policy_document = f"{service.lower()}.{service.lower()}_tag_based_{action.lower()}"
        
        # Generar tags canónicos
        canonical_tags = self._generate_canonical_tags(policy_name, service_norm, action_norm)
        
        # Crear estructura de política
        new_policy = {
            "description": description,
            "type": "managed",
            "policy_document": policy_document,
            "canonical_tags": canonical_tags
        }
        
        # Mostrar resumen
        print(f"\n📋 RESUMEN DE NUEVA POLÍTICA:")
        print(f"   🏷️  Nombre: {policy_name}")
        print(f"   📝 Descripción: {description}")
        print(f"   📦 Block: {policy_document}")
        print(f"   🛡️  SOX: {canonical_tags['Alcance SOX']}")
        
        confirm = input("\n✅ ¿Crear esta política? (s/N): ").strip().lower()
        if confirm in ['s', 'si', 'y', 'yes']:
            # Agregar al catálogo
            if 'policies' not in self.policies_data:
                self.policies_data['policies'] = {}
            
            self.policies_data['policies'][policy_name] = new_policy
            
            # Agregar al policy_blocks si no existe
            if 'policy_blocks' not in self.policies_data:
                self.policies_data['policy_blocks'] = {}
            
            block_key = f"{service.lower()}_tag_based_{action.lower()}"
            if block_key not in self.policies_data['policy_blocks']:
                self.policies_data['policy_blocks'][block_key] = policy_document
            
            self._save_catalog()
            print(f"✅ Política '{policy_name}' creada exitosamente")
        else:
            print("❌ Creación cancelada")
    
    def edit_policy(self):
        """Editar política existente"""
        policies = self.policies_data.get('policies', {})
        if not policies:
            print("📋 No hay políticas para editar")
            return
        
        print("\n✏️ EDITAR POLÍTICA")
        print("=" * 50)
        
        # Mostrar políticas disponibles
        policy_list = list(policies.keys())
        for i, name in enumerate(policy_list, 1):
            print(f"   {i}. {name}")
        
        try:
            choice = input(f"\nSelecciona política (1-{len(policy_list)}): ").strip()
            if not choice.isdigit() or not (1 <= int(choice) <= len(policy_list)):
                print("❌ Selección inválida")
                return
            
            policy_name = policy_list[int(choice) - 1]
            policy = policies[policy_name]
            
        except:
            print("❌ Selección inválida")
            return
        
        print(f"\n📝 Editando: {policy_name}")
        print(f"   Descripción actual: {policy.get('description', 'N/A')}")
        print(f"   Block actual: {policy.get('policy_document', 'N/A')}")
        
        # Opciones de edición
        print("\n¿Qué deseas editar?")
        print("   1. Descripción")
        print("   2. Policy Block")
        print("   3. Tags canónicos")
        print("   4. Todo")
        
        edit_choice = input("Selecciona opción (1-4): ").strip()
        
        if edit_choice == "1" or edit_choice == "4":
            new_description = input(f"Nueva descripción [{policy.get('description', '')}]: ").strip()
            if new_description:
                policy['description'] = new_description
        
        if edit_choice == "2" or edit_choice == "4":
            available_blocks = self._get_available_policy_blocks()
            if available_blocks:
                print("\nBloques disponibles:")
                for i, block in enumerate(available_blocks, 1):
                    print(f"   {i}. {block}")
            
            new_block = input(f"Nuevo policy block [{policy.get('policy_document', '')}]: ").strip()
            if new_block:
                policy['policy_document'] = new_block
        
        if edit_choice == "3" or edit_choice == "4":
            print("\n🏷️ Editando tags canónicos:")
            tags = policy.get('canonical_tags', {})
            
            for key, value in tags.items():
                if key in ['Name', 'Fechas de Creación', 'Creado Por']:
                    continue  # No editar estos campos automáticos
                
                new_value = input(f"{key} [{value}]: ").strip()
                if new_value:
                    tags[key] = self.normalize_to_camelcase(new_value)
        
        # Actualizar timestamp
        if 'canonical_tags' in policy:
            policy['canonical_tags']['Fechas de Creación'] = datetime.now().strftime("%Y-%m-%dT%H:%M:%SZ")
        
        self._save_catalog()
        print(f"✅ Política '{policy_name}' actualizada exitosamente")
    
    def delete_policy(self):
        """Eliminar política"""
        policies = self.policies_data.get('policies', {})
        if not policies:
            print("📋 No hay políticas para eliminar")
            return
        
        print("\n🗑️ ELIMINAR POLÍTICA")
        print("=" * 50)
        print("⚠️ ADVERTENCIA: Esta acción es irreversible")
        
        # Mostrar políticas disponibles
        policy_list = list(policies.keys())
        for i, name in enumerate(policy_list, 1):
            desc = policies[name].get('description', 'Sin descripción')
            print(f"   {i}. {name} - {desc}")
        
        try:
            choice = input(f"\nSelecciona política a eliminar (1-{len(policy_list)}): ").strip()
            if not choice.isdigit() or not (1 <= int(choice) <= len(policy_list)):
                print("❌ Selección inválida")
                return
            
            policy_name = policy_list[int(choice) - 1]
            
        except:
            print("❌ Selección inválida")
            return
        
        print(f"\n⚠️ ¿Estás SEGURO de eliminar '{policy_name}'?")
        print("   Esta política puede estar siendo usada por roles existentes.")
        
        confirm = input("Escribe 'CONFIRMAR' para eliminar: ").strip()
        if confirm == "CONFIRMAR":
            del self.policies_data['policies'][policy_name]
            self._save_catalog()
            print(f"✅ Política '{policy_name}' eliminada exitosamente")
        else:
            print("❌ Eliminación cancelada")

def main():
    """Función principal con menú interactivo"""
    manager = PolicyManager()
    
    while True:
        print("\n" + "="*60)
        print("🏢 ENTERPRISE POLICY MANAGEMENT SYSTEM")
        print("="*60)
        print("1. 📋 Listar todas las políticas")
        print("2. 🔍 Buscar políticas")
        print("3. 🆕 Crear nueva política")
        print("4. ✏️ Editar política existente")
        print("5. 🗑️ Eliminar política")
        print("6. 📊 Estadísticas del catálogo")
        print("0. 🚪 Salir")
        print("-" * 60)
        
        choice = input("Selecciona opción: ").strip()
        
        try:
            if choice == "1":
                service_filter = input("Filtrar por servicio (opcional): ").strip()
                manager.list_policies(service_filter if service_filter else None)
                
            elif choice == "2":
                query = input("Buscar políticas (nombre/servicio/descripción): ").strip()
                if query:
                    manager.search_policies(query)
                else:
                    print("❌ Debes ingresar un término de búsqueda")
                
            elif choice == "3":
                manager.create_policy()
                
            elif choice == "4":
                manager.edit_policy()
                
            elif choice == "5":
                manager.delete_policy()
                
            elif choice == "6":
                policies = manager.policies_data.get('policies', {})
                blocks = manager.policies_data.get('policy_blocks', {})
                services = {}
                for name in policies.keys():
                    service = name.split('-')[1] if '-' in name else 'Unknown'
                    services[service] = services.get(service, 0) + 1
                
                print(f"\n📊 ESTADÍSTICAS DEL CATÁLOGO:")
                print(f"   📋 Total políticas: {len(policies)}")
                print(f"   📦 Policy blocks: {len(blocks)}")
                print(f"   🔐 Servicios cubiertos:")
                for service, count in sorted(services.items()):
                    print(f"      - {service}: {count} políticas")
                
            elif choice == "0":
                print("👋 ¡Hasta luego!")
                break
                
            else:
                print("❌ Opción inválida")
                
        except KeyboardInterrupt:
            print("\n👋 ¡Hasta luego!")
            break
        except Exception as e:
            print(f"❌ Error: {e}")

if __name__ == "__main__":
    main()