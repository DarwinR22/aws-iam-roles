#!/usr/bin/env python3
"""
🔄 Migrador de Arquitectura IAM - Legacy a Enterprise
Convierte roles existentes a la nueva arquitectura building blocks
"""

import json
import os
import sys
from pathlib import Path
import shutil
from datetime import datetime

class IAMArchitectureMigrator:
    """Migrador de arquitectura IAM a enterprise."""
    
    def __init__(self):
        self.base_path = Path('gerencias')
        self.backup_path = Path('backup_migration')
        self.migration_log = []
        
        # Mapeo de políticas legacy a building blocks
        self.policy_mapping = {
            # S3 policies
            'policy-s3-readonly': 'MCI-S3-ReadOnly',
            'policy-s3-read': 'MCI-S3-ReadOnly', 
            'policy-s3-write': 'MCI-S3-Write',
            'policy-s3-full': 'MCI-S3-Write',
            
            # Lambda policies
            'policy-lambda-invoke': 'MCI-Lambda-Invoke',
            'policy-lambda-execute': 'MCI-Lambda-Invoke',
            
            # DynamoDB policies
            'policy-dynamodb-read': 'MCI-DynamoDB-ReadOnly',
            'policy-dynamodb-readonly': 'MCI-DynamoDB-ReadOnly',
            'policy-dynamodb-write': 'MCI-DynamoDB-Write',
            'policy-dynamodb-full': 'MCI-DynamoDB-Write',
        }

    def print_banner(self):
        """Banner del migrador."""
        print("🔄 " + "="*70)
        print("🔄 MIGRADOR ENTERPRISE IAM - LEGACY → BUILDING BLOCKS")
        print("🔄 Convierte roles existentes a arquitectura enterprise")
        print("🔄 " + "="*70)
        print()

    def create_backup(self):
        """Crear backup antes de migración."""
        if self.backup_path.exists():
            shutil.rmtree(self.backup_path)
        
        if self.base_path.exists():
            shutil.copytree(self.base_path, self.backup_path)
            print(f"✅ Backup creado en: {self.backup_path}")
            return True
        return False

    def scan_existing_roles(self):
        """Escanear roles existentes."""
        roles = []
        
        if not self.base_path.exists():
            return roles
        
        for role_file in self.base_path.rglob('rol-*.json'):
            try:
                with open(role_file, 'r', encoding='utf-8') as f:
                    role_data = json.load(f)
                
                # Detectar área del path
                relative_path = role_file.relative_to(self.base_path)
                area = relative_path.parts[0] if relative_path.parts else 'unknown'
                
                roles.append({
                    'file': role_file,
                    'name': role_file.stem,
                    'area': area,
                    'data': role_data
                })
            except Exception as e:
                print(f"⚠️ Error leyendo {role_file}: {e}")
        
        return roles

    def analyze_role(self, role_data):
        """Analizar rol y determinar migración."""
        analysis = {
            'needs_migration': False,
            'legacy_policies': [],
            'suggested_blocks': [],
            'aws_policies': [],
            's3_custom': [],
            'unknown_policies': []
        }
        
        policies = role_data.get('policies', {})
        
        # Analizar políticas custom/legacy
        custom_policies = policies.get('custom', [])
        for policy in custom_policies:
            if policy in self.policy_mapping:
                analysis['legacy_policies'].append(policy)
                suggested_block = self.policy_mapping[policy]
                if suggested_block not in analysis['suggested_blocks']:
                    analysis['suggested_blocks'].append(suggested_block)
                analysis['needs_migration'] = True
            else:
                # Verificar si es S3 específico por nombre
                if 's3' in policy.lower() and any(x in policy.lower() for x in ['path', 'bucket', 'specific']):
                    analysis['s3_custom'].append(policy)
                    analysis['needs_migration'] = True
                else:
                    analysis['unknown_policies'].append(policy)
        
        # Políticas AWS ya están bien
        aws_managed = policies.get('aws_managed', [])
        analysis['aws_policies'] = aws_managed
        
        return analysis

    def migrate_role(self, role_info, analysis, interactive=True):
        """Migrar un rol individual."""
        role_data = role_info['data'].copy()
        migrated = False
        
        print(f"\n🔄 Migrando: {role_info['name']}")
        print(f"📁 Área: {role_info['area']}")
        
        if not analysis['needs_migration']:
            print("✅ Rol ya compatible con arquitectura enterprise")
            return role_data, False
        
        # Crear nueva estructura de políticas
        new_policies = {}
        
        # Mantener AWS managed
        if analysis['aws_policies']:
            new_policies['aws_managed'] = analysis['aws_policies']
        
        # Convertir legacy a building blocks
        if analysis['suggested_blocks']:
            new_policies['mci_generic'] = analysis['suggested_blocks']
            print(f"🧱 Building blocks sugeridos: {analysis['suggested_blocks']}")
            migrated = True
        
        # Manejar S3 custom
        if analysis['s3_custom']:
            if interactive:
                print(f"🔐 Políticas S3 específicas encontradas: {analysis['s3_custom']}")
                print("💡 Estas necesitan configuración manual en area-metadata.tfvars")
                
                convert_s3 = input("👉 ¿Convertir a S3 granular? [y/n]: ").strip().lower()
                if convert_s3 in ['y', 'yes']:
                    # Generar nombres S3 granular basados en política legacy
                    s3_granular = []
                    for s3_policy in analysis['s3_custom']:
                        granular_name = s3_policy.replace('policy-', '').replace('-policy', '')
                        s3_granular.append(granular_name)
                    
                    new_policies['s3_granular'] = s3_granular
                    print(f"✅ S3 granular configurado: {s3_granular}")
                    migrated = True
            else:
                # Migración automática
                s3_granular = []
                for s3_policy in analysis['s3_custom']:
                    granular_name = s3_policy.replace('policy-', '').replace('-policy', '')
                    s3_granular.append(granular_name)
                new_policies['s3_granular'] = s3_granular
                migrated = True
        
        # Reportar políticas desconocidas
        if analysis['unknown_policies']:
            print(f"⚠️ Políticas no reconocidas: {analysis['unknown_policies']}")
            print("💡 Estas necesitan revisión manual")
        
        # Actualizar role data
        role_data['policies'] = new_policies
        
        # Agregar tags de migración
        if 'tags' not in role_data:
            role_data['tags'] = {}
        
        role_data['tags']['MigratedToEnterprise'] = datetime.now().strftime("%Y-%m-%d")
        role_data['tags']['MigrationVersion'] = 'v1.0'
        
        return role_data, migrated

    def save_migrated_role(self, role_info, migrated_data):
        """Guardar rol migrado."""
        try:
            with open(role_info['file'], 'w', encoding='utf-8') as f:
                json.dump(migrated_data, f, indent=2, ensure_ascii=False)
            return True
        except Exception as e:
            print(f"❌ Error guardando {role_info['file']}: {e}")
            return False

    def generate_migration_report(self):
        """Generar reporte de migración."""
        report_file = Path('migration_report.md')
        
        with open(report_file, 'w', encoding='utf-8') as f:
            f.write("# 🔄 Reporte de Migración Enterprise IAM\n\n")
            f.write(f"**Fecha:** {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}\n\n")
            
            f.write("## 📊 Resumen\n\n")
            f.write(f"- **Roles procesados:** {len(self.migration_log)}\n")
            
            migrated_count = sum(1 for log in self.migration_log if log['migrated'])
            f.write(f"- **Roles migrados:** {migrated_count}\n")
            f.write(f"- **Roles sin cambios:** {len(self.migration_log) - migrated_count}\n\n")
            
            f.write("## 📋 Detalle por Rol\n\n")
            for log in self.migration_log:
                f.write(f"### {log['name']}\n")
                f.write(f"- **Área:** {log['area']}\n")
                f.write(f"- **Migrado:** {'✅ Sí' if log['migrated'] else '❌ No'}\n")
                
                if log.get('building_blocks'):
                    f.write(f"- **Building Blocks:** {', '.join(log['building_blocks'])}\n")
                
                if log.get('s3_granular'):
                    f.write(f"- **S3 Granular:** {', '.join(log['s3_granular'])}\n")
                
                if log.get('warnings'):
                    f.write(f"- **Advertencias:** {', '.join(log['warnings'])}\n")
                
                f.write("\n")
            
            f.write("## 🚀 Próximos Pasos\n\n")
            f.write("1. Revisar configuraciones S3 granulares en `area-metadata.tfvars`\n")
            f.write("2. Validar building blocks asignados\n")
            f.write("3. Hacer commit de cambios: `git add . && git commit -m 'feat: migrate to enterprise architecture'`\n")
            f.write("4. Push y validar en GitHub Actions\n")
        
        print(f"📋 Reporte generado: {report_file}")

    def run_migration(self, interactive=True):
        """Ejecutar migración completa."""
        self.print_banner()
        
        # Crear backup
        if not self.create_backup():
            print("❌ No se encontraron roles para migrar")
            return
        
        # Escanear roles
        roles = self.scan_existing_roles()
        if not roles:
            print("❌ No se encontraron roles para analizar")
            return
        
        print(f"📊 Encontrados {len(roles)} roles para analizar")
        
        # Analizar y migrar cada rol
        total_migrated = 0
        
        for role_info in roles:
            analysis = self.analyze_role(role_info['data'])
            migrated_data, was_migrated = self.migrate_role(role_info, analysis, interactive)
            
            if was_migrated:
                if self.save_migrated_role(role_info, migrated_data):
                    total_migrated += 1
                    print(f"✅ Migrado exitosamente")
                else:
                    print(f"❌ Error guardando migración")
            
            # Log para reporte
            log_entry = {
                'name': role_info['name'],
                'area': role_info['area'],
                'migrated': was_migrated,
                'building_blocks': migrated_data.get('policies', {}).get('mci_generic', []),
                's3_granular': migrated_data.get('policies', {}).get('s3_granular', []),
                'warnings': analysis['unknown_policies']
            }
            self.migration_log.append(log_entry)
        
        # Generar reporte
        self.generate_migration_report()
        
        print("\n" + "="*70)
        print(f"🎉 MIGRACIÓN COMPLETADA")
        print(f"📊 {total_migrated}/{len(roles)} roles migrados exitosamente")
        print(f"💾 Backup disponible en: {self.backup_path}")
        print("="*70)

def main():
    """Función principal."""
    migrator = IAMArchitectureMigrator()
    
    print("🔄 MIGRADOR ENTERPRISE IAM")
    print("¿Deseas ejecutar migración interactiva o automática?")
    print("   [1] Interactiva (recomendado)")
    print("   [2] Automática")
    
    choice = input("👉 Selecciona [1-2]: ").strip()
    interactive = choice != '2'
    
    try:
        migrator.run_migration(interactive)
    except KeyboardInterrupt:
        print("\n❌ Migración cancelada")
    except Exception as e:
        print(f"❌ Error en migración: {e}")

if __name__ == "__main__":
    main()
