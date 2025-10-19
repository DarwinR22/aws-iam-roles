#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Extended SGSI Infrastructure Generator
====================================
Extends the original IAM generator to include:
- VPC and Networking components
- Security Groups and NACLs
- Compute resources
- Security and monitoring tools
- Full SGSI infrastructure

Usage:
    python generators/generate_sgsi_all.py
    python generators/generate_sgsi_all.py --layer networking
    python generators/generate_sgsi_all.py --clean
"""

import os
import yaml
import json
import argparse
import subprocess
from pathlib import Path
from jinja2 import Environment, FileSystemLoader
from datetime import datetime

class SGSIInfrastructureGenerator:
    def __init__(self, repo_root: Path):
        self.repo_root = repo_root
        self.definitions_dir = repo_root / "definitions"
        self.templates_dir = repo_root / "templates" 
        self.generated_dir = repo_root / "generated"
        
        # Ensure generated directory exists
        self.generated_dir.mkdir(exist_ok=True)
        
        # Setup Jinja2 environment
        self.jinja_env = Environment(
            loader=FileSystemLoader(str(self.templates_dir)),
            trim_blocks=True,
            lstrip_blocks=True
        )
        
        # Configuration per layer
        self.layers = {
            'iam': {
                'dir': 'policies',
                'template': 'policy.tf.j2',
                'output_dir': 'modules/policies'
            },
            'networking': {
                'dir': 'network',
                'templates': {
                    'vpcs': 'vpc.tf.j2',
                    'security-groups': 'security-group.tf.j2',
                    'subnets': 'subnet.tf.j2'
                },
                'output_dir': 'network'
            },
            'compute': {
                'dir': 'compute',
                'templates': {
                    'ec2': 'ec2.tf.j2',
                    'rds': 'rds.tf.j2',
                    'load-balancers': 'alb.tf.j2'
                },
                'output_dir': 'compute'
            },
            'security': {
                'dir': 'security',
                'templates': {
                    'waf': 'waf.tf.j2',
                    'guardduty': 'guardduty.tf.j2',
                    'config': 'config.tf.j2'
                },
                'output_dir': 'security'
            }
        }

    def get_account_id_from_branch(self):
        """Get account ID based on git branch"""
        try:
            result = subprocess.run(['git', 'branch', '--show-current'], 
                                  capture_output=True, text=True, cwd=self.repo_root)
            branch = result.stdout.strip()
            print(f"Branch: {branch} -> Account: 393209814297")
            return "051963532279"  # Personal account
        except:
            return "051963532279"

    def load_yaml_definition(self, file_path):
        """Load and parse YAML definition file"""
        try:
            with open(file_path, 'r', encoding='utf-8') as f:
                return yaml.safe_load(f)
        except Exception as e:
            print(f"Error loading {file_path}: {e}")
            return None

    def generate_networking_layer(self):
        """Generate networking infrastructure"""
        print("🌐 Generating Networking Layer...")
        generated_files = []
        
        # Generate VPCs
        vpc_dir = self.definitions_dir / "network" / "vpcs"
        if vpc_dir.exists():
            for vpc_file in vpc_dir.glob("*.yaml"):
                print(f"🔄 Processing VPC: {vpc_file.name}")
                definition = self.load_yaml_definition(vpc_file)
                if definition and 'vpc' in definition:
                    tf_content = self.generate_vpc_terraform(definition, vpc_file.name)
                    output_file = self.generated_dir / f"network-{vpc_file.stem}.tf"
                    # No need to create subdirectory, put in root generated/
                    
                    with open(output_file, 'w', encoding='utf-8') as f:
                        f.write(tf_content)
                    
                    generated_files.append(output_file)
                    print(f"✅ Generated: {output_file}")

        # Generate Security Groups
        sg_dir = self.definitions_dir / "network" / "security-groups"
        if sg_dir.exists():
            for sg_file in sg_dir.glob("*.yaml"):
                print(f"🔄 Processing Security Groups: {sg_file.name}")
                definition = self.load_yaml_definition(sg_file)
                if definition and 'security_groups' in definition:
                    tf_content = self.generate_security_groups_terraform(definition, sg_file.name)
                    output_file = self.generated_dir / f"network-security-groups-{sg_file.stem}.tf"
                    # Place in root generated/ directory for Terraform to find
                    
                    with open(output_file, 'w', encoding='utf-8') as f:
                        f.write(tf_content)
                    
                    generated_files.append(output_file)
                    print(f"✅ Generated: {output_file}")
        
        return generated_files

    def generate_vpc_terraform(self, definition, source_file):
        """Generate Terraform for VPC from definition"""
        try:
            template = self.jinja_env.get_template('vpc.tf.j2')
            
            context = {
                'vpc': definition['vpc'],
                'variables': definition.get('variables', {}),
                'tags': definition.get('tags', {}),
                'timestamp': datetime.now().isoformat(),
                'source_file': source_file,
                'account_id': self.get_account_id_from_branch()
            }
            
            return template.render(**context)
            
        except Exception as e:
            print(f"Error generating VPC Terraform: {e}")
            return f"# Error generating VPC: {e}"

    def generate_security_groups_terraform(self, definition, source_file):
        """Generate Terraform for Security Groups"""
        # For now, create a basic template
        content = f"""# Security Groups generated from {source_file}
# Generated: {datetime.now().isoformat()}

"""
        for sg in definition['security_groups']:
            sg_name = sg['name'].replace('-', '_')
            content += f"""
resource "aws_security_group" "{sg_name}" {{
  name        = "{sg['name']}"
  description = "{sg['description']}"
  
  # Ingress rules
"""
            for rule in sg.get('ingress_rules', []):
                content += f"""  ingress {{
    from_port   = {rule['from_port']}
    to_port     = {rule['to_port']}
    protocol    = "{rule['protocol']}"
"""
                if 'cidr_blocks' in rule:
                    content += f'    cidr_blocks = {json.dumps(rule["cidr_blocks"])}\n'
                if 'source_security_group' in rule:
                    content += f'    security_groups = [aws_security_group.{rule["source_security_group"].replace("-", "_")}.id]\n'
                content += f'    description = "{rule.get("description", "")}"\n  }}\n'

            content += "\n  # Egress rules\n"
            for rule in sg.get('egress_rules', []):
                content += f"""  egress {{
    from_port   = {rule['from_port']}
    to_port     = {rule['to_port']}
    protocol    = "{rule['protocol']}"
"""
                if 'cidr_blocks' in rule:
                    content += f'    cidr_blocks = {json.dumps(rule["cidr_blocks"])}\n'
                content += f'    description = "{rule.get("description", "")}"\n  }}\n'

            content += f"""
  tags = {{
    Name = "{sg['name']}"
    Tier = "{sg.get('tier', 'unknown')}"
    SecurityLevel = "High"
    ComplianceScope = "ISO27001"
  }}
}}

"""
        return content

    def generate_all_layers(self, specific_layer=None, clean_first=False):
        """Generate infrastructure for all layers or specific layer"""
        if clean_first:
            self.clean_generated()

        generated_files = []
        
        if specific_layer:
            if specific_layer == 'networking':
                generated_files.extend(self.generate_networking_layer())
            else:
                print(f"Layer '{specific_layer}' not yet implemented")
        else:
            # Generate all layers
            print("🚀 Generating All SGSI Infrastructure Layers...")
            
            # Layer 1: IAM (already exists - just mention it)
            print("✅ Layer 1: IAM - Already implemented")
            
            # Layer 2: Networking
            generated_files.extend(self.generate_networking_layer())
            
            # TODO: Add other layers
            # generated_files.extend(self.generate_compute_layer())
            # generated_files.extend(self.generate_security_layer())
            # generated_files.extend(self.generate_monitoring_layer())

        print(f"🎉 Generation complete! Generated {len(generated_files)} files")
        return generated_files

    def clean_generated(self):
        """Remove all generated files"""
        print("🧹 Cleaning generated files...")
        if self.generated_dir.exists():
            for tf_file in self.generated_dir.rglob("*.tf"):
                if tf_file.name != "backend.tf":  # Preserve backend configuration
                    tf_file.unlink()
                    print(f"Removed: {tf_file}")

def main():
    parser = argparse.ArgumentParser(description='Generate SGSI Infrastructure from YAML definitions')
    parser.add_argument('--layer', choices=['networking', 'compute', 'security', 'monitoring'], 
                       help='Generate specific layer only')
    parser.add_argument('--clean', action='store_true', help='Clean generated files first')
    
    args = parser.parse_args()
    
    # Find repository root
    repo_root = Path(__file__).parent.parent
    
    generator = SGSIInfrastructureGenerator(repo_root)
    generator.generate_all_layers(specific_layer=args.layer, clean_first=args.clean)

if __name__ == "__main__":
    main()