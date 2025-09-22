#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
DEMO: SISTEMA ESCALABLE DE GESTIoN DE POLiTICAS
===============================================
Demostracion completa de las capacidades del sistema dinamico

🎯 PROBLEMA RESUELTO:
   - Escalabilidad de 10 → 100+ politicas sin modificar codigo
   - CRUD completo de politicas
   - Validaciones automaticas
   - Integracion dinamica con Terraform

🚀 CAPACIDADES INCLUIDAS:
   ✅ Gestion completa de politicas (CRUD)
   ✅ Carga dinamica en Terraform
   ✅ Validaciones automaticas de integridad
   ✅ Integracion con creacion de roles
   ✅ Escalabilidad automatica
"""

import os
import sys
import subprocess
from pathlib import Path

def print_header(title):
    """Imprimir encabezado con estilo"""
    print("\n" + "="*80)
    print(f"🎯 {title}")
    print("="*80)

def print_section(title):
    """Imprimir seccion con estilo"""
    print(f"\n📋 {title}")
    print("-" * 60)

def run_command(command, description):
    """Ejecutar comando y mostrar resultado"""
    print(f"\n💻 {description}")
    print(f"🔧 Comando: {command}")
    print("-" * 40)
    
    try:
        result = subprocess.run(command, shell=True, capture_output=True, text=True)
        if result.stdout:
            print(result.stdout)
        if result.stderr and result.returncode != 0:
            print(f"⚠️ Error: {result.stderr}")
        return result.returncode == 0
    except Exception as e:
        print(f"❌ Error ejecutando comando: {e}")
        return False

def main():
    """Funcion principal de demostracion"""
    print_header("DEMO: SISTEMA ESCALABLE DE GESTIoN DE POLiTICAS IAM")
    
    # Verificar estructura del proyecto
    script_dir = Path(__file__).parent
    project_root = script_dir.parent
    
    print(f"📂 Directorio del proyecto: {project_root}")
    print(f"📂 Scripts disponibles:")
    
    scripts = [
        ('manage_policies.py', 'Gestion CRUD de politicas'),
        ('validate_policies.py', 'Validacion automatica del catalogo'),
        ('create_role_dinamico_clean.py', 'Creacion de roles con politicas dinamicas')
    ]
    
    for script, description in scripts:
        script_path = script_dir / script
        status = "✅" if script_path.exists() else "❌"
        print(f"   {status} {script}: {description}")
    
    # Demostrar capacidades del sistema
    print_section("1. VALIDACIoN AUTOMaTICA DEL CATaLOGO")
    
    validate_script = script_dir / "validate_policies.py"
    if validate_script.exists():
        success = run_command(f"python {validate_script}", "Validar integridad del catalogo de politicas")
        if not success:
            print("⚠️ Se encontraron problemas en el catalogo. Revisar y corregir antes de continuar.")
    else:
        print("❌ Script de validacion no encontrado")
    
    print_section("2. ESTADiSTICAS DEL CATaLOGO ACTUAL")
    
    # Cargar catalogo para mostrar estadisticas
    catalog_path = project_root / "catalog" / "policies.yaml"
    
    if catalog_path.exists():
        try:
            import yaml
            with open(catalog_path, 'r', encoding='utf-8') as f:
                catalog = yaml.safe_load(f)
            
            policies = catalog.get('policies', {})
            policy_blocks = catalog.get('policy_blocks', {})
            
            print(f"📊 ESTADiSTICAS ACTUALES:")
            print(f"   📋 Total de politicas: {len(policies)}")
            print(f"   📦 Policy blocks: {len(policy_blocks)}")
            
            # Agrupar por servicio
            services = {}
            for policy_name in policies.keys():
                if 'MCI-' in policy_name and '-TagBased-' in policy_name:
                    service = policy_name.split('-')[1] if '-' in policy_name else 'Unknown'
                    services[service] = services.get(service, 0) + 1
            
            print(f"   🔐 Servicios cubiertos:")
            for service, count in sorted(services.items()):
                print(f"      - {service}: {count} politicas")
            
        except Exception as e:
            print(f"❌ Error leyendo catalogo: {e}")
    else:
        print("❌ Catalogo de politicas no encontrado")
    
    print_section("3. SISTEMA DINaMICO EN TERRAFORM")
    
    print("🔧 CONFIGURACIoN DINaMICA:")
    print("   ✅ Data sources generados automaticamente desde YAML")
    print("   ✅ Policy attachments escalables")
    print("   ✅ Sin hardcodeo de nombres de politicas")
    print("   ✅ Escalabilidad de 10 → 100+ politicas sin cambios")
    
    # Mostrar configuracion actual
    terraform_files = [
        ('environments/dev/dynamic_policies.tf', 'Cargador dinamico de politicas'),
        ('environments/dev/main.tf', 'Configuracion principal con sistema dinamico')
    ]
    
    for tf_file, description in terraform_files:
        tf_path = project_root / tf_file
        status = "✅" if tf_path.exists() else "❌"
        print(f"   {status} {tf_file}: {description}")
    
    print_section("4. FLUJO DE TRABAJO ESCALABLE")
    
    print("🔄 FLUJO TiPICO DE EXPANSIoN:")
    print("   1️⃣ Agregar nueva politica con manage_policies.py")
    print("   2️⃣ Validar catalogo con validate_policies.py")
    print("   3️⃣ Terraform detecta automaticamente la nueva politica")
    print("   4️⃣ Roles pueden usar la nueva politica inmediatamente")
    print("   5️⃣ Sin cambios manuales en codigo Terraform")
    
    print_section("5. CAPACIDADES DE GESTIoN")
    
    manage_script = script_dir / "manage_policies.py"
    if manage_script.exists():
        print("📋 OPERACIONES DISPONIBLES EN manage_policies.py:")
        print("   ✅ Crear nuevas politicas con auto-generacion de metadatos")
        print("   ✅ Editar politicas existentes")
        print("   ✅ Eliminar politicas obsoletas")
        print("   ✅ Buscar y filtrar politicas")
        print("   ✅ Validaciones automaticas de formato")
        print("   ✅ Auto-normalizacion CamelCase")
        
        print(f"\n💡 Para usar: python {manage_script}")
    
    print_section("6. INTEGRACIoN CON ROLES")
    
    role_script = script_dir / "create_role_dinamico_clean.py"
    if role_script.exists():
        print("🔗 INTEGRACIoN DINaMICA:")
        print("   ✅ Carga automatica de politicas desde catalogo")
        print("   ✅ Visualizacion de politicas con descripcion y SOX")
        print("   ✅ Actualizacion automatica cuando se agregan politicas")
        print("   ✅ Sin necesidad de modificar codigo del script")
        
        print(f"\n💡 Para usar: python {role_script}")
    
    print_section("7. EJEMPLO DE ESCALABILIDAD")
    
    print("📈 ESCENARIO: De 10 a 100 politicas")
    print("   📊 Estado actual: ~10 politicas MCI")
    print("   🎯 Objetivo: 100+ politicas (10x crecimiento)")
    print("   ")
    print("   ✅ SISTEMA ACTUAL (Escalable):")
    print("      - Agregar politicas con manage_policies.py")
    print("      - Terraform carga automaticamente desde YAML")
    print("      - Roles detectan nuevas politicas automaticamente")
    print("      - Zero cambios de codigo requeridos")
    print("   ")
    print("   ❌ SISTEMA ANTERIOR (No escalable):")
    print("      - Hardcodear cada data source en Terraform")
    print("      - Modificar manualmente mappings de politicas")
    print("      - Actualizar scripts de roles manualmente")
    print("      - 100+ lineas de codigo por politica nueva")
    
    print_section("8. PRoXIMOS PASOS RECOMENDADOS")
    
    print("🚀 ACCIONES SUGERIDAS:")
    print("   1️⃣ Validar catalogo actual con validate_policies.py")
    print("   2️⃣ Probar creacion de politica con manage_policies.py")
    print("   3️⃣ Verificar integracion en Terraform (terraform plan)")
    print("   4️⃣ Probar creacion de rol con nuevas politicas")
    print("   5️⃣ Establecer proceso de revision para nuevas politicas")
    
    print_header("🎉 SISTEMA LISTO PARA ESCALAR DE 10 → 100+ POLiTICAS")
    
    print("✅ BENEFICIOS LOGRADOS:")
    print("   🔄 Escalabilidad automatica sin modificar codigo")
    print("   🛡️ Validaciones automaticas de integridad")
    print("   📋 Gestion completa CRUD de politicas")
    print("   🔗 Integracion dinamica con todos los componentes")
    print("   📊 Visibilidad completa del catalogo")
    print("   🎯 Mantenimiento minimo")
    
    print(f"\n💡 Para empezar: python {script_dir}/manage_policies.py")

if __name__ == "__main__":
    main()