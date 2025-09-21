#!/usr/bin/env python3
"""
Script para normalizar catalog/policies.yaml a lowercase
Convierte todos los valores de tags (excepto Name) a minúsculas
"""

import yaml
import os
import sys

def normalize_to_lowercase(text):
    """Convierte texto a lowercase, eliminando espacios extra"""
    if isinstance(text, str):
        # Mantener Name tal como está
        if text.startswith("MCI-") or text.startswith("App-") or text.startswith("Platform-"):
            return text
        # Para otros valores, convertir a lowercase y quitar espacios
        return text.lower().replace(" ", "")
    return text

def normalize_catalog():
    """Normaliza el catálogo completo a lowercase"""
    catalog_path = os.path.join(os.path.dirname(__file__), "..", "catalog", "policies.yaml")
    
    print("🔄 Normalizando catalog/policies.yaml a lowercase...")
    
    # Leer catálogo
    with open(catalog_path, 'r', encoding='utf-8') as f:
        catalog = yaml.safe_load(f)
    
    # Normalizar todas las políticas
    if 'policies' in catalog:
        for policy_name, policy_config in catalog['policies'].items():
            if 'canonical_tags' in policy_config:
                normalized_tags = {}
                for tag_key, tag_value in policy_config['canonical_tags'].items():
                    # Mantener Name tal como está, normalizar todo lo demás
                    if tag_key == "Name":
                        normalized_tags[tag_key] = tag_value
                    else:
                        normalized_tags[tag_key] = normalize_to_lowercase(tag_value)
                
                policy_config['canonical_tags'] = normalized_tags
                print(f"  ✅ Normalizado: {policy_name}")
    
    # Escribir catálogo normalizado
    with open(catalog_path, 'w', encoding='utf-8') as f:
        yaml.dump(catalog, f, default_flow_style=False, allow_unicode=True, sort_keys=False)
    
    print("✅ Catálogo normalizado completamente a lowercase")
    print("🎯 Ahora todos los tags son consistentes y simples")

if __name__ == "__main__":
    normalize_catalog()