#!/usr/bin/env python3
"""
Script para editar roles IAM existentes
Uso: python scripts/edit_role.py
"""

import json
import os
import sys
from pathlib import Path

def find_roles():
    """Buscar todos los archivos de roles en el repositorio"""
    roles = []
    root = Path(".")
    
    for json_file in root.rglob("*.json"):
        if "rol-" in json_file.name:
            roles.append(json_file)
    
    return sorted(roles)

def display_roles(roles):
    """Mostrar lista de roles disponibles"""
    print("\n🎯 Roles disponibles para editar:\n")
    for i, role in enumerate(roles, 1):
        print(f"{i:2d}. {role}")
    print()

def load_role(file_path):
    """Cargar contenido del rol"""
    try:
        with open(file_path, 'r', encoding='utf-8') as f:
            return json.load(f)
    except Exception as e:
        print(f"❌ Error cargando rol: {e}")
        return None

def save_role(file_path, role_data):
    """Guardar rol modificado"""
    try:
        with open(file_path, 'w', encoding='utf-8') as f:
            json.dump(role_data, f, indent=2, ensure_ascii=False)
        print(f"✅ Rol guardado: {file_path}")
        return True
    except Exception as e:
        print(f"❌ Error guardando rol: {e}")
        return False

def edit_role_interactively(role_data):
    """Editor interactivo de rol"""
    while True:
        print("\n🔧 ¿Qué deseas modificar?")
        print("1. Nombre del rol")
        print("2. Descripción") 
        print("3. Políticas AWS managed")
        print("4. Políticas custom (MCI-*)")
        print("5. Tags")
        print("6. Trust policy")
        print("7. Mostrar rol completo")
        print("8. Guardar y salir")
        print("9. Salir sin guardar")
        
        choice = input("\nSelecciona opción (1-9): ").strip()
        
        if choice == "1":
            current = role_data.get("role_name", "")
            print(f"Nombre actual: {current}")
            new_name = input("Nuevo nombre (Enter para mantener): ").strip()
            if new_name:
                role_data["role_name"] = new_name
                
        elif choice == "2":
            current = role_data.get("description", "")
            print(f"Descripción actual: {current}")
            new_desc = input("Nueva descripción (Enter para mantener): ").strip()
            if new_desc:
                role_data["description"] = new_desc
                
        elif choice == "3":
            current = role_data.get("policies", {}).get("aws_managed", [])
            print(f"Políticas AWS managed actuales: {current}")
            print("Ingresa políticas separadas por comas (Enter para mantener):")
            new_policies = input().strip()
            if new_policies:
                policies_list = [p.strip() for p in new_policies.split(",") if p.strip()]
                role_data.setdefault("policies", {})["aws_managed"] = policies_list
                
        elif choice == "4":
            current = role_data.get("policies", {}).get("custom", [])
            print(f"Políticas custom actuales: {current}")
            print("Políticas MCI-* disponibles:")
            print("- MCI-S3-ReadOnly, MCI-S3-Write")
            print("- MCI-DynamoDB-ReadOnly, MCI-DynamoDB-Write") 
            print("- MCI-Lambda-Invoke, MCI-SQS-Consume, MCI-SQS-Produce, MCI-CloudWatch-Logs")
            print("Ingresa políticas separadas por comas (Enter para mantener):")
            new_policies = input().strip()
            if new_policies:
                policies_list = [p.strip() for p in new_policies.split(",") if p.strip()]
                role_data.setdefault("policies", {})["custom"] = policies_list
                
        elif choice == "5":
            print("Tags actuales:")
            current_tags = role_data.get("tags", {})
            for k, v in current_tags.items():
                print(f"  {k}: {v}")
            print("\nIngresa tag en formato 'clave=valor' (Enter para terminar):")
            while True:
                tag_input = input("Tag: ").strip()
                if not tag_input:
                    break
                if "=" in tag_input:
                    key, value = tag_input.split("=", 1)
                    role_data.setdefault("tags", {})[key.strip()] = value.strip()
                    
        elif choice == "7":
            print("\n📄 Rol completo:")
            print(json.dumps(role_data, indent=2, ensure_ascii=False))
            
        elif choice == "8":
            return role_data
            
        elif choice == "9":
            return None
            
        else:
            print("❌ Opción inválida")

def main():
    print("🔧 Editor de Roles IAM")
    print("=" * 50)
    
    # Buscar roles
    roles = find_roles()
    if not roles:
        print("❌ No se encontraron roles en el repositorio")
        return
    
    # Mostrar roles
    display_roles(roles)
    
    # Seleccionar rol
    try:
        choice = int(input("Selecciona el número del rol a editar: ")) - 1
        if 0 <= choice < len(roles):
            selected_role = roles[choice]
        else:
            print("❌ Número inválido")
            return
    except ValueError:
        print("❌ Debe ser un número")
        return
    
    # Cargar rol
    print(f"\n📖 Cargando: {selected_role}")
    role_data = load_role(selected_role)
    if not role_data:
        return
    
    # Editar rol
    modified_role = edit_role_interactively(role_data)
    if modified_role:
        if save_role(selected_role, modified_role):
            print("\n🎉 Rol modificado exitosamente!")
            print("📋 Próximos pasos:")
            print("  git add .")
            print("  git commit -m 'feat: Modificar rol existente'")
            print("  git push origin tu-rama")
    else:
        print("❌ Modificación cancelada")

if __name__ == "__main__":
    main()
