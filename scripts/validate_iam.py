#!/usr/bin/env python3
"""
Script de validación para nombres de roles IAM y tags obligatorios
Valida que los recursos sigan las convenciones definidas antes del despliegue
"""

import re
import json
import sys
import os
import glob
from pathlib import Path
from typing import Dict, List, Any, Tuple
import argparse

# Convención de nombres para roles IAM
ROLE_NAME_PATTERN = r'^rol-[a-z0-9]+-[a-z0-9-]+-[a-z]+-[a-z0-9-]+$'

# Valores válidos para tags
VALID_ENVIRONMENTS = ['dev', 'qa', 'prod', 'poc']
VALID_COUNTRIES = ['GT', 'SV', 'NI', 'HN', 'CR', 'RG']
VALID_SOX_VALUES = ['Sí', 'No']
VALID_MODULES = ['Aplicación', 'DB', 'POC']
VALID_PROVIDERS = ['Inhouse', 'Tercero']
VALID_LIFECYCLES = ['Creación', 'Implementación', 'MonitoreoYMantenimiento', 'Optimización', 'Decommission']

# Tags obligatorios
REQUIRED_TAGS = [
    'ambiente', 'pais', 'direccion', 'gerencia', 'cuenta', 'modulo',
    'alcance_sox', 'propietario', 'proveedor', 'layer', 'dominio',
    'subdominio', 'aplicacion', 'soporte', 'contacto', 'proyecto',
    'creado_por', 'ciclo_vida', 'version'
]

class ValidationError(Exception):
    """Excepción personalizada para errores de validación"""
    pass

class IAMValidator:
    """Validador para recursos IAM"""
    
    def __init__(self):
        self.errors = []
        self.warnings = []
    
    def validate_role_name(self, role_name: str) -> bool:
        """
        Valida que el nombre del rol siga la convención:
        rol-[servicio]-[layer]-[ambiente]-[nombre]
        """
        if not re.match(ROLE_NAME_PATTERN, role_name):
            self.errors.append(
                f"Nombre de rol inválido: '{role_name}'. "
                f"Debe seguir el patrón: rol-[servicio]-[layer]-[ambiente]-[nombre]"
            )
            return False
        
        # Extraer componentes y validar ambiente
        parts = role_name.split('-')
        if len(parts) < 4:
            self.errors.append(f"Nombre de rol inválido: '{role_name}'. Faltan componentes.")
            return False
            
        ambiente = parts[-2]  # Penúltimo componente es el ambiente
        if ambiente not in VALID_ENVIRONMENTS:
            self.errors.append(
                f"Ambiente inválido en nombre de rol: '{ambiente}'. "
                f"Debe ser uno de: {', '.join(VALID_ENVIRONMENTS)}"
            )
            return False
            
        return True
    
    def validate_tags(self, tags: Dict[str, Any]) -> bool:
        """Valida que todos los tags obligatorios estén presentes y sean válidos"""
        is_valid = True
        
        # Verificar que todos los tags obligatorios estén presentes
        missing_tags = []
        for tag in REQUIRED_TAGS:
            if tag not in tags:
                missing_tags.append(tag)
        
        if missing_tags:
            self.errors.append(f"Tags obligatorios faltantes: {', '.join(missing_tags)}")
            is_valid = False
        
        # Validar valores específicos
        if 'ambiente' in tags and tags['ambiente'] not in VALID_ENVIRONMENTS:
            self.errors.append(
                f"Valor de tag 'ambiente' inválido: '{tags['ambiente']}'. "
                f"Debe ser uno de: {', '.join(VALID_ENVIRONMENTS)}"
            )
            is_valid = False
        
        if 'pais' in tags and tags['pais'] not in VALID_COUNTRIES:
            self.errors.append(
                f"Valor de tag 'pais' inválido: '{tags['pais']}'. "
                f"Debe ser uno de: {', '.join(VALID_COUNTRIES)}"
            )
            is_valid = False
        
        if 'alcance_sox' in tags and tags['alcance_sox'] not in VALID_SOX_VALUES:
            self.errors.append(
                f"Valor de tag 'alcance_sox' inválido: '{tags['alcance_sox']}'. "
                f"Debe ser uno de: {', '.join(VALID_SOX_VALUES)}"
            )
            is_valid = False
        
        if 'modulo' in tags and tags['modulo'] not in VALID_MODULES:
            self.errors.append(
                f"Valor de tag 'modulo' inválido: '{tags['modulo']}'. "
                f"Debe ser uno de: {', '.join(VALID_MODULES)}"
            )
            is_valid = False
        
        if 'proveedor' in tags and tags['proveedor'] not in VALID_PROVIDERS:
            self.errors.append(
                f"Valor de tag 'proveedor' inválido: '{tags['proveedor']}'. "
                f"Debe ser uno de: {', '.join(VALID_PROVIDERS)}"
            )
            is_valid = False
        
        if 'ciclo_vida' in tags and tags['ciclo_vida'] not in VALID_LIFECYCLES:
            self.errors.append(
                f"Valor de tag 'ciclo_vida' inválido: '{tags['ciclo_vida']}'. "
                f"Debe ser uno de: {', '.join(VALID_LIFECYCLES)}"
            )
            is_valid = False
        
        # Validar formato de email
        if 'contacto' in tags:
            email_pattern = r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$'
            if not re.match(email_pattern, tags['contacto']):
                self.errors.append(f"Formato de email inválido en tag 'contacto': '{tags['contacto']}'")
                is_valid = False
        
        # Validar formato de versión
        if 'version' in tags:
            version_pattern = r'^[0-9]+\.[0-9]+\.[0-9]+$'
            if not re.match(version_pattern, tags['version']):
                self.errors.append(
                    f"Formato de versión inválido en tag 'version': '{tags['version']}'. "
                    f"Debe seguir el formato semántico (ej: 1.0.0)"
                )
                is_valid = False
        
        # Verificar que no haya tags vacíos
        empty_tags = []
        for tag, value in tags.items():
            if tag in REQUIRED_TAGS and (not value or str(value).strip() == ""):
                empty_tags.append(tag)
        
        if empty_tags:
            self.errors.append(f"Tags con valores vacíos: {', '.join(empty_tags)}")
            is_valid = False
        
        return is_valid
    
    def validate_policies(self, policies: Dict[str, Any], file_dir: Path) -> bool:
        """Valida la configuración de políticas, incluyendo referencias a archivos"""
        is_valid = True
        
        if not policies:
            # Políticas vacías están permitidas
            return True
        
        # Validar políticas AWS administradas
        aws_managed = policies.get('aws_managed', [])
        if aws_managed:
            if not isinstance(aws_managed, list):
                self.errors.append("'aws_managed' debe ser una lista")
                is_valid = False
            else:
                for policy_arn in aws_managed:
                    if not isinstance(policy_arn, str):
                        self.errors.append(f"ARN de política debe ser string: {policy_arn}")
                        is_valid = False
                    elif not policy_arn.startswith('arn:aws:iam::aws:policy/'):
                        self.errors.append(f"ARN de política AWS inválido: {policy_arn}")
                        is_valid = False
        
        # Validar políticas inline
        inline_policy = policies.get('inline')
        if inline_policy:
            if not isinstance(inline_policy, dict):
                self.errors.append("'inline' debe ser un objeto JSON")
                is_valid = False
            else:
                is_valid &= self.validate_policy_document(inline_policy)
        
        # Validar referencias a archivos de políticas personalizadas
        custom_policies = policies.get('custom_policies', [])
        if custom_policies:
            if not isinstance(custom_policies, list):
                self.errors.append("'custom_policies' debe ser una lista")
                is_valid = False
            else:
                for policy_ref in custom_policies:
                    if not isinstance(policy_ref, str):
                        self.errors.append(f"Referencia de política debe ser string: {policy_ref}")
                        is_valid = False
                        continue
                    
                    # Resolver ruta del archivo de política
                    if policy_ref.startswith('./'):
                        policy_path = file_dir / policy_ref[2:]
                    else:
                        policy_path = file_dir / policy_ref
                    
                    # Verificar que el archivo existe
                    if not policy_path.exists():
                        self.errors.append(f"Archivo de política no encontrado: {policy_ref} (buscado en {policy_path})")
                        is_valid = False
                        continue
                    
                    # Validar que es un archivo de política válido
                    if not policy_path.name.startswith('policy-') or not policy_path.name.endswith('.json'):
                        self.errors.append(f"Archivo de política debe seguir el patrón 'policy-*.json': {policy_ref}")
                        is_valid = False
                        continue
                    
                    # Validar contenido del archivo de política
                    try:
                        with open(policy_path, 'r', encoding='utf-8') as f:
                            policy_content = json.load(f)
                        
                        if not self.validate_policy_document(policy_content):
                            self.errors.append(f"Política inválida en archivo: {policy_ref}")
                            is_valid = False
                    
                    except json.JSONDecodeError as e:
                        self.errors.append(f"Error de sintaxis JSON en política {policy_ref}: {e}")
                        is_valid = False
                    except Exception as e:
                        self.errors.append(f"Error leyendo archivo de política {policy_ref}: {e}")
                        is_valid = False
        
        return is_valid
    
    def validate_policy_document(self, policy: Dict[str, Any]) -> bool:
        """Valida un documento de política IAM"""
        is_valid = True
        
        # Verificar campos requeridos
        if 'Version' not in policy:
            self.errors.append("Política debe tener campo 'Version'")
            is_valid = False
        elif policy['Version'] not in ['2012-10-17', '2008-10-17']:
            self.errors.append(f"Versión de política inválida: {policy['Version']}")
            is_valid = False
        
        if 'Statement' not in policy:
            self.errors.append("Política debe tener campo 'Statement'")
            is_valid = False
        else:
            statements = policy['Statement']
            if not isinstance(statements, list):
                statements = [statements]
            
            for i, statement in enumerate(statements):
                if not isinstance(statement, dict):
                    self.errors.append(f"Statement {i} debe ser un objeto")
                    is_valid = False
                    continue
                
                # Verificar Effect
                if 'Effect' not in statement:
                    self.errors.append(f"Statement {i} debe tener campo 'Effect'")
                    is_valid = False
                elif statement['Effect'] not in ['Allow', 'Deny']:
                    self.errors.append(f"Statement {i}: Effect debe ser 'Allow' o 'Deny'")
                    is_valid = False
                
                # Verificar que tiene Action o NotAction
                if 'Action' not in statement and 'NotAction' not in statement:
                    self.errors.append(f"Statement {i} debe tener 'Action' o 'NotAction'")
                    is_valid = False
        
        return is_valid
    
    def validate_role_config(self, file_path: str) -> bool:
        """Valida un archivo de configuración JSON de rol"""
        try:
            with open(file_path, 'r', encoding='utf-8') as f:
                config = json.load(f)
            
            is_valid = True
            file_dir = Path(file_path).parent
            
            # Validar nombre de rol si está presente
            if 'role_name' in config:
                if not self.validate_role_name(config['role_name']):
                    is_valid = False
            
            # Validar tags si están presentes
            if 'tags' in config:
                if not self.validate_tags(config['tags']):
                    is_valid = False
            
            # Validar políticas si están presentes
            if 'policies' in config:
                if not self.validate_policies(config['policies'], file_dir):
                    is_valid = False
            
            return is_valid
            
        except json.JSONDecodeError as e:
            self.errors.append(f"Error de sintaxis JSON en {file_path}: {e}")
            return False
        except Exception as e:
            self.errors.append(f"Error al leer archivo {file_path}: {str(e)}")
            return False
    
    def validate_terraform_file(self, file_path: str) -> bool:
        """Valida un archivo Terraform específico"""
        try:
            with open(file_path, 'r', encoding='utf-8') as f:
                content = f.read()
            
            # Buscar nombres de roles (pattern básico)
            role_matches = re.findall(r'role_name\s*=\s*"([^"]+)"', content)
            role_matches.extend(re.findall(r'rol-[a-z0-9]+-[a-z0-9-]+-[a-z]+-[a-z0-9-]+', content))
            
            is_valid = True
            for role_name in role_matches:
                if not self.validate_role_name(role_name):
                    is_valid = False
            
            return is_valid
            
        except Exception as e:
            self.errors.append(f"Error al leer archivo {file_path}: {str(e)}")
            return False
    
    def validate_directory(self, directory: str) -> bool:
        """Valida todos los archivos .tf y .json en un directorio"""
        tf_files = glob.glob(os.path.join(directory, "**/*.tf"), recursive=True)
        json_files = glob.glob(os.path.join(directory, "**/*.json"), recursive=True)
        
        if not tf_files and not json_files:
            self.warnings.append(f"No se encontraron archivos .tf o .json en {directory}")
            return True
        
        is_valid = True
        
        # Validar archivos Terraform
        for tf_file in tf_files:
            if not self.validate_terraform_file(tf_file):
                is_valid = False
        
        # Validar archivos JSON de roles (excluir archivos de política)
        for json_file in json_files:
            if not os.path.basename(json_file).startswith('policy-'):
                if not self.validate_role_config(json_file):
                    is_valid = False
        
        return is_valid
    
    def print_results(self):
        """Imprime los resultados de la validación"""
        if self.errors:
            print("❌ ERRORES DE VALIDACIÓN:")
            for i, error in enumerate(self.errors, 1):
                print(f"  {i}. {error}")
            print()
        
        if self.warnings:
            print("⚠️  ADVERTENCIAS:")
            for i, warning in enumerate(self.warnings, 1):
                print(f"  {i}. {warning}")
            print()
        
        if not self.errors and not self.warnings:
            print("✅ Todas las validaciones pasaron exitosamente!")
        elif not self.errors:
            print("✅ Validaciones pasaron con advertencias.")
        else:
            print("❌ Validaciones fallaron. Por favor corrija los errores antes de continuar.")
    
    def has_errors(self) -> bool:
        """Retorna True si hay errores de validación"""
        return len(self.errors) > 0

def main():
    parser = argparse.ArgumentParser(description='Validador de recursos IAM')
    parser.add_argument('path', help='Ruta del archivo o directorio a validar')
    parser.add_argument('--role-name', help='Validar un nombre de rol específico')
    parser.add_argument('--tags-file', help='Archivo JSON con tags a validar')
    
    args = parser.parse_args()
    
    validator = IAMValidator()
    
    # Validar nombre de rol específico
    if args.role_name:
        validator.validate_role_name(args.role_name)
    
    # Validar tags desde archivo
    if args.tags_file:
        try:
            with open(args.tags_file, 'r', encoding='utf-8') as f:
                tags = json.load(f)
            validator.validate_tags(tags)
        except Exception as e:
            validator.errors.append(f"Error al leer archivo de tags: {str(e)}")
    
    # Validar archivo o directorio
    if os.path.isfile(args.path):
        if args.path.endswith('.json'):
            validator.validate_role_config(args.path)
        elif args.path.endswith('.tf'):
            validator.validate_terraform_file(args.path)
        else:
            validator.errors.append(f"Tipo de archivo no soportado: {args.path}. Use archivos .json o .tf")
    elif os.path.isdir(args.path):
        validator.validate_directory(args.path)
    else:
        validator.errors.append(f"Ruta no encontrada: {args.path}")
    
    # Imprimir resultados
    validator.print_results()
    
    # Salir con código de error si hay errores
    sys.exit(1 if validator.has_errors() else 0)

if __name__ == "__main__":
    main()
