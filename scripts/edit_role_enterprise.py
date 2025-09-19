#!/usr/bin/env python3
"""
🔧 Editor Enterprise de Roles IAM - MCI
Building Blocks + S3 Granular + Tags Automáticos
"""

import json
import os
import re
import sys
from pathlib import Path
from datetime import datetime

class IAMRoleEditorEnterprise:
    """Editor enterprise para roles con building blocks."""
    
    def __init__(self):
        self.base_path = Path('gerencias')
        self.environments_path = Path('environments/dev')
        
        # Building blocks MCI disponibles
        self.mci_building_blocks = {
            'S3': ['MCI-S3-ReadOnly', 'MCI-S3-Write'],
            'Lambda': ['MCI-Lambda-Invoke'],
            'DynamoDB': ['MCI-DynamoDB-ReadOnly', 'MCI-DynamoDB-Write']
        }
        
        # AWS managed policies comunes
        self.aws_managed_common = [
            'ReadOnlyAccess', 'PowerUserAccess', 'ViewOnlyAccess',
            'IAMReadOnlyAccess', 'CloudWatchReadOnlyAccess', 'EC2ReadOnlyAccess'
        ]

    def print_banner(self):
        """Banner del editor enterprise."""
        print("🔧 " + "="*70)
        print("🔧 EDITOR ENTERPRISE DE ROLES IAM - MCI")
        print("🔧 Building Blocks + S3 Granular + Navegación Escalable")
        print("🔧 " + "="*70)
        print()

    def organize_roles_by_area(self):
        """Organizar roles por área de negocio."""
        roles_by_area = {}
        
        if not self.base_path.exists():
            return roles_by_area
        
        for area_dir in self.base_path.iterdir():
            if area_dir.is_dir() and not area_dir.name.startswith('.'):
                area_name = area_dir.name
                roles = []
                
                for role_file in area_dir.glob('rol-*.json'):
                    if role_file.is_file():
                        roles.append({
                            'name': role_file.stem,
                            'path': role_file,
                            'area': area_name
                        })
                
                if roles:
                    roles_by_area[area_name] = sorted(roles, key=lambda x: x['name'])
        
        return roles_by_area

    def display_area_navigation(self, roles_by_area):
        """Mostrar navegación por áreas escalable."""
        if not roles_by_area:
            print("❌ No se encontraron roles en gerencias/")
            return None, None
        
        print("🏢 NAVEGACIÓN POR ÁREAS DE NEGOCIO")
        print("-" * 50)
        
        areas = list(roles_by_area.keys())
        for i, area in enumerate(areas, 1):
            role_count = len(roles_by_area[area])
            print(f"   [{i}] {area.upper()} ({role_count} roles)")
        
        while True:
            try:
                choice = input(f"\n👉 Selecciona área [1-{len(areas)}]: ").strip()
                area_idx = int(choice) - 1
                
                if 0 <= area_idx < len(areas):
                    selected_area = areas[area_idx]
                    area_roles = roles_by_area[selected_area]
                    
                    print(f"\n📁 ROLES EN {selected_area.upper()}:")
                    print("-" * 30)
                    
                    for i, role in enumerate(area_roles, 1):
                        print(f"   [{i}] {role['name']}")
                    
                    while True:
                        try:
                            role_choice = input(f"\n👉 Selecciona rol [1-{len(area_roles)}]: ").strip()
                            role_idx = int(role_choice) - 1
                            
                            if 0 <= role_idx < len(area_roles):
                                return selected_area, area_roles[role_idx]
                            print("❌ Número de rol inválido")
                        except ValueError:
                            print("❌ Ingresa un número válido")
                print("❌ Número de área inválido")
            except ValueError:
                print("❌ Ingresa un número válido")

    def load_role_data(self, role_info):
        """Cargar datos del rol."""
        try:
            with open(role_info['path'], 'r', encoding='utf-8') as f:
                return json.load(f)
        except Exception as e:
            print(f"❌ Error cargando rol: {e}")
            return None

    def display_role_summary(self, role_name, role_data, area):
        """Mostrar resumen enterprise del rol."""
        print("\n" + "="*70)
        print(f"📋 RESUMEN ENTERPRISE: {role_name}")
        print("="*70)
        print(f"🏢 Área: {area}")
        print(f"📝 Descripción: {role_data.get('description', 'Sin descripción')}")
        print()
        
        # Building blocks MCI
        mci_policies = role_data.get('policies', {}).get('mci_generic', [])
        if mci_policies:
            print("🧱 BUILDING BLOCKS MCI:")
            for policy in mci_policies:
                description = self.get_block_description(policy)
                print(f"   ✅ {policy} - {description}")
        else:
            print("🧱 BUILDING BLOCKS MCI: Ninguno")
        
        print()
        
        # S3 Granular
        s3_policies = role_data.get('policies', {}).get('s3_granular', [])
        if s3_policies:
            print("🔐 S3 GRANULAR:")
            for policy in s3_policies:
                print(f"   ✅ {policy}")
        else:
            print("🔐 S3 GRANULAR: Ninguno")
        
        print()
        
        # AWS Managed
        aws_policies = role_data.get('policies', {}).get('aws_managed', [])
        if aws_policies:
            print("☁️ AWS ADMINISTRADAS:")
            for policy in aws_policies:
                policy_name = policy.split('/')[-1] if '/' in policy else policy
                print(f"   ✅ {policy_name}")
        else:
            print("☁️ AWS ADMINISTRADAS: Ninguna")
        
        print()
        
        # Tags
        tags = role_data.get('tags', {})
        if tags:
            print("🏷️ TAGS DEL ROL:")
            for key, value in tags.items():
                print(f"   • {key}: {value}")
        
        print()
        print("🏷️ TAGS AUTOMÁTICOS POR ÁREA:")
        print(f"   • Area: {area}")
        print("   • Propietario: [configurado en area-metadata.tfvars]")
        print("   • Team: [configurado en area-metadata.tfvars]")
        print("   • CostCenter: [configurado en area-metadata.tfvars]")

    def get_block_description(self, block_name):
        """Descripción de building blocks."""
        descriptions = {
            'MCI-S3-ReadOnly': 'Lectura global en S3',
            'MCI-S3-Write': 'Escritura global en S3',
            'MCI-Lambda-Invoke': 'Ejecutar funciones Lambda',
            'MCI-DynamoDB-ReadOnly': 'Lectura en DynamoDB',
            'MCI-DynamoDB-Write': 'Escritura en DynamoDB'
        }
        return descriptions.get(block_name, 'Building block personalizado')

    def show_edit_menu(self):
        """Mostrar menú de edición enterprise."""
        print("\n🔧 OPCIONES DE EDICIÓN ENTERPRISE")
        print("-" * 40)
        print("   [1] 🧱 Editar Building Blocks MCI")
        print("   [2] 🔐 Gestionar S3 Granular")
        print("   [3] ☁️ Editar Políticas AWS")
        print("   [4] 🏷️ Editar Tags del Rol")
        print("   [5] 📝 Cambiar Descripción")
        print("   [6] 💾 Guardar y Salir")
        print("   [7] ❌ Salir sin Guardar")
        
        return input("\n👉 Selecciona opción [1-7]: ").strip()

    def edit_building_blocks(self, role_data):
        """Editar building blocks MCI."""
        print("\n🧱 EDITAR BUILDING BLOCKS MCI")
        print("-" * 40)
        
        current_blocks = role_data.get('policies', {}).get('mci_generic', [])
        print(f"Building blocks actuales: {current_blocks}")
        print()
        
        # Mostrar disponibles
        all_blocks = []
        for service, blocks in self.mci_building_blocks.items():
            print(f"🔹 {service}:")
            for i, block in enumerate(blocks, 1):
                block_idx = len(all_blocks) + i
                description = self.get_block_description(block)
                status = "✅" if block in current_blocks else "⬜"
                print(f"   [{block_idx}] {status} {block} - {description}")
            all_blocks.extend(blocks)
        
        print(f"\n💡 Selecciona números para toggle (agregar/quitar)")
        print(f"💡 Ejemplo: 1,3,5 para toggle building blocks 1, 3 y 5")
        
        while True:
            choices = input("👉 Building blocks a toggle [números separados por coma]: ").strip()
            if not choices:
                break
            
            try:
                indices = [int(x.strip()) for x in choices.split(',')]
                new_blocks = current_blocks.copy()
                
                for idx in indices:
                    if 1 <= idx <= len(all_blocks):
                        block = all_blocks[idx - 1]
                        if block in new_blocks:
                            new_blocks.remove(block)
                            print(f"   ❌ Removido: {block}")
                        else:
                            new_blocks.append(block)
                            print(f"   ✅ Agregado: {block}")
                
                # Actualizar role data
                if 'policies' not in role_data:
                    role_data['policies'] = {}
                role_data['policies']['mci_generic'] = new_blocks
                
                print(f"\n✅ Building blocks actualizados: {new_blocks}")
                break
                
            except ValueError:
                print("❌ Formato inválido. Usa números separados por coma")

    def manage_s3_granular(self, role_data):
        """Gestionar políticas S3 granulares."""
        print("\n🔐 GESTIONAR S3 GRANULAR")
        print("-" * 40)
        
        current_s3 = role_data.get('policies', {}).get('s3_granular', [])
        print(f"Políticas S3 actuales: {current_s3}")
        print()
        
        print("🔧 Opciones:")
        print("   [1] Agregar nueva política S3")
        print("   [2] Remover política S3 existente")
        print("   [3] Volver al menú principal")
        
        choice = input("👉 Selecciona [1-3]: ").strip()
        
        if choice == '1':
            # Agregar nueva
            policy_name = input("👉 Nombre de la política S3 (ej: ventas-reportes): ").strip()
            if policy_name:
                if 'policies' not in role_data:
                    role_data['policies'] = {}
                if 's3_granular' not in role_data['policies']:
                    role_data['policies']['s3_granular'] = []
                
                if policy_name not in role_data['policies']['s3_granular']:
                    role_data['policies']['s3_granular'].append(policy_name)
                    print(f"✅ Agregada política S3: {policy_name}")
                    print(f"💡 Recuerda configurar '{policy_name}' en area-metadata.tfvars")
                else:
                    print("❌ Política ya existe")
        
        elif choice == '2':
            # Remover existente
            if current_s3:
                print("Políticas S3 actuales:")
                for i, policy in enumerate(current_s3, 1):
                    print(f"   [{i}] {policy}")
                
                try:
                    remove_idx = int(input("👉 Número a remover: ").strip()) - 1
                    if 0 <= remove_idx < len(current_s3):
                        removed = current_s3.pop(remove_idx)
                        role_data['policies']['s3_granular'] = current_s3
                        print(f"✅ Removida política S3: {removed}")
                except ValueError:
                    print("❌ Número inválido")
            else:
                print("❌ No hay políticas S3 para remover")

    def edit_aws_policies(self, role_data):
        """Editar políticas AWS administradas."""
        print("\n☁️ EDITAR POLÍTICAS AWS ADMINISTRADAS")
        print("-" * 40)
        
        current_aws = role_data.get('policies', {}).get('aws_managed', [])
        print(f"Políticas AWS actuales: {len(current_aws)}")
        for policy in current_aws:
            policy_name = policy.split('/')[-1] if '/' in policy else policy
            print(f"   ✅ {policy_name}")
        print()
        
        print("Políticas AWS comunes:")
        for i, policy in enumerate(self.aws_managed_common, 1):
            full_arn = f"arn:aws:iam::aws:policy/{policy}"
            status = "✅" if full_arn in current_aws else "⬜"
            print(f"   [{i}] {status} {policy}")
        
        while True:
            choices = input("👉 Políticas a toggle [números separados por coma]: ").strip()
            if not choices:
                break
            
            try:
                indices = [int(x.strip()) for x in choices.split(',')]
                new_aws = current_aws.copy()
                
                for idx in indices:
                    if 1 <= idx <= len(self.aws_managed_common):
                        policy = self.aws_managed_common[idx - 1]
                        full_arn = f"arn:aws:iam::aws:policy/{policy}"
                        
                        if full_arn in new_aws:
                            new_aws.remove(full_arn)
                            print(f"   ❌ Removido: {policy}")
                        else:
                            new_aws.append(full_arn)
                            print(f"   ✅ Agregado: {policy}")
                
                if 'policies' not in role_data:
                    role_data['policies'] = {}
                role_data['policies']['aws_managed'] = new_aws
                
                print(f"\n✅ Políticas AWS actualizadas")
                break
                
            except ValueError:
                print("❌ Formato inválido")

    def edit_role_tags(self, role_data):
        """Editar tags del rol."""
        print("\n🏷️ EDITAR TAGS DEL ROL")
        print("-" * 40)
        
        current_tags = role_data.get('tags', {})
        print("Tags actuales:")
        for key, value in current_tags.items():
            print(f"   • {key}: {value}")
        print()
        
        print("🔧 Opciones:")
        print("   [1] Agregar/Editar tag")
        print("   [2] Remover tag")
        print("   [3] Volver")
        
        choice = input("👉 Selecciona [1-3]: ").strip()
        
        if choice == '1':
            key = input("👉 Nombre del tag: ").strip()
            value = input("👉 Valor del tag: ").strip()
            
            if key and value:
                if 'tags' not in role_data:
                    role_data['tags'] = {}
                role_data['tags'][key] = value
                print(f"✅ Tag actualizado: {key} = {value}")
        
        elif choice == '2':
            if current_tags:
                tag_keys = list(current_tags.keys())
                for i, key in enumerate(tag_keys, 1):
                    print(f"   [{i}] {key}")
                
                try:
                    remove_idx = int(input("👉 Número a remover: ").strip()) - 1
                    if 0 <= remove_idx < len(tag_keys):
                        removed_key = tag_keys[remove_idx]
                        del role_data['tags'][removed_key]
                        print(f"✅ Tag removido: {removed_key}")
                except ValueError:
                    print("❌ Número inválido")

    def edit_description(self, role_data):
        """Editar descripción del rol."""
        print("\n📝 EDITAR DESCRIPCIÓN")
        print("-" * 40)
        
        current_desc = role_data.get('description', '')
        print(f"Descripción actual: {current_desc}")
        
        new_desc = input("👉 Nueva descripción: ").strip()
        if new_desc:
            role_data['description'] = new_desc
            print("✅ Descripción actualizada")

    def save_role_data(self, role_info, role_data):
        """Guardar datos del rol."""
        try:
            # Actualizar timestamp
            if 'tags' not in role_data:
                role_data['tags'] = {}
            role_data['tags']['LastModified'] = datetime.now().strftime("%Y-%m-%d %H:%M:%S")
            
            with open(role_info['path'], 'w', encoding='utf-8') as f:
                json.dump(role_data, f, indent=2, ensure_ascii=False)
            
            print(f"✅ Rol guardado: {role_info['path']}")
            return True
        except Exception as e:
            print(f"❌ Error guardando: {e}")
            return False

    def run(self):
        """Ejecutar editor enterprise."""
        try:
            self.print_banner()
            
            # Organizar roles por área
            roles_by_area = self.organize_roles_by_area()
            
            # Navegación escalable
            area, role_info = self.display_area_navigation(roles_by_area)
            if not area or not role_info:
                return
            
            # Cargar datos del rol
            role_data = self.load_role_data(role_info)
            if not role_data:
                return
            
            # Loop principal de edición
            while True:
                self.display_role_summary(role_info['name'], role_data, area)
                choice = self.show_edit_menu()
                
                if choice == '1':
                    self.edit_building_blocks(role_data)
                elif choice == '2':
                    self.manage_s3_granular(role_data)
                elif choice == '3':
                    self.edit_aws_policies(role_data)
                elif choice == '4':
                    self.edit_role_tags(role_data)
                elif choice == '5':
                    self.edit_description(role_data)
                elif choice == '6':
                    if self.save_role_data(role_info, role_data):
                        print("\n🎉 Rol guardado exitosamente")
                        print("🚀 Próximo paso: git add . && git commit && git push")
                    break
                elif choice == '7':
                    print("❌ Saliendo sin guardar...")
                    break
                else:
                    print("❌ Opción inválida")
        
        except KeyboardInterrupt:
            print("\n\n❌ Operación cancelada")
        except Exception as e:
            print(f"❌ Error: {e}")

def main():
    """Función principal."""
    editor = IAMRoleEditorEnterprise()
    editor.run()

if __name__ == "__main__":
    main()
