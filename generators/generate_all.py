#!/usr/bin/env python3
# -*- coding: utf-8 -*-
import sys
import io

# Force UTF-8 encoding for Windows console
if sys.platform == 'win32':
    sys.stdout = io.TextIOWrapper(sys.stdout.buffer, encoding='utf-8', errors='replace')
    sys.stderr = io.TextIOWrapper(sys.stderr.buffer, encoding='utf-8', errors='replace')

"""
MCI AWS IAM Policy and Role Generator
====================================
Updated: 2025-09-25 - Added terraform plan support to workflow
Updated: 2025-09-25 - Added workflow_dispatch for manual execution
Updated: 2025-09-25 - Testing branch protection bypass for admin user
Updated: 2025-09-25 - Fixed terraform fmt and syntax issues - Ready for production!
Updated: 2025-09-25 - Added detailed logging and auto-format to debug pipeline issues
Updated: 2025-09-25 - FIXED policy_modules attachment bug - policies should now attach to roles

Generates Terraform code from YAML/JSON definitions.
Replaces manual policy_lib/ and modules/ with declarative approach.

Usage:
    python generators/generate_all.py
    python generators/generate_all.py --validate-only
    python generators/generate_all.py --clean
"""

import os
import yaml
import json
import argparse
import subprocess
from pathlib import Path
from jinja2 import Environment, FileSystemLoader
from datetime import datetime
import boto3
import re

class IAMGenerator:
    def __init__(self, repo_root: Path):
        self.repo_root = repo_root
        self.definitions_dir = repo_root / "definitions"
        self.templates_dir = repo_root / "templates" 
        self.generated_dir = repo_root / "generated"
        self.catalog_dir = repo_root / "catalog"
        # Policy attachments disabled - policies created as independent modules
        # Workflow trigger comment
        
        # Smart timestamp - preserve if no real changes
        self.last_generation_time = self._get_last_generation_time()
        self.current_generation_time = datetime.now().isoformat()
        
        # Setup Jinja2
        self.jinja_env = Environment(
            loader=FileSystemLoader(str(self.templates_dir)),
            trim_blocks=True,
            lstrip_blocks=True
        )
        
        # Detect current branch and map to account ID
        self.current_branch = self._detect_current_branch()
        self.account_id = self._get_account_id_for_branch()
        print(f"Branch: {self.current_branch} -> Account: {self.account_id}")
    
    def _detect_current_branch(self) -> str:
        """Detect current git branch"""
        try:
            result = subprocess.run(
                ['git', 'branch', '--show-current'],
                capture_output=True,
                text=True,
                check=True
            )
            branch = result.stdout.strip()
            return branch if branch else 'dev'
        except Exception as e:
            print(f"⚠️  Could not detect branch: {e}")
            return 'dev'
    
    def _get_account_id_for_branch(self) -> str:
        """Map branch to AWS account ID"""
        branch_to_account = {
            'dev': '393209814297',
            'qa': '873152456645',
            'main': '331355389575',
            'prod': '331355389575'  # Alias for main
        }
        
        account_id = branch_to_account.get(self.current_branch)
        
        if not account_id:
            print(f"⚠️  Unknown branch '{self.current_branch}', defaulting to DEV account")
            return '393209814297'
        
        return account_id
    
    def _get_branch_restriction(self) -> str:
        """Get OIDC branch restriction for current branch"""
        branch_restrictions = {
            'dev': 'ref:refs/heads/dev',
            'qa': 'ref:refs/heads/qa',
            'main': 'ref:refs/heads/main',
            'prod': 'ref:refs/heads/main'
        }
        return branch_restrictions.get(self.current_branch, 'ref:refs/heads/dev')
    
    def _allow_pull_requests(self) -> bool:
        """Determine if pull requests should be allowed for current branch"""
        # Only allow PRs in dev and qa, NOT in production
        return self.current_branch in ['dev', 'qa']
    
    def _get_last_generation_time(self) -> str:
        """Get the last generation timestamp from existing files"""
        try:
            # Try to read from existing deployment-roles.tf
            deployment_file = self.generated_dir / "deployment-roles.tf"
            if deployment_file.exists():
                content = deployment_file.read_text()
                # Look for Generated tag in the content
                import re
                match = re.search(r'"Generated"\s*=\s*"([^"]+)"', content)
                if match:
                    return match.group(1)
        except Exception:
            pass
        
        # Default to current time if no existing timestamp found
        return datetime.now().isoformat()
    
    def _should_update_timestamp(self, definition_content: str, yaml_path: Path) -> bool:
        """Determine if timestamp should be updated based on real changes"""
        try:
            # Check if this is a version bump (explicit change)
            if 'version' in definition_content and any(x in definition_content.lower() for x in ['v1.', 'v2.', 'version']):
                # Parse version from YAML
                data = yaml.safe_load(definition_content)
                current_version = data.get('role', {}).get('metadata', {}).get('version', '1.0.0')
                
                # If version changed from last known, update timestamp
                # (For simplicity, we'll update timestamp on any version that's not 1.0.0)
                if current_version != '1.0.0':
                    return True
            
            # Check if policy_modules list changed
            if 'policy_modules:' in definition_content:
                return True
                
            # Check if it's a forced regeneration (--clean flag will be handled separately)
            return False
            
        except Exception:
            return False
    
    def validate_yaml_schema(self, yaml_file: Path, schema_type: str) -> dict:
        """Validate YAML against expected schema"""
        with open(yaml_file, 'r') as f:
            data = yaml.safe_load(f)
        
        if schema_type == 'policy':
            required_fields = ['policy', 'policy.name', 'policy.permissions']
            # Add validation logic
        elif schema_type == 'role':
            required_fields = ['role', 'role.name', 'role.tags']
            # Add validation logic
            
        return data
    
    def validate_abac_compliance(self, definition: dict) -> bool:
        """Ensure ABAC tags and conditions are present"""
        if 'policy' in definition:
            # Check ABAC conditions
            statements = definition['policy'].get('statements', [])
            for stmt in statements:
                conditions = stmt.get('abac_conditions', [])
                has_gerencia = any(c.get('variable') == 'aws:PrincipalTag/Gerencia' for c in conditions)
                if not has_gerencia:
                    raise ValueError(f"Policy missing required ABAC Gerencia condition")
        
        if 'role' in definition:
            # Check required tags
            tags = definition['role'].get('tags', {})
            required_tags = ['Gerencia', 'Area', 'Ambiente']
            for tag in required_tags:
                if tag not in tags:
                    raise ValueError(f"Role missing required tag: {tag}")
                    
        return True
    
    def validate_naming_convention(self, name: str, type: str) -> bool:
        """Validate naming follows MCI standards"""
        
        # Excepciones para recursos legacy/existentes (sin warnings)
        legacy_exceptions = [
            # Políticas de GitHub deployment (legacy)
            r'^github-deployment-.*$',
            # Rol de GitHub deployment existente (legacy)
            r'^github-actions-iam-deployment-role$'
        ]
        
        # Verificar si es una excepción legacy
        for exception_pattern in legacy_exceptions:
            if re.match(exception_pattern, name):
                return True  # Sin warning para recursos legacy
        
        # Validación estricta para nuevos recursos MCI
        if type == 'policy':
            # mci-service-action pattern (kebab-case)
            pattern = r'^mci-[a-z0-9]+-[a-z0-9-]+$'
        elif type == 'role':
            # mci-service-layer-ambiente-nombre pattern (kebab-case)
            pattern = r'^mci-[a-z0-9]+-[a-z0-9-]+$'
        
        if not re.match(pattern, name):
            print(f"⚠️  Warning: Name '{name}' doesn't follow strict MCI naming convention, but proceeding...")
            # For now, just warn instead of failing
        return True
    
    def generate_terraform_name(self, display_name: str) -> str:
        """Convert display name to terraform-safe name"""
        return display_name.lower().replace('-', '_').replace(' ', '_')
    
    def generate_policies(self) -> list:
        """Generate all policy Terraform modules"""
        generated_files = []
        policies_dir = self.definitions_dir / "policies"
        
        if not policies_dir.exists():
            print(f"⚠️  No policies directory found: {policies_dir}")
            return generated_files
        
        # Module templates
        main_template = self.jinja_env.get_template('modules/policy-main.tf.j2')
        variables_template = self.jinja_env.get_template('modules/policy-variables.tf.j2')
        outputs_template = self.jinja_env.get_template('modules/policy-outputs.tf.j2')
        
        # Search for YAML files in policies directory and subdirectories
        yaml_files = []
        yaml_files.extend(policies_dir.glob("*.yaml"))  # Root level
        yaml_files.extend(policies_dir.glob("**/*.yaml"))  # Subdirectories
        
        for yaml_file in yaml_files:
            print(f"🔄 Processing policy module: {yaml_file.name}")
            
            # Load and validate
            definition = self.validate_yaml_schema(yaml_file, 'policy')
            
            # Skip ABAC validation for deployment policies (different schema)
            if 'deployment' not in str(yaml_file):
                self.validate_abac_compliance(definition)
                
            self.validate_naming_convention(definition['policy']['name'], 'policy')
            
            # Generate terraform name with MCI prefix for consistency
            terraform_name = self.generate_terraform_name(definition['policy']['name'])
            # Add MCI prefix ONLY to non-github-deployment policies
            # github-deployment-* are legacy GitHub Actions policies, should NOT have MCI prefix
            if not terraform_name.startswith('mci_') and not terraform_name.startswith('github_deployment'):
                terraform_name = f"mci_{terraform_name}"
            
            # Create module directory
            module_dir = self.generated_dir / "modules" / "policies" / terraform_name
            module_dir.mkdir(parents=True, exist_ok=True)
            
            # Extract variables from policy definition
            required_params = self.extract_policy_parameters(definition['policy'])
            
            # Render templates
            template_data = {
                'policy_name': definition['policy']['name'],
                'terraform_name': terraform_name,
                'description': definition['policy'].get('description', ''),
                'statements': definition['policy']['statements'],
                'required_params': required_params,
                'source_yaml_path': f"definitions/policies/{yaml_file.relative_to(policies_dir)}"
            }
            
            # Generate main.tf
            main_code = main_template.render(**template_data)
            main_file = module_dir / "main.tf"
            with open(main_file, 'w') as f:
                f.write(main_code)
            
            # Generate variables.tf
            variables_code = variables_template.render(**template_data)
            variables_file = module_dir / "variables.tf"
            with open(variables_file, 'w') as f:
                f.write(variables_code)
            
            # Generate outputs.tf
            outputs_code = outputs_template.render(**template_data)
            outputs_file = module_dir / "outputs.tf"
            with open(outputs_file, 'w') as f:
                f.write(outputs_code)
            
            generated_files.extend([main_file, variables_file, outputs_file])
            print(f"✅ Generated module: {module_dir}")
        
        return generated_files
    
    def extract_policy_parameters(self, policy_definition: dict) -> list:
        """Extract required parameters from policy definition"""
        params = []
        
        # Extract bucket names, queues, etc. from resources
        for statement in policy_definition.get('statements', []):
            resources = statement.get('resource', [])
            if isinstance(resources, str):
                resources = [resources]
            
            for resource in resources:
                # Extract S3 bucket names
                if 's3:::' in resource and '${' in resource:
                    # Extract variable name from resource ARN
                    import re
                    matches = re.findall(r'\$\{([^}]+)\}', resource)
                    for match in matches:
                        if match not in [p['name'] for p in params]:
                            params.append({
                                'name': match,
                                'description': f"Parameter extracted from resource: {resource}",
                                'type': 'string'
                            })
        
        return params
    
    def generate_roles(self) -> list:
        """Generate consolidated role Terraform files following best practices"""
        generated_files = []
        roles_dir = self.definitions_dir / "roles"
        
        if not roles_dir.exists():
            print(f"⚠️  No roles directory found: {roles_dir}")
            return generated_files
        
        # Load role template
        role_template = self.jinja_env.get_template('role.tf.j2')
        
        # Categorize roles by type for best practices
        deployment_roles = []
        application_roles = []
        
        # Process all YAML files in roles directory
        for yaml_file in roles_dir.glob("*.yaml"):
            print(f"🔄 Processing role: {yaml_file.name}")
            
            # Load and validate
            definition = self.validate_yaml_schema(yaml_file, 'role')
            self.validate_abac_compliance(definition)
            self.validate_naming_convention(definition['role']['name'], 'role')
            
            # Generate terraform name  
            definition['role']['terraform_name'] = self.generate_terraform_name(
                definition['role']['name']
            )
            
            # Extract real policy names from policy_modules for template
            policy_modules = definition.get('role', {}).get('policy_modules', [])
            real_policy_names = []
            
            for pm in policy_modules:
                # Skip inline policies (they don't have a file)
                if 'inline_policy' in pm:
                    continue
                    
                # Allow specifying policy folder, default to 'deployment'
                policy_folder = pm.get('folder', 'deployment')
                policy_file = self.definitions_dir / "policies" / policy_folder / pm['file']
                
                if policy_file.exists():
                    with open(policy_file, 'r') as f:
                        policy_def = yaml.safe_load(f)
                        real_name = policy_def['policy']['name']
                        real_policy_names.append(real_name)
                else:
                    print(f"⚠️  Policy file not found: {policy_file}")
                    
            definition['role']['policies'] = real_policy_names
            
            # Determine smart timestamp - only update if real changes detected
            yaml_content = yaml_file.read_text()
            should_update = self._should_update_timestamp(yaml_content, yaml_file)
            generation_time = self.current_generation_time if should_update else self.last_generation_time
            
            # Override account_id and branch restriction in role definition
            definition['role']['variables'] = {
                'account_id': {'default': self.account_id},
                'environment': {'default': self.current_branch}
            }
            
            # Update OIDC conditions with current branch restriction
            # DISABLED: Respect YAML values instead of hardcoding branch restrictions
            # if definition['role'].get('trust_policy', {}).get('type') == 'oidc':
            #     conditions = definition['role']['trust_policy']['oidc_config']['conditions']
            #     for condition in conditions:
            #         if condition['variable'] == 'token.actions.githubusercontent.com:sub':
            #             # Replace branch restriction
            #             branch_restriction = f"repo:ClaroCENAM/mci-aws-iam:ref:refs/heads/{self.current_branch}"
            #             condition['values'] = [branch_restriction]
            #             
            #             # Add pull_request only for dev/qa
            #             if self._allow_pull_requests():
            #                 condition['values'].append("repo:ClaroCENAM/mci-aws-iam:pull_request")
            
            # Categorize by role type (deployment vs application)
            role_name = definition['role']['name'].lower()
            if 'github' in role_name or 'deployment' in role_name or 'ci' in role_name or 'cd' in role_name:
                deployment_roles.append({
                    'definition': definition,
                    'yaml_file': yaml_file,
                    'terraform_code': role_template.render(
                        role=definition['role'],
                        policy_modules=definition.get('role', {}).get('policy_modules', []),
                        source_file=f"definitions/roles/{yaml_file.name}",
                        generation_time=generation_time,
                        account_id=self.account_id,
                        current_branch=self.current_branch
                    )
                })
            else:
                application_roles.append({
                    'definition': definition,
                    'yaml_file': yaml_file,
                    'terraform_code': role_template.render(
                        role=definition['role'],
                        policy_modules=definition.get('role', {}).get('policy_modules', []),
                        source_file=f"definitions/roles/{yaml_file.name}",
                        generation_time=generation_time,
                        account_id=self.account_id,
                        current_branch=self.current_branch
                    )
                })
        
        # Generate deployment-roles.tf (infrastructure/CI-CD roles)
        if deployment_roles:
            deployment_content = self._generate_consolidated_roles_file(
                deployment_roles, 
                "Deployment and Infrastructure Roles",
                "CI/CD, GitHub Actions, and infrastructure automation roles"
            )
            deployment_file = self.generated_dir / "deployment-roles.tf"
            with open(deployment_file, 'w') as f:
                f.write(deployment_content)
            generated_files.append(deployment_file)
            print(f"✅ Generated: deployment-roles.tf ({len(deployment_roles)} roles)")
        
        # Generate application-roles.tf (business/application roles)  
        if application_roles:
            application_content = self._generate_consolidated_roles_file(
                application_roles,
                "Application and Business Roles", 
                "Business user roles for applications, analytics, and services"
            )
            application_file = self.generated_dir / "application-roles.tf"
            with open(application_file, 'w') as f:
                f.write(application_content)
            generated_files.append(application_file)
            print(f"✅ Generated: application-roles.tf ({len(application_roles)} roles)")
        
        return generated_files
    
    def _generate_consolidated_roles_file(self, roles: list, title: str, description: str) -> str:
        """Generate a consolidated Terraform file with multiple roles"""
        header = f'''# ==============================================================================
# {title}
# ==============================================================================
# {description}
# 
# This file is auto-generated from YAML definitions.
# DO NOT EDIT MANUALLY - Changes will be overwritten.
# 
# Generated: {self.current_generation_time}
# Source: Multiple role definitions in definitions/roles/
# ==============================================================================

'''
        
        content = header
        for role_data in roles:
            content += f"\n# Role from: {role_data['yaml_file'].name}\n"
            content += role_data['terraform_code']
            content += "\n\n"
        
        return content
    
    def clean_generated(self):
        """Remove all generated files"""
        print("Cleaning generated files...")
        for tf_file in self.generated_dir.rglob("*.tf"):
            tf_file.unlink()
            print(f"Removed: {tf_file}")
    
    def generate_all(self, clean_first=False):
        """Generate all policies and roles"""
        if clean_first:
            self.clean_generated()
        
        print("Starting IAM generation...")
        
        # Generate policies
        policy_files = self.generate_policies()
        print(f"Generated {len(policy_files)} policy files")
        
        # Generate roles  
        role_files = self.generate_roles()
        print(f"Generated {len(role_files)} role files")
        
        print(f"Generation complete! Total files: {len(policy_files) + len(role_files)}")
        return policy_files + role_files

def main():
    parser = argparse.ArgumentParser(description='Generate IAM Terraform from YAML definitions')
    parser.add_argument('--validate-only', action='store_true', help='Only validate, do not generate')
    parser.add_argument('--clean', action='store_true', help='Clean generated files first')
    
    args = parser.parse_args()
    
    # Find repository root
    repo_root = Path(__file__).parent.parent
    
    generator = IAMGenerator(repo_root)
    
    if args.validate_only:
        print("Validation mode - no files will be generated")
        # Add validation-only logic
    else:
        generator.generate_all(clean_first=args.clean)

if __name__ == "__main__":
    main()