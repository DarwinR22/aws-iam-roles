#!/usr/bin/env python3
"""
🔍 IAM Lint - Validador de Estructura y Convenciones
==================================================

Script para validar que roles y políticas cumplan con:
- Convenciones de nomenclatura
- Estructura de carpetas correcta
- Tags requeridos
- Formato JSON válido
- Coherencia entre archivos

Uso:
    python scripts/iam_lint.py                    # Validar todo
    python scripts/iam_lint.py --roles-only       # Solo roles
    python scripts/iam_lint.py --policies-only    # Solo políticas
    python scripts/iam_lint.py --fix              # Auto-corregir errores menores
"""

import json
import yaml
import re
import argparse
from pathlib import Path
from datetime import datetime
from typing import List, Dict, Tuple

class IAMLinter:
    def __init__(self, base_path: Path = None):
        self.base_path = base_path or Path(__file__).parent.parent
        self.gerencias_path = self.base_path / "gerencias"
        self.catalog_path = self.base_path / "catalog"
        self.policy_lib_path = self.base_path / "policy_lib"
        
        # Patrones de validación
        self.ROLE_NAME_PATTERN = r'^rol-[a-z]{2,6}-[a-z0-9\-]{2,15}-(gt|sv|ni|cr|hn|rg)-[a-z0-9\-]{2,20}$'
        self.POLICY_NAME_PATTERN = r'^MCI-.+-.+$'
        
        # Configuración de validación
        self.required_role_tags = [
            'ambiente', 'pais', 'gerencia', 'area', 
            'Equipo', 'Proyecto', 'propietario', 'Aplicacion', 'Version'
        ]
        
        self.valid_countries = ['gt', 'sv', 'ni', 'cr', 'hn', 'rg']
        self.valid_environments = ['dev', 'qa', 'prod', 'all']
        
        # Contadores de errores
        self.errors = []
        self.warnings = []
        self.fixed = []

    def log_error(self, message: str):
        """Registrar error."""
        self.errors.append(f"❌ {message}")
        print(f"❌ {message}")

    def log_warning(self, message: str):
        """Registrar advertencia.""" 
        self.warnings.append(f"⚠️  {message}")
        print(f"⚠️  {message}")

    def log_fixed(self, message: str):
        """Registrar corrección automática."""
        self.fixed.append(f"🔧 {message}")
        print(f"🔧 {message}")

    def validate_json_file(self, file_path: Path) -> bool:
        """Validar que el archivo JSON sea válido."""
        try:
            with open(file_path, 'r', encoding='utf-8') as f:
                json.load(f)
            return True
        except json.JSONDecodeError as e:
            self.log_error(f"{file_path}: JSON inválido - {e}")
            return False
        except Exception as e:
            self.log_error(f"{file_path}: Error leyendo archivo - {e}")
            return False

    def validate_role_naming(self, role_file: Path, role_data: Dict) -> bool:
        """Validar nomenclatura de roles."""
        role_name = role_data.get('role_name', '')
        file_name = role_file.stem
        
        is_valid = True
        
        # Validar que nombre del archivo coincida con role_name
        if role_name != file_name:
            self.log_error(f"{role_file}: role_name '{role_name}' no coincide con archivo '{file_name}'")
            is_valid = False
        
        # Validar patrón de nomenclatura
        if not re.match(self.ROLE_NAME_PATTERN, role_name):
            self.log_error(f"{role_file}: Nombre '{role_name}' no sigue patrón rol-{{gerencia}}-{{area}}-{{pais}}-{{aplicacion}}")
            is_valid = False
        
        return is_valid

    def validate_role_structure(self, role_file: Path, role_data: Dict) -> bool:
        """Validar estructura de carpetas vs nombre del rol."""
        role_name = role_data.get('role_name', '')
        path_parts = role_file.parts
        
        is_valid = True
        
        if len(path_parts) >= 4:
            gerencia_folder = path_parts[-4]  # gerencias/MCI/bi/roles/rol.json
            area_folder = path_parts[-3]
            
            # Extraer partes del nombre del rol
            role_parts = role_name.split('-')
            if len(role_parts) >= 4:
                role_gerencia = role_parts[1]
                role_area = role_parts[2]
                
                if gerencia_folder.lower() != role_gerencia.lower():
                    self.log_error(f"{role_file}: Gerencia en carpeta '{gerencia_folder}' ≠ rol '{role_gerencia}'")
                    is_valid = False
                
                if area_folder.lower() != role_area.lower():
                    self.log_error(f"{role_file}: Área en carpeta '{area_folder}' ≠ rol '{role_area}'")
                    is_valid = False
        
        return is_valid

    def validate_role_tags(self, role_file: Path, role_data: Dict, fix_mode: bool = False) -> bool:
        """Validar tags requeridos en roles."""
        tags = role_data.get('tags', {})
        is_valid = True
        
        # Verificar tags requeridos
        for required_tag in self.required_role_tags:
            if required_tag not in tags:
                if fix_mode:
                    # Auto-completar algunos tags básicos
                    if required_tag == 'Fechas de Creacion':
                        tags[required_tag] = datetime.now().strftime('%Y-%m-%d')
                        self.log_fixed(f"{role_file}: Agregado tag '{required_tag}'")
                    elif required_tag == 'map-migrated':
                        tags[required_tag] = 'n/a'
                        self.log_fixed(f"{role_file}: Agregado tag '{required_tag}'")
                    else:
                        self.log_error(f"{role_file}: Falta tag requerido '{required_tag}'")
                        is_valid = False
                else:
                    self.log_error(f"{role_file}: Falta tag requerido '{required_tag}'")
                    is_valid = False
        
        # Validar valores de tags específicos
        if 'pais' in tags and tags['pais'] not in self.valid_countries:
            self.log_error(f"{role_file}: País '{tags['pais']}' no válido. Use: {self.valid_countries}")
            is_valid = False
        
        if 'ambiente' in tags and tags['ambiente'] not in self.valid_environments:
            self.log_error(f"{role_file}: Ambiente '{tags['ambiente']}' no válido. Use: {self.valid_environments}")
            is_valid = False
        
        # Guardar cambios si se hicieron correcciones
        if fix_mode and 'Fechas de Creacion' in tags and role_data.get('tags') != tags:
            role_data['tags'] = tags
            with open(role_file, 'w', encoding='utf-8') as f:
                json.dump(role_data, f, indent=2, ensure_ascii=False)
        
        return is_valid

    def validate_role_policies(self, role_file: Path, role_data: Dict) -> bool:
        """Validar que las políticas referenciadas existan."""
        is_valid = True
        
        # Solo usar catálogo V2 - V1 legacy eliminado
        v2_index_file = self.catalog_path / "v2" / "index.yaml"
        if v2_index_file.exists():
            print("📂 Usando catálogo V2 modular...")
            return self._validate_catalog_v2()
        
        # Sin fallback - solo V2 existe
        self.log_error(f"Catálogo V2 no encontrado: {v2_index_file}")
        self.log_error("📂 Estructura esperada: catalog/v2/index.yaml")
        return False

    def _validate_catalog_v2(self) -> bool:
        """Validar catálogo V2 modular."""
        is_valid = True
        
        try:
            # Cargar índice principal
            index_file = self.catalog_path / "v2" / "index.yaml"
            with open(index_file, 'r', encoding='utf-8') as f:
                index = yaml.safe_load(f)
            
            available_policies = []
            
            # Cargar todos los servicios
            for service_name, service_file in index.get('services', {}).items():
                service_path = self.catalog_path / "v2" / service_file
                
                if not service_path.exists():
                    self.log_warning(f"Archivo de servicio no encontrado: {service_path}")
                    continue
                
                with open(service_path, 'r', encoding='utf-8') as f:
                    service_catalog = yaml.safe_load(f)
                
                # Agregar políticas del servicio
                for policy_name in service_catalog.get('policies', {}).keys():
                    available_policies.append(policy_name)
            
            print(f"📋 Encontradas {len(available_policies)} políticas en catálogo V2")
            
            # Validar roles contra catálogo V2
            role_files = list(self.gerencias_path.glob("**/rol-*.json"))
            for role_file in role_files:
                try:
                    with open(role_file, 'r', encoding='utf-8') as f:
                        role_data = json.load(f)
                    
                    # Verificar políticas MCI en el rol
                    mci_policies = role_data.get('policies', {}).get('mci_managed', [])
                    for policy in mci_policies:
                        if policy not in available_policies:
                            self.log_error(f"{role_file}: Política MCI '{policy}' no existe en catálogo V2")
                            is_valid = False
                
                except Exception as e:
                    self.log_warning(f"Error validando rol {role_file}: {e}")
            
        except Exception as e:
            self.log_error(f"Error validando catálogo V2: {e}")
            is_valid = False
        
        return is_valid

    def validate_roles(self, fix_mode: bool = False) -> bool:
        """Validar todos los roles."""
        print("\n🔍 VALIDANDO ROLES...")
        print("=" * 50)
        
        if not self.gerencias_path.exists():
            self.log_error("Directorio 'gerencias' no encontrado")
            return False
        
        role_files = list(self.gerencias_path.glob("**/rol-*.json"))
        
        if not role_files:
            self.log_warning("No se encontraron archivos de roles")
            return True
        
        print(f"📋 Encontrados {len(role_files)} archivos de roles")
        
        all_valid = True
        
        for role_file in role_files:
            print(f"\n📄 Validando: {role_file.relative_to(self.base_path)}")
            
            # Validar JSON
            if not self.validate_json_file(role_file):
                all_valid = False
                continue
            
            # Cargar datos del rol
            try:
                with open(role_file, 'r', encoding='utf-8') as f:
                    role_data = json.load(f)
            except Exception as e:
                self.log_error(f"{role_file}: Error cargando datos - {e}")
                all_valid = False
                continue
            
            # Ejecutar validaciones
            validations = [
                self.validate_role_naming(role_file, role_data),
                self.validate_role_structure(role_file, role_data),
                self.validate_role_tags(role_file, role_data, fix_mode),
                self.validate_role_policies(role_file, role_data)
            ]
            
            if all(validations):
                print(f"✅ {role_file.name}: Todas las validaciones exitosas")
            else:
                all_valid = False
        
        return all_valid

    def validate_policies(self) -> bool:
        """Validar estructura del catálogo de políticas V2."""
        print("\n🔍 VALIDANDO CATÁLOGO DE POLÍTICAS V2...")
        print("=" * 50)
        
        # Solo validar catálogo V2
        v2_index_file = self.catalog_path / "v2" / "index.yaml"
        
        if not v2_index_file.exists():
            self.log_error(f"Catálogo V2 no encontrado: {v2_index_file}")
            return False
        
        # Delegar validación a método V2
        return self._validate_catalog_v2()

    def print_summary(self):
        """Imprimir resumen de validación."""
        print("\n" + "="*60)
        print("📊 RESUMEN DE VALIDACIÓN")
        print("="*60)
        
        print(f"❌ Errores: {len(self.errors)}")
        print(f"⚠️  Advertencias: {len(self.warnings)}")
        print(f"🔧 Correcciones automáticas: {len(self.fixed)}")
        
        if self.errors:
            print(f"\n❌ ERRORES ENCONTRADOS ({len(self.errors)}):")
            for error in self.errors:
                print(f"  {error}")
        
        if self.warnings:
            print(f"\n⚠️  ADVERTENCIAS ({len(self.warnings)}):")
            for warning in self.warnings:
                print(f"  {warning}")
        
        if self.fixed:
            print(f"\n🔧 CORRECCIONES APLICADAS ({len(self.fixed)}):")
            for fix in self.fixed:
                print(f"  {fix}")
        
        if not self.errors:
            print("\n🎉 ¡VALIDACIÓN EXITOSA! Todos los archivos cumplen con las convenciones")
            return True
        else:
            print(f"\n🚨 VALIDACIÓN FALLIDA: {len(self.errors)} errores deben corregirse")
            return False

def main():
    parser = argparse.ArgumentParser(description='IAM Lint - Validador de estructura y convenciones')
    parser.add_argument('--roles-only', action='store_true', help='Validar solo roles')
    parser.add_argument('--policies-only', action='store_true', help='Validar solo políticas')
    parser.add_argument('--fix', action='store_true', help='Auto-corregir errores menores')
    parser.add_argument('--path', type=str, help='Ruta base del proyecto')
    
    args = parser.parse_args()
    
    # Inicializar linter
    base_path = Path(args.path) if args.path else None
    linter = IAMLinter(base_path)
    
    print("🔍 IAM LINT - VALIDADOR DE ESTRUCTURA")
    print("=" * 50)
    print(f"📁 Base: {linter.base_path}")
    print(f"🔧 Modo corrección: {'Habilitado' if args.fix else 'Deshabilitado'}")
    
    # Ejecutar validaciones
    success = True
    
    if args.policies_only:
        success = linter.validate_policies()
    elif args.roles_only:
        success = linter.validate_roles(args.fix)
    else:
        success = linter.validate_roles(args.fix) and linter.validate_policies()
    
    # Mostrar resumen
    final_success = linter.print_summary()
    
    # Exit code para CI/CD
    exit(0 if final_success else 1)

if __name__ == "__main__":
    main()