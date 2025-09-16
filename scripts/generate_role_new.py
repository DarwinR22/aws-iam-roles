#!/usr/bin/env python3
"""
Generador de Roles IAM
=====================

Script para generar automáticamente la estructura de archivos y configuración
para nuevos roles IAM siguiendo las convenciones organizacionales.

Uso:
    python3 scripts/generate_role.py config.json --gerencia <gerencia> --area <area>

Ejemplo:
    python3 scripts/generate_role.py lambda-payments.json --gerencia tecnologia --area aplicaciones
"""

import json
import os
import sys
import argparse
import re
from pathlib import Path
from datetime import datetime
from typing import Dict, List, Any

class IAMRoleGenerator:
    """Generador de roles IAM con validaciones y templates."""
    
    def __init__(self):
        self.base_path = Path(__file__).parent.parent
        self.templates_path = self.base_path / "templates"
        self.mandatory_tags = [
            "pais", "direccion", "gerencia", "modulo", "alcance_sox",
            "propietario", "proveedor", "dominio", "subdominio", "aplicacion",
            "soporte", "contacto", "proyecto", "creado_por", "ciclo_vida", "version"
        ]
        
    def validate_role_name(self, servicio: str, layer: str, ambiente: str, nombre: str) -> str:
        """Validar y generar nombre de rol según convenciones."""
        # Convertir a lowercase y reemplazar espacios/caracteres especiales
        servicio = re.sub(r'[^a-z0-9-]', '', servicio.lower())
        layer = re.sub(r'[^a-z0-9-]', '', layer.lower())
        ambiente = re.sub(r'[^a-z0-9-]', '', ambiente.lower())
        nombre = re.sub(r'[^a-zA-Z0-9-]', '', nombre)
        
        # Construir nombre
        role_name = f"rol-{servicio}-{layer}-{ambiente}-{nombre}"
        
        # Validar patrón
        pattern = r'^rol-[a-z0-9-]+-[a-z0-9-]+-[a-z0-9-]+-[a-zA-Z0-9-]+$'
        if not re.match(pattern, role_name):
            raise ValueError(f"Nombre de rol inválido: {role_name}")
            
        return role_name
    
    def validate_tags(self, tags: Dict[str, str]) -> None:
        """Validar que todos los tags obligatorios estén presentes."""
        missing_tags = []
        for tag in self.mandatory_tags:
            if tag not in tags or not tags[tag]:
                missing_tags.append(tag)
        
        if missing_tags:
            print(f"❌ Tags obligatorios faltantes: {', '.join(missing_tags)}")
            print("\nTags requeridos:")
            for tag in self.mandatory_tags:
                print(f"  - {tag}")
            raise ValueError("Tags obligatorios faltantes")
        
        # Validar valores específicos
        valid_pais = ["GT", "CR", "SV", "HN", "NI", "PA"]
        if tags.get("pais") not in valid_pais:
            raise ValueError(f"País debe ser uno de: {', '.join(valid_pais)}")
        
        valid_modulo = ["Aplicación", "Infraestructura", "Comunicación", "Analítica"]
        if tags.get("modulo") not in valid_modulo:
            raise ValueError(f"Módulo debe ser uno de: {', '.join(valid_modulo)}")
        
        valid_sox = ["Sí", "No"]
        if tags.get("alcance_sox") not in valid_sox:
            raise ValueError(f"Alcance SOX debe ser: {', '.join(valid_sox)}")
        
        valid_proveedor = ["AWS", "Inhouse", "Externo"]
        if tags.get("proveedor") not in valid_proveedor:
            raise ValueError(f"Proveedor debe ser uno de: {', '.join(valid_proveedor)}")
    
    def validate_policies(self, policies: Dict[str, Any]) -> None:
        """Validar estructura de políticas."""
        if not policies:
            print("⚠️  Advertencia: No se definieron políticas")
            return
            
        # Validar políticas administradas por AWS
        if "aws_managed" in policies:
            for policy_arn in policies["aws_managed"]:
                if not policy_arn.startswith("arn:aws:iam::aws:policy/"):
                    raise ValueError(f"ARN de política inválido: {policy_arn}")
        
        # Validar política inline
        if "inline" in policies:
            inline_policy = policies["inline"]
            if not isinstance(inline_policy, dict):
                raise ValueError("Política inline debe ser un objeto JSON")
            if "Version" not in inline_policy:
                raise ValueError("Política inline debe tener campo 'Version'")
            if "Statement" not in inline_policy:
                raise ValueError("Política inline debe tener campo 'Statement'")
    
    def create_directory_structure(self, gerencia: str, area: str) -> Path:
        """Crear estructura de directorios si no existe."""
        gerencia_path = self.base_path / "gerencias" / gerencia / area
        gerencia_path.mkdir(parents=True, exist_ok=True)
        
        # Crear archivos de configuración si no existen
        tfvars_example = gerencia_path / "terraform.tfvars.example"
        if not tfvars_example.exists():
            self.create_tfvars_example(tfvars_example)
        
        backend_tf = gerencia_path / "backend.tf"
        if not backend_tf.exists():
            self.create_backend_tf(backend_tf, gerencia, area)
        
        return gerencia_path
    
    def create_tfvars_example(self, file_path: Path) -> None:
        """Crear archivo terraform.tfvars.example."""
        content = '''# Configuración del ambiente
ambiente     = "dev"  # dev, qa, prod
aws_region   = "us-east-1"
account_name = "my-account"

# Información del responsable
pais             = "GT"
propietario      = ""
soporte_email    = ""
proyecto_codigo  = ""
creado_por      = ""
ciclo_vida      = "Creación"  # Creación, Implementación, MonitoreoYMantenimiento, Desactivación
version         = "1.0.0"

# Opcional: Override de tags específicos
# custom_tags = {
#   "additional_tag" = "value"
# }
'''
        file_path.write_text(content, encoding='utf-8')
        print(f"✅ Creado: {file_path}")
    
    def create_backend_tf(self, file_path: Path, gerencia: str, area: str) -> None:
        """Crear archivo backend.tf."""
        content = f'''terraform {{
  backend "s3" {{
    bucket         = var.terraform_state_bucket
    key            = "iam/{gerencia}/{area}/terraform.tfstate"
    region         = var.aws_region
    encrypt        = true
    dynamodb_table = var.terraform_lock_table
  }}
}}

variable "terraform_state_bucket" {{
  description = "S3 bucket para almacenar el estado de Terraform"
  type        = string
}}

variable "terraform_lock_table" {{
  description = "DynamoDB table para locks de Terraform"
  type        = string
}}

variable "aws_region" {{
  description = "Región AWS"
  type        = string
  default     = "us-east-1"
}}
'''
        file_path.write_text(content, encoding='utf-8')
        print(f"✅ Creado: {file_path}")
    
    def generate_terraform_file(self, config: Dict[str, Any], output_path: Path) -> str:
        """Generar archivo Terraform para el rol."""
        servicio = config["servicio"]
        layer = config["layer"]
        ambiente = config["ambiente"]
        nombre = config["nombre"]
        description = config.get("description", f"Rol IAM para {servicio}")
        policies = config.get("policies", {})
        tags = config["tags"]
        
        # Generar nombre del rol
        role_name = self.validate_role_name(servicio, layer, ambiente, nombre)
        
        # Nombre del archivo (sin extensión para uso en template)
        file_name = f"{servicio}-{layer}-{nombre}".lower()
        
        # Construir contenido del archivo
        content = f'''# Rol IAM: {role_name}
# Descripción: {description}
# Generado: {datetime.now().strftime("%Y-%m-%d %H:%M:%S")}

locals {{
  role_name = "{role_name}"
  common_tags = {{
'''
        
        # Agregar tags
        for key, value in tags.items():
            content += f'    {key:<15} = "{value}"\n'
        
        content += '''  }
}

module "iam_role" {
  source = "../../../modules/iam-role"
  
  role_name   = local.role_name
  description = "''' + description + '''"
  
  # Configuración del trust policy (assume role)
  trusted_services = ["''' + servicio + '''.amazonaws.com"]
  
  # Tags obligatorios
  tags = local.common_tags
}
'''
        
        # Agregar políticas administradas por AWS
        if policies.get("aws_managed"):
            content += "\n# Políticas administradas por AWS\n"
            for i, policy_arn in enumerate(policies["aws_managed"]):
                content += f'''resource "aws_iam_role_policy_attachment" "managed_policy_{i}" {{
  role       = module.iam_role.role_name
  policy_arn = "{policy_arn}"
}}

'''
        
        # Agregar política inline
        if policies.get("inline"):
            content += '''# Política inline personalizada
resource "aws_iam_role_policy" "inline_policy" {
  name = "${local.role_name}-inline-policy"
  role = module.iam_role.role_id
  
  policy = jsonencode('''
            content += json.dumps(policies["inline"], indent=4).replace('\n', '\n    ')
            content += ''')
}

'''
        
        # Outputs
        content += f'''# Outputs
output "{file_name}_role_arn" {{
  description = "ARN del rol {role_name}"
  value       = module.iam_role.role_arn
}}

output "{file_name}_role_name" {{
  description = "Nombre del rol {role_name}"
  value       = module.iam_role.role_name
}}
'''
        
        # Escribir archivo
        tf_file = output_path / f"{file_name}.tf"
        tf_file.write_text(content, encoding='utf-8')
        print(f"✅ Generado: {tf_file}")
        
        return role_name
    
    def generate_readme(self, output_path: Path, role_name: str, config: Dict[str, Any]) -> None:
        """Generar README específico para el área."""
        readme_path = output_path / "README.md"
        
        if readme_path.exists():
            # Agregar al README existente
            existing_content = readme_path.read_text(encoding='utf-8')
            if role_name not in existing_content:
                new_entry = f"\n## {role_name}\n\n"
                new_entry += f"**Descripción**: {config.get('description', 'N/A')}\n"
                new_entry += f"**Servicio**: {config['servicio']}\n"
                new_entry += f"**Layer**: {config['layer']}\n"
                new_entry += f"**Ambiente**: {config['ambiente']}\n"
                new_entry += f"**Propietario**: {config['tags'].get('propietario', 'N/A')}\n"
                new_entry += f"**Contacto**: {config['tags'].get('contacto', 'N/A')}\n"
                new_entry += f"**Creado**: {datetime.now().strftime('%Y-%m-%d')}\n"
                
                readme_path.write_text(existing_content + new_entry, encoding='utf-8')
        else:
            # Crear nuevo README
            area_name = output_path.name.title()
            gerencia_name = output_path.parent.name.title()
            
            content = f'''# Roles IAM - {gerencia_name} / {area_name}

Este directorio contiene los roles IAM para el área de {area_name} 
de la gerencia de {gerencia_name}.

## Configuración

1. Copiar `terraform.tfvars.example` a `terraform.tfvars`
2. Completar las variables según el ambiente
3. Ejecutar `terraform plan` para revisar cambios
4. Ejecutar `terraform apply` para crear recursos

## Roles Definidos

## {role_name}

**Descripción**: {config.get('description', 'N/A')}
**Servicio**: {config['servicio']}
**Layer**: {config['layer']}
**Ambiente**: {config['ambiente']}
**Propietario**: {config['tags'].get('propietario', 'N/A')}
**Contacto**: {config['tags'].get('contacto', 'N/A')}
**Creado**: {datetime.now().strftime('%Y-%m-%d')}

## Comandos Útiles

```bash
# Validar configuración
terraform validate

# Ver plan de cambios
terraform plan

# Aplicar cambios
terraform apply

# Verificar rol en AWS
aws iam get-role --role-name {role_name}

# Listar políticas adjuntas
aws iam list-attached-role-policies --role-name {role_name}
```

## Soporte

Para preguntas sobre estos roles, contactar a:
- **Email**: {config['tags'].get('contacto', 'N/A')}
- **Propietario**: {config['tags'].get('propietario', 'N/A')}
'''
            readme_path.write_text(content, encoding='utf-8')
        
        print(f"✅ Actualizado: {readme_path}")
    
    def generate_from_config(self, config_file: Path, gerencia: str, area: str) -> None:
        """Generar rol desde archivo de configuración."""
        try:
            # Leer configuración
            with open(config_file, 'r', encoding='utf-8') as f:
                config = json.load(f)
            
            print(f"📋 Generando rol desde: {config_file}")
            print(f"📁 Destino: gerencias/{gerencia}/{area}")
            
            # Validaciones
            required_fields = ["servicio", "layer", "ambiente", "nombre", "tags"]
            for field in required_fields:
                if field not in config:
                    raise ValueError(f"Campo requerido faltante: {field}")
            
            self.validate_tags(config["tags"])
            self.validate_policies(config.get("policies", {}))
            
            # Crear estructura de directorios
            output_path = self.create_directory_structure(gerencia, area)
            
            # Generar archivos
            role_name = self.generate_terraform_file(config, output_path)
            self.generate_readme(output_path, role_name, config)
            
            print(f"\n🎉 Rol {role_name} generado exitosamente!")
            print(f"\n📋 Próximos pasos:")
            print(f"1. cd gerencias/{gerencia}/{area}")
            print(f"2. cp terraform.tfvars.example terraform.tfvars")
            print(f"3. nano terraform.tfvars  # Completar variables")
            print(f"4. terraform plan  # Revisar cambios")
            print(f"5. git add . && git commit -m 'feat: agregar rol {role_name}'")
            
        except Exception as e:
            print(f"❌ Error: {e}")
            sys.exit(1)

def main():
    """Función principal."""
    parser = argparse.ArgumentParser(
        description="Generar roles IAM siguiendo convenciones organizacionales",
        formatter_class=argparse.RawDescriptionHelpFormatter,
        epilog="""
Ejemplos de uso:

  # Generar rol para Lambda
  python3 scripts/generate_role.py lambda-payments.json --gerencia tecnologia --area aplicaciones
  
  # Generar rol para Glue
  python3 scripts/generate_role.py glue-etl.json --gerencia datos --area analytics
  
  # Generar rol para EC2
  python3 scripts/generate_role.py ec2-web.json --gerencia infraestructura --area compute

Estructura del archivo JSON de configuración:

{
  "servicio": "lambda",
  "layer": "api", 
  "ambiente": "dev",
  "nombre": "procesadorPagos",
  "description": "Rol para función Lambda que procesa pagos",
  "policies": {
    "aws_managed": [
      "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
    ],
    "inline": {
      "Version": "2012-10-17",
      "Statement": [...]
    }
  },
  "tags": {
    "pais": "GT",
    "direccion": "Gerencia de Tecnología",
    "gerencia": "Desarrollo de Aplicaciones",
    "modulo": "Aplicación",
    "alcance_sox": "Sí",
    "propietario": "María García",
    "proveedor": "Inhouse",
    "dominio": "FinTech",
    "subdominio": "Pagos",
    "aplicacion": "PAYMENT-PROCESSOR-V2",
    "soporte": "Equipo Backend",
    "contacto": "backend-team@empresa.com",
    "proyecto": "PROJ-2024-PAGOS",
    "creado_por": "maria.garcia@empresa.com",
    "ciclo_vida": "Implementación",
    "version": "1.0.0"
  }
}
        """
    )
    
    parser.add_argument(
        "config_file",
        help="Archivo JSON con la configuración del rol"
    )
    
    parser.add_argument(
        "--gerencia",
        required=True,
        help="Nombre de la gerencia (ej: tecnologia, datos, infraestructura)"
    )
    
    parser.add_argument(
        "--area", 
        required=True,
        help="Nombre del área dentro de la gerencia (ej: aplicaciones, analytics, compute)"
    )
    
    args = parser.parse_args()
    
    # Validar que el archivo de configuración existe
    config_file = Path(args.config_file)
    if not config_file.exists():
        print(f"❌ Error: Archivo no encontrado: {config_file}")
        sys.exit(1)
    
    # Generar rol
    generator = IAMRoleGenerator()
    generator.generate_from_config(config_file, args.gerencia, args.area)

if __name__ == "__main__":
    main()
