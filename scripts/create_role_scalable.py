#!/usr/bin/env python3
"""
🚀 Creador de Roles IAM - Framework ABAC MCI
=============================================

Script mejorado que se integra perfectamente con la infraestructura ABAC existente:
- Usa las políticas MCI TagBased del catálogo
- Genera estructura de roles compatible con Terraform
- Sigue convenciones de nomenclatura organizacional
- Deploy automático con GitHub Actions
- Escalable para +200 roles con filtros y paginación
"""

import json
import yaml
from pathlib import Path
from datetime import datetime

class MCI_RoleCreator:
    def __init__(self):
        self.base_path = Path(__file__).parent.parent
        self.catalog_path = self.base_path / "catalog"
        self.gerencias_path = self.base_path / "gerencias"
        
        # Cargar catálogo de políticas ABAC
        self.mci_policies = self.cargar_catalogo_politicas()
        
        # Configuración estática
        self.servicios_trust = {
            'lambda': 'lambda.amazonaws.com',
            'ec2': 'ec2.amazonaws.com',
            'ecs': 'ecs-tasks.amazonaws.com',
            'glue': 'glue.amazonaws.com',
            'stepfunctions': 'states.amazonaws.com'
        }
        
        self.ambientes = {
            'dev': 'Desarrollo',
            'qa': 'QA/Testing',
            'prod': 'Producción'
        }
        
        self.paises = {
            'gt': 'Guatemala',
            'sv': 'El Salvador',
            'ni': 'Nicaragua',
            'cr': 'Costa Rica',
            'hn': 'Honduras',
            'rg': 'Regional'
        }

    def cargar_catalogo_politicas(self):
        """Cargar políticas del catálogo ABAC V2 modular."""
        # Primero intentar catálogo V2 modular
        v2_index_file = self.catalog_path / "v2" / "index.yaml"
        if v2_index_file.exists():
            return self._cargar_catalogo_v2()
        
        # Fallback a catálogo V1 si V2 no existe
        catalog_file = self.catalog_path / "policies.yaml"
        if not catalog_file.exists():
            print(f"⚠️  Catálogo no encontrado: {catalog_file}")
            return {}
        
        try:
            with open(catalog_file, 'r', encoding='utf-8') as f:
                catalog = yaml.safe_load(f)
            
            # Organizar políticas por servicio
            policies_by_service = {}
            
            for policy_name, policy_info in catalog.get('policies', {}).items():
                service = policy_info.get('service', 'unknown')
                
                if service not in policies_by_service:
                    policies_by_service[service] = []
                
                policies_by_service[service].append({
                    'name': policy_name,
                    'description': policy_info.get('description', ''),
                    'sox_compliance': policy_info.get('sox_compliance', False)
                })
            
            return policies_by_service
            
        except Exception as e:
            print(f"❌ Error cargando catálogo: {e}")
            return {}

    def _cargar_catalogo_v2(self):
        """Cargar catálogo V2 modular."""
        print("📂 Cargando catálogo V2 modular...")
        try:
            # Cargar índice principal
            index_file = self.catalog_path / "v2" / "index.yaml"
            with open(index_file, 'r', encoding='utf-8') as f:
                index = yaml.safe_load(f)
            
            # Cargar todos los servicios
            policies_by_service = {}
            
            for service_name, service_file in index.get('services', {}).items():
                service_path = self.catalog_path / "v2" / service_file
                
                if service_path.exists():
                    with open(service_path, 'r', encoding='utf-8') as f:
                        service_catalog = yaml.safe_load(f)
                    
                    policies = []
                    for policy_name, policy_info in service_catalog.get('policies', {}).items():
                        policies.append({
                            'name': policy_name,
                            'description': policy_info.get('description', ''),
                            'sox_compliance': policy_info.get('sox_compliance', False),
                            'building_block': policy_info.get('building_block', ''),
                            'policy_document': policy_info.get('policy_document', '')
                        })
                    
                    if policies:
                        policies_by_service[service_name] = policies
            
            print(f"✅ Catálogo V2 cargado: {len(policies_by_service)} servicios")
            return policies_by_service
            
        except Exception as e:
            print(f"❌ Error cargando catálogo V2: {e}")
            print("🔄 Fallback a catálogo V1...")
            return self._cargar_catalogo_v1()

    def _cargar_catalogo_v1(self):
        """Cargar catálogo V1 legacy."""
        catalog_file = self.catalog_path / "policies.yaml"
        if not catalog_file.exists():
            return {}
        
        try:
            with open(catalog_file, 'r', encoding='utf-8') as f:
                catalog = yaml.safe_load(f)
            
            # Organizar políticas por servicio (lógica original)
            policies_by_service = {}
            
            for policy_name, policy_info in catalog.get('policies', {}).items():
                service = policy_info.get('service', 'unknown')
                
                if service not in policies_by_service:
                    policies_by_service[service] = []
                
                policies_by_service[service].append({
                    'name': policy_name,
                    'description': policy_info.get('description', ''),
                    'sox_compliance': policy_info.get('sox_compliance', False)
                })
            
            return policies_by_service
            
        except Exception as e:
            print(f"❌ Error cargando catálogo V1: {e}")
            return {}

    def print_banner(self):
        """Banner del script."""
        print("\n" + "🚀" + "=" * 60)
        print("🚀 CREADOR DE ROLES IAM - FRAMEWORK ABAC MCI")
        print("🚀" + "=" * 60)
        print("📋 Integrado con catálogo de políticas ABAC")
        print("🏷️  Tags canónicos automáticos")
        print("⚡ Compatible con deploy de Terraform\n")

    def mostrar_politicas_disponibles(self):
        """Mostrar políticas MCI disponibles organizadas por servicio."""
        print("\n📋 POLÍTICAS MCI DISPONIBLES (ABAC):")
        print("=" * 50)
        
        for service, policies in self.mci_policies.items():
            print(f"\n🔹 {service.upper()}:")
            for i, policy in enumerate(policies, 1):
                sox_icon = "🔒" if policy['sox_compliance'] else "🔓"
                print(f"   {i}) {policy['name']} {sox_icon}")
                print(f"      {policy['description']}")
        
        print("\n🔒 = SOX Compliance Required")
        print("🔓 = No SOX Compliance Required")

    def mostrar_menu_principal(self):
        """Mostrar menú principal de opciones."""
        print("\n📋 ¿QUÉ DESEAS HACER?")
        print("=" * 30)
        print("   1️⃣  Crear nuevo rol")
        print("   2️⃣  Editar rol existente")  
        print("   3️⃣  Listar roles existentes")
        print("   4️⃣  Salir")
        
        while True:
            try:
                choice = int(input("\n👉 Opción [1-4]: "))
                if 1 <= choice <= 4:
                    return choice
            except ValueError:
                pass
            print("❌ Opción inválida")

    def listar_roles_existentes(self):
        """Listar todos los roles existentes con filtros."""
        roles = self.obtener_todos_los_roles()
        
        if not roles:
            print("📭 No se encontraron roles existentes")
            input("\n⏎ Presiona Enter para continuar...")
            return
        
        print(f"\n📊 Total de roles: {len(roles)}")
        
        # Aplicar filtros si hay muchos roles
        if len(roles) > 20:
            roles_filtrados = self.aplicar_filtros_busqueda(roles)
            self.mostrar_roles_paginado(roles_filtrados)
        else:
            self.mostrar_roles_simple(roles)
        
        input("\n⏎ Presiona Enter para continuar...")

    def mostrar_roles_simple(self, roles):
        """Mostrar roles cuando hay pocos."""
        print("\n📋 ROLES EXISTENTES")
        print("=" * 50)
        
        for i, role in enumerate(roles, 1):
            print(f"\n{i:2}) {role['name']}")
            print(f"    🏢 {role['gerencia'].upper()}/{role['area'].upper()}")
            print(f"    🔧 {role.get('service', 'unknown').upper()} | 🌍 {role.get('ambiente', 'unknown').upper()}")
            print(f"    📝 {role['description'][:60]}{'...' if len(role['description']) > 60 else ''}")

    def mostrar_roles_paginado(self, roles, roles_por_pagina=10):
        """Mostrar roles con paginación."""
        total_roles = len(roles)
        total_paginas = (total_roles + roles_por_pagina - 1) // roles_por_pagina
        pagina_actual = 1
        
        while True:
            start_idx = (pagina_actual - 1) * roles_por_pagina
            end_idx = min(start_idx + roles_por_pagina, total_roles)
            roles_pagina = roles[start_idx:end_idx]
            
            print(f"\n📋 ROLES - PÁGINA {pagina_actual}/{total_paginas} ({total_roles} roles total)")
            print("=" * 60)
            
            for i, role in enumerate(roles_pagina, start_idx + 1):
                print(f"\n{i:2}) {role['name']}")
                print(f"    🏢 {role['gerencia'].upper()}/{role['area'].upper()}")
                print(f"    🔧 {role.get('service', 'unknown').upper()} | 🌍 {role.get('ambiente', 'unknown').upper()}")
                print(f"    📝 {role['description'][:50]}{'...' if len(role['description']) > 50 else ''}")
            
            print(f"\n📄 NAVEGACIÓN:")
            if pagina_actual > 1:
                print("   ⬅️  'p' = Página anterior")
            if pagina_actual < total_paginas:
                print("   ➡️  'n' = Página siguiente")
            print("   🔍 'f' = Aplicar filtros")
            print("   ❌ 'q' = Salir")
            
            user_input = input(f"\n👉 Navegación: ").strip().lower()
            
            if user_input == 'n' and pagina_actual < total_paginas:
                pagina_actual += 1
            elif user_input == 'p' and pagina_actual > 1:
                pagina_actual -= 1
            elif user_input == 'f':
                new_roles = self.aplicar_filtros_busqueda(self.obtener_todos_los_roles())
                return self.mostrar_roles_paginado(new_roles, roles_por_pagina)
            elif user_input == 'q':
                break

    def obtener_todos_los_roles(self):
        """Obtener todos los roles del sistema."""
        roles_encontrados = []
        
        for gerencia_path in self.gerencias_path.iterdir():
            if gerencia_path.is_dir():
                for area_path in gerencia_path.iterdir():
                    if area_path.is_dir():
                        roles_path = area_path / "roles"
                        if roles_path.exists():
                            for role_file in roles_path.glob("*.json"):
                                try:
                                    with open(role_file, 'r', encoding='utf-8') as f:
                                        role_data = json.load(f)
                                    
                                    roles_encontrados.append({
                                        'name': role_data.get('role_name', role_file.stem),
                                        'gerencia': gerencia_path.name,
                                        'area': area_path.name,
                                        'description': role_data.get('description', 'Sin descripción'),
                                        'file': role_file,
                                        'data': role_data,
                                        'service': role_data.get('tags', {}).get('servicio', 'unknown'),
                                        'ambiente': role_data.get('tags', {}).get('ambiente', 'unknown')
                                    })
                                except Exception as e:
                                    print(f"⚠️  Error leyendo {role_file}: {e}")
        
        # Ordenar por gerencia, área y nombre
        roles_encontrados.sort(key=lambda x: (x['gerencia'], x['area'], x['name']))
        return roles_encontrados

    def aplicar_filtros_busqueda(self, roles):
        """Aplicar filtros y búsqueda a la lista de roles."""
        print("\n🔍 FILTROS Y BÚSQUEDA")
        print("=" * 25)
        print("   1️⃣  Ver todos los roles")
        print("   2️⃣  Filtrar por gerencia")
        print("   3️⃣  Filtrar por área")
        print("   4️⃣  Buscar por nombre")
        print("   5️⃣  Filtros avanzados")
        
        while True:
            try:
                choice = int(input("\n👉 Opción [1-5]: "))
                if 1 <= choice <= 5:
                    break
            except ValueError:
                pass
            print("❌ Opción inválida")
        
        if choice == 1:
            return roles
        
        elif choice == 2:
            # Filtrar por gerencia
            gerencias = list(set(role['gerencia'] for role in roles))
            gerencias.sort()
            
            print("\n🏢 GERENCIAS DISPONIBLES:")
            for i, gerencia in enumerate(gerencias, 1):
                count = len([r for r in roles if r['gerencia'] == gerencia])
                print(f"   {i}) {gerencia} ({count} roles)")
            
            while True:
                try:
                    choice = int(input(f"\n👉 Gerencia [1-{len(gerencias)}]: "))
                    if 1 <= choice <= len(gerencias):
                        selected_gerencia = gerencias[choice - 1]
                        return [r for r in roles if r['gerencia'] == selected_gerencia]
                except ValueError:
                    pass
                print("❌ Opción inválida")
        
        elif choice == 3:
            # Filtrar por área
            areas = list(set(f"{role['gerencia']}/{role['area']}" for role in roles))
            areas.sort()
            
            print("\n📂 ÁREAS DISPONIBLES:")
            for i, area in enumerate(areas, 1):
                gerencia, area_name = area.split('/')
                count = len([r for r in roles if r['gerencia'] == gerencia and r['area'] == area_name])
                print(f"   {i}) {area} ({count} roles)")
            
            while True:
                try:
                    choice = int(input(f"\n👉 Área [1-{len(areas)}]: "))
                    if 1 <= choice <= len(areas):
                        selected_area = areas[choice - 1]
                        gerencia, area_name = selected_area.split('/')
                        return [r for r in roles if r['gerencia'] == gerencia and r['area'] == area_name]
                except ValueError:
                    pass
                print("❌ Opción inválida")
        
        elif choice == 4:
            # Buscar por nombre
            search_term = input("\n🔍 Buscar rol (nombre parcial): ").strip().lower()
            if search_term:
                return [r for r in roles if search_term in r['name'].lower()]
            else:
                return roles
        
        elif choice == 5:
            # Filtros avanzados
            print("\n⚙️ FILTROS AVANZADOS")
            print("=" * 20)
            
            # Filtro por servicio
            servicios = list(set(role['service'] for role in roles))
            print(f"Servicios disponibles: {', '.join(servicios)}")
            service_filter = input("🔧 Filtrar por servicio (Enter para omitir): ").strip().lower()
            
            # Filtro por ambiente
            ambientes = list(set(role['ambiente'] for role in roles))
            print(f"Ambientes disponibles: {', '.join(ambientes)}")
            ambiente_filter = input("🌍 Filtrar por ambiente (Enter para omitir): ").strip().lower()
            
            # Aplicar filtros
            filtered_roles = roles
            if service_filter:
                filtered_roles = [r for r in filtered_roles if service_filter in r['service'].lower()]
            if ambiente_filter:
                filtered_roles = [r for r in filtered_roles if ambiente_filter in r['ambiente'].lower()]
            
            return filtered_roles
        
        return roles

    def editar_rol_existente(self):
        """Editar un rol existente con filtros y búsqueda escalable."""
        print("\n✏️ EDITAR ROL EXISTENTE")
        print("=" * 30)
        
        # Buscar todos los roles
        roles_encontrados = self.obtener_todos_los_roles()
        
        if not roles_encontrados:
            print("📭 No se encontraron roles existentes")
            input("\n⏎ Presiona Enter para continuar...")
            return
        
        print(f"\n📊 Total de roles encontrados: {len(roles_encontrados)}")
        
        # Aplicar filtros si hay muchos roles
        if len(roles_encontrados) > 10:
            roles_filtrados = self.aplicar_filtros_busqueda(roles_encontrados)
            
            if not roles_filtrados:
                print("📭 No se encontraron roles con los filtros aplicados")
                input("\n⏎ Presiona Enter para continuar...")
                return
            
            # Seleccionar rol con paginación
            selected_role = self.seleccionar_rol_paginado(roles_filtrados)
        else:
            # Selección simple para pocos roles
            selected_role = self.seleccionar_rol_simple(roles_encontrados)
        
        if selected_role:
            # Editar el rol seleccionado
            self.editar_rol_interactivo(selected_role)

    def seleccionar_rol_simple(self, roles):
        """Selección simple para pocos roles."""
        print("\n📋 ROLES DISPONIBLES PARA EDITAR:")
        print("=" * 40)
        for i, role in enumerate(roles, 1):
            print(f"\n{i:2}) {role['name']}")
            print(f"    🏢 {role['gerencia'].upper()}/{role['area'].upper()}")
            print(f"    🔧 {role['service'].upper()} | 🌍 {role['ambiente'].upper()}")
            print(f"    📝 {role['description'][:60]}{'...' if len(role['description']) > 60 else ''}")
        
        while True:
            try:
                choice = int(input(f"\n👉 Selecciona rol a editar [1-{len(roles)}]: "))
                if 1 <= choice <= len(roles):
                    return roles[choice - 1]
            except ValueError:
                pass
            print("❌ Opción inválida")

    def seleccionar_rol_paginado(self, roles, roles_por_pagina=10):
        """Seleccionar rol con paginación para muchos roles."""
        total_roles = len(roles)
        total_paginas = (total_roles + roles_por_pagina - 1) // roles_por_pagina
        pagina_actual = 1
        
        while True:
            # Calcular índices para la página actual
            start_idx = (pagina_actual - 1) * roles_por_pagina
            end_idx = min(start_idx + roles_por_pagina, total_roles)
            roles_pagina = roles[start_idx:end_idx]
            
            # Mostrar header
            print(f"\n📋 EDITAR ROLES - PÁGINA {pagina_actual}/{total_paginas} ({total_roles} roles filtrados)")
            print("=" * 70)
            
            # Mostrar roles de la página actual
            for i, role in enumerate(roles_pagina, start_idx + 1):
                print(f"\n{i:2}) {role['name']}")
                print(f"    🏢 {role['gerencia'].upper()}/{role['area'].upper()}")
                print(f"    🔧 {role['service'].upper()} | 🌍 {role['ambiente'].upper()}")
                print(f"    📝 {role['description'][:50]}{'...' if len(role['description']) > 50 else ''}")
            
            # Mostrar opciones de navegación
            print(f"\n📄 NAVEGACIÓN:")
            if pagina_actual > 1:
                print("   ⬅️  'p' = Página anterior")
            if pagina_actual < total_paginas:
                print("   ➡️  'n' = Página siguiente")
            print("   🔍 'f' = Aplicar nuevos filtros")
            print("   ❌ 'q' = Cancelar")
            print(f"   📝 [1-{total_roles}] = Seleccionar rol para editar")
            
            # Procesar entrada del usuario
            user_input = input(f"\n👉 Opción: ").strip().lower()
            
            if user_input == 'n' and pagina_actual < total_paginas:
                pagina_actual += 1
            elif user_input == 'p' and pagina_actual > 1:
                pagina_actual -= 1
            elif user_input == 'f':
                # Aplicar nuevos filtros
                new_roles = self.aplicar_filtros_busqueda(self.obtener_todos_los_roles())
                if new_roles:
                    return self.seleccionar_rol_paginado(new_roles, roles_por_pagina)
                else:
                    print("📭 No se encontraron roles con los nuevos filtros")
                    continue
            elif user_input == 'q':
                return None
            else:
                try:
                    choice = int(user_input)
                    if 1 <= choice <= total_roles:
                        return roles[choice - 1]
                    else:
                        print("❌ Número fuera de rango")
                except ValueError:
                    print("❌ Opción inválida")

    def detectar_gerencias_disponibles(self):
        """Detectar gerencias disponibles en el sistema de archivos."""
        gerencias = {}
        
        if not self.gerencias_path.exists():
            return gerencias
        
        for gerencia_path in self.gerencias_path.iterdir():
            if gerencia_path.is_dir():
                gerencia_code = gerencia_path.name
                areas = {}
                
                for area_path in gerencia_path.iterdir():
                    if area_path.is_dir():
                        area_code = area_path.name
                        roles_path = area_path / "roles"
                        
                        # Contar roles existentes
                        roles_count = 0
                        if roles_path.exists():
                            roles_count = len(list(roles_path.glob("*.json")))
                        
                        areas[area_code] = {
                            'name': area_code.replace('-', ' ').title(),
                            'path': area_path,
                            'roles_count': roles_count
                        }
                
                gerencias[gerencia_code] = {
                    'name': gerencia_code,
                    'path': gerencia_path,
                    'areas': areas
                }
        
        return gerencias

    def seleccionar_gerencia(self):
        """Seleccionar gerencia existente o crear nueva."""
        print("\n🏢 SELECCIONAR GERENCIA")
        print("=" * 30)
        
        gerencias = self.detectar_gerencias_disponibles()
        gerencias_list = list(gerencias.keys())
        
        if gerencias_list:
            for i, gerencia_code in enumerate(gerencias_list, 1):
                gerencia_info = gerencias[gerencia_code]
                areas_count = len(gerencia_info['areas'])
                print(f"   {i}) {gerencia_code} - {gerencia_info['name']}")
                print(f"      📁 {areas_count} área(s) disponible(s)")
        
        # Opción para crear nueva gerencia
        next_option = len(gerencias_list) + 1
        print(f"   {next_option}) ➕ Crear nueva gerencia")
        
        while True:
            try:
                choice = int(input(f"\n👉 Gerencia [1-{next_option}]: "))
                if 1 <= choice <= len(gerencias_list):
                    selected_gerencia = gerencias_list[choice - 1]
                    return selected_gerencia, gerencias[selected_gerencia]
                elif choice == next_option:
                    return self.crear_nueva_gerencia()
            except ValueError:
                pass
            print("❌ Opción inválida")

    def crear_nueva_gerencia(self):
        """Crear una nueva gerencia."""
        print("\n➕ CREAR NUEVA GERENCIA")
        print("=" * 25)
        
        while True:
            gerencia_code = input("👉 Código de gerencia (ej: MCI, TEC, FIN): ").strip().upper()
            if gerencia_code and len(gerencia_code) >= 2:
                break
            print("❌ Código debe tener al menos 2 caracteres")
        
        gerencia_name = input(f"📝 Nombre completo de la gerencia: ").strip()
        if not gerencia_name:
            gerencia_name = gerencia_code
        
        gerencia_data = {
            'name': gerencia_name,
            'path': None,
            'areas': {}
        }
        
        return gerencia_code, gerencia_data

    def seleccionar_area(self, gerencia_code, gerencia_data):
        """Seleccionar área dentro de la gerencia."""
        print(f"\n📂 SELECCIONAR ÁREA EN {gerencia_code}")
        print("=" * 35)
        
        areas = gerencia_data['areas']
        areas_list = list(areas.keys())
        
        if areas_list:
            for i, area_code in enumerate(areas_list, 1):
                area_info = areas[area_code]
                print(f"   {i}) {area_code} - {area_info['name']}")
                print(f"      🗂️  {area_info['roles_count']} rol(es) existente(s)")
        
        # Opción para crear nueva área
        next_option = len(areas_list) + 1
        print(f"   {next_option}) ➕ Crear nueva área")
        
        while True:
            try:
                choice = int(input(f"\n👉 Área [1-{next_option}]: "))
                if 1 <= choice <= len(areas_list):
                    selected_area = areas_list[choice - 1]
                    return selected_area, areas[selected_area]
                elif choice == next_option:
                    return self.crear_nueva_area(gerencia_code)
            except ValueError:
                pass
            print("❌ Opción inválida")

    def crear_nueva_area(self, gerencia_code):
        """Crear una nueva área."""
        print(f"\n➕ CREAR NUEVA ÁREA EN {gerencia_code}")
        print("=" * 30)
        
        while True:
            area_code = input("👉 Código de área (ej: bi, finanzas, infra): ").strip().lower()
            if area_code and len(area_code) >= 2:
                break
            print("❌ Código debe tener al menos 2 caracteres")
        
        area_name = input(f"📝 Nombre completo del área: ").strip()
        if not area_name:
            area_name = area_code.replace('-', ' ').title()
        
        area_data = {
            'name': area_name,
            'path': None,
            'roles_count': 0
        }
        
        return area_code, area_data

    def crear_rol_interactivo(self):
        """Proceso interactivo para crear rol."""
        print("\n🏢 SELECCIÓN DE ESTRUCTURA ORGANIZACIONAL")
        print("=" * 45)
        
        # Primero seleccionar gerencia y área
        gerencia_code, gerencia_data = self.seleccionar_gerencia()
        area_code, area_data = self.seleccionar_area(gerencia_code, gerencia_data)
        
        print(f"\n✅ Ubicación seleccionada: {gerencia_code.upper()}/{area_code.upper()}")
        
        # Seleccionar país antes del nombre
        print("\n🌎 PAÍS")
        print("=" * 10)
        for i, (key, name) in enumerate(self.paises.items(), 1):
            print(f"   {i}) {key} - {name}")
        
        while True:
            try:
                choice = int(input(f"\nPaís [1-{len(self.paises)}]: "))
                if 1 <= choice <= len(self.paises):
                    pais = list(self.paises.keys())[choice - 1]
                    break
            except ValueError:
                pass
            print("❌ Opción inválida")
        
        print("\n📝 INFORMACIÓN BÁSICA DEL ROL")
        print("=" * 40)
        
        # Prefijo fijo basado en la selección organizacional y país
        role_prefix = f"rol-{gerencia_code.lower()}-{area_code.lower()}-{pais}"
        print(f"\n🔒 Prefijo fijo: {role_prefix}-")
        print("💡 Solo completa: [aplicacion]")
        print("📄 Ejemplos:")
        print(f"   • {role_prefix}-analytics")
        print(f"   • {role_prefix}-reports")
        print(f"   • {role_prefix}-monitoring")
        
        while True:
            suffix = input(f"\n👉 Completa el nombre ({role_prefix}-): ").strip()
            if suffix and len(suffix) >= 2:
                role_name = f"{role_prefix}-{suffix}"
                break
            print("❌ Debe tener al menos 2 caracteres (ej: analytics)")
        
        # Descripción
        while True:
            description = input("📝 Descripción del rol: ").strip()
            if description and len(description) >= 10:
                break
            print("❌ Descripción debe tener al menos 10 caracteres")
        
        # Servicio de confianza
        print("\n🔐 POLÍTICA DE CONFIANZA")
        print("=" * 30)
        print("¿Qué servicio AWS usará este rol?")
        for i, (key, service) in enumerate(self.servicios_trust.items(), 1):
            print(f"   {i}) {key.upper()} ({service})")
        
        while True:
            try:
                choice = int(input(f"\nServicio [1-{len(self.servicios_trust)}]: "))
                if 1 <= choice <= len(self.servicios_trust):
                    trust_service = list(self.servicios_trust.keys())[choice - 1]
                    break
            except ValueError:
                pass
            print("❌ Opción inválida")
        
        # Ambiente
        print("\n🌍 AMBIENTE")
        print("=" * 15)
        for i, (key, name) in enumerate(self.ambientes.items(), 1):
            print(f"   {i}) {key} - {name}")
        
        while True:
            try:
                choice = int(input(f"\nAmbiente [1-{len(self.ambientes)}]: "))
                if 1 <= choice <= len(self.ambientes):
                    ambiente = list(self.ambientes.keys())[choice - 1]
                    break
            except ValueError:
                pass
            print("❌ Opción inválida")
        
        # Mostrar políticas disponibles
        self.mostrar_politicas_disponibles()
        
        # Seleccionar políticas MCI
        print("\n📋 SELECCIÓN DE POLÍTICAS MCI")
        print("=" * 35)
        print("Selecciona las políticas que necesita este rol:")
        print("(Ejemplo: 1,3,5 para múltiples políticas)")
        
        selected_policies = []
        all_policies = []
        
        for service, policies in self.mci_policies.items():
            for policy in policies:
                all_policies.append(policy['name'])
        
        for i, policy_name in enumerate(all_policies, 1):
            print(f"   {i}) {policy_name}")
        
        while True:
            selection = input("\n🎯 Políticas [números separados por comas]: ").strip()
            if selection:
                try:
                    indices = [int(x.strip()) for x in selection.split(',')]
                    if all(1 <= idx <= len(all_policies) for idx in indices):
                        selected_policies = [all_policies[idx - 1] for idx in indices]
                        break
                    else:
                        print("❌ Algunos números están fuera de rango")
                except ValueError:
                    print("❌ Formato inválido. Use números separados por comas")
            else:
                print("❌ Debe seleccionar al menos una política")
        
        # Tags adicionales
        print("\n🏷️ TAGS ADICIONALES")
        print("=" * 20)
        additional_tags = {}
        
        # Tags básicos requeridos
        equipo = input("👥 Equipo/Team: ").strip() or "DefaultTeam"
        proyecto = input("📁 Proyecto: ").strip() or "DefaultProject"
        propietario = input("👤 Propietario (email): ").strip() or "admin@mci.com"
        
        # Tags adicionales para compatibilidad completa
        print("\n📋 TAGS ESPECÍFICOS DE APLICACIÓN")
        print("=" * 35)
        aplicacion = input("📱 Aplicación: ").strip() or role_name.split('-')[-1]
        version = input("🔢 Versión: ").strip() or "1.0.0"
        
        # Tags con valores predeterminados
        fecha_creacion = datetime.now().strftime('%Y-%m-%d')
        
        additional_tags.update({
            "Equipo": equipo,
            "Proyecto": proyecto,
            "propietario": propietario,
            "ambiente": ambiente,
            "pais": pais,
            "gerencia": gerencia_code,
            "area": area_code,
            "Aplicacion": aplicacion,
            "Version": version,
            "Fechas de Creacion": fecha_creacion,
            "map-migrated": "n/a"
        })
        
        # Generar rol
        return self.generar_rol_json(
            role_name=role_name,
            description=description,
            trust_service=trust_service,
            ambiente=ambiente,
            pais=pais,
            selected_policies=selected_policies,
            additional_tags=additional_tags,
            gerencia_code=gerencia_code,
            area_code=area_code
        )

    def generar_rol_json(self, role_name, description, trust_service, ambiente, pais, selected_policies, additional_tags, gerencia_code, area_code):
        """Generar estructura JSON del rol."""
        
        # Trust policy
        trust_policy = {
            "Version": "2012-10-17",
            "Statement": [
                {
                    "Effect": "Allow",
                    "Principal": {
                        "Service": self.servicios_trust[trust_service]
                    },
                    "Action": "sts:AssumeRole"
                }
            ]
        }
        
        # Políticas AWS managed básicas según el servicio
        aws_managed = []
        if trust_service == 'lambda':
            aws_managed.append("arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole")
        elif trust_service == 'glue':
            aws_managed.append("arn:aws:iam::aws:policy/service-role/AWSGlueServiceRole")
        
        # Tags canónicos
        tags = {
            "ambiente": ambiente,
            "pais": pais,
            "servicio": trust_service,
            "gerencia": gerencia_code,
            "area": area_code,
            **additional_tags
        }
        
        # Estructura del rol
        role_structure = {
            "role_name": role_name,
            "description": description,
            "trust_policy": trust_policy,
            "policies": {
                "aws_managed": aws_managed,
                "mci_managed": selected_policies
            },
            "tags": tags,
            "gerencia_code": gerencia_code,
            "area_code": area_code,
            "note": f"Rol ABAC creado automáticamente - {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}"
        }
        
        return role_structure

    def guardar_rol(self, role_data):
        """Guardar rol en la estructura de carpetas."""
        role_name = role_data['role_name']
        
        # Usar la información de estructura organizacional del rol
        gerencia_code = role_data.get('gerencia_code', 'MCI')
        area_code = role_data.get('area_code', 'general')
        
        # Crear estructura de carpetas
        gerencia_path = self.gerencias_path / gerencia_code.upper()
        area_path = gerencia_path / area_code.lower()
        roles_path = area_path / "roles"
        
        roles_path.mkdir(parents=True, exist_ok=True)
        
        # Guardar archivo
        file_path = roles_path / f"{role_name}.json"
        
        with open(file_path, 'w', encoding='utf-8') as f:
            json.dump(role_data, f, indent=2, ensure_ascii=False)
        
        print(f"\n✅ ROL GUARDADO EXITOSAMENTE")
        print(f"📁 Ubicación: {file_path}")
        print(f"🏢 Gerencia: {gerencia_code.upper()}")
        print(f"📂 Área: {area_code.lower()}")
        print(f"🚀 Listo para deploy con Terraform!")
        
        return file_path

    def editar_rol_interactivo(self, role_info):
        """Proceso interactivo para editar un rol."""
        role_data = role_info['data']
        role_file = role_info['file']
        
        print(f"\n✏️ EDITANDO: {role_data['role_name']}")
        print("=" * 50)
        
        print("\n📋 ¿QUÉ DESEAS EDITAR?")
        print("=" * 25)
        print("   1️⃣  Descripción")
        print("   2️⃣  Políticas MCI")
        print("   3️⃣  Tags")
        print("   4️⃣  Todo (descripción, políticas y tags)")
        print("   5️⃣  Cancelar")
        
        while True:
            try:
                choice = int(input("\n👉 Opción [1-5]: "))
                if 1 <= choice <= 5:
                    break
            except ValueError:
                pass
            print("❌ Opción inválida")
        
        if choice == 5:
            print("❌ Edición cancelada")
            return
        
        cambios_realizados = False
        
        # Editar descripción
        if choice in [1, 4]:
            print(f"\n📝 DESCRIPCIÓN ACTUAL: {role_data['description']}")
            nueva_descripcion = input("Nueva descripción (Enter para mantener): ").strip()
            if nueva_descripcion:
                role_data['description'] = nueva_descripcion
                cambios_realizados = True
                print("✅ Descripción actualizada")
        
        # Editar políticas
        if choice in [2, 4]:
            print(f"\n📋 POLÍTICAS ACTUALES: {', '.join(role_data['policies']['mci_managed'])}")
            
            # Mostrar políticas disponibles
            self.mostrar_politicas_disponibles()
            
            print("\n📋 SELECCIÓN DE NUEVAS POLÍTICAS MCI")
            print("=" * 40)
            print("Selecciona las nuevas políticas (reemplazará las actuales):")
            print("(Ejemplo: 1,3,5 para múltiples políticas)")
            
            all_policies = []
            for service, policies in self.mci_policies.items():
                for policy in policies:
                    all_policies.append(policy['name'])
            
            for i, policy_name in enumerate(all_policies, 1):
                current_mark = "✅" if policy_name in role_data['policies']['mci_managed'] else "  "
                print(f"{current_mark} {i}) {policy_name}")
            
            selection = input("\n🎯 Nuevas políticas [números separados por comas]: ").strip()
            if selection:
                try:
                    indices = [int(x.strip()) for x in selection.split(',')]
                    if all(1 <= idx <= len(all_policies) for idx in indices):
                        nuevas_politicas = [all_policies[idx - 1] for idx in indices]
                        role_data['policies']['mci_managed'] = nuevas_politicas
                        cambios_realizados = True
                        print("✅ Políticas actualizadas")
                    else:
                        print("❌ Algunos números están fuera de rango")
                except ValueError:
                    print("❌ Formato inválido")
        
        # Editar tags
        if choice in [3, 4]:
            print("\n🏷️ TAGS ACTUALES:")
            for key, value in role_data['tags'].items():
                print(f"   {key}: {value}")
            
            print("\n🏷️ EDITAR TAGS")
            print("=" * 15)
            print("Escribe 'skip' para mantener el valor actual")
            
            # Editar tags principales
            tags_editables = ['Equipo', 'Proyecto', 'propietario', 'Aplicacion', 'Version']
            
            for tag in tags_editables:
                if tag in role_data['tags']:
                    valor_actual = role_data['tags'][tag]
                    nuevo_valor = input(f"{tag} [{valor_actual}]: ").strip()
                    if nuevo_valor and nuevo_valor.lower() != 'skip':
                        role_data['tags'][tag] = nuevo_valor
                        cambios_realizados = True
        
        if cambios_realizados:
            # Actualizar nota de modificación
            role_data['note'] = f"Rol ABAC modificado - {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}"
            
            # Guardar cambios
            with open(role_file, 'w', encoding='utf-8') as f:
                json.dump(role_data, f, indent=2, ensure_ascii=False)
            
            print(f"\n✅ ROL ACTUALIZADO EXITOSAMENTE")
            print(f"📁 Ubicación: {role_file}")
            print(f"🚀 Listo para deploy con Terraform!")
            
            print("\n🚀 PRÓXIMOS PASOS:")
            print("1️⃣  Hacer commit de los cambios")
            print("2️⃣  Push a la rama de desarrollo")
            print("3️⃣  El workflow de GitHub Actions desplegará automáticamente")
        else:
            print("\n📭 No se realizaron cambios")
        
        input("\n⏎ Presiona Enter para continuar...")

    def ejecutar(self):
        """Punto de entrada principal."""
        self.print_banner()
        
        try:
            while True:
                choice = self.mostrar_menu_principal()
                
                if choice == 1:
                    # Crear nuevo rol
                    role_data = self.crear_rol_interactivo()
                    
                    print("\n" + "=" * 60)
                    print("📋 RESUMEN DEL ROL")
                    print("=" * 60)
                    print(f"🏷️  Nombre: {role_data['role_name']}")
                    print(f"📝 Descripción: {role_data['description']}")
                    print(f"🔐 Servicio: {role_data['trust_policy']['Statement'][0]['Principal']['Service']}")
                    print(f"📋 Políticas MCI: {len(role_data['policies']['mci_managed'])}")
                    print(f"🏷️  Tags: {len(role_data['tags'])}")
                    
                    confirmar = input("\n✅ ¿Crear este rol? [y/N]: ").strip().lower()
                    
                    if confirmar in ['y', 'yes', 'si', 's']:
                        file_path = self.guardar_rol(role_data)
                        
                        print("\n🚀 PRÓXIMOS PASOS:")
                        print("1️⃣  Hacer commit del nuevo rol")
                        print("2️⃣  Push a la rama de desarrollo")
                        print("3️⃣  El workflow de GitHub Actions desplegará automáticamente")
                        print("\n🎉 ¡Rol creado exitosamente!")
                        
                        input("\n⏎ Presiona Enter para continuar...")
                    else:
                        print("❌ Operación cancelada")
                
                elif choice == 2:
                    # Editar rol existente
                    self.editar_rol_existente()
                
                elif choice == 3:
                    # Listar roles existentes
                    self.listar_roles_existentes()
                
                elif choice == 4:
                    # Salir
                    print("\n👋 ¡Hasta luego!")
                    break
                    
        except KeyboardInterrupt:
            print("\n\n❌ Operación cancelada por el usuario")
        except Exception as e:
            print(f"\n❌ Error inesperado: {e}")

def main():
    """Función principal."""
    creator = MCI_RoleCreator()
    creator.ejecutar()

if __name__ == "__main__":
    main()