#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Generador de Roles IAM con Estructura Obligatoria
rol-<gerencia>-<area>-<aplicacion>-<pais>
"""

import json
import os
import re
import sys
from pathlib import Path
from datetime import datetime

class GeneradorRolEstructurado:
    """Generador con estructura de nombres obligatoria."""
    
    def __init__(self):
        # Gerencias autorizadas
        self.gerencias = {
            '1': {'code': 'mci', 'name': 'MCI - Mercados y Clientes Individuales'},
            '2': {'code': 'mcm', 'name': 'MCM - Mercados y Clientes Masivos'}, 
            '3': {'code': 'tec', 'name': 'TEC - Tecnologia'},
            '4': {'code': 'ope', 'name': 'OPE - Operaciones'},
            '5': {'code': 'fin', 'name': 'FIN - Finanzas'}
        }
        
        # Areas por gerencia
        self.areas = {
            'mci': {
                '1': {'code': 'bi', 'name': 'Business Intelligence'},
                '2': {'code': 'da', 'name': 'Data Analytics'},
                '3': {'code': 'crm', 'name': 'Customer Relationship Management'},
                '4': {'code': 'prod', 'name': 'Productos'}
            },
            'tec': {
                '1': {'code': 'infra', 'name': 'Infraestructura'},
                '2': {'code': 'dev', 'name': 'Desarrollo'},
                '3': {'code': 'sec', 'name': 'Seguridad'},
                '4': {'code': 'data', 'name': 'Data Engineering'}
            },
            'mcm': {
                '1': {'code': 'market', 'name': 'Marketing'},
                '2': {'code': 'sales', 'name': 'Ventas'},
                '3': {'code': 'support', 'name': 'Soporte'}
            }
        }
        
        # Paises autorizados  
        self.paises = {
            '1': {'code': 'gt', 'name': 'Guatemala'},
            '2': {'code': 'sv', 'name': 'El Salvador'},
            '3': {'code': 'hn', 'name': 'Honduras'},
            '4': {'code': 'ni', 'name': 'Nicaragua'},
            '5': {'code': 'cr', 'name': 'Costa Rica'},
            '6': {'code': 'pa', 'name': 'Panama'}
        }

    def mostrar_banner(self):
        """Mostrar banner del generador."""
        print("=" * 70)
        print("GENERADOR DE ROLES IAM - ESTRUCTURA OBLIGATORIA")
        print("Formato: rol-<gerencia>-<area>-<aplicacion>-<pais>")
        print("=" * 70)
        print()

    def seleccionar_gerencia(self):
        """Seleccionar gerencia."""
        print("1. SELECCIONA GERENCIA:")
        for key, gerencia in self.gerencias.items():
            print(f"   {key}) {gerencia['code'].upper()} - {gerencia['name']}")
        
        while True:
            choice = input("\nGerencia [1-5]: ").strip()
            if choice in self.gerencias:
                selected = self.gerencias[choice]
                print(f"Seleccionado: {selected['code'].upper()}")
                return selected
            print("Opcion invalida. Solo numeros 1-5.")

    def seleccionar_area(self, gerencia_code):
        """Seleccionar area basada en gerencia."""
        print(f"\n2. SELECCIONA AREA PARA {gerencia_code.upper()}:")
        areas_disp = self.areas.get(gerencia_code, {})
        
        if not areas_disp:
            print(f"No hay areas para {gerencia_code}")
            return None
            
        for key, area in areas_disp.items():
            print(f"   {key}) {area['code'].upper()} - {area['name']}")
        
        while True:
            choice = input(f"\nArea [1-{len(areas_disp)}]: ").strip()
            if choice in areas_disp:
                selected = areas_disp[choice]
                print(f"Seleccionado: {selected['code'].upper()}")
                return selected
            print(f"Opcion invalida. Solo numeros 1-{len(areas_disp)}.")

    def solicitar_aplicacion(self):
        """Solicitar nombre de aplicacion con validacion."""
        print(f"\n3. NOMBRE DE APLICACION:")
        print("Reglas:")
        print("   • Solo letras minusculas y guiones")
        print("   • Entre 3-20 caracteres")
        print("   • Ejemplos: s3-manager, data-processor, web-api")
        
        while True:
            app = input("\nAplicacion: ").strip().lower()
            
            if not re.match(r'^[a-z][a-z0-9-]*[a-z0-9]$', app):
                print("Formato invalido. Solo letras, numeros y guiones.")
                continue
                
            if len(app) < 3 or len(app) > 20:
                print("Longitud invalida. Entre 3-20 caracteres.")
                continue
                
            print(f"Aplicacion: {app}")
            return app

    def seleccionar_pais(self):
        """Seleccionar pais."""
        print("\n4. SELECCIONA PAIS:")
        for key, pais in self.paises.items():
            print(f"   {key}) {pais['code'].upper()} - {pais['name']}")
        
        while True:
            choice = input("\nPais [1-6]: ").strip()
            if choice in self.paises:
                selected = self.paises[choice]
                print(f"Seleccionado: {selected['code'].upper()}")
                return selected
            print("Opcion invalida. Solo numeros 1-6.")

    def generar_nombre_rol(self):
        """Generar nombre de rol con estructura obligatoria."""
        print("ESTRUCTURA OBLIGATORIA DEL ROL")
        print("Formato: rol-<gerencia>-<area>-<aplicacion>-<pais>")
        print("-" * 60)
        
        # Selecciones
        gerencia = self.seleccionar_gerencia()
        area = self.seleccionar_area(gerencia['code'])
        if not area:
            return None
        aplicacion = self.solicitar_aplicacion()
        pais = self.seleccionar_pais()
        
        # Generar nombre
        nombre_rol = f"rol-{gerencia['code']}-{area['code']}-{aplicacion}-{pais['code']}"
        
        print(f"\nNOMBRE GENERADO:")
        print(f"Rol: {nombre_rol}")
        print(f"Gerencia: {gerencia['name']}")
        print(f"Area: {area['name']}")
        print(f"Aplicacion: {aplicacion}")
        print(f"Pais: {pais['name']}")
        
        confirm = input(f"\nConfirmar '{nombre_rol}'? [y/N]: ").strip().lower()
        if confirm not in ['y', 'yes', 'si']:
            print("Cancelado")
            return None
            
        return {
            'nombre': nombre_rol,
            'gerencia': gerencia,
            'area': area,
            'aplicacion': aplicacion,
            'pais': pais
        }

    def solicitar_descripcion(self):
        """Solicitar descripcion del rol."""
        print(f"\n5. DESCRIPCION DEL ROL:")
        while True:
            desc = input("Describe la funcion del rol: ").strip()
            if len(desc) >= 10:
                return desc
            print("Descripcion muy corta. Minimo 10 caracteres.")

    def seleccionar_servicio(self):
        """Seleccionar servicio que usara el rol."""
        servicios = {
            '1': 'lambda',
            '2': 'ec2', 
            '3': 'ecs',
            '4': 'github-actions'
        }
        
        print(f"\n6. SERVICIO QUE USARA EL ROL:")
        print("   1) AWS Lambda")
        print("   2) Amazon EC2")
        print("   3) Amazon ECS") 
        print("   4) GitHub Actions")
        
        while True:
            choice = input("\nServicio [1-4]: ").strip()
            if choice in servicios:
                service = servicios[choice]
                print(f"Seleccionado: {service}")
                return service
            print("Opcion invalida. Solo numeros 1-4.")

    def seleccionar_permisos_s3(self):
        """Configurar permisos S3 especificos."""
        print(f"\n7. CONFIGURACION S3:")
        print("Para tu caso: s3://s3-data-analytics-raw-dev-tfstate/iam/dev/")
        
        bucket = input("Bucket S3: ").strip() or "s3-data-analytics-raw-dev-tfstate"
        path = input("Ruta [iam/dev/]: ").strip() or "iam/dev/"
        
        permisos = {
            '1': 'read',
            '2': 'write',
            '3': 'read-write'
        }
        
        print("\nPermisos:")
        print("   1) Solo lectura")
        print("   2) Solo escritura") 
        print("   3) Lectura y escritura")
        
        while True:
            choice = input("\nPermisos [1-3]: ").strip()
            if choice in permisos:
                perm = permisos[choice]
                print(f"Seleccionado: {perm}")
                return {
                    'bucket': bucket,
                    'path': path,
                    'permisos': perm
                }
            print("Opcion invalida. Solo numeros 1-3.")

    def crear_rol_catalog(self, info_rol, descripcion, servicio, s3_config):
        """Crear entrada en catalog/roles.yaml."""
        try:
            import yaml
        except ImportError:
            print("Error: PyYAML no instalado. Ejecuta: pip install PyYAML")
            return False

        catalog_dir = Path('catalog')
        catalog_dir.mkdir(exist_ok=True)
        catalog_file = catalog_dir / 'roles.yaml'
        
        # Leer catalog existente
        if catalog_file.exists():
            with open(catalog_file, 'r', encoding='utf-8') as f:
                catalog = yaml.safe_load(f) or {}
        else:
            catalog = {}
        
        if 'roles' not in catalog:
            catalog['roles'] = {}
        
        # Crear definicion del rol
        timestamp = datetime.now().isoformat() + "Z"
        
        rol_def = {
            'description': descripcion,
            'trust_policy': f'{servicio}_service',
            'permission_boundary': 'app_standard',
            'policies': {
                'aws_managed': [],
                'policy_blocks': [
                    {'type': 's3_path_based_read_write',
                     'bucket_arn': f'arn:aws:s3:::{s3_config["bucket"]}',
                     'path_prefix': s3_config['path']}
                ]
            },
            'canonical_tags': {
                'Ambiente': 'Dev',
                'Pais': info_rol['pais']['code'].upper(),
                'Direccion': 'Tecnologia',
                'Gerencia': info_rol['gerencia']['code'].upper(),
                'Cuenta': '393209814297',
                'Modulo': info_rol['area']['name'],
                'Alcance SOX': 'No',
                'Propietario': f"{info_rol['area']['code'].upper()}-Team",
                'Proveedor': 'Claro',
                'Layer': 'Application',
                'Dominio': info_rol['gerencia']['name'],
                'Subdominio': info_rol['area']['name'],
                'Aplicacion': info_rol['aplicacion'],
                'Name': info_rol['nombre'],
                'Soporte': f"{info_rol['area']['code'].upper()}-Team",
                'Contacto': f"{info_rol['area']['code']}-team@claro.com",
                'Proyecto': info_rol['aplicacion'].title(),
                'Fechas de Creacion': timestamp,
                'Creado Por': 'terraform-iac',
                'Tipo de Recurso': 'IAM-Role',
                'Ciclo de Vida': 'Active',
                'Version': '1.0',
                'Map-migrated': f"mig_{info_rol['aplicacion'].replace('-', '_')}_001"
            }
        }
        
        # Agregar al catalog
        catalog['roles'][info_rol['nombre']] = rol_def
        
        # Escribir archivo
        with open(catalog_file, 'w', encoding='utf-8') as f:
            yaml.dump(catalog, f, default_flow_style=False, allow_unicode=True, indent=2)
        
        print(f"\nROL CREADO EXITOSAMENTE!")
        print(f"Archivo: {catalog_file}")
        print(f"Nombre: {info_rol['nombre']}")
        print(f"\nProximos pasos:")
        print(f"1. cd environments/dev")
        print(f"2. terraform plan")
        print(f"3. terraform apply")
        
        return True

    def ejecutar(self):
        """Ejecutar el generador."""
        try:
            self.mostrar_banner()
            
            # Verificar directorio
            if not Path('catalog').exists() and not Path('.').resolve().name == 'mci-aws-iam':
                print("Error: Ejecuta desde la raiz del repo mci-aws-iam")
                return
            
            # Generar nombre estructurado
            info_rol = self.generar_nombre_rol()
            if not info_rol:
                return
            
            # Recopilar informacion
            descripcion = self.solicitar_descripcion()
            servicio = self.seleccionar_servicio()
            s3_config = self.seleccionar_permisos_s3()
            
            # Mostrar resumen
            print(f"\nRESUMEN:")
            print(f"Rol: {info_rol['nombre']}")
            print(f"Descripcion: {descripcion}")
            print(f"Servicio: {servicio}")
            print(f"S3 Bucket: {s3_config['bucket']}")
            print(f"S3 Path: {s3_config['path']}")
            print(f"Permisos: {s3_config['permisos']}")
            
            confirm = input(f"\nCrear rol? [y/N]: ").strip().lower()
            if confirm not in ['y', 'yes', 'si']:
                print("Cancelado")
                return
            
            # Crear rol
            self.crear_rol_catalog(info_rol, descripcion, servicio, s3_config)
            
        except KeyboardInterrupt:
            print("\n\nCancelado por usuario")
        except Exception as e:
            print(f"\nError: {e}")

def main():
    generador = GeneradorRolEstructurado()
    generador.ejecutar()

if __name__ == "__main__":
    main()