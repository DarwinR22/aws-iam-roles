#!/usr/bin/env python3
"""
Script para limpiar y validar nombres en archivos JSON de IAM
- Quita espacios de nombres de personas
- Quita tildes de tags
- Valida formato correcto
"""

import json
import re
import sys
from pathlib import Path

def clean_name(name):
    """Limpia nombres quitando espacios y guiones."""
    if not name:
        return name
    return re.sub(r'[\s\-]', '', name)

def remove_accents(text):
    """Quita tildes y acentos de texto."""
    replacements = {
        'á': 'a', 'é': 'e', 'í': 'i', 'ó': 'o', 'ú': 'u',
        'Á': 'A', 'É': 'E', 'Í': 'I', 'Ó': 'O', 'Ú': 'U',
        'ñ': 'n', 'Ñ': 'N',
        'ü': 'u', 'Ü': 'U'
    }
    
    for accented, clean in replacements.items():
        text = text.replace(accented, clean)
    
    return text

def clean_role_file(file_path):
    """Limpia un archivo de rol JSON."""
    print(f"🧹 Limpiando archivo: {file_path}")
    
    with open(file_path, 'r', encoding='utf-8') as f:
        data = json.load(f)
    
    changes_made = False
    
    # Campos que deben limpiarse (nombres de personas)
    name_fields = ['propietario', 'creado_por', 'contacto']
    
    # Limpiar nombres de personas
    for field in name_fields:
        if field in data and data[field]:
            original = data[field]
            cleaned = clean_name(original)
            if original != cleaned:
                print(f"  ✏️  {field}: '{original}' → '{cleaned}'")
                data[field] = cleaned
                changes_made = True
    
    # Limpiar tildes en todos los campos de texto
    def clean_object(obj):
        nonlocal changes_made
        if isinstance(obj, dict):
            for key, value in obj.items():
                if isinstance(value, str):
                    cleaned_value = remove_accents(value)
                    if value != cleaned_value:
                        print(f"  🚫 Tilde removida en {key}: '{value}' → '{cleaned_value}'")
                        obj[key] = cleaned_value
                        changes_made = True
                elif isinstance(value, (dict, list)):
                    clean_object(value)
        elif isinstance(obj, list):
            for item in obj:
                clean_object(item)
    
    clean_object(data)
    
    # Guardar cambios si los hubo
    if changes_made:
        with open(file_path, 'w', encoding='utf-8') as f:
            json.dump(data, f, indent=2, ensure_ascii=False)
        print(f"  ✅ Archivo actualizado: {file_path}")
        return True
    else:
        print(f"  ✅ Archivo ya está limpio: {file_path}")
        return False

def main():
    """Función principal."""
    if len(sys.argv) > 1:
        # Limpiar archivos específicos
        files = sys.argv[1:]
    else:
        # Buscar todos los archivos de roles
        files = []
        for pattern in ['**/*rol*.json', '**/rol-*.json']:
            files.extend(Path('.').glob(pattern))
    
    print("🧹 Limpiador de archivos IAM")
    print("=" * 50)
    
    total_changes = 0
    for file_path in files:
        if Path(file_path).exists():
            if clean_role_file(file_path):
                total_changes += 1
        else:
            print(f"❌ Archivo no encontrado: {file_path}")
    
    print("=" * 50)
    if total_changes > 0:
        print(f"🎉 Limpieza completada. {total_changes} archivos modificados.")
        print("💡 Recuerda hacer commit de los cambios.")
    else:
        print("✅ Todos los archivos ya estaban limpios.")

if __name__ == "__main__":
    main()
