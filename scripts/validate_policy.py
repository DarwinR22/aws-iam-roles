#!/usr/bin/env python3
"""
Validador de Políticas IAM
=========================

Script para validar archivos de políticas IAM individuales.
Verifica sintaxis JSON y estructura de políticas AWS.
"""

import json
import sys
import argparse
from pathlib import Path
from typing import Dict, Any, List

class PolicyValidator:
    """Validador de políticas IAM."""
    
    def __init__(self):
        self.required_policy_fields = ["Version", "Statement"]
        self.valid_versions = ["2012-10-17", "2008-10-17"]
        self.valid_effects = ["Allow", "Deny"]
    
    def validate_json_syntax(self, file_path: Path) -> Dict[str, Any]:
        """Validar sintaxis JSON."""
        try:
            with open(file_path, 'r', encoding='utf-8') as f:
                policy_data = json.load(f)
            return policy_data
        except json.JSONDecodeError as e:
            raise ValueError(f"Error de sintaxis JSON: {e}")
        except Exception as e:
            raise ValueError(f"Error leyendo archivo: {e}")
    
    def validate_policy_structure(self, policy: Dict[str, Any]) -> None:
        """Validar estructura de política IAM."""
        # Verificar campos requeridos
        for field in self.required_policy_fields:
            if field not in policy:
                raise ValueError(f"Campo requerido faltante: {field}")
        
        # Validar versión
        version = policy.get("Version")
        if version not in self.valid_versions:
            raise ValueError(f"Versión inválida: {version}. Debe ser una de: {', '.join(self.valid_versions)}")
        
        # Validar statements
        statements = policy.get("Statement")
        if not isinstance(statements, list):
            statements = [statements]
        
        for i, statement in enumerate(statements):
            self.validate_statement(statement, i)
    
    def validate_statement(self, statement: Dict[str, Any], index: int) -> None:
        """Validar un statement individual."""
        if not isinstance(statement, dict):
            raise ValueError(f"Statement {index} debe ser un objeto")
        
        # Effect es requerido
        if "Effect" not in statement:
            raise ValueError(f"Statement {index}: Campo 'Effect' requerido")
        
        effect = statement["Effect"]
        if effect not in self.valid_effects:
            raise ValueError(f"Statement {index}: Effect debe ser 'Allow' o 'Deny', encontrado: {effect}")
        
        # Action o NotAction requerido
        if "Action" not in statement and "NotAction" not in statement:
            raise ValueError(f"Statement {index}: Debe tener 'Action' o 'NotAction'")
        
        # Validar actions
        if "Action" in statement:
            self.validate_actions(statement["Action"], index, "Action")
        
        if "NotAction" in statement:
            self.validate_actions(statement["NotAction"], index, "NotAction")
        
        # Validar recursos si están presentes
        if "Resource" in statement:
            self.validate_resources(statement["Resource"], index, "Resource")
        
        if "NotResource" in statement:
            self.validate_resources(statement["NotResource"], index, "NotResource")
    
    def validate_actions(self, actions: Any, statement_index: int, field_name: str) -> None:
        """Validar acciones."""
        if isinstance(actions, str):
            actions = [actions]
        
        if not isinstance(actions, list):
            raise ValueError(f"Statement {statement_index}: {field_name} debe ser string o lista")
        
        for action in actions:
            if not isinstance(action, str):
                raise ValueError(f"Statement {statement_index}: Cada acción debe ser string")
            
            if not action or action.isspace():
                raise ValueError(f"Statement {statement_index}: Acción no puede estar vacía")
    
    def validate_resources(self, resources: Any, statement_index: int, field_name: str) -> None:
        """Validar recursos."""
        if isinstance(resources, str):
            resources = [resources]
        
        if not isinstance(resources, list):
            raise ValueError(f"Statement {statement_index}: {field_name} debe ser string o lista")
        
        for resource in resources:
            if not isinstance(resource, str):
                raise ValueError(f"Statement {statement_index}: Cada recurso debe ser string")
            
            if not resource or resource.isspace():
                raise ValueError(f"Statement {statement_index}: Recurso no puede estar vacío")
    
    def validate_policy_file(self, file_path: Path) -> None:
        """Validar archivo completo de política."""
        print(f"🔍 Validando política: {file_path}")
        
        try:
            # Validar sintaxis JSON
            policy_data = self.validate_json_syntax(file_path)
            print("✅ Sintaxis JSON válida")
            
            # Validar estructura de política
            self.validate_policy_structure(policy_data)
            print("✅ Estructura de política válida")
            
            # Validaciones específicas
            self.validate_security_best_practices(policy_data, file_path)
            print("✅ Buenas prácticas de seguridad verificadas")
            
            print(f"🎉 Política válida: {file_path}")
            
        except Exception as e:
            print(f"❌ Error en {file_path}: {e}")
            sys.exit(1)
    
    def validate_security_best_practices(self, policy: Dict[str, Any], file_path: Path) -> None:
        """Validar buenas prácticas de seguridad."""
        statements = policy.get("Statement", [])
        if not isinstance(statements, list):
            statements = [statements]
        
        for i, statement in enumerate(statements):
            effect = statement.get("Effect")
            actions = statement.get("Action", [])
            resources = statement.get("Resource", [])
            
            if isinstance(actions, str):
                actions = [actions]
            if isinstance(resources, str):
                resources = [resources]
            
            # Advertencia sobre políticas muy permisivas
            if effect == "Allow":
                # Verificar acciones con *
                for action in actions:
                    if action == "*":
                        print(f"⚠️  Advertencia: Statement {i} usa Action '*' - muy permisivo")
                
                # Verificar recursos con *
                for resource in resources:
                    if resource == "*":
                        print(f"⚠️  Advertencia: Statement {i} usa Resource '*' - muy permisivo")
            
            # Verificar combinaciones peligrosas
            dangerous_actions = ["iam:*", "iam:CreateRole", "iam:AttachRolePolicy", "iam:PutRolePolicy"]
            for action in actions:
                if any(dangerous in action for dangerous in dangerous_actions):
                    print(f"⚠️  Advertencia: Statement {i} contiene acción potencialmente peligrosa: {action}")

def main():
    """Función principal."""
    parser = argparse.ArgumentParser(
        description="Validar archivos de políticas IAM",
        formatter_class=argparse.RawDescriptionHelpFormatter,
        epilog="""
Ejemplos de uso:

  # Validar una política específica
  python scripts/validate_policy.py gerencias/tecnologia/aplicaciones/policy-s3-readonly.json
  
  # Validar múltiples políticas
  find gerencias -name "policy-*.json" -exec python scripts/validate_policy.py {} \;

Estructura esperada de archivo de política:

{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "s3:GetObject",
        "s3:ListBucket"
      ],
      "Resource": [
        "arn:aws:s3:::mi-bucket/*",
        "arn:aws:s3:::mi-bucket"
      ]
    }
  ]
}
        """
    )
    
    parser.add_argument(
        "policy_file",
        help="Archivo de política a validar"
    )
    
    args = parser.parse_args()
    
    # Validar que el archivo existe
    policy_file = Path(args.policy_file)
    if not policy_file.exists():
        print(f"❌ Error: Archivo no encontrado: {policy_file}")
        sys.exit(1)
    
    # Validar que es un archivo de política
    if not policy_file.name.startswith("policy-") or not policy_file.name.endswith(".json"):
        print(f"❌ Error: El archivo debe seguir el patrón 'policy-*.json': {policy_file}")
        sys.exit(1)
    
    # Validar política
    validator = PolicyValidator()
    validator.validate_policy_file(policy_file)

if __name__ == "__main__":
    main()
