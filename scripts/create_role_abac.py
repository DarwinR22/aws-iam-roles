#!/usr/bin/env python3
"""
🚀 Generador Enterprise de Roles IAM - ABAC Compatible
Compatible con la nueva arquitectura catalog-based pero mantiene interfaz simple
"""

import json
import os
import re
import sys
import yaml
from pathlib import Path
from datetime import datetime

class IAMRoleGeneratorABAC:
    """Generador que mantiene la interfaz simple pero usa la nueva arquitectura ABAC."""
    
    def __init__(self):
        self.base_path = Path('.')
        self.catalog_path = Path('catalog')
        self.ensure_directories()
        
        # Building blocks ABAC disponibles
        self.abac_building_blocks = {
            'S3': {
                'tag_based_read': 'Lectura basada en etiquetas coincidentes',
                'tag_based_write': 'Escritura basada en etiquetas coincidentes', 
                'tag_based_read_write': 'Lectura/Escritura basada en etiquetas',
                'path_based_read_write': 'Acceso especifico a ruta de S3'
            },
            'DynamoDB': {
                'tag_based_read': 'Lectura de tablas con etiquetas coincidentes',
                'tag_based_write': 'Escritura en tablas con etiquetas coincidentes'
            },
            'Lambda': {
                'tag_based_invoke': 'Invocacion de funciones con etiquetas coincidentes'
            },
            'SQS': {
                'tag_based_produce': 'Envio a colas con etiquetas coincidentes',
                'tag_based_consume': 'Consumo de colas con etiquetas coincidentes'
            }
        }
        
        # Trust policies comunes
        self.trust_policies = {
            'lambda': 'lambda_service',
            'ec2': 'ec2_service', 
            'ecs': 'ecs_service',
            'github': 'github_actions'
        }
        
        # Politicas AWS administradas comunes
        self.aws_managed_common = [
            'service-role/AWSLambdaBasicExecutionRole',
            'ReadOnlyAccess',
            'PowerUserAccess',
            'EC2ReadOnlyAccess',
            'CloudWatchReadOnlyAccess'
        ]

    def ensure_directories(self):
        """Crear directorios necesarios."""
        self.catalog_path.mkdir(exist_ok=True)
        
        # Crear catalog/roles.yaml si no existe
        roles_file = self.catalog_path / 'roles.yaml'
        if not roles_file.exists():
            initial_catalog = {
                'roles': {}
            }
            with open(roles_file, 'w', encoding='utf-8') as f:
                yaml.dump(initial_catalog, f, default_flow_style=False, allow_unicode=True)

    def print_banner(self):
        """Banner enterprise."""
        print("🚀 " + "="*70)
        print("🚀 GENERADOR ENTERPRISE DE ROLES IAM - ABAC")
        print("🚀 Interfaz simple + Arquitectura enterprise automatica")
        print("🚀 " + "="*70)
        print()

    def load_existing_catalog(self):
        """Cargar catalogo existente."""
        roles_file = self.catalog_path / 'roles.yaml'
        try:
            with open(roles_file, 'r', encoding='utf-8') as f:
                return yaml.safe_load(f) or {'roles': {}}
        except:
            return {'roles': {}}

    def save_catalog(self, catalog_data):
        """Guardar catalogo actualizado."""
        roles_file = self.catalog_path / 'roles.yaml'
        with open(roles_file, 'w', encoding='utf-8') as f:
            yaml.dump(catalog_data, f, default_flow_style=False, allow_unicode=True, indent=2)

    def get_role_name(self):
        """Obtener nombre del rol."""
        print("📝 INFORMACIoN BaSICA DEL ROL")
        print("=" * 40)
        
        while True:
            print("\n💡 Ejemplos de nombres:")
            print("   • s3-data-analytics-dev-reader")
            print("   • lambda-bi-processor-prod")
            print("   • ec2-web-app-qa-manager")
            
            role_name = input("\n👉 Nombre del rol: ").strip()
            if role_name and re.match(r'^[a-zA-Z0-9\-_]+$', role_name):
                return role_name
            print("❌ Nombre invalido. Usa solo letras, numeros, guiones y guiones bajos.")

    def get_role_description(self, role_name):
        """Obtener descripcion del rol."""
        suggestion = f"Rol para {role_name.replace('-', ' ')}"
        print(f"\n💡 Sugerencia: {suggestion}")
        
        description = input("👉 Descripcion del rol (Enter para usar sugerencia): ").strip()
        return description if description else suggestion

    def get_trust_policy(self):
        """Seleccionar trust policy."""
        print("\n🔐 TRUST POLICY (¿Que servicio usara este rol?)")
        print("=" * 50)
        
        services = [
            ("Lambda function", "lambda"),
            ("EC2 instance", "ec2"), 
            ("ECS task", "ecs"),
            ("GitHub Actions", "github")
        ]
        
        for i, (display, key) in enumerate(services, 1):
            print(f"   [{i}] {display}")
        
        while True:
            choice = input(f"\n👉 Selecciona servicio [1-{len(services)}]: ").strip()
            if choice.isdigit():
                choice_num = int(choice)
                if 1 <= choice_num <= len(services):
                    return self.trust_policies[services[choice_num - 1][1]]
            print("❌ Opcion invalida")

    def get_aws_managed_policies(self):
        """Seleccionar politicas AWS administradas."""
        print("\n☁️ POLiTICAS AWS ADMINISTRADAS")
        print("=" * 35)
        print("Selecciona politicas AWS (separadas por comas, o Enter para ninguna):")
        
        for i, policy in enumerate(self.aws_managed_common, 1):
            print(f"   [{i}] {policy}")
        
        selection = input(f"\n👉 Numeros separados por comas [1-{len(self.aws_managed_common)}]: ").strip()
        
        selected_policies = []
        if selection:
            try:
                indices = [int(x.strip()) for x in selection.split(',')]
                for idx in indices:
                    if 1 <= idx <= len(self.aws_managed_common):
                        selected_policies.append(self.aws_managed_common[idx - 1])
            except ValueError:
                print("❌ Formato invalido, no se agregaron politicas AWS")
        
        return selected_policies

    def get_abac_policies(self):
        """Seleccionar building blocks ABAC."""
        print("\n🏗️ BUILDING BLOCKS ABAC")
        print("=" * 25)
        print("Selecciona los permisos que necesita el rol:")
        
        selected_blocks = []
        
        for service, blocks in self.abac_building_blocks.items():
            print(f"\n🔹 {service}:")
            for block_key, description in blocks.items():
                response = input(f"   ¿Agregar {block_key}? ({description}) [s/N]: ").strip().lower()
                if response in ['s', 'si', 'si', 'y', 'yes']:
                    selected_blocks.append({
                        'type': f"{service.lower()}_{block_key}",
                        'service': service.lower()
                    })
        
        return selected_blocks

    def get_canonical_tags(self, role_name):
        """Obtener etiquetas canonicas."""
        print("\n🏷️ ETIQUETAS CANoNICAS (23 obligatorias)")
        print("=" * 40)
        
        # Tags basicos que el usuario debe proporcionar
        user_tags = {}
        
        required_user_input = [
            ('Ambiente', 'Dev/QA/Prod', 'Dev'),
            ('Proyecto', 'Nombre del proyecto', 'DataAnalytics'),
            ('Propietario', 'Equipo responsable', 'DevOps-Team'),
            ('Contacto', 'Email del equipo', 'devops@claro.com')
        ]
        
        for tag_name, description, example in required_user_input:
            while True:
                value = input(f"👉 {tag_name} ({description}) [ej: {example}]: ").strip()
                if value:
                    user_tags[tag_name] = value
                    break
                print("❌ Este campo es obligatorio")
        
        # Tags automaticos/predeterminados
        auto_tags = {
            'Pais': 'GT',
            'Direccion': 'Tecnologia', 
            'Gerencia': 'MCI',
            'Cuenta': '393209814297',
            'Modulo': user_tags.get('Proyecto', 'General'),
            'Alcance SOX': 'No',
            'Proveedor': 'Claro',
            'Layer': 'Application',
            'Dominio': 'Infrastructure',
            'Subdominio': 'IAM',
            'Aplicacion': role_name,
            'Name': role_name,
            'Soporte': user_tags.get('Propietario', 'DevOps-Team'),
            'Fechas de Creacion': datetime.now().strftime('%Y-%m-%dT%H:%M:%SZ'),
            'Creado Por': 'terraform-iac',
            'Tipo de Recurso': 'IAM-Role',
            'Ciclo de Vida': 'Active',
            'Version': '1.0',
            'Map-migrated': f"mig_{role_name.replace('-', '_')}"
        }
        
        # Combinar tags del usuario con automaticos
        all_tags = {**auto_tags, **user_tags}
        
        print(f"\n✅ Se generaron las 23 etiquetas canonicas automaticamente")
        return all_tags

    def generate_role_definition(self):
        """Generar definicion completa del rol."""
        print("\n🚀 CREANDO ROL ENTERPRISE CON ABAC...")
        
        # Recopilar informacion
        role_name = self.get_role_name()
        description = self.get_role_description(role_name)
        trust_policy = self.get_trust_policy()
        aws_managed = self.get_aws_managed_policies()
        policy_blocks = self.get_abac_policies()
        canonical_tags = self.get_canonical_tags(role_name)
        
        # Crear definicion del rol
        role_definition = {
            'description': description,
            'trust_policy': trust_policy,
            'permission_boundary': 'app_standard',
            'canonical_tags': canonical_tags
        }
        
        # Agregar politicas si existen
        policies = {}
        if aws_managed:
            policies['aws_managed'] = aws_managed
        if policy_blocks:
            policies['policy_blocks'] = policy_blocks
        
        if policies:
            role_definition['policies'] = policies
        
        return role_name, role_definition

    def preview_role(self, role_name, role_definition):
        """Mostrar preview del rol."""
        print("\n" + "="*60)
        print("📋 PREVIEW DEL ROL")
        print("="*60)
        
        print(f"🏷️  Nombre: {role_name}")
        print(f"📝 Descripcion: {role_definition['description']}")
        print(f"🔐 Trust Policy: {role_definition['trust_policy']}")
        print(f"🛡️  Permission Boundary: {role_definition['permission_boundary']}")
        
        if 'policies' in role_definition:
            if 'aws_managed' in role_definition['policies']:
                print(f"☁️  AWS Managed: {len(role_definition['policies']['aws_managed'])} politicas")
            if 'policy_blocks' in role_definition['policies']:
                print(f"🏗️  ABAC Blocks: {len(role_definition['policies']['policy_blocks'])} building blocks")
        
        print(f"🏷️  Canonical Tags: 23 etiquetas completas")
        
        print("\n" + "="*60)

    def save_role_to_catalog(self, role_name, role_definition):
        """Guardar rol en el catalogo."""
        catalog = self.load_existing_catalog()
        catalog['roles'][role_name] = role_definition
        self.save_catalog(catalog)
        
        print(f"✅ Rol '{role_name}' guardado en catalog/roles.yaml")

    def show_next_steps(self, role_name):
        """Mostrar pasos siguientes."""
        print("\n🎯 SIGUIENTES PASOS:")
        print("="*20)
        print("1. Revisar el rol en: catalog/roles.yaml")
        print("2. Aplicar los cambios:")
        print("   cd environments/dev")
        print("   terraform plan")
        print("   terraform apply")
        print("3. El rol sera creado automaticamente con ABAC! 🚀")

    def run(self):
        """Ejecutar el generador."""
        try:
            self.print_banner()
            role_name, role_definition = self.generate_role_definition()
            self.preview_role(role_name, role_definition)
            
            confirm = input("\n👉 ¿Crear este rol? [S/n]: ").strip().lower()
            if confirm in ['', 's', 'si', 'si', 'y', 'yes']:
                self.save_role_to_catalog(role_name, role_definition)
                self.show_next_steps(role_name)
                print(f"\n🎉 ¡Rol '{role_name}' creado exitosamente!")
            else:
                print("❌ Operacion cancelada.")
                
        except KeyboardInterrupt:
            print("\n\n❌ Operacion cancelada por el usuario.")
        except Exception as e:
            print(f"\n❌ Error: {e}")

if __name__ == "__main__":
    generator = IAMRoleGeneratorABAC()
    generator.run()