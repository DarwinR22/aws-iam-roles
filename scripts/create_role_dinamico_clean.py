#!/usr/bin/env python3
"""
Crear Roles IAM - Estructura Organizacional Dinamica
===================================================

Flujo directo y logico:
1. ¿Que gerencia? -> Mostrar existentes + opcion crear
2. ¿Que area? -> Mostrar existentes + opcion crear  
3. Aplicacion, pais, etc.
4. Crear rol con estructura: rol-<gerencia>-<area>-<aplicacion>-<pais>

Enfoque: Sin menus confusos, preguntas directas paso a paso.
"""

import os
import re
import json
import yaml
from pathlib import Path


class DynamicRoleCreator:
    """Creador de roles con estructura organizacional dinamica."""
    
    def __init__(self):
        self.base_path = Path(__file__).parent.parent  # mci-aws-iam/
        self.gerencias_path = self.base_path / "gerencias"
        
        # Configuracion base
        self.paises_validos = {
            'gt': 'Guatemala',
            'sv': 'El Salvador',
            'ni': 'Nicaragua', 
            'cr': 'Costa Rica',
            'hn': 'Honduras',
            'rg': 'Regional'
        }
        
        self.ambientes_validos = {
            'dev': 'Desarrollo',
            'qa': 'QA/Testing',
            'prod': 'Produccion'
        }
        
        # Direcciones disponibles (se pueden agregar nuevas)
        self.direcciones_disponibles = [
            'TI Cenam',
            'Marketing',
            'Operaciones',
            'Finanzas'
        ]
        
        # Cuentas AWS disponibles
        self.cuentas_aws = [
            'clarohn-data-analytics-dev',
            'clarohn-data-analytics-prod', 
            'clarohn-data-analytics-qa'
        ]
        
        # Building Blocks MCI disponibles (ABAC Tag-Based)
        self.mci_building_blocks = {
            'S3': [
                'MCI-S3-TagBased-ReadOnly',
                'MCI-S3-TagBased-Write'
            ],
            'DynamoDB': [
                'MCI-DynamoDB-TagBased-ReadOnly', 
                'MCI-DynamoDB-TagBased-Write'
            ],
            'Lambda': [
                'MCI-Lambda-TagBased-Invoke'
            ]
        }
        
        # AWS Managed Policies comunes
        self.aws_managed_policies = [
            'AWSLambdaBasicExecutionRole',
            'AWSGlueServiceRole',
            'ReadOnlyAccess',
            'PowerUserAccess'
        ]
        
        # Opciones SOX
        self.opciones_sox = ['Si', 'No']
        
        # Proveedores disponibles
        self.proveedores_disponibles = [
            'Inhouse',
            'Tercero'
        ]
        
        # Ciclo de vida disponibles
        self.ciclos_vida = [
            'Creacion',
            'Implementacion', 
            'MonitoreoYMantenimiento',
            'Escalado',
            'OptimizacionDeCostos',
            'DesactivacionYEliminacion'
        ]
        
        # Map-migrated opciones
        self.opciones_migrated = ['Si', 'No']
        
        # Estructura organizacional dinamica
        self.org_structure = {
            'gerencias': {},
            'metadata': {
                'last_updated': None,
                'version': '1.0'
            }
        }
        
        # Detectar estructura existente
        self.detectar_estructura_existente()

    def print_banner(self):
        """Banner simple y claro."""
        print(f"\n" + "=" * 50)
        print(f"  GESTION ROLES IAM")
        print(f"=" * 50)

    def detectar_estructura_existente(self):
        """Detecta gerencias y areas existentes en el filesystem."""
        if not self.gerencias_path.exists():
            print(f"Creando carpeta gerencias: {self.gerencias_path}")
            self.gerencias_path.mkdir(parents=True, exist_ok=True)
            return
        
        # Escanear gerencias existentes
        for gerencia_dir in self.gerencias_path.iterdir():
            if gerencia_dir.is_dir() and not gerencia_dir.name.startswith('.'):
                gerencia_code = gerencia_dir.name
                
                # Detectar areas dentro de la gerencia
                areas = {}
                for area_dir in gerencia_dir.iterdir():
                    if area_dir.is_dir() and not area_dir.name.startswith('.'):
                        areas[area_dir.name] = {
                            'name': area_dir.name.replace('-', ' ').title(),
                            'path': str(area_dir),
                            'roles_count': len(list((area_dir / 'roles').glob('*.json'))) if (area_dir / 'roles').exists() else 0
                        }
                
                self.org_structure['gerencias'][gerencia_code] = {
                    'name': gerencia_code.upper(),  # Por ahora simple
                    'areas': areas,
                    'path': str(gerencia_dir)
                }
        
        print(f"Estructura detectada: {len(self.org_structure['gerencias'])} gerencias")

    def seleccionar_o_crear_gerencia(self):
        """Flujo directo: seleccionar gerencia existente o crear nueva."""
        gerencias = list(self.org_structure['gerencias'].keys())
        
        print(f"\n1. GERENCIA:")
        
        # Mostrar gerencias existentes
        if gerencias:
            print(f"Gerencias disponibles:")
            for i, codigo in enumerate(gerencias, 1):
                nombre = self.org_structure['gerencias'][codigo]['name']
                areas_count = len(self.org_structure['gerencias'][codigo]['areas'])
                print(f"   {i}) {codigo} - {nombre} ({areas_count} areas)")
            print(f"   {len(gerencias) + 1}) Crear nueva gerencia")
        else:
            print(f"No hay gerencias. Necesitas crear una.")
            print(f"   1) Crear nueva gerencia")
        
        while True:
            if gerencias:
                try:
                    choice = int(input(f"\nOpcion [1-{len(gerencias) + 1}]: ").strip())
                    if 1 <= choice <= len(gerencias):
                        # Seleccionar gerencia existente
                        gerencia_code = gerencias[choice - 1]
                        gerencia_data = self.org_structure['gerencias'][gerencia_code]
                        return gerencia_code, gerencia_data
                    elif choice == len(gerencias) + 1:
                        # Crear nueva gerencia
                        return self.crear_nueva_gerencia()
                    else:
                        print(f"Numero invalido.")
                except ValueError:
                    print("Ingresa un numero valido.")
            else:
                # Solo opcion de crear
                try:
                    choice = int(input(f"\nOpcion [1]: ").strip())
                    if choice == 1:
                        return self.crear_nueva_gerencia()
                    else:
                        print("Solo hay opcion 1.")
                except ValueError:
                    print("Ingresa el numero 1.")

    def crear_nueva_gerencia(self):
        """Crear una nueva gerencia."""
        print(f"\nCREAR NUEVA GERENCIA:")
        print(f"Paso 1 - Codigo de la gerencia:")
        print(f"  Reglas: 2-10 chars, solo letras mayusculas")
        print(f"  Ejemplos: MCI, TI, RRHH, OPS, VENTAS")
        
        while True:
            codigo = input(f"\nCodigo gerencia: ").strip().upper()
            if re.match(r'^[A-Z]{2,10}$', codigo):
                if codigo not in self.org_structure['gerencias']:
                    break
                print(f"Gerencia {codigo} ya existe.")
            else:
                print("Formato invalido. Solo letras mayusculas, 2-10 chars.")
        
        print(f"\nCodigo confirmado: {codigo}")
        
        # Usar el codigo como nombre por defecto (simplificado)
        nombre = codigo
        
        # Crear estructura fisica
        gerencia_path = self.gerencias_path / codigo
        gerencia_path.mkdir(exist_ok=True)
        
        # Actualizar estructura logica
        gerencia_data = {
            'name': nombre,
            'areas': {},
            'path': str(gerencia_path)
        }
        
        self.org_structure['gerencias'][codigo] = gerencia_data
        
        print(f"Gerencia '{codigo}' creada!")
        return codigo, gerencia_data

    def seleccionar_o_crear_area(self, gerencia_code):
        """Flujo directo: seleccionar area existente o crear nueva."""
        gerencia_data = self.org_structure['gerencias'][gerencia_code]
        areas = list(gerencia_data['areas'].keys())
        
        print(f"\n2. AREA en {gerencia_code}:")
        
        # Mostrar areas existentes
        if areas:
            print(f"Areas disponibles:")
            for i, codigo in enumerate(areas, 1):
                nombre = gerencia_data['areas'][codigo]['name']
                roles_count = gerencia_data['areas'][codigo]['roles_count']
                print(f"   {i}) {codigo} - {nombre} ({roles_count} roles)")
            print(f"   {len(areas) + 1}) Crear nueva area")
        else:
            print(f"No hay areas en {gerencia_code}. Necesitas crear una.")
            print(f"   1) Crear nueva area")
        
        while True:
            if areas:
                try:
                    choice = int(input(f"\nOpcion [1-{len(areas) + 1}]: ").strip())
                    if 1 <= choice <= len(areas):
                        # Seleccionar area existente
                        area_code = areas[choice - 1]
                        area_name = gerencia_data['areas'][area_code]['name']
                        return area_code, area_name
                    elif choice == len(areas) + 1:
                        # Crear nueva area
                        return self.crear_nueva_area(gerencia_code)
                    else:
                        print(f"Numero invalido.")
                except ValueError:
                    print("Ingresa un numero valido.")
            else:
                # Solo opcion de crear
                try:
                    choice = int(input(f"\nOpcion [1]: ").strip())
                    if choice == 1:
                        return self.crear_nueva_area(gerencia_code)
                    else:
                        print("Solo hay opcion 1.")
                except ValueError:
                    print("Ingresa el numero 1.")

    def crear_nueva_area(self, gerencia_code):
        """Crear una nueva area dentro de una gerencia."""
        print(f"\nCREAR NUEVA AREA en {gerencia_code}:")
        print(f"Paso 1 - Codigo del area:")
        print(f"  Reglas: 2-15 chars, letras minusculas y guiones")
        print(f"  Ejemplos: bi, data-analytics, web-services, security")
        
        while True:
            codigo = input(f"\nCodigo area: ").strip().lower()
            if re.match(r'^[a-z][a-z0-9-]*[a-z0-9]$', codigo) and 2 <= len(codigo) <= 15:
                if codigo not in self.org_structure['gerencias'][gerencia_code]['areas']:
                    break
                print(f"Area {codigo} ya existe en {gerencia_code}.")
            else:
                print("Formato invalido. Solo letras minusculas, numeros y guiones.")
        
        print(f"\nCodigo confirmado: {codigo}")
        
        # Usar el codigo como nombre también (simplificado)
        nombre = codigo.replace('-', ' ').title()
        
        # Crear estructura fisica
        gerencia_path = Path(self.org_structure['gerencias'][gerencia_code]['path'])
        area_path = gerencia_path / codigo
        area_path.mkdir(exist_ok=True)
        
        # Crear carpeta roles
        roles_path = area_path / 'roles'
        roles_path.mkdir(exist_ok=True)
        
        # Actualizar estructura logica
        area_data = {
            'name': nombre,
            'path': str(area_path),
            'roles_count': 0
        }
        
        self.org_structure['gerencias'][gerencia_code]['areas'][codigo] = area_data
        
        print(f"Area '{codigo}' creada en {gerencia_code}!")
        return codigo, nombre

    def seleccionar_o_crear_direccion(self):
        """Seleccionar dirección existente o crear nueva."""
        print(f"\nDIRECCION SOLICITANTE:")
        
        # Mostrar direcciones existentes
        for i, direccion in enumerate(self.direcciones_disponibles, 1):
            print(f"   {i}) {direccion}")
        print(f"   {len(self.direcciones_disponibles) + 1}) Crear nueva dirección")
        
        while True:
            try:
                choice = int(input(f"\nOpcion [1-{len(self.direcciones_disponibles) + 1}]: ").strip())
                if 1 <= choice <= len(self.direcciones_disponibles):
                    # Seleccionar dirección existente
                    return self.direcciones_disponibles[choice - 1]
                elif choice == len(self.direcciones_disponibles) + 1:
                    # Crear nueva dirección
                    nueva_direccion = input(f"\nNueva dirección: ").strip()
                    while len(nueva_direccion) < 3:
                        print("Nombre muy corto.")
                        nueva_direccion = input(f"Nueva dirección: ").strip()
                    
                    # Agregar a la lista para futuras ejecuciones
                    self.direcciones_disponibles.append(nueva_direccion)
                    print(f"Dirección '{nueva_direccion}' agregada!")
                    return nueva_direccion
                else:
                    print(f"Numero invalido.")
            except ValueError:
                print("Ingresa un numero valido.")

    def seleccionar_cuenta_aws(self):
        """Seleccionar cuenta AWS."""
        print(f"\nCUENTA AWS:")
        
        # Mostrar cuentas disponibles
        for i, cuenta in enumerate(self.cuentas_aws, 1):
            print(f"   {i}) {cuenta}")
        
        while True:
            try:
                choice = int(input(f"\nCuenta [1-{len(self.cuentas_aws)}]: ").strip())
                if 1 <= choice <= len(self.cuentas_aws):
                    return self.cuentas_aws[choice - 1]
                else:
                    print(f"Numero invalido.")
            except ValueError:
                print("Ingresa un numero valido.")

    def seleccionar_politicas(self):
        """Seleccionar políticas para el rol."""
        print(f"\n" + "=" * 50)
        print(f"POLITICAS PARA EL ROL")
        print(f"=" * 50)
        
        selected_policies = {
            'aws_managed': [],
            'mci_managed': []
        }
        
        # 1. AWS Managed Policies
        print(f"\n1. POLITICAS AWS MANAGED (⚠️ Solo casos especiales):")
        print(f"   Usar solo si no existe MCI Building Block equivalente")
        for i, policy in enumerate(self.aws_managed_policies, 1):
            print(f"   {i}) {policy}")
        print(f"   {len(self.aws_managed_policies) + 1}) Ninguna (Recomendado)")
        
        while True:
            try:
                choices = input(f"\nAWS Managed [números separados por coma o {len(self.aws_managed_policies) + 1} para ninguna]: ").strip()
                if choices == str(len(self.aws_managed_policies) + 1):
                    break
                
                indices = [int(x.strip()) for x in choices.split(',') if x.strip()]
                valid_policies = []
                for idx in indices:
                    if 1 <= idx <= len(self.aws_managed_policies):
                        policy = self.aws_managed_policies[idx - 1]
                        valid_policies.append(policy)
                        print(f"   ⚠️ {policy}")
                
                if valid_policies:
                    print(f"\n📋 RECORDATORIO: Documentar justificación para governance")
                    confirmacion = input(f"¿Confirmar uso de AWS Managed? [y/N]: ").strip().lower()
                    if confirmacion in ['y', 'yes', 'si']:
                        selected_policies['aws_managed'] = valid_policies
                    else:
                        print(f"📌 AWS Managed canceladas")
                break
            except ValueError:
                print("Formato inválido. Usa números separados por coma.")
        
        # 2. MCI Building Blocks
        print(f"\n2. BUILDING BLOCKS MCI (✅ Recomendado):")
        all_mci_blocks = []
        counter = 1
        
        for service, blocks in self.mci_building_blocks.items():
            print(f"\n   {service}:")
            for block in blocks:
                print(f"   {counter}) {block}")
                all_mci_blocks.append(block)
                counter += 1
        
        print(f"   {counter}) Ninguna")
        
        while True:
            try:
                choices = input(f"\nMCI Building Blocks [números separados por coma o {counter} para ninguna]: ").strip()
                if choices == str(counter):
                    break
                
                indices = [int(x.strip()) for x in choices.split(',') if x.strip()]
                valid_blocks = []
                for idx in indices:
                    if 1 <= idx <= len(all_mci_blocks):
                        block = all_mci_blocks[idx - 1]
                        valid_blocks.append(block)
                        print(f"   ✅ {block}")
                
                if valid_blocks:
                    selected_policies['mci_managed'] = valid_blocks
                break
            except ValueError:
                print("Formato inválido. Usa números separados por coma.")
        
        return selected_policies

    def seleccionar_accion(self):
        """Seleccionar si crear o editar rol."""
        print(f"\n¿QUE DESEAS HACER?")
        print(f"   1) Crear nuevo rol")
        print(f"   2) Editar rol existente")
        print(f"   3) Listar roles existentes")
        
        while True:
            try:
                choice = int(input(f"\nOpcion [1-3]: ").strip())
                if choice == 1:
                    return "crear"
                elif choice == 2:
                    return "editar"
                elif choice == 3:
                    return "listar"
                else:
                    print("Opcion invalida.")
            except ValueError:
                print("Ingresa un numero valido.")

    def listar_roles_existentes(self):
        """Listar todos los roles existentes en la estructura."""
        print(f"\n" + "=" * 50)
        print(f"ROLES EXISTENTES")
        print(f"=" * 50)
        
        total_roles = 0
        
        for gerencia_code, gerencia_data in self.org_structure['gerencias'].items():
            if gerencia_data['areas']:
                print(f"\n{gerencia_code} - {gerencia_data['name']}:")
                
                for area_code, area_data in gerencia_data['areas'].items():
                    area_path = Path(area_data['path']) / 'roles'
                    if area_path.exists():
                        roles_files = list(area_path.glob('*.json'))
                        if roles_files:
                            print(f"  {area_code} ({len(roles_files)} roles):")
                            for role_file in roles_files:
                                role_name = role_file.stem
                                print(f"    - {role_name}")
                                total_roles += 1
                        else:
                            print(f"  {area_code} (0 roles)")
        
        if total_roles == 0:
            print(f"\nNo hay roles creados todavía.")
        else:
            print(f"\nTotal: {total_roles} roles")
        
        input(f"\nPresiona Enter para continuar...")

    def seleccionar_rol_existente(self):
        """Seleccionar un rol existente para editar."""
        print(f"\n" + "=" * 50)
        print(f"SELECCIONAR ROL PARA EDITAR")
        print(f"=" * 50)
        
        # Recopilar todos los roles
        roles_disponibles = []
        
        for gerencia_code, gerencia_data in self.org_structure['gerencias'].items():
            for area_code, area_data in gerencia_data['areas'].items():
                area_path = Path(area_data['path']) / 'roles'
                if area_path.exists():
                    for role_file in area_path.glob('*.json'):
                        roles_disponibles.append({
                            'nombre': role_file.stem,
                            'archivo': str(role_file),
                            'gerencia': gerencia_code,
                            'area': area_code
                        })
        
        if not roles_disponibles:
            print(f"No hay roles para editar. ¡Crea uno primero!")
            return None
        
        # Mostrar roles disponibles
        for i, rol in enumerate(roles_disponibles, 1):
            print(f"   {i}) {rol['nombre']} ({rol['gerencia']}/{rol['area']})")
        
        while True:
            try:
                choice = int(input(f"\nRol a editar [1-{len(roles_disponibles)}]: ").strip())
                if 1 <= choice <= len(roles_disponibles):
                    return roles_disponibles[choice - 1]
                else:
                    print("Numero invalido.")
            except ValueError:
                print("Ingresa un numero valido.")

    def editar_rol_existente(self):
        """Editar un rol existente."""
        rol_seleccionado = self.seleccionar_rol_existente()
        if not rol_seleccionado:
            return False
        
        print(f"\n" + "=" * 50)
        print(f"EDITANDO ROL: {rol_seleccionado['nombre']}")
        print(f"=" * 50)
        
        # Leer el archivo actual
        try:
            with open(rol_seleccionado['archivo'], 'r', encoding='utf-8') as f:
                rol_actual = json.load(f)
            
            print(f"\nConfiguracion actual:")
            print(f"Descripcion: {rol_actual['metadata']['description']}")
            print(f"Ambiente: {rol_actual['metadata']['ambiente']}")
            
            # Manejar diferentes formatos de políticas
            policies_data = {}
            if 'policies' in rol_actual and isinstance(rol_actual['policies'], dict):
                # Formato nuevo: policies como diccionario en raíz
                policies_data = rol_actual['policies']
            elif 'policies' in rol_actual['metadata']:
                # Formato intermedio: policies en metadata
                if isinstance(rol_actual['metadata']['policies'], list):
                    # Lista vacía, convertir a formato nuevo
                    policies_data = {'aws_managed': [], 'mci_managed': []}
                elif isinstance(rol_actual['metadata']['policies'], dict):
                    policies_data = rol_actual['metadata']['policies']
            else:
                # Sin políticas, crear estructura
                policies_data = {'aws_managed': [], 'mci_managed': []}
            
            # Mostrar políticas actuales
            if policies_data.get('aws_managed') or policies_data.get('mci_managed'):
                print(f"\nPoliticas actuales:")
                if policies_data.get('aws_managed'):
                    print(f"  AWS Managed: {', '.join(policies_data['aws_managed'])}")
                if policies_data.get('mci_managed'):
                    print(f"  MCI Managed: {', '.join(policies_data['mci_managed'])}")
            
            cambios_realizados = False
            
            while True:
                # Mostrar menú siempre al inicio del loop
                print(f"\n" + "=" * 50)
                print(f"¿QUE DESEAS EDITAR?")
                print(f"=" * 50)
                print(f"   1) Descripción")
                print(f"   2) Ambiente")
                print(f"   3) Políticas AWS Managed (⚠️ Solo en casos especiales)")
                print(f"   4) Políticas MCI Building Blocks (✅ Recomendado)")
                print(f"   5) Tags específicos")
                print(f"   6) Guardar cambios y salir")
                print(f"   7) Salir sin guardar")
                
                try:
                    choice = int(input(f"\nOpcion [1-7]: ").strip())
                    
                    if choice == 1:
                        # Editar descripción
                        print(f"\nDescripción actual: {rol_actual['metadata']['description']}")
                        nueva_desc = input(f"Nueva descripción (Enter para mantener actual): ").strip()
                        if nueva_desc and len(nueva_desc) >= 10:
                            rol_actual['metadata']['description'] = nueva_desc
                            cambios_realizados = True
                            print(f"✅ Descripción actualizada")
                            
                            # Preguntar si quiere continuar editando
                            continuar_editando = input(f"\n¿Continuar editando el rol? [y/N]: ").strip().lower()
                            if continuar_editando not in ['y', 'yes', 'si']:
                                # Guardar automáticamente y salir
                                with open(rol_seleccionado['archivo'], 'w', encoding='utf-8') as f:
                                    json.dump(rol_actual, f, indent=2, ensure_ascii=False)
                                print(f"\n✅ ¡ROL ACTUALIZADO EXITOSAMENTE!")
                                print(f"Archivo: {rol_seleccionado['archivo']}")
                                return True
                        elif nueva_desc and len(nueva_desc) < 10:
                            print(f"❌ Descripción muy corta (mínimo 10 caracteres)")
                        else:
                            print(f"📌 Descripción sin cambios")
                            # Preguntar si quiere continuar editando
                            continuar_editando = input(f"\n¿Continuar editando el rol? [y/N]: ").strip().lower()
                            if continuar_editando not in ['y', 'yes', 'si']:
                                return False
                    
                    elif choice == 2:
                        # Editar ambiente
                        print(f"\nAmbiente actual: {rol_actual['metadata']['ambiente']}")
                        print(f"Ambientes disponibles:")
                        ambientes_list = list(self.ambientes_validos.keys())
                        for i, code in enumerate(ambientes_list, 1):
                            name = self.ambientes_validos[code]
                            actual = "← ACTUAL" if code == rol_actual['metadata']['ambiente'] else ""
                            print(f"   {i}) {code} - {name} {actual}")
                        
                        try:
                            amb_choice = int(input(f"\nNuevo ambiente [1-{len(ambientes_list)} o Enter para mantener]: ").strip() or "0")
                            if 1 <= amb_choice <= len(ambientes_list):
                                nuevo_ambiente = ambientes_list[amb_choice - 1]
                                if nuevo_ambiente != rol_actual['metadata']['ambiente']:
                                    rol_actual['metadata']['ambiente'] = nuevo_ambiente
                                    # Actualizar también en tags
                                    if 'tags' in rol_actual['metadata']:
                                        rol_actual['metadata']['tags']['Ambiente'] = nuevo_ambiente
                                    cambios_realizados = True
                                    print(f"✅ Ambiente actualizado a: {nuevo_ambiente}")
                                    
                                    # Preguntar si quiere continuar editando
                                    continuar_editando = input(f"\n¿Continuar editando el rol? [y/N]: ").strip().lower()
                                    if continuar_editando not in ['y', 'yes', 'si']:
                                        # Guardar automáticamente y salir
                                        with open(rol_seleccionado['archivo'], 'w', encoding='utf-8') as f:
                                            json.dump(rol_actual, f, indent=2, ensure_ascii=False)
                                        print(f"\n✅ ¡ROL ACTUALIZADO EXITOSAMENTE!")
                                        print(f"Archivo: {rol_seleccionado['archivo']}")
                                        return True
                                else:
                                    print(f"📌 Ambiente sin cambios")
                                    # Preguntar si quiere continuar editando
                                    continuar_editando = input(f"\n¿Continuar editando el rol? [y/N]: ").strip().lower()
                                    if continuar_editando not in ['y', 'yes', 'si']:
                                        return False
                            else:
                                print(f"📌 Ambiente sin cambios")
                                # Preguntar si quiere continuar editando
                                continuar_editando = input(f"\n¿Continuar editando el rol? [y/N]: ").strip().lower()
                                if continuar_editando not in ['y', 'yes', 'si']:
                                    return False
                        except ValueError:
                            print(f"📌 Ambiente sin cambios")
                    
                    elif choice == 3:
                        # Editar políticas AWS Managed
                        print(f"\n⚠️ ADVERTENCIA - POLÍTICAS AWS MANAGED")
                        print(f"=" * 50)
                        print(f"Las políticas AWS Managed deben usarse solo cuando:")
                        print(f"• No existe un MCI Building Block equivalente")
                        print(f"• Es un caso especial aprobado por Architecture")
                        print(f"• Para servicios que MCI aún no ha estandarizado")
                        print(f"")
                        print(f"✅ RECOMENDADO: Usar MCI Building Blocks (Opción 4)")
                        print(f"")
                        
                        continuar = input(f"¿Continuar con AWS Managed? [y/N]: ").strip().lower()
                        if continuar not in ['y', 'yes', 'si']:
                            print(f"📌 Operación cancelada - Usa MCI Building Blocks (Opción 4)")
                            continue
                        
                        print(f"\nPolíticas AWS Managed actuales:")
                        aws_actuales = policies_data.get('aws_managed', [])
                        if aws_actuales:
                            for i, policy in enumerate(aws_actuales, 1):
                                print(f"   {i}) {policy}")
                        else:
                            print(f"   (Ninguna)")
                        
                        print(f"\nPolíticas AWS disponibles:")
                        for i, policy in enumerate(self.aws_managed_policies, 1):
                            marcado = "✅" if policy in aws_actuales else "⬜"
                            print(f"   {i}) {marcado} {policy}")
                        print(f"   {len(self.aws_managed_policies) + 1}) Limpiar todas")
                        
                        choices = input(f"\nAWS Policies [números separados por coma, {len(self.aws_managed_policies) + 1} para limpiar, Enter para mantener]: ").strip()
                        if choices:
                            try:
                                if choices == str(len(self.aws_managed_policies) + 1):
                                    # Limpiar todas
                                    policies_data['aws_managed'] = []
                                    # Actualizar en el rol
                                    rol_actual['policies'] = policies_data
                                    # Limpiar de metadata si existe
                                    if 'policies' in rol_actual['metadata']:
                                        del rol_actual['metadata']['policies']
                                    cambios_realizados = True
                                    print(f"✅ Políticas AWS limpiadas")
                                else:
                                    # Seleccionar específicas
                                    indices = [int(x.strip()) for x in choices.split(',') if x.strip()]
                                    nuevas_policies = []
                                    for idx in indices:
                                        if 1 <= idx <= len(self.aws_managed_policies):
                                            nuevas_policies.append(self.aws_managed_policies[idx - 1])
                                    
                                    if nuevas_policies != aws_actuales:
                                        policies_data['aws_managed'] = nuevas_policies
                                        # Actualizar en el rol
                                        rol_actual['policies'] = policies_data
                                        # Limpiar de metadata si existe
                                        if 'policies' in rol_actual['metadata']:
                                            del rol_actual['metadata']['policies']
                                        cambios_realizados = True
                                        print(f"⚠️ Políticas AWS actualizadas: {', '.join(nuevas_policies)}")
                                        print(f"📋 RECORDATORIO: Documentar justificación para governance")
                                        
                                        # Preguntar si quiere continuar editando
                                        continuar_editando = input(f"\n¿Continuar editando el rol? [y/N]: ").strip().lower()
                                        if continuar_editando not in ['y', 'yes', 'si']:
                                            # Guardar automáticamente y salir
                                            with open(rol_seleccionado['archivo'], 'w', encoding='utf-8') as f:
                                                json.dump(rol_actual, f, indent=2, ensure_ascii=False)
                                            print(f"\n✅ ¡ROL ACTUALIZADO EXITOSAMENTE!")
                                            print(f"Archivo: {rol_seleccionado['archivo']}")
                                            return True
                                    else:
                                        print(f"📌 Políticas AWS sin cambios")
                                        # Preguntar si quiere continuar editando
                                        continuar_editando = input(f"\n¿Continuar editando el rol? [y/N]: ").strip().lower()
                                        if continuar_editando not in ['y', 'yes', 'si']:
                                            return False
                            except ValueError:
                                print(f"❌ Formato inválido")
                        else:
                            print(f"📌 Políticas AWS sin cambios")
                    
                    elif choice == 4:
                        # Editar políticas MCI - con bucle interno
                        while True:
                            print(f"\nPolíticas MCI Building Blocks actuales:")
                            mci_actuales = policies_data.get('mci_managed', [])
                            if mci_actuales:
                                for i, policy in enumerate(mci_actuales, 1):
                                    print(f"   {i}) {policy}")
                            else:
                                print(f"   (Ninguna)")
                            
                            print(f"\nBuilding Blocks MCI disponibles:")
                            print(f"💡 Tip: ✅ = seleccionada, ⬜ = disponible")
                            print(f"💡 Comportamiento: Seleccionar número agrega/quita la política")
                            
                            all_mci_blocks = []
                            counter = 1
                            
                            for service, blocks in self.mci_building_blocks.items():
                                print(f"\n   {service}:")
                                for block in blocks:
                                    marcado = "✅" if block in mci_actuales else "⬜"
                                    print(f"   {counter}) {marcado} {block}")
                                    all_mci_blocks.append(block)
                                    counter += 1
                            
                            print(f"   {counter}) Limpiar todas las políticas")
                            
                            choices = input(f"\nMCI Blocks [números separados por coma, {counter} para limpiar todas, Enter para mantener]: ").strip()
                            if choices:
                                try:
                                    if choices == str(counter):
                                        # Limpiar todas
                                        policies_data['mci_managed'] = []
                                        # Actualizar en el rol
                                        rol_actual['policies'] = policies_data
                                        # Limpiar de metadata si existe
                                        if 'policies' in rol_actual['metadata']:
                                            del rol_actual['metadata']['policies']
                                        cambios_realizados = True
                                        print(f"✅ Todas las políticas MCI eliminadas")
                                    else:
                                        # Comportamiento toggle: agregar si no está, quitar si ya está
                                        indices = [int(x.strip()) for x in choices.split(',') if x.strip()]
                                        nuevas_policies = list(mci_actuales)  # Copiar existentes
                                        
                                        for idx in indices:
                                            if 1 <= idx <= len(all_mci_blocks):
                                                policy = all_mci_blocks[idx - 1]
                                                if policy in nuevas_policies:
                                                    # Ya está, quitarla
                                                    nuevas_policies.remove(policy)
                                                    print(f"   ❌ Removida: {policy}")
                                                else:
                                                    # No está, agregarla
                                                    nuevas_policies.append(policy)
                                                    print(f"   ✅ Agregada: {policy}")
                                        
                                        if nuevas_policies != mci_actuales:
                                            policies_data['mci_managed'] = nuevas_policies
                                            # Actualizar en el rol
                                            rol_actual['policies'] = policies_data
                                            # Limpiar de metadata si existe
                                            if 'policies' in rol_actual['metadata']:
                                                del rol_actual['metadata']['policies']
                                            cambios_realizados = True
                                            if nuevas_policies:
                                                print(f"🔄 Políticas MCI actualizadas: {', '.join(nuevas_policies)}")
                                            else:
                                                print(f"🔄 Todas las políticas MCI removidas")
                                        else:
                                            print(f"📌 Políticas MCI sin cambios")
                                except ValueError:
                                    print(f"❌ Formato inválido")
                            else:
                                print(f"📌 Políticas MCI sin cambios")
                            
                            # Preguntar si quiere agregar/modificar más políticas MCI
                            mas_mci = input(f"\n¿Continuar con políticas MCI? [y/N]: ").strip().lower()
                            if mas_mci not in ['y', 'yes', 'si']:
                                break
                        
                        # Después de salir del bucle de políticas MCI, preguntar si continuar editando otras cosas
                        if cambios_realizados:
                            continuar_editando = input(f"\n¿Continuar editando otras opciones del rol? [y/N]: ").strip().lower()
                            if continuar_editando not in ['y', 'yes', 'si']:
                                # Guardar automáticamente y salir
                                with open(rol_seleccionado['archivo'], 'w', encoding='utf-8') as f:
                                    json.dump(rol_actual, f, indent=2, ensure_ascii=False)
                                print(f"\n✅ ¡ROL ACTUALIZADO EXITOSAMENTE!")
                                print(f"Archivo: {rol_seleccionado['archivo']}")
                                return True
                    
                    elif choice == 5:
                        # Editar tags específicos
                        print(f"\nTags editables:")
                        tags_editables = ['Propietario', 'Soporte', 'Contacto', 'Módulo', 'Versión']
                        tags = rol_actual.get('metadata', {}).get('tags', {})
                        
                        for i, tag in enumerate(tags_editables, 1):
                            valor_actual = tags.get(tag, "No definido")
                            print(f"   {i}) {tag}: {valor_actual}")
                        
                        try:
                            tag_choice = int(input(f"\nTag a editar [1-{len(tags_editables)} o Enter para cancelar]: ").strip() or "0")
                            if 1 <= tag_choice <= len(tags_editables):
                                tag_name = tags_editables[tag_choice - 1]
                                valor_actual = tags.get(tag_name, "")
                                print(f"\nValor actual de '{tag_name}': {valor_actual}")
                                nuevo_valor = input(f"Nuevo valor (Enter para mantener actual): ").strip()
                                if nuevo_valor and len(nuevo_valor) >= 2:
                                    if 'tags' not in rol_actual['metadata']:
                                        rol_actual['metadata']['tags'] = {}
                                    rol_actual['metadata']['tags'][tag_name] = nuevo_valor
                                    cambios_realizados = True
                                    print(f"✅ Tag '{tag_name}' actualizado")
                                    
                                    # Preguntar si quiere continuar editando
                                    continuar_editando = input(f"\n¿Continuar editando el rol? [y/N]: ").strip().lower()
                                    if continuar_editando not in ['y', 'yes', 'si']:
                                        # Guardar automáticamente y salir
                                        with open(rol_seleccionado['archivo'], 'w', encoding='utf-8') as f:
                                            json.dump(rol_actual, f, indent=2, ensure_ascii=False)
                                        print(f"\n✅ ¡ROL ACTUALIZADO EXITOSAMENTE!")
                                        print(f"Archivo: {rol_seleccionado['archivo']}")
                                        return True
                                elif nuevo_valor:
                                    print(f"❌ Valor muy corto")
                                else:
                                    print(f"📌 Tag sin cambios")
                                    # Preguntar si quiere continuar editando
                                    continuar_editando = input(f"\n¿Continuar editando el rol? [y/N]: ").strip().lower()
                                    if continuar_editando not in ['y', 'yes', 'si']:
                                        return False
                        except ValueError:
                            print(f"📌 Operación cancelada")
                            # Preguntar si quiere continuar editando
                            continuar_editando = input(f"\n¿Continuar editando el rol? [y/N]: ").strip().lower()
                            if continuar_editando not in ['y', 'yes', 'si']:
                                return False
                    
                    elif choice == 6:
                        # Guardar cambios
                        if cambios_realizados:
                            print(f"\n" + "=" * 50)
                            print(f"RESUMEN DE CAMBIOS")
                            print(f"=" * 50)
                            print(f"Archivo: {rol_seleccionado['archivo']}")
                            
                            confirmacion = input(f"\n¿Guardar cambios? [y/N]: ").strip().lower()
                            if confirmacion in ['y', 'yes', 'si']:
                                # Guardar archivo
                                with open(rol_seleccionado['archivo'], 'w', encoding='utf-8') as f:
                                    json.dump(rol_actual, f, indent=2, ensure_ascii=False)
                                print(f"\n✅ ¡ROL ACTUALIZADO EXITOSAMENTE!")
                                print(f"Archivo: {rol_seleccionado['archivo']}")
                                return True
                            else:
                                print(f"\n❌ Cambios descartados")
                                return False
                        else:
                            print(f"\n📌 No hay cambios para guardar")
                            return False
                    
                    elif choice == 7:
                        # Salir sin guardar
                        if cambios_realizados:
                            confirmacion = input(f"\n¿Salir sin guardar cambios? [y/N]: ").strip().lower()
                            if confirmacion in ['y', 'yes', 'si']:
                                print(f"\n❌ Cambios descartados")
                                return False
                        else:
                            print(f"\n📌 Sin cambios, saliendo...")
                            return False
                    
                    else:
                        print(f"❌ Opción inválida")
                        
                except ValueError:
                    print(f"❌ Ingresa un número válido")
            
        except Exception as e:
            print(f"Error leyendo rol: {e}")
            return False

    def seleccionar_opcion_simple(self, titulo, opciones):
        """Selector genérico para opciones simples."""
        print(f"\n{titulo}:")
        
        for i, opcion in enumerate(opciones, 1):
            print(f"   {i}) {opcion}")
        
        while True:
            try:
                choice = int(input(f"\nOpcion [1-{len(opciones)}]: ").strip())
                if 1 <= choice <= len(opciones):
                    return opciones[choice - 1]
                else:
                    print(f"Numero invalido.")
            except ValueError:
                print("Ingresa un numero valido.")

    def seleccionar_o_crear_proveedor(self):
        """Seleccionar proveedor existente o crear nuevo."""
        print(f"\nPROVEEDOR:")
        
        for i, proveedor in enumerate(self.proveedores_disponibles, 1):
            print(f"   {i}) {proveedor}")
        print(f"   {len(self.proveedores_disponibles) + 1}) Crear nuevo proveedor")
        
        while True:
            try:
                choice = int(input(f"\nOpcion [1-{len(self.proveedores_disponibles) + 1}]: ").strip())
                if 1 <= choice <= len(self.proveedores_disponibles):
                    return self.proveedores_disponibles[choice - 1]
                elif choice == len(self.proveedores_disponibles) + 1:
                    nuevo_proveedor = input(f"\nNuevo proveedor: ").strip()
                    while len(nuevo_proveedor) < 3:
                        print("Nombre muy corto.")
                        nuevo_proveedor = input(f"Nuevo proveedor: ").strip()
                    
                    self.proveedores_disponibles.append(nuevo_proveedor)
                    print(f"Proveedor '{nuevo_proveedor}' agregado!")
                    return nuevo_proveedor
                else:
                    print(f"Numero invalido.")
            except ValueError:
                print("Ingresa un numero valido.")

    def generar_nombre_rol_directo(self):
        """Genera el nombre del rol con flujo directo y logico."""
        print(f"\nVamos a crear un rol siguiendo la estructura:")
        print(f"rol-<gerencia>-<area>-<aplicacion>-<pais>")
        print(f"\n" + "-" * 40)
        
        # 1. Seleccionar o crear gerencia
        gerencia_code, gerencia_data = self.seleccionar_o_crear_gerencia()
        if not gerencia_code:
            return None
        
        # 2. Seleccionar o crear area
        area_code, area_name = self.seleccionar_o_crear_area(gerencia_code)
        if not area_code:
            return None
        
        # 3. Aplicacion
        print(f"\n3. APLICACION:")
        print(f"¿Para que aplicacion o sistema es este rol?")
        print(f"Ejemplos: s3-manager, bi-processor, web-api, data-pipeline")
        
        while True:
            aplicacion = input(f"\nNombre aplicacion: ").strip().lower()
            if re.match(r'^[a-z][a-z0-9-]*[a-z0-9]$', aplicacion) and 3 <= len(aplicacion) <= 20:
                break
            print("Formato: 3-20 chars, solo letras minusculas, numeros y guiones")
        
        # 4. Pais
        paises_list = list(self.paises_validos.keys())
        print(f"\n4. PAIS:")
        for i, codigo in enumerate(paises_list, 1):
            nombre = self.paises_validos[codigo]
            print(f"   {i}) {codigo} - {nombre}")
        
        while True:
            try:
                choice = int(input(f"\nPais [1-{len(paises_list)}]: ").strip())
                if 1 <= choice <= len(paises_list):
                    pais_code = paises_list[choice - 1]
                    break
                print(f"Numero invalido.")
            except ValueError:
                print("Ingresa un numero valido.")
        
        # 5. Generar nombre final
        nombre_rol = f"rol-{gerencia_code.lower()}-{area_code.lower()}-{aplicacion}-{pais_code.lower()}"
        
        print(f"\n" + "=" * 40)
        print(f"ROL GENERADO: {nombre_rol}")
        print(f"=" * 40)
        print(f"Gerencia: {gerencia_code} - {gerencia_data['name']}")
        print(f"Area: {area_code} - {area_name}")
        print(f"Aplicacion: {aplicacion}")
        print(f"Pais: {pais_code} - {self.paises_validos[pais_code]}")
        print(f"=" * 40)
        
        confirmacion = input(f"\n¿Confirmar este nombre? [y/N]: ").strip().lower()
        if confirmacion not in ['y', 'yes', 'si']:
            return None
        
        return {
            'nombre_rol': nombre_rol,
            'gerencia_code': gerencia_code,
            'gerencia_name': gerencia_data['name'],
            'area_code': area_code,
            'area_name': area_name,
            'aplicacion': aplicacion,
            'pais_code': pais_code,
            'pais_name': self.paises_validos[pais_code]
        }

    def crear_archivo_rol(self, info_rol, descripcion, ambiente, politicas):
        """Crear el archivo JSON del rol."""
        try:
            # Estructura del rol IAM
            rol_data = {
                "Version": "2012-10-17",
                "Statement": [
                    {
                        "Effect": "Allow",
                        "Principal": {
                            "Service": "ec2.amazonaws.com"
                        },
                        "Action": "sts:AssumeRole"
                    }
                ]
            }
            
            # Solicitar tags obligatorios adicionales
            print(f"\n" + "=" * 50)
            print(f"TAGS OBLIGATORIOS PARA GOVERNANCE")
            print(f"=" * 50)
            
            # Tags ya conocidos
            tags_obligatorios = {
                "Ambiente": ambiente,
                "País": info_rol['pais_name'],
                "Gerencia": info_rol['gerencia_name'],
                "Aplicación": info_rol['aplicacion'],
                "Name": info_rol['nombre_rol'],
                "Fechas de Creación": "2025-09-21",
                "Tipo de Recurso": "IAM Role"
            }
            
            # Tags que necesitamos preguntar
            tags_por_solicitar = {
                "Módulo": "Tipo de módulo (ej: Aplicación, DB, POC)",
                "Alcance SOX": "¿Está en alcance SOX? (Si/No)",
                "Propietario": "Email del responsable (ej: tu-email@mci.com)",
                "Proveedor": "¿Quién desarrolla? (Inhouse/Tercero)",
                "Layer": "Capa del sistema (ej: Data Analytics & AI)",
                "Dominio": "Dominio AMX (ej: Digital Services)",
                "Subdominio": "Subdominio AMX (ej: Data Platform)",
                "Soporte": "Email de soporte (ej: soporte@mci.com)",
                "Contacto": "Email de contacto técnico",
                "Proyecto": "Nombre del proyecto (ej: DataAnalytics)",
                "Creado Por": "Quién creó el rol (ej: DevOps Team)",
                "Ciclo de Vida": "Ciclo de vida (ej: Desarrollo, Producción)",
                "Versión": "Versión del rol (ej: 1.0.0)",
                "Map-migrated": "¿Migrado? (Si/No)"
            }
            
            print(f"Tags automáticos:")
            for key, value in tags_obligatorios.items():
                print(f"   {key}: {value}")
            
            print(f"\nTags requeridos adicionales:")
            
            # Dirección con selector
            direccion = self.seleccionar_o_crear_direccion()
            tags_obligatorios["Dirección"] = direccion
            
            # Cuenta con selector
            cuenta = self.seleccionar_cuenta_aws()
            tags_obligatorios["Cuenta"] = cuenta
            
            # SOX con selector
            sox = self.seleccionar_opcion_simple("ALCANCE SOX", self.opciones_sox)
            tags_obligatorios["Alcance SOX"] = sox
            
            # Proveedor con selector
            proveedor = self.seleccionar_o_crear_proveedor()
            tags_obligatorios["Proveedor"] = proveedor
            
            # Ciclo de vida con selector
            ciclo_vida = self.seleccionar_opcion_simple("CICLO DE VIDA", self.ciclos_vida)
            tags_obligatorios["Ciclo de Vida"] = ciclo_vida
            
            # Map-migrated con selector
            migrated = self.seleccionar_opcion_simple("MAP-MIGRATED", self.opciones_migrated)
            tags_obligatorios["Map-migrated"] = migrated
            
            print(f"\n" + "-" * 40)
            print(f"CAMPOS DE TEXTO ADICIONALES:")
            print(f"-" * 40)
            
            # Resto de tags por solicitar (campos de texto)
            tags_restantes = {
                "Módulo": "Tipo de módulo (ej: Aplicación, DB, POC)",
                "Propietario": "Email del responsable (ej: tu-email@mci.com)",
                "Layer": "Capa del sistema (ej: Data Analytics & AI)",
                "Dominio": "Dominio AMX (ej: Digital Services)",
                "Subdominio": "Subdominio AMX (ej: Data Platform)",
                "Soporte": "Email de soporte (ej: soporte@mci.com)",
                "Contacto": "Email de contacto técnico",
                "Proyecto": "Nombre del proyecto (ej: DataAnalytics)",
                "Creado Por": "Quién creó el rol (ej: DevOps Team)",
                "Versión": "Versión del rol (ej: 1.0.0)"
            }
            
            for key, descripcion in tags_restantes.items():
                while True:
                    valor = input(f"{key} ({descripcion}): ").strip()
                    if len(valor) >= 2:
                        tags_obligatorios[key] = valor
                        break
                    print(f"Valor muy corto para {key}")
            
            # Metadata del rol completa
            metadata = {
                "role_name": info_rol['nombre_rol'],
                "description": descripcion,
                "ambiente": ambiente,
                "gerencia": {
                    "code": info_rol['gerencia_code'],
                    "name": info_rol['gerencia_name']
                },
                "area": {
                    "code": info_rol['area_code'], 
                    "name": info_rol['area_name']
                },
                "aplicacion": info_rol['aplicacion'],
                "pais": {
                    "code": info_rol['pais_code'],
                    "name": info_rol['pais_name']
                },
                "created_date": "2025-09-21",
                "tags": tags_obligatorios,
                "policies": []
            }
            
            # Crear estructura completa
            role_complete = {
                "metadata": metadata,
                "assume_role_policy": rol_data,
                "policies": {
                    "aws_managed": politicas['aws_managed'],
                    "mci_managed": politicas['mci_managed']
                }
            }
            
            # Crear el archivo
            role_path = Path(self.org_structure['gerencias'][info_rol['gerencia_code']]['areas'][info_rol['area_code']]['path'])
            roles_dir = role_path / 'roles'
            role_file = roles_dir / f"{info_rol['nombre_rol']}.json"
            
            with open(role_file, 'w', encoding='utf-8') as f:
                json.dump(role_complete, f, indent=2, ensure_ascii=False)
            
            # Actualizar contador de roles
            self.org_structure['gerencias'][info_rol['gerencia_code']]['areas'][info_rol['area_code']]['roles_count'] += 1
            
            return True
            
        except Exception as e:
            print(f"Error creando archivo: {e}")
            return False


def main():
    """Punto de entrada principal - FLUJO DIRECTO."""
    try:
        creator = DynamicRoleCreator()
        # Usar el nuevo flujo con selección de acción
        creator.print_banner()
        
        # Seleccionar acción
        accion = creator.seleccionar_accion()
        
        if accion == "crear":
            # Usar método actualizado para creación
            info_rol = creator.generar_nombre_rol_directo()
            if not info_rol:
                print("Proceso cancelado.")
                return False
            
            # Configuración del rol
            print(f"\nCONFIGURACION DEL ROL")
            print(f"-" * 30)
            
            descripcion = input(f"Descripcion del rol (minimo 10 chars): ").strip()
            while len(descripcion) < 10:
                print("Descripcion muy corta.")
                descripcion = input(f"Descripcion del rol: ").strip()
            
            # Seleccionar políticas
            politicas_seleccionadas = creator.seleccionar_politicas()
            
            # Ambiente
            print(f"\nAMBIENTES DISPONIBLES:")
            ambientes_list = list(creator.ambientes_validos.keys())
            for i, code in enumerate(ambientes_list, 1):
                name = creator.ambientes_validos[code]
                print(f"   {i}) {code} - {name}")
            
            while True:
                try:
                    choice = int(input(f"\nAmbiente [1-{len(ambientes_list)}]: ").strip())
                    if 1 <= choice <= len(ambientes_list):
                        ambiente = ambientes_list[choice - 1]
                        break
                    print(f"Numero invalido.")
                except ValueError:
                    print("Ingresa un numero valido.")
            
            # Mostrar resumen final
            print(f"\nRESUMEN FINAL:")
            print(f"=" * 50)
            print(f"Nombre: {info_rol['nombre_rol']}")
            print(f"Descripcion: {descripcion}")
            print(f"Ambiente: {ambiente}")
            print(f"Gerencia: {info_rol['gerencia_code']} - {info_rol['gerencia_name']}")
            print(f"Area: {info_rol['area_code']} - {info_rol['area_name']}")
            print(f"Aplicacion: {info_rol['aplicacion']}")
            print(f"Pais: {info_rol['pais_code']} - {info_rol['pais_name']}")
            
            # Mostrar políticas seleccionadas
            print(f"\nPOLITICAS ASIGNADAS:")
            if politicas_seleccionadas['aws_managed']:
                print(f"  AWS Managed:")
                for policy in politicas_seleccionadas['aws_managed']:
                    print(f"    - {policy}")
            if politicas_seleccionadas['mci_managed']:
                print(f"  MCI Building Blocks:")
                for policy in politicas_seleccionadas['mci_managed']:
                    print(f"    - {policy}")
            if not politicas_seleccionadas['aws_managed'] and not politicas_seleccionadas['mci_managed']:
                print(f"    - Ninguna (solo assume role)")
            
            print(f"=" * 50)
            
            confirmacion = input(f"\nCrear este rol? [y/N]: ").strip().lower()
            if confirmacion in ['y', 'yes', 'si']:
                # Crear el archivo JSON del rol
                success = creator.crear_archivo_rol(info_rol, descripcion, ambiente, politicas_seleccionadas)
                if success:
                    print(f"\nROL CREADO EXITOSAMENTE!")
                    print(f"Nombre: {info_rol['nombre_rol']}")
                    print(f"Archivo: gerencias/{info_rol['gerencia_code']}/{info_rol['area_code']}/roles/{info_rol['nombre_rol']}.json")
                else:
                    print(f"\nError al crear el archivo del rol.")
                return success
            else:
                print("Proceso cancelado.")
                return False
                
        elif accion == "editar":
            creator.editar_rol_existente()
            
        elif accion == "listar":
            creator.listar_roles_existentes()
            input("\nPresiona Enter para continuar...")
            
        else:
            print("Accion cancelada.")
            
    except KeyboardInterrupt:
        print(f"\n\nProceso interrumpido por el usuario.")
    except Exception as e:
        print(f"\nError: {e}")
        import traceback
        traceback.print_exc()


if __name__ == "__main__":
    main()