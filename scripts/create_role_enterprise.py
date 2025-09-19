#!/usr/bin/env python3
"""
🏗️ Generador Enterprise de Roles IAM - MCI
Arquitectura Building Blocks + S3 Granular + Tags Automáticos
"""

import json
import os
import re
import sys
from pathlib import Path
from datetime import datetime

class IAMRoleGeneratorEnterprise:
    """Generador enterprise con building blocks y S3 granular."""
    
    def __init__(self):
        self.base_path = Path('gerencias')
        self.politicas_path = Path('politicas')
        self.base_path.mkdir(exist_ok=True)
        self.politicas_path.mkdir(exist_ok=True)
        
        # Building blocks MCI disponibles
        self.mci_building_blocks = {
            'S3': [
                'MCI-S3-ReadOnly',
                'MCI-S3-Write'
            ],
            'Lambda': [
                'MCI-Lambda-Invoke'
            ],
            'DynamoDB': [
                'MCI-DynamoDB-ReadOnly',
                'MCI-DynamoDB-Write'
            ]
        }
        
        # Políticas AWS administradas comunes
        self.aws_managed_common = [
            'ReadOnlyAccess',
            'PowerUserAccess',
            'ViewOnlyAccess',
            'IAMReadOnlyAccess',
            'CloudWatchReadOnlyAccess',
            'EC2ReadOnlyAccess'
        ]

    def print_banner(self):
        """Banner enterprise."""
        print("🏗️ " + "="*70)
        print("🏗️ GENERADOR ENTERPRISE DE ROLES IAM - MCI")
        print("🏗️ Building Blocks + S3 Granular + Tags Automáticos")
        print("🏗️ " + "="*70)
        print()
        print("✨ CARACTERÍSTICAS ENTERPRISE:")
        print("   🧱 Building blocks MCI reutilizables")
        print("   🔐 S3 granular por bucket/path")
        print("   🏷️ Tags automáticos por área")
        print("   📈 Escalable a 500+ roles")
        print()

    def get_existing_areas(self):
        """Obtener áreas existentes."""
        areas = []
        for item in self.base_path.iterdir():
            if item.is_dir() and not item.name.startswith('.'):
                areas.append(item.name)
        return sorted(areas)

    def select_or_create_area(self):
        """Seleccionar o crear área de negocio."""
        print("🏢 PASO 1: Selección de Área de Negocio")
        print("-" * 40)
        
        areas = self.get_existing_areas()
        
        if areas:
            print("📋 Áreas existentes:")
            for i, area in enumerate(areas, 1):
                print(f"   [{i}] {area}")
            print(f"   [{len(areas) + 1}] 🆕 Crear nueva área")
            
            while True:
                choice = input(f"\n👉 Selecciona opción [1-{len(areas) + 1}]: ").strip()
                if choice.isdigit():
                    choice_num = int(choice)
                    if 1 <= choice_num <= len(areas):
                        selected_area = areas[choice_num - 1]
                        print(f"✅ Área seleccionada: {selected_area}")
                        return selected_area
                    elif choice_num == len(areas) + 1:
                        break
                print("❌ Opción inválida")
        else:
            print("📝 No hay áreas existentes, crear nueva:")
        
        # Crear nueva área
        print("\n💡 Ejemplos de áreas: ventas, marketing, finanzas, rrhh, it, operaciones")
        while True:
            area = input("👉 Nombre de la nueva área: ").strip().lower()
            if area and re.match(r'^[a-z][a-z0-9_]*$', area):
                print(f"✅ Nueva área: {area}")
                return area
            print("❌ Solo letras minúsculas, números y guiones bajos")

    def get_role_details(self, area):
        """Obtener detalles del rol."""
        print(f"\n👤 PASO 2: Detalles del Rol en {area}")
        print("-" * 40)
        
        # Nombre del rol
        while True:
            print(f"\n💡 Ejemplos: analista, manager, director, especialista, consultor")
            nombre = input("👉 Nombre del rol (sin prefijos): ").strip().lower()
            if nombre and re.match(r'^[a-z][a-z0-9-]*$', nombre):
                break
            print("❌ Solo letras minúsculas, números y guiones")
        
        # Descripción
        descripcion = input("👉 Descripción del rol: ").strip()
        if not descripcion:
            descripcion = f"Rol {nombre} para el área {area}"
        
        # Generar nombre completo del rol
        role_name = f"rol-{area}-{nombre}"
        
        print(f"\n✅ Rol a crear: {role_name}")
        print(f"✅ Descripción: {descripcion}")
        
        return role_name, descripcion

    def select_building_blocks(self):
        """Seleccionar building blocks MCI."""
        print(f"\n🧱 PASO 3: Building Blocks MCI")
        print("-" * 40)
        print("Selecciona las capacidades que necesita el rol:")
        print()
        
        selected_blocks = []
        
        for service, blocks in self.mci_building_blocks.items():
            print(f"🔹 {service}:")
            for i, block in enumerate(blocks, 1):
                description = self.get_block_description(block)
                print(f"   [{i}] {block} - {description}")
            
            while True:
                choices = input(f"👉 Selecciona {service} [números separados por coma, o 'skip']: ").strip()
                if choices.lower() == 'skip':
                    break
                
                try:
                    selected_indices = [int(x.strip()) for x in choices.split(',') if x.strip()]
                    valid_blocks = []
                    for idx in selected_indices:
                        if 1 <= idx <= len(blocks):
                            block_name = blocks[idx - 1]
                            valid_blocks.append(block_name)
                            print(f"   ✅ Agregado: {block_name}")
                    
                    if valid_blocks:
                        selected_blocks.extend(valid_blocks)
                    break
                except ValueError:
                    print("❌ Formato inválido. Usa números separados por coma")
            print()
        
        return selected_blocks

    def get_block_description(self, block_name):
        """Obtener descripción de building block."""
        descriptions = {
            'MCI-S3-ReadOnly': 'Lectura global en S3',
            'MCI-S3-Write': 'Escritura global en S3',
            'MCI-Lambda-Invoke': 'Ejecutar funciones Lambda',
            'MCI-DynamoDB-ReadOnly': 'Lectura en DynamoDB',
            'MCI-DynamoDB-Write': 'Escritura en DynamoDB'
        }
        return descriptions.get(block_name, 'Building block personalizado')

    def configure_s3_granular(self):
        """Configurar acceso S3 granular."""
        print(f"\n🔐 PASO 4: S3 Granular (Opcional)")
        print("-" * 40)
        print("¿Necesitas acceso específico a buckets/rutas S3?")
        
        s3_configs = []
        
        while True:
            add_s3 = input("👉 ¿Agregar acceso S3 específico? [y/n]: ").strip().lower()
            if add_s3 not in ['y', 'yes', 'n', 'no']:
                continue
            if add_s3 in ['n', 'no']:
                break
            
            print("\n🪣 Configurar acceso S3:")
            bucket = input("👉 Nombre del bucket: ").strip()
            path = input("👉 Prefijo/ruta (ej: ventas/reportes): ").strip()
            
            print("\n📝 Tipo de acceso:")
            print("   [1] Solo lectura")
            print("   [2] Lectura y escritura")
            
            while True:
                access_choice = input("👉 Selecciona [1-2]: ").strip()
                if access_choice == '1':
                    access_type = 'readonly'
                    break
                elif access_choice == '2':
                    access_type = 'write'
                    break
                print("❌ Opción inválida")
            
            config_name = f"{bucket.replace('-', '')}_{path.replace('/', '_')}"
            s3_config = {
                'name': config_name,
                'bucket': bucket,
                'path': path,
                'access_type': access_type
            }
            
            s3_configs.append(s3_config)
            print(f"✅ S3 configurado: {bucket}/{path} ({access_type})")
            
            more = input("👉 ¿Agregar más configuraciones S3? [y/n]: ").strip().lower()
            if more in ['n', 'no']:
                break
        
        return s3_configs

    def select_aws_managed_policies(self):
        """Seleccionar políticas AWS administradas."""
        print(f"\n☁️ PASO 5: Políticas AWS Administradas (Opcional)")
        print("-" * 40)
        print("Políticas AWS comunes:")
        
        for i, policy in enumerate(self.aws_managed_common, 1):
            description = self.get_aws_policy_description(policy)
            print(f"   [{i}] {policy} - {description}")
        
        selected_aws = []
        
        while True:
            choices = input("👉 Selecciona políticas [números separados por coma, o 'skip']: ").strip()
            if choices.lower() == 'skip':
                break
            
            try:
                selected_indices = [int(x.strip()) for x in choices.split(',') if x.strip()]
                for idx in selected_indices:
                    if 1 <= idx <= len(self.aws_managed_common):
                        policy = self.aws_managed_common[idx - 1]
                        selected_aws.append(f"arn:aws:iam::aws:policy/{policy}")
                        print(f"   ✅ Agregado: {policy}")
                break
            except ValueError:
                print("❌ Formato inválido")
        
        return selected_aws

    def get_aws_policy_description(self, policy_name):
        """Descripción de políticas AWS."""
        descriptions = {
            'ReadOnlyAccess': 'Acceso solo lectura a todos los servicios',
            'PowerUserAccess': 'Acceso completo excepto IAM',
            'ViewOnlyAccess': 'Ver configuraciones sin datos',
            'IAMReadOnlyAccess': 'Solo lectura IAM',
            'CloudWatchReadOnlyAccess': 'Solo lectura CloudWatch',
            'EC2ReadOnlyAccess': 'Solo lectura EC2'
        }
        return descriptions.get(policy_name, 'Política AWS estándar')

    def create_trust_policy(self):
        """Crear trust policy básica."""
        return {
            "Version": "2012-10-17",
            "Statement": [
                {
                    "Effect": "Allow",
                    "Principal": {
                        "AWS": "arn:aws:iam::ACCOUNT_ID:root"
                    },
                    "Action": "sts:AssumeRole",
                    "Condition": {
                        "StringEquals": {
                            "sts:ExternalId": "mci-external-id"
                        }
                    }
                }
            ]
        }

    def generate_role_json(self, role_name, descripcion, mci_blocks, s3_configs, aws_policies, area):
        """Generar JSON del rol enterprise."""
        role_data = {
            "role_name": role_name,
            "description": descripcion,
            "trust_policy": self.create_trust_policy(),
            "policies": {},
            "tags": {
                "RoleType": "Application",
                "CreatedBy": "IAMGenerator",
                "CreatedDate": datetime.now().strftime("%Y-%m-%d"),
                "Nivel": "Standard"
            }
        }
        
        # Building blocks MCI
        if mci_blocks:
            role_data["policies"]["mci_generic"] = mci_blocks
        
        # Políticas AWS administradas
        if aws_policies:
            role_data["policies"]["aws_managed"] = aws_policies
        
        # S3 granular (se configurará en area-metadata.tfvars)
        if s3_configs:
            s3_policy_names = [config['name'] for config in s3_configs]
            role_data["policies"]["s3_granular"] = s3_policy_names
        
        return role_data, s3_configs

    def update_area_metadata(self, s3_configs, area):
        """Actualizar area-metadata.tfvars con configuraciones S3."""
        if not s3_configs:
            return
        
        metadata_file = Path('environments/dev/area-metadata.tfvars')
        print(f"\n📝 Actualizando configuración S3 en {metadata_file}")
        
        for config in s3_configs:
            print(f"\n🔧 Agregar esta configuración a area-metadata.tfvars:")
            print(f"  \"{config['name']}\" = {{")
            print(f"    bucket_name = \"{config['bucket']}\"")
            print(f"    path_prefix = \"{config['path']}\"")
            print(f"    access_type = \"{config['access_type']}\"")
            print(f"    description = \"Acceso {area} a {config['bucket']}/{config['path']}\"")
            print(f"  }}")

    def create_directory_structure(self, area):
        """Crear estructura de directorios."""
        area_path = self.base_path / area
        area_path.mkdir(exist_ok=True)
        return area_path

    def save_role_file(self, area_path, role_name, role_data):
        """Guardar archivo de rol."""
        filename = f"{role_name}.json"
        file_path = area_path / filename
        
        with open(file_path, 'w', encoding='utf-8') as f:
            json.dump(role_data, f, indent=2, ensure_ascii=False)
        
        return file_path

    def print_summary(self, role_name, file_path, area, mci_blocks, s3_configs, aws_policies):
        """Imprimir resumen de creación."""
        print("\n" + "="*70)
        print("🎉 ROL ENTERPRISE CREADO EXITOSAMENTE")
        print("="*70)
        print(f"📁 Archivo: {file_path}")
        print(f"🏢 Área: {area}")
        print(f"👤 Rol: {role_name}")
        print()
        
        if mci_blocks:
            print("🧱 Building Blocks MCI:")
            for block in mci_blocks:
                print(f"   ✅ {block}")
        
        if aws_policies:
            print("\n☁️ Políticas AWS:")
            for policy in aws_policies:
                policy_name = policy.split('/')[-1]
                print(f"   ✅ {policy_name}")
        
        if s3_configs:
            print("\n🔐 Configuraciones S3:")
            for config in s3_configs:
                print(f"   ✅ {config['bucket']}/{config['path']} ({config['access_type']})")
        
        print(f"\n🏷️ Tags automáticos por área:")
        print(f"   • Area: {area}")
        print(f"   • Propietario: [configurado en area-metadata.tfvars]")
        print(f"   • Team: [configurado en area-metadata.tfvars]")
        print(f"   • CostCenter: [configurado en area-metadata.tfvars]")
        
        print("\n🚀 PRÓXIMOS PASOS:")
        if s3_configs:
            print("   1. Actualizar area-metadata.tfvars con configuraciones S3 mostradas arriba")
            print("   2. git add . && git commit -m 'feat: add enterprise role'")
            print("   3. git push")
        else:
            print("   1. git add . && git commit -m 'feat: add enterprise role'")
            print("   2. git push")
        print("   3. GitHub Actions desplegará automáticamente")

    def run(self):
        """Ejecutar generador enterprise."""
        try:
            self.print_banner()
            
            # Paso 1: Seleccionar área
            area = self.select_or_create_area()
            
            # Paso 2: Detalles del rol
            role_name, descripcion = self.get_role_details(area)
            
            # Paso 3: Building blocks
            mci_blocks = self.select_building_blocks()
            
            # Paso 4: S3 granular
            s3_configs = self.configure_s3_granular()
            
            # Paso 5: AWS policies
            aws_policies = self.select_aws_managed_policies()
            
            # Generar rol
            role_data, s3_configs = self.generate_role_json(
                role_name, descripcion, mci_blocks, s3_configs, aws_policies, area
            )
            
            # Crear estructura y guardar
            area_path = self.create_directory_structure(area)
            file_path = self.save_role_file(area_path, role_name, role_data)
            
            # Actualizar metadata si hay S3
            if s3_configs:
                self.update_area_metadata(s3_configs, area)
            
            # Mostrar resumen
            self.print_summary(role_name, file_path, area, mci_blocks, s3_configs, aws_policies)
            
        except KeyboardInterrupt:
            print("\n\n❌ Operación cancelada por el usuario")
            sys.exit(1)
        except Exception as e:
            print(f"\n❌ Error: {e}")
            sys.exit(1)

def main():
    """Función principal."""
    generator = IAMRoleGeneratorEnterprise()
    generator.run()

if __name__ == "__main__":
    main()
