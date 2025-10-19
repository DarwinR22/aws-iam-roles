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
                content = deployment_file.read_text(encoding='utf-8')
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
        with open(yaml_file, 'r', encoding='utf-8') as f:
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
            # Check ABAC conditions - support both patterns:
            # - Deployment policies: use Gerencia + Ambiente
            # - Execution policies: use Cuenta (+ Proposito for S3)
            statements = definition['policy'].get('statements', [])
            for stmt in statements:
                conditions = stmt.get('abac_conditions', [])
                has_gerencia = any(c.get('variable') == 'aws:PrincipalTag/Gerencia' for c in conditions)
                has_cuenta = any(c.get('variable') == 'aws:PrincipalTag/Cuenta' for c in conditions)
                
                # Policy must have at least one ABAC pattern
                if not has_gerencia and not has_cuenta:
                    raise ValueError(f"Policy missing required ABAC condition (needs Gerencia OR Cuenta)")
        
        if 'role' in definition:
            # Check required tags - flexible validation
            tags = definition['role'].get('tags', {})
            
            # Deployment roles need: Gerencia, Area, Ambiente
            # Execution roles need: Cuenta (+ Proposito for S3 access)
            has_deployment_tags = all(tag in tags for tag in ['Gerencia', 'Area', 'Ambiente'])
            has_execution_tags = 'Cuenta' in tags
            
            if not has_deployment_tags and not has_execution_tags:
                raise ValueError(f"Role missing required tags. Need either [Gerencia, Area, Ambiente] OR [Cuenta]")
                    
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
    
    def load_yaml_definition(self, file_path: Path) -> dict:
        """Load and parse YAML definition file"""
        try:
            with open(file_path, 'r', encoding='utf-8') as file:
                return yaml.safe_load(file)
        except Exception as e:
            print(f"❌ Error loading YAML file {file_path}: {e}")
            return {}
    
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
            with open(main_file, 'w', encoding='utf-8') as f:
                f.write(main_code)
            
            # Generate variables.tf
            variables_code = variables_template.render(**template_data)
            variables_file = module_dir / "variables.tf"
            with open(variables_file, 'w', encoding='utf-8') as f:
                f.write(variables_code)
            
            # Generate outputs.tf
            outputs_code = outputs_template.render(**template_data)
            outputs_file = module_dir / "outputs.tf"
            with open(outputs_file, 'w', encoding='utf-8') as f:
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
                    with open(policy_file, 'r', encoding='utf-8') as f:
                        policy_def = yaml.safe_load(f)
                        real_name = policy_def['policy']['name']
                        real_policy_names.append(real_name)
                else:
                    print(f"⚠️  Policy file not found: {policy_file}")
                    
            definition['role']['policies'] = real_policy_names
            
            # Determine smart timestamp - only update if real changes detected
            yaml_content = yaml_file.read_text(encoding='utf-8')
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
            #             branch_restriction = f"repo:DarwinR22/aws-iam-roles:ref:refs/heads/{self.current_branch}"
            #             condition['values'] = [branch_restriction]
            #             
            #             # Add pull_request only for dev/qa
            #             if self._allow_pull_requests():
            #                 condition['values'].append("repo:DarwinR22/aws-iam-roles:pull_request")
            
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
            with open(deployment_file, 'w', encoding='utf-8') as f:
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
            with open(application_file, 'w', encoding='utf-8') as f:
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


# Common data sources (shared by all roles)
data "aws_caller_identity" "current" {{}}

'''
        
        content = header
        for role_data in roles:
            content += f"\n# Role from: {role_data['yaml_file'].name}\n"
            # Remove duplicate data sources from individual role code
            role_code = role_data['terraform_code']
            role_code = role_code.replace('data "aws_caller_identity" "current" {}\n\n', '')
            role_code = role_code.replace('# Get current AWS account ID\ndata "aws_caller_identity" "current" {}\n\n', '')
            content += role_code
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
        
        # Generate SGSI Infrastructure (Layer 3)
        sgsi_files = self.generate_sgsi_infrastructure()
        print(f"Generated {len(sgsi_files)} SGSI infrastructure files")
        
        print(f"Generation complete! Total files: {len(policy_files) + len(role_files) + len(sgsi_files)}")
        return policy_files + role_files + sgsi_files

    def generate_sgsi_infrastructure(self):
        """Generate SGSI Infrastructure (Layer 3) from definitions"""
        print("🖥️ Generating SGSI Layer 3 Infrastructure...")
        generated_files = []
        
        # Generate shared data sources first
        shared_data_sources = self.generate_shared_data_sources()
        if shared_data_sources:
            generated_files.append(shared_data_sources)
        
        # Generate compute infrastructure
        compute_dir = self.definitions_dir / "compute"
        if not compute_dir.exists():
            print("⚠️  No compute definitions found, skipping SGSI infrastructure generation")
            return generated_files
        
        # Generate ALB
        alb_dir = compute_dir / "load-balancers"
        if alb_dir.exists():
            for alb_file in alb_dir.glob("*.yaml"):
                print(f"🔄 Processing ALB: {alb_file.name}")
                definition = self.load_yaml_definition(alb_file)
                if definition and 'alb' in definition:
                    tf_content = self.generate_alb_terraform(definition, alb_file.name)
                    output_file = self.generated_dir / f"compute-alb-{alb_file.stem}.tf"
                    
                    with open(output_file, 'w', encoding='utf-8') as f:
                        f.write(tf_content)
                    
                    generated_files.append(output_file)
                    print(f"✅ Generated: {output_file}")

        # Generate EC2
        ec2_dir = compute_dir / "instances"
        if ec2_dir.exists():
            for ec2_file in ec2_dir.glob("*.yaml"):
                print(f"🔄 Processing EC2: {ec2_file.name}")
                definition = self.load_yaml_definition(ec2_file)
                if definition and 'ec2_instances' in definition:
                    tf_content = self.generate_ec2_terraform(definition, ec2_file.name)
                    output_file = self.generated_dir / f"compute-ec2-{ec2_file.stem}.tf"
                    
                    with open(output_file, 'w', encoding='utf-8') as f:
                        f.write(tf_content)
                    
                    generated_files.append(output_file)
                    print(f"✅ Generated: {output_file}")

        # Generate RDS
        rds_dir = compute_dir / "databases"
        if rds_dir.exists():
            for rds_file in rds_dir.glob("*.yaml"):
                print(f"🔄 Processing RDS: {rds_file.name}")
                definition = self.load_yaml_definition(rds_file)
                if definition and 'rds' in definition:
                    tf_content = self.generate_rds_terraform(definition, rds_file.name)
                    output_file = self.generated_dir / f"compute-rds-{rds_file.stem}.tf"
                    
                    with open(output_file, 'w', encoding='utf-8') as f:
                        f.write(tf_content)
                    
                    generated_files.append(output_file)
                    print(f"✅ Generated: {output_file}")

        # Generate Lambda
        lambda_dir = compute_dir / "lambda"
        if lambda_dir.exists():
            for lambda_file in lambda_dir.glob("*.yaml"):
                print(f"🔄 Processing Lambda: {lambda_file.name}")
                definition = self.load_yaml_definition(lambda_file)
                if definition and 'lambda_functions' in definition:
                    tf_content = self.generate_lambda_terraform(definition, lambda_file.name)
                    output_file = self.generated_dir / f"compute-lambda-{lambda_file.stem}.tf"
                    
                    with open(output_file, 'w', encoding='utf-8') as f:
                        f.write(tf_content)
                    
                    generated_files.append(output_file)
                    print(f"✅ Generated: {output_file}")

        # Generate Auto Scaling
        asg_dir = compute_dir / "auto-scaling"
        if asg_dir.exists():
            for asg_file in asg_dir.glob("*.yaml"):
                print(f"🔄 Processing ASG: {asg_file.name}")
                definition = self.load_yaml_definition(asg_file)
                if definition and 'auto_scaling' in definition:
                    tf_content = self.generate_asg_terraform(definition, asg_file.name)
                    output_file = self.generated_dir / f"compute-asg-{asg_file.stem}.tf"
                    
                    with open(output_file, 'w', encoding='utf-8') as f:
                        f.write(tf_content)
                    
                    generated_files.append(output_file)
                    print(f"✅ Generated: {output_file}")
        
        return generated_files

    def generate_shared_data_sources(self):
        """Generate shared data sources to avoid duplicates"""
        output_file = self.generated_dir / "compute-shared-data-sources.tf"
        
        content = '''# Shared Data Sources for SGSI Layer 3
# Generated: 2025-10-18
# This file contains all shared data sources to avoid duplicates

# VPC DATA SOURCE
data "aws_vpc" "sgsi_vpc_main" {
  filter {
    name   = "tag:Name"
    values = ["sgsi-vpc-main"]
  }
}

# SUBNET DATA SOURCES - DMZ (Public)
data "aws_subnet" "sgsi_dmz_subnet_us_east_1a" {
  filter {
    name   = "tag:Name"
    values = ["sgsi-dmz-subnet-us-east-1a"]
  }
}

data "aws_subnet" "sgsi_dmz_subnet_us_east_1b" {
  filter {
    name   = "tag:Name"
    values = ["sgsi-dmz-subnet-us-east-1b"]
  }
}

data "aws_subnet" "sgsi_dmz_subnet_us_east_1c" {
  filter {
    name   = "tag:Name"
    values = ["sgsi-dmz-subnet-us-east-1c"]
  }
}

# SUBNET DATA SOURCES - App (Private)
data "aws_subnet" "sgsi_app_subnet_us_east_1a" {
  filter {
    name   = "tag:Name"
    values = ["sgsi-app-subnet-us-east-1a"]
  }
}

data "aws_subnet" "sgsi_app_subnet_us_east_1b" {
  filter {
    name   = "tag:Name"
    values = ["sgsi-app-subnet-us-east-1b"]
  }
}

data "aws_subnet" "sgsi_app_subnet_us_east_1c" {
  filter {
    name   = "tag:Name"
    values = ["sgsi-app-subnet-us-east-1c"]
  }
}

# SUBNET DATA SOURCES - DB (Isolated)
data "aws_subnet" "sgsi_db_subnet_us_east_1a" {
  filter {
    name   = "tag:Name"
    values = ["sgsi-db-subnet-us-east-1a"]
  }
}

data "aws_subnet" "sgsi_db_subnet_us_east_1b" {
  filter {
    name   = "tag:Name"
    values = ["sgsi-db-subnet-us-east-1b"]
  }
}

data "aws_subnet" "sgsi_db_subnet_us_east_1c" {
  filter {
    name   = "tag:Name"
    values = ["sgsi-db-subnet-us-east-1c"]
  }
}

# SECURITY GROUP DATA SOURCES
data "aws_security_group" "sgsi_alb_sg" {
  filter {
    name   = "tag:Name"
    values = ["sgsi-alb-sg"]
  }
}

data "aws_security_group" "sgsi_web_sg" {
  filter {
    name   = "tag:Name"
    values = ["sgsi-web-sg"]
  }
}

data "aws_security_group" "sgsi_app_sg" {
  filter {
    name   = "tag:Name"
    values = ["sgsi-app-sg"]
  }
}

data "aws_security_group" "sgsi_db_sg" {
  filter {
    name   = "tag:Name"
    values = ["sgsi-db-sg"]
  }
}

data "aws_security_group" "sgsi_lambda_sg" {
  filter {
    name   = "tag:Name"
    values = ["sgsi-lambda-sg"]
  }
}

# LAUNCH TEMPLATE DATA SOURCE
data "aws_launch_template" "sgsi_web_server_template" {
  name = "sgsi-web-server-template"
}
'''
        
        with open(output_file, 'w', encoding='utf-8') as f:
            f.write(content)
        
        print(f"✅ Generated shared data sources: {output_file}")
        return output_file

    def generate_alb_terraform(self, definition, source_file):
        """Generate Terraform for Application Load Balancer"""
        alb_config = definition['alb']
        name = alb_config['name']
        spec = alb_config['configuration']
        
        content = f'''# ALB Terraform generated from {source_file}
# Application Load Balancer for SGSI Layer 3

resource "aws_lb" "{name.replace('-', '_')}" {{
  name               = "{name}"
  internal           = {str(spec.get('internal', False)).lower()}
  load_balancer_type = "application"
  security_groups    = [data.aws_security_group.sgsi_alb_sg.id]
  subnets            = [
    data.aws_subnet.sgsi_public_subnet_1.id,
    data.aws_subnet.sgsi_public_subnet_2.id
  ]

  enable_deletion_protection = {str(spec.get('enable_deletion_protection', False)).lower()}

  tags = {{
    Name        = "{name}"
    Environment = "{spec.get('environment', 'dev')}"
    Layer       = "3-compute"
    Component   = "alb"
    Proposito   = "{spec.get('purpose', 'sgsi-web-load-balancer')}"
  }}
}}

resource "aws_lb_target_group" "{name.replace('-', '_')}_tg" {{
  name     = "{name}-tg"
  port     = {spec.get('target_group', {}).get('port', 80)}
  protocol = "{spec.get('target_group', {}).get('protocol', 'HTTP')}"
  vpc_id   = data.aws_vpc.sgsi_main_vpc.id

  health_check {{
    enabled             = true
    healthy_threshold   = {spec.get('health_check', {}).get('healthy_threshold', 3)}
    interval            = {spec.get('health_check', {}).get('interval', 30)}
    matcher             = "{spec.get('health_check', {}).get('matcher', '200')}"
    path                = "{spec.get('health_check', {}).get('path', '/health')}"
    port                = "traffic-port"
    protocol            = "{spec.get('target_group', {}).get('protocol', 'HTTP')}"
    timeout             = {spec.get('health_check', {}).get('timeout', 5)}
    unhealthy_threshold = {spec.get('health_check', {}).get('unhealthy_threshold', 3)}
  }}

  tags = {{
    Name        = "{name}-tg"
    Environment = "{spec.get('environment', 'dev')}"
    Layer       = "3-compute"
    Component   = "alb-target-group"
  }}
}}

resource "aws_lb_listener" "{name.replace('-', '_')}_listener" {{
  load_balancer_arn = aws_lb.{name.replace('-', '_')}.arn
  port              = "{spec.get('listeners', [{}])[0].get('port', 80)}"
  protocol          = "{spec.get('listeners', [{}])[0].get('protocol', 'HTTP')}"

  default_action {{
    type             = "forward"
    target_group_arn = aws_lb_target_group.{name.replace('-', '_')}_tg.arn
  }}

  tags = {{
    Name        = "{name}-listener"
    Environment = "{spec.get('environment', 'dev')}"
    Layer       = "3-compute"
    Component   = "alb-listener"
  }}
}}
'''

        return content

    def generate_ec2_terraform(self, definition, source_file):
        """Generate Terraform for EC2 instances"""
        ec2_config = definition['ec2_instances']
        name = ec2_config['name']
        spec = ec2_config
        
        content = f'''# EC2 Terraform generated from {source_file}
# EC2 Web Servers for SGSI Layer 3

# Launch Template for Web Servers
resource "aws_launch_template" "sgsi_web_server_template" {{
  name_prefix   = "sgsi-web-server-"
  image_id      = "{spec.get('ami_id', 'ami-0abcdef1234567890')}"
  instance_type = "{spec.get('instance_type', 't3.micro')}"
  
  vpc_security_group_ids = [data.aws_security_group.sgsi_web_sg.id]
  
  user_data = base64encode(<<-EOF
    #!/bin/bash
    yum update -y
    yum install -y httpd
    systemctl start httpd
    systemctl enable httpd
    
    # Create health check endpoint
    echo "<h1>SGSI Web Server</h1>" > /var/www/html/index.html
    echo "OK" > /var/www/html/health
    
    # Install CloudWatch Agent
    yum install -y amazon-cloudwatch-agent
    
    # Configure CloudWatch monitoring
    cat > /opt/aws/amazon-cloudwatch-agent/etc/amazon-cloudwatch-agent.json <<EOL
    {{
      "metrics": {{
        "namespace": "SGSI/EC2",
        "metrics_collected": {{
          "cpu": {{"measurement": ["cpu_usage_idle", "cpu_usage_iowait", "cpu_usage_user", "cpu_usage_system"]}},
          "disk": {{"measurement": ["used_percent"], "resources": ["*"]}},
          "mem": {{"measurement": ["mem_used_percent"]}}
        }}
      }}
    }}
EOL
    
    /opt/aws/amazon-cloudwatch-agent/bin/amazon-cloudwatch-agent-ctl \\
      -a fetch-config -m ec2 -c file:/opt/aws/amazon-cloudwatch-agent/etc/amazon-cloudwatch-agent.json -s
  EOF
  )

  iam_instance_profile {{
    name = aws_iam_instance_profile.sgsi_ec2_profile.name
  }}

  tag_specifications {{
    resource_type = "instance"
    tags = {{
      Name        = "{name}"
      Environment = "{spec.get('environment', 'dev')}"
      Layer       = "3-compute"
      Component   = "web-server"
      Proposito   = "{spec.get('purpose', 'sgsi-web-application')}"
    }}
  }}

  tags = {{
    Name        = "sgsi-web-server-template"
    Environment = "{spec.get('environment', 'dev')}"
    Layer       = "3-compute"
  }}
}}

# IAM Role for EC2 instances
resource "aws_iam_role" "sgsi_ec2_role" {{
  name = "sgsi-ec2-cloudwatch-role"

  assume_role_policy = jsonencode({{
    Version = "2012-10-17"
    Statement = [
      {{
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {{
          Service = "ec2.amazonaws.com"
        }}
      }}
    ]
  }})

  tags = {{
    Name        = "sgsi-ec2-cloudwatch-role"
    Environment = "{spec.get('environment', 'dev')}"
    Layer       = "3-compute"
  }}
}}

# IAM Policy for CloudWatch
resource "aws_iam_role_policy_attachment" "sgsi_ec2_cloudwatch" {{
  policy_arn = "arn:aws:iam::aws:policy/CloudWatchAgentServerPolicy"
  role       = aws_iam_role.sgsi_ec2_role.name
}}

# Instance Profile
resource "aws_iam_instance_profile" "sgsi_ec2_profile" {{
  name = "sgsi-ec2-profile"
  role = aws_iam_role.sgsi_ec2_role.name

  tags = {{
    Name        = "sgsi-ec2-profile"
    Environment = "{spec.get('environment', 'dev')}"
    Layer       = "3-compute"
  }}
}}
'''

        return content

    def generate_rds_terraform(self, definition, source_file):
        """Generate Terraform for RDS"""
        rds_config = definition['rds']
        name = rds_config['name']
        spec = rds_config
        
        content = f'''# RDS Terraform generated from {source_file}
# MySQL Database for SGSI Layer 3

# DB Subnet Group
resource "aws_db_subnet_group" "sgsi_db_subnet_group" {{
  name       = "sgsi-db-subnet-group"
  subnet_ids = [
    data.aws_subnet.sgsi_private_subnet_1.id,
    data.aws_subnet.sgsi_private_subnet_2.id
  ]

  tags = {{
    Name        = "sgsi-db-subnet-group"
    Environment = "{spec.get('environment', 'dev')}"
    Layer       = "3-compute"
    Component   = "database"
  }}
}}

# DB Parameter Group
resource "aws_db_parameter_group" "sgsi_mysql_params" {{
  family = "mysql8.0"
  name   = "sgsi-mysql-params"

  parameter {{
    name  = "innodb_buffer_pool_size"
    value = "{{DBInstanceClassMemory*3/4}}"
  }}

  parameter {{
    name  = "max_connections"
    value = "1000"
  }}

  tags = {{
    Name        = "sgsi-mysql-params"
    Environment = "{spec.get('environment', 'dev')}"
    Layer       = "3-compute"
  }}
}}

# RDS Instance
resource "aws_db_instance" "{name.replace('-', '_')}" {{
  identifier     = "{name}"
  engine         = "{spec.get('engine', 'mysql')}"
  engine_version = "{spec.get('engine_version', '8.0')}"
  instance_class = "{spec.get('instance_class', 'db.t3.micro')}"
  
  allocated_storage     = {spec.get('allocated_storage', 20)}
  max_allocated_storage = {spec.get('max_allocated_storage', 100)}
  storage_type          = "{spec.get('storage_type', 'gp2')}"
  storage_encrypted     = {str(spec.get('storage_encrypted', True)).lower()}
  
  db_name  = "{spec.get('database_name', 'sgsidb')}"
  username = "{spec.get('master_username', 'admin')}"
  password = "{spec.get('master_password', 'ChangeMe123!')}"
  
  vpc_security_group_ids = [data.aws_security_group.sgsi_db_sg.id]
  db_subnet_group_name   = aws_db_subnet_group.sgsi_db_subnet_group.name
  parameter_group_name   = aws_db_parameter_group.sgsi_mysql_params.name
  
  multi_az               = {str(spec.get('multi_az', True)).lower()}
  publicly_accessible    = {str(spec.get('publicly_accessible', False)).lower()}
  backup_retention_period = {spec.get('backup_retention_period', 7)}
  backup_window          = "{spec.get('backup_window', '03:00-04:00')}"
  maintenance_window     = "{spec.get('maintenance_window', 'sun:04:00-sun:05:00')}"
  
  deletion_protection = {str(spec.get('deletion_protection', False)).lower()}
  skip_final_snapshot = {str(spec.get('skip_final_snapshot', False)).lower()}
  final_snapshot_identifier = "{name}-final-snapshot"
  
  # Performance Insights
  performance_insights_enabled = {str(spec.get('performance_insights_enabled', True)).lower()}
  performance_insights_retention_period = {spec.get('performance_insights_retention_period', 7)}
  
  # Enhanced monitoring
  monitoring_interval = {spec.get('monitoring_interval', 60)}
  monitoring_role_arn = aws_iam_role.sgsi_rds_monitoring_role.arn
  
  enabled_cloudwatch_logs_exports = {spec.get('enabled_cloudwatch_logs_exports', '["error", "general", "slow_query"]')}
  
  tags = {{
    Name        = "{name}"
    Environment = "{spec.get('environment', 'dev')}"
    Layer       = "3-compute"
    Component   = "database"
    Proposito   = "{spec.get('purpose', 'sgsi-application-database')}"
  }}
}}

# IAM Role for Enhanced Monitoring
resource "aws_iam_role" "sgsi_rds_monitoring_role" {{
  name = "sgsi-rds-monitoring-role"

  assume_role_policy = jsonencode({{
    Version = "2012-10-17"
    Statement = [
      {{
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {{
          Service = "monitoring.rds.amazonaws.com"
        }}
      }}
    ]
  }})

  tags = {{
    Name        = "sgsi-rds-monitoring-role"
    Environment = "{spec.get('environment', 'dev')}"
    Layer       = "3-compute"
  }}
}}

resource "aws_iam_role_policy_attachment" "sgsi_rds_monitoring" {{
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonRDSEnhancedMonitoringRole"
  role       = aws_iam_role.sgsi_rds_monitoring_role.name
}}
'''

        return content

    def generate_lambda_terraform(self, definition, source_file):
        """Generate Terraform for Lambda"""
        lambda_config = definition['lambda_functions']
        name = lambda_config['name']
        spec = lambda_config
        
        content = f'''# Lambda Terraform generated from {source_file}
# Lambda Functions for SGSI Layer 3

# Lambda Function 1: API Handler
resource "aws_lambda_function" "sgsi_api_handler" {{
  filename         = "api_handler.zip"
  function_name    = "sgsi-api-handler"
  role            = aws_iam_role.sgsi_lambda_role.arn
  handler         = "index.handler"
  source_code_hash = filebase64sha256("api_handler.zip")
  runtime         = "{spec.get('runtime', 'python3.9')}"
  timeout         = {spec.get('timeout', 30)}
  memory_size     = {spec.get('memory_size', 128)}

  vpc_config {{
    subnet_ids         = [
      data.aws_subnet.sgsi_private_subnet_1.id,
      data.aws_subnet.sgsi_private_subnet_2.id
    ]
    security_group_ids = [data.aws_security_group.sgsi_lambda_sg.id]
  }}

  environment {{
    variables = {{
      ENVIRONMENT = "{spec.get('environment', 'dev')}"
      DB_HOST     = aws_db_instance.{spec.get('database_instance', 'sgsi_main_database').replace('-', '_')}.endpoint
      DB_NAME     = "{spec.get('database_name', 'sgsidb')}"
    }}
  }}

  tags = {{
    Name        = "sgsi-api-handler"
    Environment = "{spec.get('environment', 'dev')}"
    Layer       = "3-compute"
    Component   = "lambda"
    Proposito   = "{spec.get('purpose', 'sgsi-api-processing')}"
  }}
}}

# Lambda Function 2: Data Processor
resource "aws_lambda_function" "sgsi_data_processor" {{
  filename         = "data_processor.zip"
  function_name    = "sgsi-data-processor"
  role            = aws_iam_role.sgsi_lambda_role.arn
  handler         = "processor.handler"
  source_code_hash = filebase64sha256("data_processor.zip")
  runtime         = "{spec.get('runtime', 'python3.9')}"
  timeout         = {spec.get('timeout', 300)}
  memory_size     = {spec.get('memory_size', 512)}

  vpc_config {{
    subnet_ids         = [
      data.aws_subnet.sgsi_private_subnet_1.id,
      data.aws_subnet.sgsi_private_subnet_2.id
    ]
    security_group_ids = [data.aws_security_group.sgsi_lambda_sg.id]
  }}

  environment {{
    variables = {{
      ENVIRONMENT = "{spec.get('environment', 'dev')}"
      DB_HOST     = aws_db_instance.{spec.get('database_instance', 'sgsi_main_database').replace('-', '_')}.endpoint
      DB_NAME     = "{spec.get('database_name', 'sgsidb')}"
    }}
  }}

  tags = {{
    Name        = "sgsi-data-processor"
    Environment = "{spec.get('environment', 'dev')}"
    Layer       = "3-compute"
    Component   = "lambda"
    Proposito   = "{spec.get('purpose', 'sgsi-data-processing')}"
  }}
}}

# IAM Role for Lambda
resource "aws_iam_role" "sgsi_lambda_role" {{
  name = "sgsi-lambda-execution-role"

  assume_role_policy = jsonencode({{
    Version = "2012-10-17"
    Statement = [
      {{
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {{
          Service = "lambda.amazonaws.com"
        }}
      }}
    ]
  }})

  tags = {{
    Name        = "sgsi-lambda-execution-role"
    Environment = "{spec.get('environment', 'dev')}"
    Layer       = "3-compute"
  }}
}}

# Lambda VPC Execution Policy
resource "aws_iam_role_policy_attachment" "sgsi_lambda_vpc_execution" {{
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaVPCAccessExecutionRole"
  role       = aws_iam_role.sgsi_lambda_role.name
}}

# CloudWatch Logs Policy
resource "aws_iam_role_policy_attachment" "sgsi_lambda_logs" {{
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
  role       = aws_iam_role.sgsi_lambda_role.name
}}

# CloudWatch Log Groups
resource "aws_cloudwatch_log_group" "sgsi_api_handler_logs" {{
  name              = "/aws/lambda/sgsi-api-handler"
  retention_in_days = {spec.get('log_retention_days', 14)}

  tags = {{
    Name        = "sgsi-api-handler-logs"
    Environment = "{spec.get('environment', 'dev')}"
    Layer       = "3-compute"
  }}
}}

resource "aws_cloudwatch_log_group" "sgsi_data_processor_logs" {{
  name              = "/aws/lambda/sgsi-data-processor"
  retention_in_days = {spec.get('log_retention_days', 14)}

  tags = {{
    Name        = "sgsi-data-processor-logs"
    Environment = "{spec.get('environment', 'dev')}"
    Layer       = "3-compute"
  }}
}}
'''

        return content

    def generate_asg_terraform(self, definition, source_file):
        """Generate Terraform for Auto Scaling Group"""
        asg_config = definition['auto_scaling']
        name = asg_config['name']
        spec = asg_config
        
        content = f'''# ASG Terraform generated from {source_file}
# Auto Scaling Group for SGSI Layer 3

resource "aws_autoscaling_group" "{name.replace('-', '_')}" {{
  name                = "{name}"
  vpc_zone_identifier = [
    data.aws_subnet.sgsi_private_subnet_1.id,
    data.aws_subnet.sgsi_private_subnet_2.id
  ]
  target_group_arns   = [aws_lb_target_group.sgsi_main_alb_tg.arn]
  health_check_type   = "ELB"
  health_check_grace_period = {spec.get('health_check_grace_period', 300)}

  min_size         = {spec.get('min_size', 2)}
  max_size         = {spec.get('max_size', 6)}
  desired_capacity = {spec.get('desired_capacity', 2)}

  launch_template {{
    id      = data.aws_launch_template.sgsi_web_server_template.id
    version = "$Latest"
  }}

  # Instance refresh settings
  instance_refresh {{
    strategy = "Rolling"
    preferences {{
      min_healthy_percentage = 50
    }}
  }}

  tag {{
    key                 = "Name"
    value               = "{name}"
    propagate_at_launch = true
  }}

  tag {{
    key                 = "Environment"
    value               = "{spec.get('environment', 'dev')}"
    propagate_at_launch = true
  }}

  tag {{
    key                 = "Layer"
    value               = "3-compute"
    propagate_at_launch = true
  }}

  tag {{
    key                 = "Component"
    value               = "web-server"
    propagate_at_launch = true
  }}

  tag {{
    key                 = "Proposito"
    value               = "{spec.get('purpose', 'sgsi-web-application')}"
    propagate_at_launch = true
  }}
}}

# Auto Scaling Policy - Scale Up
resource "aws_autoscaling_policy" "sgsi_scale_up" {{
  name                   = "sgsi-scale-up"
  scaling_adjustment     = {spec.get('scale_up_adjustment', 1)}
  adjustment_type        = "ChangeInCapacity"
  cooldown               = {spec.get('cooldown', 300)}
  autoscaling_group_name = aws_autoscaling_group.{name.replace('-', '_')}.name
}}

# Auto Scaling Policy - Scale Down
resource "aws_autoscaling_policy" "sgsi_scale_down" {{
  name                   = "sgsi-scale-down"
  scaling_adjustment     = {spec.get('scale_down_adjustment', -1)}
  adjustment_type        = "ChangeInCapacity"
  cooldown               = {spec.get('cooldown', 300)}
  autoscaling_group_name = aws_autoscaling_group.{name.replace('-', '_')}.name
}}

# CloudWatch Alarm - High CPU
resource "aws_cloudwatch_metric_alarm" "sgsi_high_cpu" {{
  alarm_name          = "sgsi-high-cpu"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "2"
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = "120"
  statistic           = "Average"
  threshold           = "{spec.get('high_cpu_threshold', 70)}"
  alarm_description   = "This metric monitors ec2 cpu utilization"
  alarm_actions       = [aws_autoscaling_policy.sgsi_scale_up.arn]

  dimensions = {{
    AutoScalingGroupName = aws_autoscaling_group.{name.replace('-', '_')}.name
  }}

  tags = {{
    Name        = "sgsi-high-cpu-alarm"
    Environment = "{spec.get('environment', 'dev')}"
    Layer       = "3-compute"
  }}
}}

# CloudWatch Alarm - Low CPU
resource "aws_cloudwatch_metric_alarm" "sgsi_low_cpu" {{
  alarm_name          = "sgsi-low-cpu"
  comparison_operator = "LessThanThreshold"
  evaluation_periods  = "2"
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = "120"
  statistic           = "Average"
  threshold           = "{spec.get('low_cpu_threshold', 30)}"
  alarm_description   = "This metric monitors ec2 cpu utilization"
  alarm_actions       = [aws_autoscaling_policy.sgsi_scale_down.arn]

  dimensions = {{
    AutoScalingGroupName = aws_autoscaling_group.{name.replace('-', '_')}.name
  }}

  tags = {{
    Name        = "sgsi-low-cpu-alarm"
    Environment = "{spec.get('environment', 'dev')}"
    Layer       = "3-compute"
  }}
}}

# Scheduled Scaling - Business Hours Scale Up
resource "aws_autoscaling_schedule" "sgsi_business_hours_scale_up" {{
  scheduled_action_name  = "sgsi-business-hours-scale-up"
  min_size               = {spec.get('business_hours_min_size', 3)}
  max_size               = {spec.get('max_size', 6)}
  desired_capacity       = {spec.get('business_hours_desired_capacity', 3)}
  recurrence             = "{spec.get('business_hours_start_cron', '0 8 * * MON-FRI')}"
  autoscaling_group_name = aws_autoscaling_group.{name.replace('-', '_')}.name
}}

# Scheduled Scaling - Off Hours Scale Down
resource "aws_autoscaling_schedule" "sgsi_off_hours_scale_down" {{
  scheduled_action_name  = "sgsi-off-hours-scale-down"
  min_size               = {spec.get('min_size', 2)}
  max_size               = {spec.get('max_size', 6)}
  desired_capacity       = {spec.get('desired_capacity', 2)}
  recurrence             = "{spec.get('off_hours_start_cron', '0 18 * * MON-FRI')}"
  autoscaling_group_name = aws_autoscaling_group.{name.replace('-', '_')}.name
}}
'''

        return content

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