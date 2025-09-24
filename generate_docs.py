#!/usr/bin/env python3
"""
Generate IAM Policies Documentation
Automatically creates markdown documentation from the policies catalog
"""

import json
import yaml
import os
from datetime import datetime

def generate_documentation():
    """Generate comprehensive IAM policies documentation"""
    
    print("📚 Generating IAM documentation from catalog V2...")
    
    # Try to read V2 catalog first
    try:
        # Read V2 index
        with open('catalog/v2/index.yaml', 'r', encoding='utf-8') as f:
            v2_index = yaml.safe_load(f)
        
        # Combine all services from V2
        all_policies = {}
        for service_name, service_file in v2_index.get('services', {}).items():
            service_path = f'catalog/v2/{service_file}'
            if os.path.exists(service_path):
                with open(service_path, 'r', encoding='utf-8') as f:
                    service_catalog = yaml.safe_load(f)
                all_policies.update(service_catalog.get('policies', {}))
        
        catalog = {'policies': all_policies}
        print(f"✅ Using catalog V2 - {len(all_policies)} policies loaded")
        
    except FileNotFoundError:
        print("❌ Catalog V2 not found - no fallback available")
        print("📂 Expected structure: catalog/v2/index.yaml")
        return
    
    # Generate markdown documentation
    with open('POLICIES_DOCUMENTATION.md', 'w', encoding='utf-8') as f:
        f.write('# 📋 IAM Policies Documentation\n\n')
        f.write('Auto-generated documentation for all IAM policies.\n\n')
        f.write(f'**Generated:** {datetime.now().strftime("%Y-%m-%d %H:%M:%S UTC")}\n\n')
        f.write('---\n\n')
        
        # Table of Contents
        f.write('## 📑 Table of Contents\n\n')
        for policy_name in catalog['policies'].keys():
            f.write(f'- [{policy_name}](#{policy_name.lower().replace("-", "")})\n')
        f.write('\n---\n\n')
        
        # Policies Documentation
        for policy_name, policy_data in catalog['policies'].items():
            f.write(f'## {policy_name}\n\n')
            f.write(f'**Description:** {policy_data["description"]}\n\n')
            f.write(f'**Type:** {policy_data["type"]}\n\n')
            f.write(f'**Policy Document:** `{policy_data["policy_document"]}`\n\n')
            
            # Tags section
            f.write('### 🏷️ **Canonical Tags:**\n\n')
            f.write('| Tag | Value |\n')
            f.write('|-----|-------|\n')
            for tag_key, tag_value in policy_data['canonical_tags'].items():
                f.write(f'| {tag_key} | {tag_value} |\n')
            f.write('\n')
            
            # Usage example
            f.write('### 💡 **Usage Example:**\n\n')
            f.write('```hcl\n')
            f.write('resource "aws_iam_policy" "example" {\n')
            f.write(f'  name        = "{policy_name}"\n')
            f.write(f'  description = "{policy_data["description"]}"\n')
            f.write('  policy      = data.aws_iam_policy_document.policy.json\n')
            f.write('}\n')
            f.write('```\n\n')
            
            f.write('---\n\n')
        
        # Summary section
        f.write('## 📊 Summary\n\n')
        f.write(f'**Total Policies:** {len(catalog["policies"])}\n\n')
        
        # Group by type
        policy_types = {}
        for policy_data in catalog['policies'].values():
            policy_type = policy_data['type']
            policy_types[policy_type] = policy_types.get(policy_type, 0) + 1
        
        f.write('**Policies by Type:**\n')
        for policy_type, count in policy_types.items():
            f.write(f'- {policy_type}: {count}\n')
        f.write('\n')
        
        # Footer
        f.write('---\n\n')
        f.write('*This documentation is auto-generated from the policies catalog. ')
        f.write('Do not edit manually - changes will be overwritten.*\n')
    
    print('✅ Documentation generated successfully')
    return True

if __name__ == "__main__":
    try:
        generate_documentation()
    except Exception as e:
        print(f'❌ Error generating documentation: {e}')
        exit(1)