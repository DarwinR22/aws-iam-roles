#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Generador Enterprise de Roles IAM - MCI
Estructura Dinamica Basada en tu Organizacion Real
"""

import json
import os
import re
import sys
from pathlib import Path
from datetime import datetime

class IAMRoleGeneratorDinamico:
    """Generador que aprende tu estructura organizacional dinamicamente."""
    
    def __init__(self):
        self.catalog_path = Path('catalog')
        self.gerencias_path = Path('gerencias')  # Carpetas fisicas
        self.config_path = Path('catalog/org_structure.json')
        
        # Crear directorios necesarios
        self.catalog_path.mkdir(exist_ok=True)
        self.gerencias_path.mkdir(exist_ok=True)
        
        # Cargar estructura organizacional existente
        self.org_structure = self.cargar_estructura_org()
        
        # Sincronizar con carpetas fisicas existentes
        self.sincronizar_con_filesystem()
        
        # Paises fijos (estos si los sabemos)
        self.paises_validos = {
            'GT': 'Guatemala',
            'SV': 'El Salvador', 
            'HN': 'Honduras',
            'NI': 'Nicaragua',
            'CR': 'Costa Rica',
            'PA': 'Panama'
        }
        
        # Ambientes fijos
        self.ambientes_validos = {
            'dev': 'Desarrollo',
            'qa': 'Quality Assurance',
            'prod': 'Produccion'
        }

    def cargar_estructura_org(self):
        """Carga la estructura organizacional existente o inicializa vacia."""
        if self.config_path.exists():
            try:
                with open(self.config_path, 'r', encoding='utf-8') as f:
                    return json.load(f)
            except Exception as e:
                print(f"Error cargando estructura: {e}")
        
        # Estructura inicial vacia
        return {
            'gerencias': {},
            'version': '1.0',
            'ultima_actualizacion': datetime.now().isoformat()
        }

    def sincronizar_con_filesystem(self):
        """Sincroniza la estructura organizacional con las carpetas fisicas existentes."""
        print("Sincronizando con carpetas existentes...")
        
        # Detectar gerencias fisicas existentes
        if self.gerencias_path.exists():
            for gerencia_dir in self.gerencias_path.iterdir():
                if gerencia_dir.is_dir():
                    gerencia_code = gerencia_dir.name.upper()
                    
                    # Si no existe en estructura, agregarla
                    if gerencia_code not in self.org_structure['gerencias']:
                        self.org_structure['gerencias'][gerencia_code] = {
                            'name': f'{gerencia_code} - Detectada desde filesystem',
                            'areas': {},
                            'creado': datetime.now().isoformat(),
                            'origen': 'filesystem'
                        }
                        print(f"  • Detectada gerencia: {gerencia_code}")
                    
                    # Detectar areas dentro de la gerencia
                    for area_dir in gerencia_dir.iterdir():
                        if area_dir.is_dir():
                            area_code = area_dir.name.upper()
                            
                            # Si no existe en estructura, agregarla
                            if area_code not in self.org_structure['gerencias'][gerencia_code]['areas']:
                                self.org_structure['gerencias'][gerencia_code]['areas'][area_code] = f'{area_code} - Detectada desde filesystem'
                                print(f"    • Detectada area: {area_code}")
        
        # Guardar cambios
        self.guardar_estructura_org()

    def crear_carpetas_fisicas(self, gerencia_code, area_code=None):
        """Crea las carpetas fisicas para gerencia y/o area."""
        gerencia_path = self.gerencias_path / gerencia_code
        
        # Crear carpeta de gerencia
        gerencia_path.mkdir(exist_ok=True)
        print(f"Carpeta creada: {gerencia_path}")
        
        if area_code:
            # Crear carpeta de area
            area_path = gerencia_path / area_code
            area_path.mkdir(exist_ok=True)
            print(f"Carpeta creada: {area_path}")
            
            # Crear subcarpeta roles si no existe
            roles_path = area_path / "roles"
            roles_path.mkdir(exist_ok=True)
            print(f"Carpeta creada: {roles_path}")
            
            return area_path
        
        return gerencia_path

    def print_banner(self):
        """Banner del generador dinamico."""
        print("=" * 70)
        print("GENERADOR ENTERPRISE DE ROLES IAM - MCI")
        print("Estructura Dinamica - Aprende tu Organizacion")
        print("FORMATO: rol-<gerencia>-<area>-<aplicacion>-<pais>")
        print("=" * 70)
        print()

    def guardar_estructura_org(self):
        """Guarda la estructura organizacional actual."""
        self.org_structure['ultima_actualizacion'] = datetime.now().isoformat()
        try:
            with open(self.config_path, 'w', encoding='utf-8') as f:
                json.dump(self.org_structure, f, indent=2, ensure_ascii=False)
            return True
        except Exception as e:
            print(f"Error guardando estructura: {e}")
            return False

    def mostrar_estructura_actual(self):
        """Muestra la estructura organizacional actual."""
        if not self.org_structure['gerencias']:
            print("No hay estructura organizacional configurada.")
            print("Las carpetas fisicas existentes se detectaran automaticamente.")
            return
        
        print("\nESTRUCTURA ORGANIZACIONAL ACTUAL:")
        print("-" * 40)
        for gerencia_code, gerencia_data in self.org_structure['gerencias'].items():
            origen = " (detectada)" if gerencia_data.get('origen') == 'filesystem' else ""
            print(f"\nGerencia: {gerencia_code} - {gerencia_data['name']}{origen}")
            
            if gerencia_data['areas']:
                for area_code, area_name in gerencia_data['areas'].items():
                    area_origen = " (detectada)" if "filesystem" in area_name else ""
                    print(f"  • {area_code} - {area_name}{area_origen}")
            else:
                print("  (Sin areas configuradas)")
                
        print(f"\nCarpetas fisicas en: {self.gerencias_path}")

    def agregar_gerencia(self):
        """Agrega una nueva gerencia."""
        print(f"\nAGREGAR NUEVA GERENCIA")
        print(f"-" * 30)
        
        while True:
            codigo = input("Codigo de gerencia (ej: MCI, TEC, FIN): ").strip().upper()
            if re.match(r'^[A-Z]{2,5}$', codigo):
                break
            print("Codigo invalido. Solo 2-5 letras mayusculas.")
        
        nombre = input("Nombre completo de la gerencia: ").strip()
        
        if codigo in self.org_structure['gerencias']:
            print(f"La gerencia {codigo} ya existe.")
            return
        
        # Agregar a estructura
        self.org_structure['gerencias'][codigo] = {
            'name': nombre,
            'areas': {},
            'creado': datetime.now().isoformat(),
            'origen': 'manual'
        }
        
        # Crear carpeta fisica
        self.crear_carpetas_fisicas(codigo)
        
        print(f"Gerencia {codigo} - {nombre} agregada!")
        self.guardar_estructura_org()

    def agregar_area(self):
        """Agrega un area a una gerencia existente."""
        if not self.org_structure['gerencias']:
            print("No hay gerencias configuradas. Agrega una gerencia primero.")
            return
        
        print(f"\nAGREGAR AREA A GERENCIA")
        print(f"-" * 30)
        
        # Mostrar gerencias disponibles
        print("Gerencias disponibles:")
        for codigo, data in self.org_structure['gerencias'].items():
            print(f"  • {codigo} - {data['name']}")
        
        while True:
            gerencia = input("Codigo de gerencia: ").strip().upper()
            if gerencia in self.org_structure['gerencias']:
                break
            print("Gerencia no encontrada.")
        
        while True:
            area_codigo = input("Codigo de area (ej: BI, DA, SEC): ").strip().upper()
            if re.match(r'^[A-Z]{2,8}$', area_codigo):
                break
            print("Codigo invalido. Solo 2-8 letras mayusculas.")
        
        area_nombre = input("Nombre completo del area: ").strip()
        
        if area_codigo in self.org_structure['gerencias'][gerencia]['areas']:
            print(f"El area {area_codigo} ya existe en {gerencia}.")
            return
        
        # Agregar a estructura
        self.org_structure['gerencias'][gerencia]['areas'][area_codigo] = area_nombre
        
        # Crear carpeta fisica
        self.crear_carpetas_fisicas(gerencia, area_codigo)
        
        print(f"Area {area_codigo} - {area_nombre} agregada a {gerencia}!")
        self.guardar_estructura_org()

    def seleccionar_o_crear_gerencia(self):
        """Selecciona gerencia existente o crea una nueva."""
        gerencias = list(self.org_structure['gerencias'].keys())
        
        print(f"\nSELECCIONA O CREA GERENCIA:")
        
        # Mostrar gerencias existentes
        if gerencias:
            print(f"Gerencias existentes:")
            for i, codigo in enumerate(gerencias, 1):
                nombre = self.org_structure['gerencias'][codigo]['name']
                print(f"   {i}) {codigo} - {nombre}")
            print(f"   {len(gerencias) + 1}) Crear nueva gerencia")
        else:
            print(f"No hay gerencias configuradas.")
            print(f"   1) Crear nueva gerencia")
        
        while True:
            if gerencias:
                try:
                    choice = int(input(f"\nOpcion [1-{len(gerencias) + 1}]: ").strip())
                    if 1 <= choice <= len(gerencias):
                        # Seleccionar gerencia existente
                        gerencia_code = gerencias[choice - 1]
                        gerencia_data = self.org_structure['gerencias'][gerencia_code]
                        print(f"Seleccionado: {gerencia_code} - {gerencia_data['name']}")
                        return gerencia_code, gerencia_data
                    elif choice == len(gerencias) + 1:
                        # Crear nueva gerencia
                        return self.crear_nueva_gerencia()
                    else:
                        print(f"Numero invalido.")
                except ValueError:
                    print("Ingresa un numero valido.")
            else:
                # Solo opcion crear nueva
                choice = input(f"\nOpcion [1]: ").strip()
                if choice == "1":
                    return self.crear_nueva_gerencia()
                else:
                    print("Solo hay opcion 1.")

    def crear_nueva_gerencia(self):
        """Crea una nueva gerencia interactivamente."""
        print(f"\nCREAR NUEVA GERENCIA:")
        
        while True:
            codigo = input("Codigo de gerencia (ej: MCI, TEC, FIN): ").strip().upper()
            if re.match(r'^[A-Z]{2,5}$', codigo):
                if codigo not in self.org_structure['gerencias']:
                    break
                else:
                    print(f"La gerencia {codigo} ya existe.")
            else:
                print("Codigo invalido. Solo 2-5 letras mayusculas.")
        
        nombre = input("Nombre completo de la gerencia: ").strip()
        
        # Agregar a estructura
        gerencia_data = {
            'name': nombre,
            'areas': {},
            'creado': datetime.now().isoformat(),
            'origen': 'manual'
        }
        self.org_structure['gerencias'][codigo] = gerencia_data
        
        # Crear carpeta fisica
        self.crear_carpetas_fisicas(codigo)
        
        print(f"Gerencia {codigo} - {nombre} creada!")
        self.guardar_estructura_org()
        
        return codigo, gerencia_data

    def seleccionar_o_crear_area(self, gerencia_code):
        """Selecciona area existente o crea una nueva para la gerencia."""
        gerencia_data = self.org_structure['gerencias'][gerencia_code]
        areas = gerencia_data['areas']
        area_codes = list(areas.keys())
        
        print(f"\nSELECCIONA O CREA AREA PARA {gerencia_code}:")
        
        # Mostrar areas existentes
        if area_codes:
            print(f"Areas existentes en {gerencia_code}:")
            for i, codigo in enumerate(area_codes, 1):
                nombre = areas[codigo]
                print(f"   {i}) {codigo} - {nombre}")
            print(f"   {len(area_codes) + 1}) Crear nueva area")
        else:
            print(f"No hay areas en {gerencia_code}.")
            print(f"   1) Crear nueva area")
        
        while True:
            if area_codes:
                try:
                    choice = int(input(f"\nOpcion [1-{len(area_codes) + 1}]: ").strip())
                    if 1 <= choice <= len(area_codes):
                        # Seleccionar area existente
                        area_code = area_codes[choice - 1]
                        area_name = areas[area_code]
                        print(f"Seleccionado: {area_code} - {area_name}")
                        return area_code, area_name
                    elif choice == len(area_codes) + 1:
                        # Crear nueva area
                        return self.crear_nueva_area(gerencia_code)
                    else:
                        print(f"Numero invalido.")
                except ValueError:
                    print("Ingresa un numero valido.")
            else:
                # Solo opcion crear nueva
                choice = input(f"\nOpcion [1]: ").strip()
                if choice == "1":
                    return self.crear_nueva_area(gerencia_code)
                else:
                    print("Solo hay opcion 1.")

    def crear_nueva_area(self, gerencia_code):
        """Crea una nueva area para la gerencia."""
        print(f"\nCREAR NUEVA AREA PARA {gerencia_code}:")
        
        while True:
            area_codigo = input("Codigo de area (ej: BI, DA, SEC): ").strip().upper()
            if re.match(r'^[A-Z]{2,8}$', area_codigo):
                if area_codigo not in self.org_structure['gerencias'][gerencia_code]['areas']:
                    break
                else:
                    print(f"El area {area_codigo} ya existe en {gerencia_code}.")
            else:
                print("Codigo invalido. Solo 2-8 letras mayusculas.")
        
        area_nombre = input("Nombre completo del area: ").strip()
        
        # Agregar a estructura
        self.org_structure['gerencias'][gerencia_code]['areas'][area_codigo] = area_nombre
        
        # Crear carpeta fisica
        self.crear_carpetas_fisicas(gerencia_code, area_codigo)
        
        print(f"Area {area_codigo} - {area_nombre} creada!")
        self.guardar_estructura_org()
        
        return area_codigo, area_nombre

    def seleccionar_gerencia_y_area(self):
        """Selecciona gerencia y area de la estructura configurada."""
        gerencias = list(self.org_structure['gerencias'].keys())
        
        print(f"\nSELECCIONA GERENCIA:")
        for i, codigo in enumerate(gerencias, 1):
            nombre = self.org_structure['gerencias'][codigo]['name']
            print(f"   {i}) {codigo} - {nombre}")
        
        while True:
            try:
                choice = int(input(f"\nGerencia [1-{len(gerencias)}]: ").strip())
                if 1 <= choice <= len(gerencias):
                    gerencia_code = gerencias[choice - 1]
                    gerencia_name = self.org_structure['gerencias'][gerencia_code]['name']
                    break
                print(f"Numero invalido. Entre 1 y {len(gerencias)}.")
            except ValueError:
                print("Ingresa un numero valido.")
        
        # Seleccionar area
        areas = self.org_structure['gerencias'][gerencia_code]['areas']
        if not areas:
            print(f"La gerencia {gerencia_code} no tiene areas configuradas.")
            print("Regresa al menu para agregar areas.")
            return None
        
        area_codes = list(areas.keys())
        print(f"\nSELECCIONA AREA PARA {gerencia_code}:")
        for i, codigo in enumerate(area_codes, 1):
            nombre = areas[codigo]
            print(f"   {i}) {codigo} - {nombre}")
        
        while True:
            try:
                choice = int(input(f"\nArea [1-{len(area_codes)}]: ").strip())
                if 1 <= choice <= len(area_codes):
                    area_code = area_codes[choice - 1]
                    area_name = areas[area_code]
                    break
                print(f"Numero invalido. Entre 1 y {len(area_codes)}.")
            except ValueError:
                print("Ingresa un numero valido.")
        
        return {
            'gerencia_code': gerencia_code,
            'gerencia_name': gerencia_name,
            'area_code': area_code,
            'area_name': area_name
        }

    def generar_nombre_rol_directo(self):
        """Genera el nombre del rol con flujo directo y logico."""
        print(f"\nGENERAR ROL - ESTRUCTURA ORGANIZACIONAL")
        print(f"Formato: rol-<gerencia>-<area>-<aplicacion>-<pais>")
        print(f"=" * 50)
        
        # 1. Seleccionar o crear gerencia
        gerencia_code, gerencia_data = self.seleccionar_o_crear_gerencia()
        
        # 2. Seleccionar o crear area
        area_code, area_name = self.seleccionar_o_crear_area(gerencia_code)
        
        # 3. Aplicacion
        print(f"\nNOMBRE DE APLICACION:")
        print(f"Reglas: solo letras minusculas, numeros y guiones (3-20 chars)")
        print(f"Ejemplos: s3-manager, bi-processor, web-api")
        
        while True:
            aplicacion = input(f"\nAplicacion: ").strip().lower()
            if re.match(r'^[a-z][a-z0-9-]*[a-z0-9]$', aplicacion) and 3 <= len(aplicacion) <= 20:
                break
            print("Formato invalido. Revisa las reglas.")
        
        # 4. Pais
        paises_list = list(self.paises_validos.keys())
        print(f"\nSELECCIONA PAIS:")
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
        
        print(f"\nNOMBRE GENERADO:")
        print(f"=" * 40)
        print(f"Rol: {nombre_rol}")
        print(f"Gerencia: {gerencia_code} - {gerencia_data['name']}")
        print(f"Area: {area_code} - {area_name}")
        print(f"Aplicacion: {aplicacion}")
        print(f"Pais: {pais_code} - {self.paises_validos[pais_code]}")
        print(f"=" * 40)
        
        confirmacion = input(f"\nConfirmar estructura? [y/N]: ").strip().lower()
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

    def crear_rol_completo(self):
        """Flujo completo de creacion de rol - DIRECTO Y LOGICO."""
        self.print_banner()
        
        # 1. Generar estructura organizacional y nombre
        info_rol = self.generar_nombre_rol_directo()
        if not info_rol:
            print("Proceso cancelado.")
            return False
        
        # 2. Configuracion del rol
        print(f"\nCONFIGURACION DEL ROL")
        print(f"-" * 30)
        
        descripcion = input(f"Descripcion del rol (minimo 10 chars): ").strip()
        while len(descripcion) < 10:
            print("Descripcion muy corta.")
            descripcion = input(f"Descripcion del rol: ").strip()
        
        # 3. Ambiente (por ahora simple)
        print(f"\nAmbientes disponibles:")
        ambientes_list = list(self.ambientes_validos.keys())
        for i, code in enumerate(ambientes_list, 1):
            name = self.ambientes_validos[code]
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
        
        # 4. Mostrar resumen final
        print(f"\nRESUMEN FINAL:")
        print(f"=" * 50)
        print(f"Nombre: {info_rol['nombre_rol']}")
        print(f"Descripcion: {descripcion}")
        print(f"Ambiente: {ambiente}")
        print(f"Gerencia: {info_rol['gerencia_code']} - {info_rol['gerencia_name']}")
        print(f"Area: {info_rol['area_code']} - {info_rol['area_name']}")
        print(f"Aplicacion: {info_rol['aplicacion']}")
        print(f"Pais: {info_rol['pais_code']} - {info_rol['pais_name']}")
        print(f"=" * 50)
        
        confirmacion = input(f"\nCrear este rol? [y/N]: ").strip().lower()
        if confirmacion in ['y', 'yes', 'si']:
            print(f"\nROL CREADO: {info_rol['nombre_rol']}")
            print(f"Carpeta: gerencias/{info_rol['gerencia_code']}/{info_rol['area_code']}/roles/")
            print(f"(Integracion con catalog/roles.yaml pendiente)")
            return True
        else:
            print("Proceso cancelado.")
            return False

def main():
    """Punto de entrada principal."""
    generator = IAMRoleGeneratorDinamico()
    
    try:
        success = generator.crear_rol_completo()
        if success:
            print(f"\nExitoso!")
        else:
            print(f"\nCancelado")
    except KeyboardInterrupt:
        print(f"\n\nCancelado por usuario")
    except Exception as e:
        print(f"\nError: {e}")

if __name__ == "__main__":
    main()