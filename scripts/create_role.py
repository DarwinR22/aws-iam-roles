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
        self.base_path = Path('gerencias')  # Buscar solo en carpeta gerencias
        self.politicas_path = Path('politicas')  # Carpeta de políticas genéricas
        # Crear carpetas si no existen
        self.base_path.mkdir(exist_ok=True)
        self.politicas_path.mkdir(exist_ok=True)
        
        self.ambientes = {
            '1': 'dev',
            '2': 'qa', 
            '3': 'prod',
        }

    def get_available_policies(self):
        """Detecta políticas genéricas disponibles por servicio."""
        policies = {}
        if self.politicas_path.exists():
            for service_dir in self.politicas_path.iterdir():
                if service_dir.is_dir():
                    service_policies = []
                    for policy_file in service_dir.glob('MCI-*.json'):
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
                # Quitar espacios y convertir a formato CamelCase
                nombre_propietario = ''.join(word.capitalize() for word in nombre_propietario.split())
                print(f"✅ Nombre formateado: {nombre_propietario}")
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

    def get_additional_info(self):
        """Obtener información adicional para tags."""
        print(f"\n📋 PASO 4: Información Adicional")
        print("-" * 30)
        
        # Dirección
        print("🏢 Dirección organizacional:")
        print("   [1] TICenam")
       # print("   [2] Operaciones")     # Para agregar nuevas: descomenta y agrega lógica en el while
       # print("   [3] Comercial")       # Para agregar nuevas: descomenta y agrega lógica en el while  
       # print("   [4] Finanzas")        # Para agregar nuevas: descomenta y agrega lógica en el while
        print("   [0] Otra (especificar)")
        
        while True:
            direccion_choice = input("👉 Selecciona dirección [1 o 0]: ").strip()
            if direccion_choice == "1":
                direccion = "TICenam"
                break
            # elif direccion_choice == "2":    # Descomenta para agregar Operaciones
            #     direccion = "Operaciones"
            #     break
            # elif direccion_choice == "3":    # Descomenta para agregar Comercial
            #     direccion = "Comercial"  
            #     break
            # elif direccion_choice == "4":    # Descomenta para agregar Finanzas
            #     direccion = "Finanzas"
            #     break
            elif direccion_choice == "0":
                direccion = input("👉 Especifica la dirección: ").strip()
                if direccion:
                    break
            print("❌ Opción inválida, intenta de nuevo")
        
        # Proyecto
        print(f"\n📂 Proyecto:")
        print("💡 Especifica el nombre del proyecto o iniciativa")
        print("   Ejemplos: Portal-Cliente, Analytics-BI, Mobile-App")
        
        while True:
            proyecto = input("👉 Nombre del proyecto: ").strip()
            if proyecto:
                break
            print("❌ El proyecto no puede estar vacío")
        
        # Proveedor
        print(f"\n🏭 Proveedor/Desarrollador:")
        print("   [1] INHOUSE (desarrollo interno)")
        print("   [2] Otro proveedor externo")
        
        while True:
            proveedor_choice = input("👉 Selecciona proveedor [1-2]: ").strip()
            if proveedor_choice == "1":
                proveedor = "INHOUSE"
                break
            elif proveedor_choice == "2":
                proveedor = input("👉 Especifica el proveedor: ").strip()
                if proveedor:
                    break
            print("❌ Opción inválida, intenta de nuevo")
        
        print(f"\n✅ Información adicional configurada:")
        print(f"   • Dirección: {direccion}")
        print(f"   • Proyecto: {proyecto}")
        print(f"   • Proveedor: {proveedor}")
        
        return direccion, proyecto, proveedor

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
        """Seleccionar trust relationship, políticas múltiples y ambiente - SEPARADOS."""
        
        # PASO 3A: Seleccionar Trust Relationship (solo UNA)
        print("\n🔐 PASO 3A: Trust Relationship")
        print("-" * 40)
        print("🤔 ¿QUIÉN puede asumir este rol?")
        
        trust_options = [
            ("lambda", "🔧 Servicio AWS Lambda"),
            ("ec2", "🔧 Servicio AWS EC2"),
            ("glue", "🔧 Servicio AWS Glue"),
            ("ecs", "� Servicio AWS ECS"),
            ("codebuild", "🔧 Servicio AWS CodeBuild"),
            ("stepfunctions", "🔧 Servicio AWS Step Functions"),
            ("sagemaker", "🔧 Servicio AWS SageMaker"),
            ("cross-account", "🏢 Cross-Account Role"),
            ("user", "👤 Usuario Específico"),
            ("federated", "🔐 SAML/Federated"),
            ("github", "🔧 GitHub Actions OIDC")
        ]
        
        for i, (service, description) in enumerate(trust_options, 1):
            print(f"   [{i}] {description}")
        
        # Seleccionar trust relationship
        while True:
            choice = input(f"\n� Selecciona trust relationship [1-{len(trust_options)}]: ").strip()
            try:
                choice_idx = int(choice) - 1
                if 0 <= choice_idx < len(trust_options):
                    trust_service, trust_description = trust_options[choice_idx]
                    print(f"✅ Trust relationship: {trust_description}")
                    break
                else:
                    print("❌ Número fuera de rango")
            except ValueError:
                print("❌ Debe ser un número")
        
        # PASO 3B: Seleccionar Políticas de Permisos (MÚLTIPLES)
        print(f"\n� PASO 3B: Políticas de Permisos")
        print("-" * 40)
        print("🎯 ¿QUÉ puede hacer este rol? (selección múltiple)")
        
        available_policies = self.get_available_policies()
        
        if not available_policies:
            print("\n❌ No hay políticas genéricas disponibles")
            print("💡 Primero debes crear políticas en la carpeta 'politicas/'")
            return None
        
        # Mostrar políticas disponibles
        policy_options = []
        counter = 1
        
        for service, policies in available_policies.items():
            print(f"\n📁 {service.upper()}:")
            for policy in policies:
                print(f"   [{counter}] {policy}")
                policy_options.append(policy)
                counter += 1
        
        # Selección múltiple de políticas
        selected_policies = []
        print(f"\n💡 Selecciona múltiples políticas (una por vez):")
        print(f"💡 Escribe '0' cuando termines de seleccionar")
        
        while True:
            choice = input(f"\n👉 Selecciona política [1-{len(policy_options)}, 0=finalizar]: ").strip()
            
            if choice == '0':
                if selected_policies:
                    break
                else:
                    print("❌ Debes seleccionar al menos una política")
                    continue
            
            try:
                choice_idx = int(choice) - 1
                if 0 <= choice_idx < len(policy_options):
                    policy = policy_options[choice_idx]
                    if policy not in selected_policies:
                        selected_policies.append(policy)
                        print(f"   ✅ Agregada: {policy}")
                        print(f"   📋 Seleccionadas: {', '.join(selected_policies)}")
                    else:
                        print("   ⚠️  Ya seleccionada, elige otra")
                else:
                    print("❌ Número fuera de rango")
            except ValueError:
                print("❌ Debe ser un número o '0' para finalizar")
        
        print(f"\n✅ Políticas seleccionadas: {', '.join(selected_policies)}")
        
        # PASO 3C: Ambiente
        print(f"\n🌍 PASO 3C: Ambiente")
        print("-" * 20)
        for key, env in self.ambientes.items():
            print(f"   [{key}] {env}")
        
        while True:
            env_choice = input(f"👉 Selecciona ambiente [1-{len(self.ambientes)}]: ").strip()
            if env_choice in self.ambientes:
                ambiente = self.ambientes[env_choice]
                break
            print("❌ Opción inválida")
        
        # PASO 3D: Recursos Específicos por Política
        policy_resources = self.collect_specific_resources(selected_policies)
        
        # Validar nombre completo del rol usando el primer servicio de las políticas para naming
        first_policy = selected_policies[0]
        servicio_for_naming = first_policy.split('-')[1].lower()  # MCI-S3-ReadOnly -> s3
        
        role_name, errors = self.validate_role_name(nombre, servicio_for_naming, ambiente)
        
        if errors:
            print(f"\n❌ ERRORES en el nombre del rol:")
            for error in errors:
                print(f"   • {error}")
            print(f"\n🔧 Nombre generado: {role_name}")
            print("💡 Vuelve a intentar con un nombre más corto o diferente")
            # En caso de error, reiniciar desde el principio con política info
            return self.select_policy_and_environment(nombre)
        
        print(f"\n✅ Rol válido: {role_name}")
        print(f"✅ Trust relationship: {trust_description}")
        print(f"✅ Políticas: {', '.join(selected_policies)}")
        
        return nombre, trust_service, ambiente, selected_policies, policy_resources

    def collect_specific_resources(self, selected_policies):
        """Recopilar recursos específicos para cada política seleccionada."""
        print(f"\n🎯 PASO 3D: Recursos Específicos por Política")
        print("-" * 50)
        print("💡 Define a QUÉ recursos aplicar cada política (principio de menor privilegio)")
        
        policy_resources = {}
        
        for policy in selected_policies:
            service = policy.split('-')[1].lower()  # MCI-S3-ReadOnly -> s3
            action_type = policy.split('-')[2].lower()  # ReadOnly, Write, etc.
            
            print(f"\n📋 RECURSOS PARA: {policy}")
            print("-" * 30)
            
            # Ejemplos específicos según el servicio
            if service == 's3':
                print("📝 Ejemplos de recursos S3:")
                print("   • arn:aws:s3:::mi-bucket-data")
                print("   • arn:aws:s3:::mi-bucket-data/*")
                print("   • arn:aws:s3:::cubo-prepago-*")
                print("   • arn:aws:s3:::analytics-*/reports/*")
            elif service == 'dynamodb':
                print("📝 Ejemplos de recursos DynamoDB:")
                print("   • arn:aws:dynamodb:us-east-1:123456789012:table/users")
                print("   • arn:aws:dynamodb:*:*:table/cubo-prepago-*")
                print("   • arn:aws:dynamodb:us-east-1:*:table/analytics-data")
            elif service == 'lambda':
                print("📝 Ejemplos de recursos Lambda:")
                print("   • arn:aws:lambda:us-east-1:123456789012:function:process-data")
                print("   • arn:aws:lambda:*:*:function:transform-*")
                print("   • arn:aws:lambda:*:*:function:cubo-prepago-*")
            elif service == 'sqs':
                print("📝 Ejemplos de recursos SQS:")
                print("   • arn:aws:sqs:us-east-1:123456789012:data-queue")
                print("   • arn:aws:sqs:*:*:cubo-prepago-*")
            else:
                print(f"📝 Recursos para {service.upper()}:")
                print(f"   • arn:aws:{service}:region:account:resource-type/resource-name")
            
            # Recopilar recursos para esta política
            resources = []
            print(f"\n👉 ARNs para {policy} (Enter vacío para terminar):")
            
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
                print(f"⚠️  Sin recursos específicos para {policy}")
                print(f"🔓 Se aplicará a TODOS los recursos {service.upper()} (*)")
                resources = ["*"]
                
                confirm = input("¿Confirmas aplicar a TODOS los recursos? [s/N]: ").lower()
                if not confirm.startswith('s'):
                    print("💡 Vuelve a definir recursos específicos:")
                    continue
            
            policy_resources[policy] = resources
            print(f"✅ {policy}: {len(resources)} recurso(s) definido(s)")
        
        # Resumen final
        print(f"\n📊 RESUMEN DE RECURSOS:")
        for policy, resources in policy_resources.items():
            print(f"   🔧 {policy}")
            for resource in resources[:3]:  # Mostrar máximo 3
                print(f"      • {resource}")
            if len(resources) > 3:
                print(f"      • ... y {len(resources) - 3} más")
        
        return policy_resources

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
        main_path = Path("gerencias") / gerencia / area
        main_path.mkdir(parents=True, exist_ok=True)
        
        # Crear subcarpeta solo para roles (políticas están centralizadas en /politicas/)
        roles_path = main_path / "roles"
        roles_path.mkdir(exist_ok=True)
        
        print(f"✅ Estructura creada:")
        print(f"   📁 Gerencias/{gerencia}/")
        print(f"   📁 Gerencias/{gerencia}/{area}/")
        print(f"   📁 Gerencias/{gerencia}/{area}/roles/")
        print(f"   � Políticas centralizadas en: /politicas/ (MCI-*)")
        
        return roles_path  # Devolver la carpeta de roles para guardar el archivo ahí

    def create_trust_policy(self, servicio):
        """Crear trust policy según el servicio con soporte extendido."""
        
        # Mapeo de servicios AWS estándar
        service_mapping = {
            'lambda': 'lambda.amazonaws.com',
            'ec2': 'ec2.amazonaws.com',
            'glue': 'glue.amazonaws.com',
            's3': 'ec2.amazonaws.com',  # Para instance profiles
            'ecs': 'ecs-tasks.amazonaws.com',
            'apigateway': 'apigateway.amazonaws.com',
            'rds': 'rds.amazonaws.com',
            'dynamodb': 'ec2.amazonaws.com',
            'codebuild': 'codebuild.amazonaws.com',
            'codepipeline': 'codepipeline.amazonaws.com',
            'events': 'events.amazonaws.com',
            'stepfunctions': 'states.amazonaws.com',
            'batch': 'batch.amazonaws.com',
            'datasync': 'datasync.amazonaws.com',
            'dms': 'dms.amazonaws.com',
            'elasticmapreduce': 'elasticmapreduce.amazonaws.com',
            'kinesis': 'kinesis.amazonaws.com',
            'firehose': 'firehose.amazonaws.com',
            'sagemaker': 'sagemaker.amazonaws.com'
        }
        
        # Detectar casos especiales
        if servicio.startswith('cross-account'):
            return self._create_cross_account_trust()
        elif servicio.startswith('user'):
            return self._create_user_trust()
        elif servicio.startswith('federated'):
            return self._create_federated_trust()
        elif servicio.startswith('github'):
            return self._create_github_oidc_trust()
        
        # Servicios AWS estándar
        service = service_mapping.get(servicio, f"{servicio}.amazonaws.com")
        
        return {
            "Version": "2012-10-17",
            "Statement": [{
                "Effect": "Allow",
                "Principal": {
                    "Service": service
                },
                "Action": "sts:AssumeRole"
            }]
        }
    
    def _create_cross_account_trust(self):
        """Trust policy para roles cross-account."""
        print("\n🏢 CONFIGURACIÓN CROSS-ACCOUNT")
        account_id = input("👉 Account ID que puede asumir el rol: ").strip()
        
        trust_policy = {
            "Version": "2012-10-17",
            "Statement": [{
                "Effect": "Allow",
                "Principal": {
                    "AWS": f"arn:aws:iam::{account_id}:root"
                },
                "Action": "sts:AssumeRole"
            }]
        }
        
        # Opcional: agregar condición MFA
        mfa_required = input("👉 ¿Requiere MFA? (s/N): ").lower().startswith('s')
        if mfa_required:
            trust_policy["Statement"][0]["Condition"] = {
                "Bool": {
                    "aws:MultiFactorAuthPresent": "true"
                }
            }
        
        return trust_policy
    
    def _create_user_trust(self):
        """Trust policy para usuarios específicos."""
        print("\n👤 CONFIGURACIÓN USUARIO ESPECÍFICO")
        account_id = input("👉 Account ID: ").strip()
        username = input("👉 Nombre de usuario: ").strip()
        
        return {
            "Version": "2012-10-17",
            "Statement": [{
                "Effect": "Allow",
                "Principal": {
                    "AWS": f"arn:aws:iam::{account_id}:user/{username}"
                },
                "Action": "sts:AssumeRole",
                "Condition": {
                    "Bool": {
                        "aws:MultiFactorAuthPresent": "true"
                    }
                }
            }]
        }
    
    def _create_federated_trust(self):
        """Trust policy para autenticación federada (SAML)."""
        print("\n🔐 CONFIGURACIÓN SAML/FEDERATED")
        provider_arn = input("👉 ARN del SAML Provider: ").strip()
        
        return {
            "Version": "2012-10-17",
            "Statement": [{
                "Effect": "Allow",
                "Principal": {
                    "Federated": provider_arn
                },
                "Action": "sts:AssumeRoleWithSAML",
                "Condition": {
                    "StringEquals": {
                        "SAML:aud": "https://signin.aws.amazon.com/saml"
                    }
                }
            }]
        }
    
    def _create_github_oidc_trust(self):
        """Trust policy para GitHub Actions OIDC."""
        print("\n🔧 CONFIGURACIÓN GITHUB ACTIONS OIDC")
        account_id = input("👉 Account ID de AWS: ").strip()
        repo = input("👉 Repositorio (org/repo): ").strip()
        branch = input("👉 Branch (opcional, default: main): ").strip() or "main"
        
        condition = {
            "StringEquals": {
                f"token.actions.githubusercontent.com:aud": "sts.amazonaws.com"
            },
            "StringLike": {
                f"token.actions.githubusercontent.com:sub": f"repo:{repo}:ref:refs/heads/{branch}"
            }
        }
        
        return {
            "Version": "2012-10-17",
            "Statement": [{
                "Effect": "Allow",
                "Principal": {
                    "Federated": f"arn:aws:iam::{account_id}:oidc-provider/token.actions.githubusercontent.com"
                },
                "Action": "sts:AssumeRoleWithWebIdentity",
                "Condition": condition
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

    def create_role_config(self, gerencia, area, nombre, servicio, ambiente, selected_policies, policy_resources,
                         nombre_propietario, email_propietario, direccion, proyecto, proveedor):
        """Crear configuración del rol usando múltiples políticas genéricas."""
        
        # Para naming, usar el primer servicio de las políticas
        first_policy = selected_policies[0] if selected_policies else "MCI-Custom"
        naming_service = first_policy.split('-')[1].lower() if first_policy != "MCI-Custom" else servicio
        
        role_name = f"rol-{naming_service}-{nombre}-{ambiente}"
        
        # Verificar si ya existe
        exists, existing_path = self.check_role_exists(role_name)
        if exists:
            print(f"\n⚠️  ADVERTENCIA: Ya existe un rol con este nombre")
            print(f"📄 Ubicación: {existing_path}")
            
            choice = input("¿Continuar anyway? [y/N]: ").strip().lower()
            if choice != 'y':
                print("❌ Operación cancelada")
                sys.exit(1)
        
        # Caso normal: políticas MCI-* seleccionadas
        print(f"\n🎯 CONFIGURACIÓN DEL ROL")
        print("-" * 30)
        print(f"✅ Trust relationship: {servicio}")
        print(f"✅ Políticas seleccionadas: {', '.join(selected_policies)}")
        
        # Mostrar resumen de recursos
        print(f"\n📊 Recursos por política:")
        for policy, resources in policy_resources.items():
            print(f"   🔧 {policy}: {len(resources)} recurso(s)")
        
        config = {
            "role_name": role_name,
            "description": f"Rol con trust {servicio} - {nombre} en ambiente {ambiente}",
            "trust_policy": self.create_trust_policy(servicio),
            "policies": {
                "aws_managed": [],
                "custom": selected_policies
            },
            "policy_resources": policy_resources,
            "tags": {
                "ambiente": ambiente,
                "pais": "GT",
                "direccion": direccion,
                "gerencia": gerencia,
                "cuenta": "Desarrollo",
                "modulo": "Aplicacion",
                "alcance_sox": "No",
                "propietario": nombre_propietario,
                "proveedor": proveedor,
                "layer": naming_service,
                "dominio": area,
                "subdominio": nombre,
                "aplicacion": f"{area}-{nombre}",
                "soporte": "DevOps",
                "contacto": email_propietario,
                "proyecto": proyecto,
                "creado_por": nombre_propietario,
                "ciclo_vida": "Creacion",
                "version": "1.0.0"
            },
            "note": f"Rol con trust relationship '{servicio}' y políticas: {', '.join(selected_policies)}. Recursos específicos definidos por política."
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

    def show_next_steps_updated(self, file_path, role_name, selected_policies):
        """Mostrar próximos pasos para el nuevo flujo con múltiples políticas genéricas."""
        print(f"\n🎉 ¡Rol creado exitosamente!")
        print("=" * 60)
        print(f"📄 Archivo: {file_path}")
        print(f"🔧 Políticas aplicadas: {', '.join(selected_policies)}")
        
        print(f"\n📝 PRÓXIMOS PASOS:")
        print(f"   1. Verificar configuración en: {file_path}")
        
        # Mostrar ubicación de cada política
        for i, policy in enumerate(selected_policies, 2):
            service = policy.split('-')[1].lower()
            print(f"   {i}. Revisar política: politicas/{policy}.json")
        
        next_step = len(selected_policies) + 2
        print(f"   {next_step}. git add {file_path}")
        print(f"   {next_step + 1}. git commit -m 'feat: agregar {role_name} con políticas {', '.join(selected_policies)}'")
        print(f"   {next_step + 2}. git push origin dev")
        
        print(f"\n🚀 El pipeline de GitHub Actions se ejecutará automáticamente!")
        print(f"\n💡 VENTAJAS:")
        print(f"   ✅ Múltiples políticas aplicadas de una vez")
        print(f"   ✅ Trust relationship configurado correctamente")
        print(f"   ✅ Reutilización de políticas probadas y auditadas")

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
            
            # Paso 4: Información adicional (dirección, proyecto, proveedor)
            direccion, proyecto, proveedor = self.get_additional_info()
            
            # Paso 5: Información del rol y selección de política
            role_info = self.get_role_info()
            if role_info is None:
                print("❌ No se pudo obtener información del rol")
                return
            
            nombre, servicio, ambiente, selected_policies, policy_resources = role_info
            
            # Paso 6: Crear estructura
            roles_path = self.create_structure(gerencia, area)
            
            # Paso 7: Crear configuración del rol
            config = self.create_role_config(gerencia, area, nombre, servicio, ambiente, selected_policies, policy_resources,
                                           nombre_propietario, email_propietario, direccion, proyecto, proveedor)
            
            # Paso 8: Guardar archivo de rol
            role_file = self.save_role_file(roles_path, config)
            
            # Paso 9: Mostrar próximos pasos
            self.show_next_steps_updated(role_file, config['role_name'], selected_policies)
            
        except KeyboardInterrupt:
            print(f"\n\n❌ Operación cancelada por el usuario")
            sys.exit(1)
        except Exception as e:
            print(f"\n❌ Error: {e}")
            sys.exit(1)

if __name__ == "__main__":
    generator = IAMRoleGenerator()
    generator.run()
