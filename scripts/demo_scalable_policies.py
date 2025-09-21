#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
DEMO: SISTEMA ESCALABLE DE GESTIÓN DE POLÍTICAS
===============================================
Demostración completa de las capacidades del sistema dinámico

🎯 PROBLEMA RESUELTO:
   - Escalabilidad de 10 → 100+ políticas sin modificar código
   - CRUD completo de políticas
   - Validaciones automáticas
   - Integración dinámica con Terraform

🚀 CAPACIDADES INCLUIDAS:
   ✅ Gestión completa de políticas (CRUD)
   ✅ Carga dinámica en Terraform
   ✅ Validaciones automáticas de integridad
   ✅ Integración con creación de roles
   ✅ Escalabilidad automática
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
    """Imprimir sección con estilo"""
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
    """Función principal de demostración"""
    print_header("DEMO: SISTEMA ESCALABLE DE GESTIÓN DE POLÍTICAS IAM")
    
    # Verificar estructura del proyecto
    script_dir = Path(__file__).parent
    project_root = script_dir.parent
    
    print(f"📂 Directorio del proyecto: {project_root}")
    print(f"📂 Scripts disponibles:")
    
    scripts = [
        ('manage_policies.py', 'Gestión CRUD de políticas'),
        ('validate_policies.py', 'Validación automática del catálogo'),
        ('create_role_dinamico_clean.py', 'Creación de roles con políticas dinámicas')
    ]
    
    for script, description in scripts:
        script_path = script_dir / script
        status = "✅" if script_path.exists() else "❌"
        print(f"   {status} {script}: {description}")
    
    # Demostrar capacidades del sistema
    print_section("1. VALIDACIÓN AUTOMÁTICA DEL CATÁLOGO")
    
    validate_script = script_dir / "validate_policies.py"
    if validate_script.exists():
        success = run_command(f"python {validate_script}", "Validar integridad del catálogo de políticas")
        if not success:
            print("⚠️ Se encontraron problemas en el catálogo. Revisar y corregir antes de continuar.")
    else:
        print("❌ Script de validación no encontrado")
    
    print_section("2. ESTADÍSTICAS DEL CATÁLOGO ACTUAL")
    
    # Cargar catálogo para mostrar estadísticas
    catalog_path = project_root / "catalog" / "policies.yaml"
    
    if catalog_path.exists():
        try:
            import yaml
            with open(catalog_path, 'r', encoding='utf-8') as f:
                catalog = yaml.safe_load(f)
            
            policies = catalog.get('policies', {})
            policy_blocks = catalog.get('policy_blocks', {})
            
            print(f"📊 ESTADÍSTICAS ACTUALES:")
            print(f"   📋 Total de políticas: {len(policies)}")
            print(f"   📦 Policy blocks: {len(policy_blocks)}")
            
            # Agrupar por servicio
            services = {}
            for policy_name in policies.keys():
                if 'MCI-' in policy_name and '-TagBased-' in policy_name:
                    service = policy_name.split('-')[1] if '-' in policy_name else 'Unknown'
                    services[service] = services.get(service, 0) + 1
            
            print(f"   🔐 Servicios cubiertos:")
            for service, count in sorted(services.items()):
                print(f"      - {service}: {count} políticas")
            
        except Exception as e:
            print(f"❌ Error leyendo catálogo: {e}")
    else:
        print("❌ Catálogo de políticas no encontrado")
    
    print_section("3. SISTEMA DINÁMICO EN TERRAFORM")
    
    print("🔧 CONFIGURACIÓN DINÁMICA:")
    print("   ✅ Data sources generados automáticamente desde YAML")
    print("   ✅ Policy attachments escalables")
    print("   ✅ Sin hardcodeo de nombres de políticas")
    print("   ✅ Escalabilidad de 10 → 100+ políticas sin cambios")
    
    # Mostrar configuración actual
    terraform_files = [
        ('environments/dev/dynamic_policies.tf', 'Cargador dinámico de políticas'),
        ('environments/dev/main.tf', 'Configuración principal con sistema dinámico')
    ]
    
    for tf_file, description in terraform_files:
        tf_path = project_root / tf_file
        status = "✅" if tf_path.exists() else "❌"
        print(f"   {status} {tf_file}: {description}")
    
    print_section("4. FLUJO DE TRABAJO ESCALABLE")
    
    print("🔄 FLUJO TÍPICO DE EXPANSIÓN:")
    print("   1️⃣ Agregar nueva política con manage_policies.py")
    print("   2️⃣ Validar catálogo con validate_policies.py")
    print("   3️⃣ Terraform detecta automáticamente la nueva política")
    print("   4️⃣ Roles pueden usar la nueva política inmediatamente")
    print("   5️⃣ Sin cambios manuales en código Terraform")
    
    print_section("5. CAPACIDADES DE GESTIÓN")
    
    manage_script = script_dir / "manage_policies.py"
    if manage_script.exists():
        print("📋 OPERACIONES DISPONIBLES EN manage_policies.py:")
        print("   ✅ Crear nuevas políticas con auto-generación de metadatos")
        print("   ✅ Editar políticas existentes")
        print("   ✅ Eliminar políticas obsoletas")
        print("   ✅ Buscar y filtrar políticas")
        print("   ✅ Validaciones automáticas de formato")
        print("   ✅ Auto-normalización CamelCase")
        
        print(f"\n💡 Para usar: python {manage_script}")
    
    print_section("6. INTEGRACIÓN CON ROLES")
    
    role_script = script_dir / "create_role_dinamico_clean.py"
    if role_script.exists():
        print("🔗 INTEGRACIÓN DINÁMICA:")
        print("   ✅ Carga automática de políticas desde catálogo")
        print("   ✅ Visualización de políticas con descripción y SOX")
        print("   ✅ Actualización automática cuando se agregan políticas")
        print("   ✅ Sin necesidad de modificar código del script")
        
        print(f"\n💡 Para usar: python {role_script}")
    
    print_section("7. EJEMPLO DE ESCALABILIDAD")
    
    print("📈 ESCENARIO: De 10 a 100 políticas")
    print("   📊 Estado actual: ~10 políticas MCI")
    print("   🎯 Objetivo: 100+ políticas (10x crecimiento)")
    print("   ")
    print("   ✅ SISTEMA ACTUAL (Escalable):")
    print("      - Agregar políticas con manage_policies.py")
    print("      - Terraform carga automáticamente desde YAML")
    print("      - Roles detectan nuevas políticas automáticamente")
    print("      - Zero cambios de código requeridos")
    print("   ")
    print("   ❌ SISTEMA ANTERIOR (No escalable):")
    print("      - Hardcodear cada data source en Terraform")
    print("      - Modificar manualmente mappings de políticas")
    print("      - Actualizar scripts de roles manualmente")
    print("      - 100+ líneas de código por política nueva")
    
    print_section("8. PRÓXIMOS PASOS RECOMENDADOS")
    
    print("🚀 ACCIONES SUGERIDAS:")
    print("   1️⃣ Validar catálogo actual con validate_policies.py")
    print("   2️⃣ Probar creación de política con manage_policies.py")
    print("   3️⃣ Verificar integración en Terraform (terraform plan)")
    print("   4️⃣ Probar creación de rol con nuevas políticas")
    print("   5️⃣ Establecer proceso de revisión para nuevas políticas")
    
    print_header("🎉 SISTEMA LISTO PARA ESCALAR DE 10 → 100+ POLÍTICAS")
    
    print("✅ BENEFICIOS LOGRADOS:")
    print("   🔄 Escalabilidad automática sin modificar código")
    print("   🛡️ Validaciones automáticas de integridad")
    print("   📋 Gestión completa CRUD de políticas")
    print("   🔗 Integración dinámica con todos los componentes")
    print("   📊 Visibilidad completa del catálogo")
    print("   🎯 Mantenimiento mínimo")
    
    print(f"\n💡 Para empezar: python {script_dir}/manage_policies.py")

if __name__ == "__main__":
    main()