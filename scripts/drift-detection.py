#!/usr/bin/env python3
"""
Enterprise Drift Detection Engine
=================================
Comprehensive solution for detecting and managing infrastructure drift
between Terraform state, source code, and AWS reality.

Author: DevOps Enterprise Team
Version: 1.0.0
"""

import json
import yaml
import boto3
import subprocess
import os
from pathlib import Path
from datetime import datetime
import logging

# Configure logging
logging.basicConfig(
    level=logging.INFO,
    format='%(asctime)s - %(levelname)s - %(message)s'
)
logger = logging.getLogger(__name__)

class DriftDetectionEngine:
    """Enterprise-grade drift detection and reconciliation system"""
    
    def __init__(self, workspace_path: str):
        self.workspace_path = Path(workspace_path)
        self.iam_client = boto3.client('iam')
        self.drift_report = {
            'timestamp': datetime.now().isoformat(),
            'orphaned_resources': [],
            'missing_resources': [],
            'policy_drifts': [],
            'recommendations': []
        }
    
    def scan_source_code_resources(self) -> dict:
        """Scan all role JSON files in gerencias/ directory"""
        logger.info("🔍 Scanning source code for IAM resources...")
        
        source_resources = {
            'roles': {},
            'policies': set()
        }
        
        # Scan role files
        gerencias_path = self.workspace_path / 'gerencias'
        for role_file in gerencias_path.rglob('rol-*.json'):
            try:
                with open(role_file, 'r', encoding='utf-8') as f:
                    role_data = json.load(f)
                    role_name = role_data.get('role_name')
                    if role_name:
                        source_resources['roles'][role_name] = {
                            'file_path': str(role_file),
                            'gerencia': role_data.get('gerencia_code', 'unknown'),
                            'policies': role_data.get('policies', {}).get('mci_managed', [])
                        }
            except Exception as e:
                logger.warning(f"⚠️ Error reading {role_file}: {e}")
        
        # Scan catalog policies
        catalog_path = self.workspace_path / 'catalog' / 'v2'
        for service_file in catalog_path.rglob('*.yaml'):
            try:
                with open(service_file, 'r', encoding='utf-8') as f:
                    service_data = yaml.safe_load(f)
                    if 'policies' in service_data:
                        source_resources['policies'].update(service_data['policies'].keys())
            except Exception as e:
                logger.warning(f"⚠️ Error reading {service_file}: {e}")
        
        logger.info(f"✅ Found {len(source_resources['roles'])} roles and {len(source_resources['policies'])} policies in source")
        return source_resources
    
    def is_cicd_managed_resource(self, role_name: str, role_info: dict) -> bool:
        """
        Determine if a resource was created by CI/CD vs manually created
        
        SITUACION 1: Recursos creados por CI/CD (GitHub Actions + Terraform)
        - Tienen tags específicos (Modulo, Environment, etc.)
        - Siguen convenciones de nombres (rol-mci-, MCI-, etc.)
        - Deben eliminarse automáticamente si se borran del código
        
        SITUACION 2: Recursos creados manualmente (Consola AWS u otros)
        - No tienen nuestros tags de gestión
        - Pueden tener nombres diferentes
        - Solo REPORTAR, NO eliminar automáticamente
        """
        try:
            tags = role_info.get('tags', {})
            
            # Indicadores de gestión por CI/CD
            cicd_indicators = {
                'has_module_tag': tags.get('Modulo') == 'iamroles',
                'has_environment_tag': 'Environment' in tags,
                'has_terraform_tag': any('terraform' in str(v).lower() for v in tags.values()),
                'has_managed_by_tag': 'ManagedBy' in tags,
                'follows_naming_convention': (
                    role_name.startswith('rol-mci-') or
                    role_name.startswith('MCI-') or
                    role_name.startswith('mci-')
                ),
                'has_framework_markers': role_info.get('managed_by_framework', False)
            }
            
            # Cuenta cuántos indicadores de CI/CD tiene
            cicd_score = sum(cicd_indicators.values())
            is_cicd_managed = cicd_score >= 2  # Al menos 2 indicadores
            
            # Log detallado para debugging
            logger.info(f"🔍 {role_name} - CI/CD Analysis:")
            logger.info(f"   📊 Score: {cicd_score}/6 indicators")
            for indicator, value in cicd_indicators.items():
                logger.info(f"   {'✅' if value else '❌'} {indicator}")
            logger.info(f"   🏷️ Decision: {'CI/CD Managed' if is_cicd_managed else 'Manual/External'}")
            
            return is_cicd_managed
            
        except Exception as e:
            logger.warning(f"⚠️ Error analyzing {role_name}: {e}")
            # Si hay error, asumir que es manual (más seguro)
            return False

    def scan_aws_resources(self) -> dict:
        """Scan actual AWS IAM resources"""
        logger.info("🔍 Scanning AWS for IAM resources...")
        
        aws_resources = {
            'roles': {},
            'policies': {}
        }
        
        try:
            # Scan IAM roles with our tags
            paginator = self.iam_client.get_paginator('list_roles')
            for page in paginator.paginate():
                for role in page['Roles']:
                    role_name = role['RoleName']
                    
                    # Skip AWS managed service roles and infrastructure roles
                    if (role_name.startswith('AWSServiceRole') or 
                        role_name.startswith('AWSReservedSSO') or 
                        role_name.startswith('AWSControlTower') or
                        role_name.startswith('aws-controltower') or
                        role_name == 'github-actions-iam-deployment-role'):
                        continue
                    
                    # Get role tags (with error handling for permission issues)
                    try:
                        tags_response = self.iam_client.list_role_tags(RoleName=role_name)
                        tags = {tag['Key']: tag['Value'] for tag in tags_response['Tags']}
                        
                        # Only include roles managed by our framework or following our naming convention
                        if (tags.get('Modulo') == 'iamroles' or 
                            role_name.startswith('rol-') or
                            role_name.startswith('github-actions')):
                            aws_resources['roles'][role_name] = {
                                'arn': role['Arn'],
                                'created': role['CreateDate'].isoformat(),
                                'tags': tags,
                                'managed_by_framework': True
                            }
                    except Exception as e:
                        # For permission errors, check if it follows our naming pattern
                        if role_name.startswith('rol-') or role_name.startswith('github-actions'):
                            logger.info(f"ℹ️ Including role {role_name} based on naming pattern (permission error: {e})")
                            aws_resources['roles'][role_name] = {
                                'arn': role['Arn'],
                                'created': role['CreateDate'].isoformat(),
                                'tags': {},
                                'managed_by_framework': True
                            }
                        else:
                            logger.debug(f"🔒 Skipping role {role_name} due to permission error: {e}")
            
            # Scan managed policies
            policy_paginator = self.iam_client.get_paginator('list_policies')
            for page in policy_paginator.paginate(Scope='Local'):
                for policy in page['Policies']:
                    policy_name = policy['PolicyName']
                    if policy_name.startswith('MCI-'):
                        aws_resources['policies'][policy_name] = {
                            'arn': policy['Arn'],
                            'created': policy['CreateDate'].isoformat(),
                            'version': policy['DefaultVersionId']
                        }
        
        except Exception as e:
            logger.error(f"❌ Error scanning AWS resources: {e}")
            raise
        
        logger.info(f"✅ Found {len(aws_resources['roles'])} roles and {len(aws_resources['policies'])} policies in AWS")
        return aws_resources
    
    def detect_orphaned_resources(self, source_resources: dict, aws_resources: dict):
        """
        Detect resources that exist in AWS but not in source code
        
        SITUACION 1: Recursos gestionados por CI/CD → ELIMINAR automáticamente
        SITUACION 2: Recursos manuales/externos → SOLO REPORTAR
        """
        logger.info("🔍 Detecting orphaned resources...")
        
        # Orphaned roles - con lógica diferenciada
        orphaned_roles = set(aws_resources['roles'].keys()) - set(source_resources['roles'].keys())
        
        for role_name in orphaned_roles:
            role_info = aws_resources['roles'][role_name]
            is_cicd_managed = self.is_cicd_managed_resource(role_name, role_info)
            
            if is_cicd_managed:
                # SITUACION 1: Recurso CI/CD - eliminar automáticamente
                recommendation = 'REMOVE_FROM_STATE_AND_AWS'
                action = '🎯 AUTO-DELETE (Created by CI/CD)'
                logger.warning(f"🎯 {role_name} - CI/CD managed role will be auto-deleted")
            else:
                # SITUACION 2: Recurso manual - solo reportar
                recommendation = 'REPORT_ONLY_MANUAL_RESOURCE'
                action = '⚠️ REPORT ONLY (Created manually)'
                logger.info(f"⚠️ {role_name} - Manual resource detected, will only report")
            
            self.drift_report['orphaned_resources'].append({
                'type': 'role',
                'name': role_name,
                'arn': role_info['arn'],
                'created': role_info['created'],
                'tags': role_info.get('tags', {}),
                'recommendation': recommendation,
                'action': action,
                'managed_by_cicd': is_cicd_managed,
                'reason': 'Resource exists in AWS but not in source code'
            })
        
        # Orphaned policies - similar logic
        orphaned_policies = set(aws_resources['policies'].keys()) - source_resources['policies']
        for policy_name in orphaned_policies:
            policy_info = aws_resources['policies'][policy_name]
            
            # Para políticas, ser más conservador - siempre revisar primero
            is_mci_policy = policy_name.startswith('MCI-')
            if is_mci_policy:
                recommendation = 'REVIEW_USAGE_BEFORE_REMOVAL'
                action = '🔍 REVIEW (MCI managed policy)'
            else:
                recommendation = 'REPORT_ONLY_EXTERNAL_POLICY'
                action = '⚠️ REPORT ONLY (External policy)'
            
            self.drift_report['orphaned_resources'].append({
                'type': 'policy',
                'name': policy_name,
                'arn': policy_info['arn'],
                'created': policy_info['created'],
                'recommendation': recommendation,
                'action': action,
                'managed_by_cicd': is_mci_policy,
                'reason': 'Policy exists in AWS but not in source code'
            })
        
        # Estadísticas detalladas
        cicd_roles = sum(1 for r in self.drift_report['orphaned_resources'] 
                        if r['type'] == 'role' and r['managed_by_cicd'])
        manual_roles = sum(1 for r in self.drift_report['orphaned_resources'] 
                          if r['type'] == 'role' and not r['managed_by_cicd'])
        
        logger.info(f"� DRIFT SUMMARY:")
        logger.info(f"   🎯 CI/CD Roles (will auto-delete): {cicd_roles}")
        logger.info(f"   ⚠️ Manual Roles (report only): {manual_roles}")
        logger.info(f"   📜 Policies (review needed): {len(orphaned_policies)}")
        logger.info(f"   🚨 Total drifts: {len(orphaned_roles) + len(orphaned_policies)}")
    
    def detect_missing_resources(self, source_resources: dict, aws_resources: dict):
        """Detect resources that exist in source but not in AWS"""
        logger.info("🔍 Detecting missing resources...")
        
        missing_roles = set(source_resources['roles'].keys()) - set(aws_resources['roles'].keys())
        for role_name in missing_roles:
            role_info = source_resources['roles'][role_name]
            self.drift_report['missing_resources'].append({
                'type': 'role',
                'name': role_name,
                'file_path': role_info['file_path'],
                'gerencia': role_info['gerencia'],
                'recommendation': 'DEPLOY_MISSING_RESOURCE'
            })
        
        logger.info(f"📋 Found {len(missing_roles)} missing roles in AWS")
    
    def check_terraform_state_exists(self, resource_address: str) -> bool:
        """Check if a resource exists in Terraform state before attempting removal"""
        try:
            # Run terraform state list to get all resources
            result = subprocess.run(
                ['terraform', 'state', 'list'],
                capture_output=True,
                text=True,
                cwd=self.workspace_path
            )
            
            if result.returncode != 0:
                logger.warning(f"⚠️ Could not list Terraform state: {result.stderr}")
                return False
            
            # Check if our resource address exists in the state
            state_resources = result.stdout.strip().split('\n')
            resource_exists = resource_address in state_resources
            
            logger.info(f"🔍 Resource {resource_address} {'exists' if resource_exists else 'NOT FOUND'} in Terraform state")
            return resource_exists
            
        except Exception as e:
            logger.error(f"❌ Error checking Terraform state: {e}")
            return False

    def generate_cleanup_script(self) -> str:
        """
        Generate Terraform cleanup script ONLY for CI/CD managed resources
        
        REGLA DE SEGURIDAD: Solo eliminar recursos que fueron creados por nuestro CI/CD
        """
        cleanup_commands = []
        skipped_manual = []
        
        for resource in self.drift_report['orphaned_resources']:
            if resource['type'] == 'role':
                role_name = resource['name']
                
                # CRITICAL: Never delete essential infrastructure roles
                protected_roles = [
                    'github-actions-iam-deployment-role',
                    'github-actions',
                    'aws-',
                    'AWSServiceRole',
                    'AWSReservedSSO',
                    'AWSControlTower'
                ]
                
                # Check if role is protected
                is_protected = any(role_name.startswith(prefix) for prefix in protected_roles)
                if is_protected:
                    logger.warning(f"🔒 PROTECTED: Skipping cleanup of critical role: {role_name}")
                    continue
                
                # NUEVA LOGICA: Solo eliminar recursos gestionados por CI/CD
                if resource['recommendation'] == 'REMOVE_FROM_STATE_AND_AWS' and resource.get('managed_by_cicd', False):
                    # Check if resource actually exists in Terraform state
                    resource_address = f'module.iam_roles["{role_name}"]'
                    if not self.check_terraform_state_exists(resource_address):
                        logger.info(f"✅ Resource {role_name} already removed from state - skipping cleanup")
                        continue
                    
                    logger.info(f"🎯 CI/CD MANAGED: Adding cleanup for {role_name}")
                    cleanup_commands.append(f'terraform state rm \'{resource_address}\'')
                    # TODO: Implementar eliminación de AWS después de validación
                    # cleanup_commands.append(f'aws iam delete-role --role-name {role_name}')
                    
                elif resource['recommendation'] == 'REPORT_ONLY_MANUAL_RESOURCE':
                    logger.info(f"⚠️ MANUAL RESOURCE: Skipping cleanup for {role_name} (created manually)")
                    skipped_manual.append(role_name)
        
        # Resumen de acciones
        if cleanup_commands:
            logger.info(f"🧹 Will cleanup {len(cleanup_commands)} CI/CD managed resources")
        if skipped_manual:
            logger.info(f"⚠️ Skipped {len(skipped_manual)} manual resources: {', '.join(skipped_manual)}")
        
        return '\n'.join(cleanup_commands)
    
    def save_drift_report(self):
        """Save comprehensive drift report"""
        report_path = self.workspace_path / 'drift-report.json'
        with open(report_path, 'w', encoding='utf-8') as f:
            json.dump(self.drift_report, f, indent=2, ensure_ascii=False)
        
        logger.info(f"📊 Drift report saved to {report_path}")
        return str(report_path)
    
    def run_full_detection(self) -> dict:
        """Run complete drift detection analysis"""
        logger.info("🚀 Starting enterprise drift detection...")
        
        try:
            # Scan both sources
            source_resources = self.scan_source_code_resources()
            aws_resources = self.scan_aws_resources()
            
            # Detect drifts
            self.detect_orphaned_resources(source_resources, aws_resources)
            self.detect_missing_resources(source_resources, aws_resources)
            
            # Generate recommendations
            cleanup_script = self.generate_cleanup_script()
            if cleanup_script:
                self.drift_report['recommendations'].append({
                    'type': 'cleanup_script',
                    'description': 'Terraform commands to clean orphaned resources',
                    'script': cleanup_script
                })
            
            # Save report
            report_path = self.save_drift_report()
            
            logger.info("✅ Drift detection completed successfully")
            return {
                'success': True,
                'report_path': report_path,
                'summary': {
                    'orphaned_resources': len(self.drift_report['orphaned_resources']),
                    'missing_resources': len(self.drift_report['missing_resources']),
                    'total_drifts': len(self.drift_report['orphaned_resources']) + len(self.drift_report['missing_resources'])
                }
            }
        
        except Exception as e:
            logger.error(f"❌ Drift detection failed: {e}")
            return {
                'success': False,
                'error': str(e)
            }

if __name__ == '__main__':
    import sys
    
    workspace_path = sys.argv[1] if len(sys.argv) > 1 else '.'
    
    detector = DriftDetectionEngine(workspace_path)
    result = detector.run_full_detection()
    
    if result['success']:
        print(f"✅ Drift detection completed. Found {result['summary']['total_drifts']} drifts.")
        print(f"📊 Report: {result['report_path']}")
        sys.exit(0)
    else:
        print(f"❌ Drift detection failed: {result['error']}")
        sys.exit(1)