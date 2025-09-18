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

def organize_roles_by_folder(roles):
    """Organizar roles por estructura de carpetas"""
    folders = {}
    
    for role in roles:
        parts = role.parts
        if len(parts) >= 2:
            # Ejemplo: gerencias/MCI/BI/roles/rol-xxx.json
            folder_path = "/".join(parts[:-1])  # gerencias/MCI/BI/roles
            area = parts[2] if len(parts) > 2 else "Other"  # BI, IT, etc.
            
            if area not in folders:
                folders[area] = []
            folders[area].append(role)
    
    return folders

def display_folder_navigation(folders):
    """Mostrar navegación por carpetas"""
    print(f"\n📁 Navegación por áreas:\n")
    
    areas = list(folders.keys())
    for i, area in enumerate(areas, 1):
        role_count = len(folders[area])
        print(f"{i:2d}. 📁 {area}/ ({role_count} roles)")
    
    print(f"\n{len(areas)+1:2d}. 🔍 Búsqueda libre")
    print(f"{len(areas)+2:2d}. 📋 Ver todos los roles")
    
    return areas

def display_roles_in_area(area, roles):
    """Mostrar roles de un área específica"""
    print(f"\n📁 Roles en {area}:\n")
    
    for i, role in enumerate(roles, 1):
        # Extraer solo el nombre del archivo
        role_name = role.name
        # Extraer ambiente del path si existe
        path_str = str(role)
        if "dev" in path_str:
            env = "🟢 dev"
        elif "qa" in path_str:
            env = "🟡 qa"  
        elif "prod" in path_str:
            env = "🔴 prod"
        else:
            env = "⚪ -"
            
        print(f"{i:2d}. {env} {role_name}")
    
    return roles

def display_roles(roles):
    """Mostrar lista de roles disponibles con navegación mejorada"""
    
    if len(roles) <= 5:
        # Pocos roles - mostrar directamente
        print(f"\n🎯 Roles disponibles para editar:\n")
        for i, role in enumerate(roles, 1):
            print(f"{i:2d}. {role}")
        return roles
    
    # Muchos roles - usar navegación por carpetas
    folders = organize_roles_by_folder(roles)
    
    while True:
        areas = display_folder_navigation(folders)
        
        try:
            choice = int(input("\nSelecciona opción: ")) - 1
            
            if 0 <= choice < len(areas):
                # Seleccionó un área
                selected_area = areas[choice]
                area_roles = folders[selected_area]
                
                selected_roles = display_roles_in_area(selected_area, area_roles)
                
                role_choice = int(input(f"\nSelecciona rol del área {selected_area} (0 para volver): "))
                if role_choice == 0:
                    continue
                elif 1 <= role_choice <= len(selected_roles):
                    return [selected_roles[role_choice - 1]]  # Retornar rol seleccionado
                else:
                    print("❌ Número inválido")
                    
            elif choice == len(areas):
                # Búsqueda libre
                search_term = input("🔍 Buscar rol (nombre/path): ").strip().lower()
                if search_term:
                    filtered_roles = [r for r in roles if search_term in str(r).lower()]
                    if filtered_roles:
                        print(f"\n📋 Roles que coinciden con '{search_term}':")
                        for i, role in enumerate(filtered_roles, 1):
                            print(f"{i:2d}. {role}")
                        return filtered_roles
                    else:
                        print(f"❌ No se encontraron roles con '{search_term}'")
                        input("Presiona Enter para continuar...")
                        
            elif choice == len(areas) + 1:
                # Ver todos
                print(f"\n📋 Todos los roles ({len(roles)}):")
                for i, role in enumerate(roles, 1):
                    print(f"{i:2d}. {role}")
                return roles
                
            else:
                print("❌ Opción inválida")
                
        except ValueError:
            print("❌ Debe ser un número")
        except KeyboardInterrupt:
            print("\n❌ Operación cancelada")
            return []

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
            print(f"\n📋 Políticas AWS Managed actuales:")
            if current:
                for i, policy in enumerate(current, 1):
                    print(f"  {i}. {policy}")
            else:
                print("  (ninguna)")
            
            print(f"\n💡 ¿Qué son las AWS Managed Policies?")
            print("   Son políticas PRE-CREADAS por AWS que puedes usar directamente.")
            print("   Ejemplos comunes:")
            print("   📦 Lambda: AWSLambdaBasicExecutionRole")
            print("   🖥️  EC2: AmazonEC2ReadOnlyAccess") 
            print("   📁 S3: AmazonS3ReadOnlyAccess")
            print("   ☁️  CloudWatch: CloudWatchAgentServerPolicy")
            
            print(f"\n🔧 Opciones:")
            print("   a) Agregar política AWS managed")
            print("   r) Remover política") 
            print("   c) Limpiar todas")
            print("   ?) Ver ejemplos comunes")
            print("   Enter) Mantener actual")
            
            action = input("\nSelecciona acción: ").strip().lower()
            
            if action == "a":
                print("\n📝 Formato: arn:aws:iam::aws:policy/PolicyName")
                print("Ejemplos:")
                print("  arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole")
                print("  arn:aws:iam::aws:policy/AmazonS3ReadOnlyAccess")
                new_policy = input("\nIngresa ARN completo de la política: ").strip()
                if new_policy and new_policy.startswith("arn:aws:iam::aws:policy/"):
                    if new_policy not in current:
                        current.append(new_policy)
                        print(f"✅ Agregada: {new_policy}")
                    else:
                        print(f"⚠️ Ya existe: {new_policy}")
                else:
                    print("❌ ARN inválido. Debe empezar con 'arn:aws:iam::aws:policy/'")
            
            elif action == "r":
                if current:
                    try:
                        num = int(input("Número de política a remover: ")) - 1
                        if 0 <= num < len(current):
                            removed = current.pop(num)
                            print(f"❌ Removida: {removed}")
                        else:
                            print("❌ Número inválido")
                    except ValueError:
                        print("❌ Debe ser un número")
                else:
                    print("⚠️ No hay políticas para remover")
            
            elif action == "c":
                confirm = input("¿Confirmas limpiar todas las políticas AWS managed? (y/N): ").strip().lower()
                if confirm == "y":
                    current.clear()
                    print("🧹 Todas las políticas AWS managed removidas")
            
            elif action == "?":
                print("\n📚 Políticas AWS Managed más comunes:")
                examples = {
                    "Lambda": [
                        "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole",
                        "arn:aws:iam::aws:policy/service-role/AWSLambdaVPCAccessExecutionRole"
                    ],
                    "EC2": [
                        "arn:aws:iam::aws:policy/AmazonEC2ReadOnlyAccess",
                        "arn:aws:iam::aws:policy/AmazonEC2FullAccess"
                    ],
                    "S3": [
                        "arn:aws:iam::aws:policy/AmazonS3ReadOnlyAccess", 
                        "arn:aws:iam::aws:policy/AmazonS3FullAccess"
                    ],
                    "CloudWatch": [
                        "arn:aws:iam::aws:policy/CloudWatchAgentServerPolicy",
                        "arn:aws:iam::aws:policy/CloudWatchLogsFullAccess"
                    ]
                }
                for service, policies in examples.items():
                    print(f"\n  📦 {service}:")
                    for policy in policies:
                        print(f"     {policy}")
                input("\nPresiona Enter para continuar...")
            
            # Actualizar en el rol
            role_data.setdefault("policies", {})["aws_managed"] = current
                
        elif choice == "4":
            current = role_data.get("policies", {}).get("custom", [])
            print(f"\n📋 Políticas custom actuales:")
            for i, policy in enumerate(current, 1):
                print(f"  {i}. {policy}")
            
            print("\n🎯 Políticas MCI-* disponibles:")
            available_policies = [
                "MCI-S3-ReadOnly", "MCI-S3-Write",
                "MCI-DynamoDB-ReadOnly", "MCI-DynamoDB-Write", 
                "MCI-Lambda-Invoke", "MCI-SQS-Consume", 
                "MCI-SQS-Produce", "MCI-CloudWatch-Logs"
            ]
            
            for i, policy in enumerate(available_policies, 1):
                status = "✅" if policy in current else "⬜"
                print(f"  {i:2d}. {status} {policy}")
            
            print("\n🔧 Opciones:")
            print("  a) Agregar política por número")
            print("  r) Remover política por número") 
            print("  c) Limpiar todas las políticas")
            print("  Enter) Mantener actual")
            
            action = input("\nSelecciona acción: ").strip().lower()
            
            if action == "a":
                try:
                    num = int(input("Número de política a agregar: ")) - 1
                    if 0 <= num < len(available_policies):
                        policy_to_add = available_policies[num]
                        if policy_to_add not in current:
                            current.append(policy_to_add)
                            print(f"✅ Agregada: {policy_to_add}")
                        else:
                            print(f"⚠️ Ya existe: {policy_to_add}")
                    else:
                        print("❌ Número inválido")
                except ValueError:
                    print("❌ Debe ser un número")
            
            elif action == "r":
                if current:
                    try:
                        num = int(input("Número de política a remover: ")) - 1
                        if 0 <= num < len(current):
                            removed = current.pop(num)
                            print(f"❌ Removida: {removed}")
                        else:
                            print("❌ Número inválido")
                    except ValueError:
                        print("❌ Debe ser un número")
                else:
                    print("⚠️ No hay políticas para remover")
            
            elif action == "c":
                confirm = input("¿Confirmas limpiar todas las políticas? (y/N): ").strip().lower()
                if confirm == "y":
                    current.clear()
                    print("🧹 Todas las políticas removidas")
            
            # Actualizar en el rol
            role_data.setdefault("policies", {})["custom"] = current
                
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
    filtered_roles = display_roles(roles)
    if not filtered_roles:
        return
    
    # Seleccionar rol
    try:
        choice = int(input("\nSelecciona el número del rol a editar: ")) - 1
        if 0 <= choice < len(filtered_roles):
            selected_role = filtered_roles[choice]
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
