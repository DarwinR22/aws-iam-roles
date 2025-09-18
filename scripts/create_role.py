#!/usr/bin/env python3
"""
🚀 Generador Interactivo de Roles IAM
Crea automáticamente estructura de carpetas y archivos de roles IAM
"""

import json
import os
import re
import sys
from pathlib import Path
from datetime import datetime

class IAMRoleGenerator:
    """Generador interactivo de roles IAM con creación de estructura."""
    
    def __init__(self):
        self.base_path = Path('Gerencias')  # Buscar solo en carpeta Gerencias
        self.politicas_path = Path('politicas')  # Carpeta de políticas genéricas
        # Crear carpetas si no existen
        self.base_path.mkdir(exist_ok=True)
        self.politicas_path.mkdir(exist_ok=True)
        
        self.ambientes = {
            '1': 'dev',
            '2': 'qa', 
            '3': 'prod',
            '4': 'poc'
        }

    def get_available_policies(self):
        """Detecta políticas genéricas disponibles por servicio."""
        policies = {}
        if self.politicas_path.exists():
            for service_dir in self.politicas_path.iterdir():
                if service_dir.is_dir():
                    service_policies = []
                    for policy_file in service_dir.glob('POL-*.json'):
                        policy_name = policy_file.stem
                        service_policies.append(policy_name)
                    if service_policies:
                        policies[service_dir.name] = service_policies
        return policies

    def print_banner(self):
        """Imprimir banner de bienvenida."""
        print("🚀 " + "="*60)
        print("🚀 GENERADOR INTERACTIVO DE ROLES IAM")
        print("🚀 Crea estructura + archivo de rol automáticamente")
        print("🚀 " + "="*60)
        print()

    def get_existing_structures(self):
        """Obtener estructuras existentes."""
        gerencias = []
        areas_by_gerencia = {}
        
        for item in self.base_path.iterdir():
            if item.is_dir() and not item.name.startswith('.'):
                gerencias.append(item.name)
                areas = []
                for subitem in item.iterdir():
                    if subitem.is_dir() and subitem.name != 'politicas':
                        areas.append(subitem.name)
                areas_by_gerencia[item.name] = areas
        
        return gerencias, areas_by_gerencia

    def select_or_create_gerencia(self):
        """Seleccionar o crear gerencia."""
        print("📁 PASO 1: Selección de Gerencia")
        print("-" * 30)
        
        gerencias, areas_by_gerencia = self.get_existing_structures()
        
        if gerencias:
            print("📋 Gerencias existentes:")
            for i, gerencia in enumerate(gerencias, 1):
                print(f"   [{i}] {gerencia}")
            print(f"   [{len(gerencias) + 1}] 🆕 Crear nueva gerencia")
            
            while True:
                choice = input(f"\n👉 Selecciona opción [1-{len(gerencias) + 1}]: ").strip()
                if choice.isdigit():
                    choice_num = int(choice)
                    if 1 <= choice_num <= len(gerencias):
                        selected_gerencia = gerencias[choice_num - 1]
                        print(f"✅ Seleccionado: {selected_gerencia}")
                        return selected_gerencia, areas_by_gerencia.get(selected_gerencia, [])
                    elif choice_num == len(gerencias) + 1:
                        break
                print("❌ Opción inválida, intenta de nuevo")
        else:
            print("📝 No hay gerencias existentes, crear nueva:")
        
        # Crear nueva gerencia
        while True:
            gerencia = input("👉 Nombre de la nueva gerencia: ").strip()
            if gerencia and re.match(r'^[A-Za-z][A-Za-z0-9_-]*$', gerencia):
                print(f"✅ Nueva gerencia: {gerencia}")
                return gerencia, []
            print("❌ Nombre inválido. Usa solo letras, números, guiones y guiones bajos")

    def select_or_create_area(self, gerencia, existing_areas):
        """Seleccionar o crear área."""
        print(f"\n📁 PASO 2: Selección de Área en {gerencia}")
        print("-" * 30)
        
        if existing_areas:
            print(f"📋 Áreas existentes en {gerencia}:")
            for i, area in enumerate(existing_areas, 1):
                print(f"   [{i}] {area}")
            print(f"   [{len(existing_areas) + 1}] 🆕 Crear nueva área")
            
            while True:
                choice = input(f"\n👉 Selecciona opción [1-{len(existing_areas) + 1}]: ").strip()
                if choice.isdigit():
                    choice_num = int(choice)
                    if 1 <= choice_num <= len(existing_areas):
                        selected_area = existing_areas[choice_num - 1]
                        print(f"✅ Seleccionado: {selected_area}")
                        return selected_area
                    elif choice_num == len(existing_areas) + 1:
                        break
                print("❌ Opción inválida, intenta de nuevo")
        else:
            print(f"📝 No hay áreas en {gerencia}, crear nueva:")
        
        # Crear nueva área
        while True:
            area = input("👉 Nombre de la nueva área: ").strip()
            if area and re.match(r'^[A-Za-z][A-Za-z0-9_-]*$', area):
                print(f"✅ Nueva área: {area}")
                return area
            print("❌ Nombre inválido. Usa solo letras, números, guiones y guiones bajos")

    def validate_role_name(self, nombre, servicio, ambiente):
        """Validar que el nombre del rol sigue la convención."""
        role_name = f"rol-{servicio}-{nombre}-{ambiente}"
        
        # Patrones de validación
        patterns = {
            'formato_general': r'^rol-[a-z0-9]+(-[a-z0-9]+)*$',
            'sin_mayusculas': r'^[^A-Z]*$',
            'sin_underscores': r'^[^_]*$',
            'longitud_maxima': 64  # AWS IAM role name limit
        }
        
        errors = []
        
        # Validar formato general
        if not re.match(patterns['formato_general'], role_name):
            errors.append("Debe seguir formato: rol-servicio-nombre-ambiente")
        
        # Validar sin mayúsculas
        if not re.match(patterns['sin_mayusculas'], role_name):
            errors.append("No debe contener mayúsculas")
        
        # Validar sin underscores
        if not re.match(patterns['sin_underscores'], role_name):
            errors.append("No debe contener guiones bajos (_)")
        
        # Validar longitud
        if len(role_name) > patterns['longitud_maxima']:
            errors.append(f"Nombre muy largo ({len(role_name)} chars). Máximo: {patterns['longitud_maxima']}")
        
        # Validar componentes individuales
        components = role_name.split('-')
        if len(components) < 4:
            errors.append("Debe tener al menos 4 componentes: rol-servicio-nombre-ambiente")
        
        for i, component in enumerate(components):
            if not component:
                errors.append(f"Componente {i+1} está vacío")
            elif not re.match(r'^[a-z0-9]+$', component):
                errors.append(f"Componente '{component}' debe ser solo minúsculas y números")
        
        return role_name, errors

    def get_owner_info(self):
        """Obtener información del propietario."""
        print(f"\n👤 PASO 3: Información del Propietario")
        print("-" * 30)
        
        # Nombre del propietario
        while True:
            nombre_propietario = input("👉 Tu nombre completo: ").strip()
            if nombre_propietario and len(nombre_propietario) >= 3:
                break
            print("❌ El nombre debe tener al menos 3 caracteres")
        
        # Email del propietario
        while True:
            email_propietario = input("👉 Tu email corporativo: ").strip()
            # Validación básica de email
            email_pattern = r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$'
            if re.match(email_pattern, email_propietario):
                break
            print("❌ Email inválido. Ejemplo: juan.perez@empresa.com")
        
        return nombre_propietario, email_propietario

    def get_role_info(self):
        """Obtener información del rol."""
        print(f"\n📝 PASO 4: Información del Rol")
        print("-" * 30)
        
        # Nombre del rol con validación mejorada
        while True:
            print("💡 El nombre será parte de: rol-[servicio]-[nombre-funcional]-[ambiente]")
            print("📏 Ejemplos válidos:")
            print("   • auth-processor    → rol-lambda-auth-processor-dev")
            print("   • data-transformer  → rol-glue-data-transformer-prod") 
            print("   • api-gateway       → rol-apigateway-api-gateway-qa")
            print("   • read-manager      → rol-s3-read-manager-dev")
            print()
            print("⚠️  Solo escribe la FUNCIÓN (sin 'rol-', sin servicio, sin ambiente)")
            nombre = input("👉 Función del rol (ej: auth-processor): ").strip().lower()
            
            if not nombre:
                print("❌ El nombre no puede estar vacío")
                continue
            
            # Validar que NO contenga 'rol-' al inicio
            if nombre.startswith('rol-'):
                print("❌ No incluyas 'rol-' al inicio. Solo la función.")
                print(f"   Ejemplo: en lugar de '{nombre}', usa '{nombre[4:]}'")
                continue
                
            if not re.match(r'^[a-z0-9]+(-[a-z0-9]+)*$', nombre):
                print("❌ Nombre inválido. Usa solo minúsculas, números y guiones")
                print("   Ejemplos válidos: auth-processor, data-sync, api-handler")
                continue
                
            if len(nombre) > 25:  # Reservar espacio para servicio y ambiente
                print("❌ Nombre muy largo. Máximo 25 caracteres para la función")
                continue
                
            break
        
        # Políticas genéricas disponibles
        return self.select_policy_and_environment(nombre)

    def select_policy_and_environment(self, nombre):
        """Seleccionar política genérica y ambiente."""
        available_policies = self.get_available_policies()
        
        if not available_policies:
            print("\n❌ No hay políticas genéricas disponibles")
            print("💡 Primero debes crear políticas en la carpeta 'politicas/'")
            return None
        
        print("\n🔧 Políticas genéricas disponibles:")
        policy_options = []
        counter = 1
        
        for service, policies in available_policies.items():
            print(f"\n📁 {service.upper()}:")
            for policy in policies:
                print(f"   [{counter}] {policy}")
                policy_options.append((service, policy))
                counter += 1
        
        # Seleccionar política
        while True:
            choice = input(f"\n👉 Selecciona política [1-{len(policy_options)}]: ").strip()
            try:
                choice_idx = int(choice) - 1
                if 0 <= choice_idx < len(policy_options):
                    servicio, policy_name = policy_options[choice_idx]
                    break
                else:
                    print("❌ Número fuera de rango")
            except ValueError:
                print("❌ Debe ser un número")
        
        # Ambiente
        print("\n🌍 Ambientes disponibles:")
        for key, env in self.ambientes.items():
            print(f"   [{key}] {env}")
        
        while True:
            env_choice = input(f"👉 Selecciona ambiente [1-{len(self.ambientes)}]: ").strip()
            if env_choice in self.ambientes:
                ambiente = self.ambientes[env_choice]
                break
            print("❌ Opción inválida")
        
        # Validar nombre completo del rol
        role_name, errors = self.validate_role_name(nombre, servicio, ambiente)
        
        if errors:
            print(f"\n❌ ERRORES en el nombre del rol:")
            for error in errors:
                print(f"   • {error}")
            print(f"\n🔧 Nombre generado: {role_name}")
            print("💡 Vuelve a intentar con un nombre más corto o diferente")
            return self.get_role_info()  # Recursión para reintentar
        
        print(f"\n✅ Rol válido: {role_name}")
        print(f"✅ Usará política: {policy_name}")
        return nombre, servicio, ambiente, policy_name

    def get_complexity_level(self):
        """Seleccionar nivel de complejidad."""
        print(f"\n⚙️ PASO 4: Nivel de Complejidad")
        print("-" * 30)
        print("   [1] 🎯 Simple - Políticas básicas AWS")
        print("   [2] 🔧 Complejo - Políticas custom + inline")
        
        while True:
            choice = input("👉 Selecciona nivel [1-2]: ").strip()
            if choice in ['1', '2']:
                return choice == '2'
            print("❌ Opción inválida")

    def create_structure(self, gerencia, area):
        """Crear estructura de carpetas."""
        print(f"\n🏗️ PASO 6: Creando Estructura")
        print("-" * 30)
        
        # Crear carpeta principal
        main_path = Path("Gerencias") / gerencia / area
        main_path.mkdir(parents=True, exist_ok=True)
        
        # Crear subcarpetas para roles y políticas
        roles_path = main_path / "roles"
        roles_path.mkdir(exist_ok=True)
        
        policies_path = main_path / "politicas"
        policies_path.mkdir(exist_ok=True)
        
        print(f"✅ Estructura creada:")
        print(f"   📁 Gerencias/{gerencia}/")
        print(f"   📁 Gerencias/{gerencia}/{area}/")
        print(f"   📁 Gerencias/{gerencia}/{area}/roles/")
        print(f"   📁 Gerencias/{gerencia}/{area}/politicas/")
        
        return roles_path  # Devolver la carpeta de roles para guardar el archivo ahí

    def create_trust_policy(self, servicio):
        """Crear trust policy según el servicio."""
        service_mapping = {
            'lambda': 'lambda.amazonaws.com',
            'ec2': 'ec2.amazonaws.com',
            'glue': 'glue.amazonaws.com',
            's3': 'ec2.amazonaws.com',  # Para instance profiles
            'ecs': 'ecs-tasks.amazonaws.com',
            'apigateway': 'apigateway.amazonaws.com',
            'rds': 'rds.amazonaws.com',
            'dynamodb': 'ec2.amazonaws.com'
        }
        
        return {
            "Version": "2012-10-17",
            "Statement": [{
                "Effect": "Allow",
                "Principal": {
                    "Service": service_mapping.get(servicio, f"{servicio}.amazonaws.com")
                },
                "Action": "sts:AssumeRole"
            }]
        }

    def check_role_exists(self, role_name):
        """Verificar si ya existe un rol con el mismo nombre."""
        # Buscar en toda la estructura Gerencias/
        for gerencia_path in self.base_path.iterdir():
            if gerencia_path.is_dir():
                for area_path in gerencia_path.rglob("*.json"):
                    if area_path.name == f"{role_name}.json":
                        return True, area_path
        return False, None

    def create_role_config(self, gerencia, area, nombre, servicio, ambiente, policy_name, nombre_propietario, email_propietario):
        """Crear configuración del rol usando políticas genéricas."""
        role_name = f"rol-{servicio}-{nombre}-{ambiente}"
        
        # Verificar si ya existe
        exists, existing_path = self.check_role_exists(role_name)
        if exists:
            print(f"\n⚠️  ADVERTENCIA: Ya existe un rol con este nombre")
            print(f"📄 Ubicación: {existing_path}")
            
            choice = input("¿Continuar anyway? [y/N]: ").strip().lower()
            if choice != 'y':
                print("❌ Operación cancelada")
                sys.exit(1)
        
        # Pedir recursos específicos
        print(f"\n🎯 PASO 5: Recursos Específicos")
        print("-" * 30)
        print(f"💡 La política '{policy_name}' se aplicará SOLO a los recursos que definas aquí.")
        print(f"📝 Ejemplos para {servicio.upper()}:")
        
        if servicio == 's3':
            print("   • arn:aws:s3:::mi-bucket-analytics")
            print("   • arn:aws:s3:::mi-bucket-analytics/*")
            print("   • arn:aws:s3:::data-lake-*")
        elif servicio == 'dynamodb':
            print("   • arn:aws:dynamodb:us-east-1:123456789012:table/users")
            print("   • arn:aws:dynamodb:*:*:table/analytics-*")
        elif servicio == 'lambda':
            print("   • arn:aws:lambda:us-east-1:123456789012:function:process-data")
            print("   • arn:aws:lambda:*:*:function:etl-*")
        elif servicio == 'sqs':
            print("   • arn:aws:sqs:us-east-1:123456789012:data-queue")
            print("   • arn:aws:sqs:*:*:analytics-*")
        
        print("\n📋 Recursos (uno por línea, Enter vacío para terminar):")
        
        resources = []
        while True:
            resource = input("👉 ARN del recurso: ").strip()
            if not resource:
                break
            if resource.startswith('arn:aws:'):
                resources.append(resource)
                print(f"   ✅ Agregado: {resource}")
            else:
                print("   ❌ Debe ser un ARN válido (empezar con 'arn:aws:')")
        
        if not resources:
            print("⚠️  Sin recursos específicos. Se aplicará a TODOS los recursos (*)")
            resources = ["*"]
        
        config = {
            "role_name": role_name,
            "description": f"Rol para {servicio} - {nombre} en ambiente {ambiente}",
            "trust_policy": self.create_trust_policy(servicio),
            "policies": {
                "generic_policy": policy_name,
                "specific_resources": resources
            },
            "tags": {
                "ambiente": ambiente,
                "pais": "GT",
                "direccion": "Tecnologia",
                "gerencia": gerencia,
                "cuenta": "Desarrollo",
                "modulo": "Aplicacion",
                "alcance_sox": "No",
                "propietario": nombre_propietario,
                "proveedor": "Interno",
                "layer": servicio,
                "dominio": area,
                "subdominio": nombre,
                "aplicacion": f"{area}-{nombre}",
                "soporte": "DevOps",
                "contacto": email_propietario,
                "proyecto": f"{gerencia}-{area}",
                "creado_por": nombre_propietario,
                "ciclo_vida": "Creacion",
                "version": "1.0.0"
            },
            "note": f"Este rol usa la política genérica '{policy_name}' con recursos específicos limitados."
        }
        
        return config

    def save_role_file(self, structure_path, config):
        """Guardar archivo de rol."""
        filename = f"{config['role_name']}.json"
        file_path = structure_path / filename
        
        with open(file_path, 'w', encoding='utf-8') as f:
            json.dump(config, f, indent=2, ensure_ascii=False)
        
        return file_path

    def create_policy_file(self, gerencia, area, nombre, servicio, is_complex):
        """Crear archivo de política sugerido."""
        policies_path = Path("Gerencias") / gerencia / area / "politicas"
        
        # Tomar primera palabra del nombre para la política
        base_name = nombre.split('-')[0]
        policy_name = f"policy-{servicio}-{base_name}"
        policy_file = policies_path / f"{policy_name}.json"
        
        # Crear política básica según el servicio
        service_policies = {
            'lambda': {
                "Version": "2012-10-17",
                "Statement": [
                    {
                        "Effect": "Allow",
                        "Action": [
                            "logs:CreateLogGroup",
                            "logs:CreateLogStream", 
                            "logs:PutLogEvents"
                        ],
                        "Resource": "arn:aws:logs:*:*:*"
                    }
                ]
            },
            's3': {
                "Version": "2012-10-17",
                "Statement": [
                    {
                        "Effect": "Allow",
                        "Action": [
                            "s3:GetObject",
                            "s3:ListBucket"
                        ],
                        "Resource": [
                            "arn:aws:s3:::CAMBIAR-BUCKET-NAME",
                            "arn:aws:s3:::CAMBIAR-BUCKET-NAME/*"
                        ]
                    }
                ]
            },
            'dynamodb': {
                "Version": "2012-10-17",
                "Statement": [
                    {
                        "Effect": "Allow",
                        "Action": [
                            "dynamodb:GetItem",
                            "dynamodb:PutItem",
                            "dynamodb:Query",
                            "dynamodb:Scan"
                        ],
                        "Resource": "arn:aws:dynamodb:*:*:table/CAMBIAR-TABLE-NAME"
                    }
                ]
            }
        }
        
        # Política por defecto
        default_policy = {
            "Version": "2012-10-17",
            "Statement": [
                {
                    "Effect": "Allow", 
                    "Action": [
                        f"TODO: Agregar acciones específicas para {servicio}"
                    ],
                    "Resource": "*"
                }
            ]
        }
        
        policy_content = service_policies.get(servicio, default_policy)
        
        with open(policy_file, 'w', encoding='utf-8') as f:
            json.dump(policy_content, f, indent=2, ensure_ascii=False)
        
        return policy_file

    def show_next_steps_updated(self, role_file, policy_file, is_complex, role_name):
        """Mostrar próximos pasos con archivos separados."""
        print(f"\n🎉 ¡Archivos creados exitosamente!")
        print("=" * 50)
        print(f"📄 ROL:      {role_file}")
        print(f"📋 POLÍTICA: {policy_file}")
        
        if is_complex:
            print(f"\n📝 PRÓXIMOS PASOS:")
            print(f"   1. Editar {role_file}")
            print(f"   2. Editar {policy_file}")
            print(f"   3. Completar los TODOs con tus configuraciones específicas")
            print(f"   4. Cambiar CAMBIAR_POR_TU_NOMBRE y CAMBIAR_POR_TU_EMAIL")
            print(f"   5. git add {role_file}")
            print(f"   6. git add {policy_file}")
        else:
            print(f"\n📝 ANTES DE HACER COMMIT:")
            print(f"   1. Verificar tags: propietario, contacto, creado_por")
            print(f"   2. Ajustar configuraciones en ambos archivos")
        
        print(f"   7. git commit -m 'feat: agregar {role_name} con política'")
        print(f"   8. git push origin dev")
        print(f"\n🚀 El pipeline de GitHub Actions se ejecutará automáticamente!")

    def show_next_steps(self, file_path, is_complex, role_name):
        """Mostrar próximos pasos."""
        print(f"\n🎉 ¡Rol creado exitosamente!")
        print("=" * 50)
        print(f"📄 Archivo: {file_path}")
        
        if is_complex:
            print(f"\n📝 PRÓXIMOS PASOS:")
            print(f"   1. Editar {file_path}")
            print(f"   2. Completar los TODOs con tus configuraciones específicas")
            print(f"   3. Cambiar CAMBIAR_POR_TU_NOMBRE y CAMBIAR_POR_TU_EMAIL")
            print(f"   4. git add {file_path}")
        else:
            print(f"\n📝 ANTES DE HACER COMMIT:")
            print(f"   1. Verificar tags: propietario, contacto, creado_por")
            print(f"   2. Ajustar descripción si es necesario")
        
        print(f"   3. git commit -m 'feat: agregar {role_name}'")
        print(f"   4. git push origin dev")
        print(f"\n🚀 El pipeline de GitHub Actions se ejecutará automáticamente!")

    def show_next_steps_updated(self, file_path, role_name, policy_name):
        """Mostrar próximos pasos para el nuevo flujo con políticas genéricas."""
        print(f"\n🎉 ¡Rol creado exitosamente!")
        print("=" * 50)
        print(f"📄 Archivo: {file_path}")
        print(f"🔧 Usa política: {policy_name}")
        
        print(f"\n📝 PRÓXIMOS PASOS:")
        print(f"   1. Verificar recursos específicos en: {file_path}")
        print(f"   2. Revisar política genérica: politicas/{policy_name.split('-')[1]}/{policy_name}.json")
        print(f"   3. git add {file_path}")
        print(f"   4. git commit -m 'feat: agregar {role_name} usando {policy_name}'")
        print(f"   5. git push origin dev")
        print(f"\n🚀 El pipeline de GitHub Actions se ejecutará automáticamente!")
        print(f"\n💡 RECUERDA: El rol limita automáticamente los recursos según lo que definiste.")

    def run(self):
        """Ejecutar el generador."""
        try:
            self.print_banner()
            
            # Paso 1: Seleccionar/crear gerencia
            gerencia, existing_areas = self.select_or_create_gerencia()
            
            # Paso 2: Seleccionar/crear área
            area = self.select_or_create_area(gerencia, existing_areas)
            
            # Paso 3: Información del propietario
            nombre_propietario, email_propietario = self.get_owner_info()
            
            # Paso 4: Información del rol y selección de política
            role_info = self.get_role_info()
            if role_info is None:
                print("❌ No se pudo obtener información del rol")
                return
            
            nombre, servicio, ambiente, policy_name = role_info
            
            # Paso 6: Crear estructura
            roles_path = self.create_structure(gerencia, area)
            
            # Paso 7: Crear configuración del rol
            config = self.create_role_config(gerencia, area, nombre, servicio, ambiente, policy_name, nombre_propietario, email_propietario)
            
            # Paso 8: Guardar archivo de rol
            role_file = self.save_role_file(roles_path, config)
            
            # Paso 9: Mostrar próximos pasos
            self.show_next_steps_updated(role_file, config['role_name'], policy_name)
            
        except KeyboardInterrupt:
            print(f"\n\n❌ Operación cancelada por el usuario")
            sys.exit(1)
        except Exception as e:
            print(f"\n❌ Error: {e}")
            sys.exit(1)

if __name__ == "__main__":
    generator = IAMRoleGenerator()
    generator.run()
