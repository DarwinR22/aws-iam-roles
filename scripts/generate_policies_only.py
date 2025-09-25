#!/usr/bin/env python3
"""
Script para generar SOLO políticas (sin roles)
Permite crear políticas generales primero
"""

import sys
from pathlib import Path
sys.path.append(str(Path(__file__).parent.parent))

from generators.generate_all import IAMGenerator

def generate_policies_only():
    """Genera solo políticas, sin roles"""
    generator = IAMGenerator(Path(__file__).parent.parent)
    
    print("🚀 Generando SOLO políticas generales...")
    
    # Solo políticas
    policy_files = generator.generate_policies()
    
    print(f"✅ Generadas {len(policy_files)} políticas")
    for file in policy_files:
        print(f"   📄 {file}")
    
    print("\n💡 Ahora puedes:")
    print("   1. Revisar las políticas generadas") 
    print("   2. Crear roles que usen estas políticas")
    print("   3. Ejecutar generador completo después")

if __name__ == "__main__":
    generate_policies_only()