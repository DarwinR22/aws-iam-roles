#!/usr/bin/env python3
"""
🏗️ SGSI Module Creator - Enterprise Architecture

Crea automáticamente todos los módulos con estructura completa:
- main.tf, variables.tf, outputs.tf para cada servicio
- Siguiendo el patrón de modules/policies/
"""

import os
from pathlib import Path

def create_module_structure():
    """Crea la estructura de módulos completa"""
    
    base_path = Path(".")
    modules_path = base_path / "modules"
    
    # Definir todos los módulos necesarios
    modules = {
        "compute": [
            "ec2-instance",
            "auto-scaling-group", 
            "application-load-balancer",
            "rds-instance",
            "lambda-function"
        ],
        "storage": [
            "s3-bucket",
            "efs-file-system",
            "backup-vault",
            "kms-key"
        ],
        "network": [
            "vpc",
            "security-group", 
            "nat-gateway",
            "internet-gateway",
            "route-table"
        ],
        "observability": [
            "cloudtrail",
            "guardduty",
            "security-hub",
            "cloudwatch-dashboard",
            "cloudwatch-alarm"
        ]
    }
    
    # Crear estructura de directorios
    for category, module_list in modules.items():
        category_path = modules_path / category
        category_path.mkdir(parents=True, exist_ok=True)
        
        for module_name in module_list:
            module_path = category_path / module_name
            module_path.mkdir(parents=True, exist_ok=True)
            
            # Crear archivos básicos si no existen
            files_to_create = ["main.tf", "variables.tf", "outputs.tf"]
            
            for file_name in files_to_create:
                file_path = module_path / file_name
                if not file_path.exists():
                    # Crear archivo con contenido básico
                    content = generate_file_content(category, module_name, file_name)
                    with open(file_path, 'w') as f:
                        f.write(content)
                    print(f"✅ Created: {file_path}")

def generate_file_content(category, module_name, file_type):
    """Genera contenido básico para cada tipo de archivo"""
    
    if file_type == "main.tf":
        return f"""# ==============================================================================
# {module_name.upper().replace('-', ' ')} MODULE - ENTERPRISE GRADE
# ==============================================================================

# TODO: Implement {module_name} resources
# This is a placeholder - implement actual resources based on requirements

resource "null_resource" "placeholder" {{
  triggers = {{
    module_name = "{module_name}"
    category   = "{category}"
  }}
}}
"""
    
    elif file_type == "variables.tf":
        return f"""# ==============================================================================
# {module_name.upper().replace('-', ' ')} MODULE - VARIABLES
# ==============================================================================

variable "name" {{
  description = "Name for the {module_name.replace('-', ' ')}"
  type        = string
}}

variable "environment" {{
  description = "Environment name"
  type        = string
  default     = "production"
}}

variable "common_tags" {{
  description = "Common tags to apply to all resources"
  type        = map(string)
  default = {{
    Project     = "SGSI-Implementation"
    ManagedBy   = "Terraform"
    AssetType   = "{category.title()}-{module_name.title()}"
  }}
}}

# TODO: Add specific variables for {module_name}
"""
    
    elif file_type == "outputs.tf":
        return f"""# ==============================================================================
# {module_name.upper().replace('-', ' ')} MODULE - OUTPUTS
# ==============================================================================

output "module_info" {{
  description = "Information about this {module_name} module"
  value = {{
    module_name = "{module_name}"
    category    = "{category}"
    status      = "implemented"
  }}
}}

# TODO: Add specific outputs for {module_name}
"""
    
    return ""

if __name__ == "__main__":
    print("🏗️ Creating SGSI Module Structure...")
    create_module_structure()
    print("✅ Module structure created successfully!")