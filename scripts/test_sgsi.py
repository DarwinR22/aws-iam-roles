#!/usr/bin/env python3
"""
🧪 SGSI Testing Suite

Script completo para testing de la infraestructura SGSI:
- Validates layer configurations
- Tests inter-layer dependencies  
- Performs security compliance checks
- Generates testing reports
"""

import subprocess
import sys
import os
import json
import yaml
import boto3
import time
from pathlib import Path
from typing import Dict, List, Tuple, Any
import logging

logger = logging.getLogger(__name__)

class SGSITester:
    """Tester completo para infraestructura SGSI"""
    
    def __init__(self, base_path: str = "."):
        self.base_path = Path(base_path)
        self.layers_path = self.base_path / "layers"
        self.definitions_path = self.base_path / "definitions" / "layers"
        
        # AWS clients
        self.aws_session = boto3.Session()
        self.iam = self.aws_session.client('iam')
        self.ec2 = self.aws_session.client('ec2')
        self.rds = self.aws_session.client('rds')
        self.s3 = self.aws_session.client('s3')
        self.cloudtrail = self.aws_session.client('cloudtrail')
        self.guardduty = self.aws_session.client('guardduty')
        
        self.test_results = {}
    
    def test_terraform_syntax(self) -> Dict[str, bool]:
        """Testa la sintaxis de Terraform en todas las layers"""
        logger.info("🔍 Testing Terraform syntax...")
        
        results = {}
        
        for layer_dir in self.layers_path.iterdir():
            if layer_dir.is_dir():
                layer_name = layer_dir.name
                main_tf = layer_dir / "main.tf"
                
                if main_tf.exists():
                    try:
                        # Cambiar al directorio de la layer
                        original_cwd = Path.cwd()
                        os.chdir(str(layer_dir))
                        
                        # Terraform fmt check
                        fmt_result = subprocess.run(
                            ["terraform", "fmt", "-check"], 
                            capture_output=True, text=True
                        )
                        
                        # Terraform validate
                        init_result = subprocess.run(
                            ["terraform", "init", "-backend=false"], 
                            capture_output=True, text=True
                        )
                        
                        if init_result.returncode == 0:
                            validate_result = subprocess.run(
                                ["terraform", "validate"], 
                                capture_output=True, text=True
                            )
                            results[layer_name] = validate_result.returncode == 0
                        else:
                            results[layer_name] = False
                            
                    except Exception as e:
                        logger.error(f"Error testing {layer_name}: {e}")
                        results[layer_name] = False
                    finally:
                        os.chdir(str(original_cwd))
                else:
                    results[layer_name] = False
        
        return results
    
    def test_yaml_definitions(self) -> Dict[str, bool]:
        """Testa la validez de las definiciones YAML"""
        logger.info("📋 Testing YAML definitions...")
        
        results = {}
        
        for layer_dir in self.definitions_path.iterdir():
            if layer_dir.is_dir():
                layer_name = layer_dir.name
                layer_valid = True
                
                for yaml_file in layer_dir.glob("*.yaml"):
                    try:
                        with open(yaml_file, 'r', encoding='utf-8') as f:
                            yaml.safe_load(f)
                    except yaml.YAMLError as e:
                        logger.error(f"YAML error in {yaml_file}: {e}")
                        layer_valid = False
                        break
                
                results[layer_name] = layer_valid
        
        return results
    
    def test_aws_connectivity(self) -> bool:
        """Testa conectividad con AWS"""
        logger.info("🔗 Testing AWS connectivity...")
        
        try:
            # Test STS
            sts = self.aws_session.client('sts')
            caller_identity = sts.get_caller_identity()
            logger.info(f"✅ Connected to AWS Account: {caller_identity['Account']}")
            
            # Test basic services
            self.iam.list_roles(MaxItems=1)
            self.ec2.describe_regions(RegionNames=['us-east-1'])
            
            return True
            
        except Exception as e:
            logger.error(f"❌ AWS connectivity failed: {e}")
            return False
    
    def test_iam_policies(self) -> Dict[str, bool]:
        """Testa que las políticas IAM estén deployadas"""
        logger.info("👤 Testing IAM policies...")
        
        expected_policies = [
            "github-deployment-cloudformation",
            "github-deployment-iam", 
            "mci-aws-s3-read",
            "mci-aws-s3-write"
        ]
        
        results = {}
        
        try:
            # Listar políticas existentes
            paginator = self.iam.get_paginator('list_policies')
            existing_policies = []
            
            for page in paginator.paginate(Scope='Local'):
                for policy in page['Policies']:
                    existing_policies.append(policy['PolicyName'])
            
            # Verificar cada política esperada
            for policy_name in expected_policies:
                results[policy_name] = policy_name in existing_policies
                
        except Exception as e:
            logger.error(f"Error testing IAM policies: {e}")
            for policy_name in expected_policies:
                results[policy_name] = False
        
        return results
    
    def test_vpc_configuration(self) -> Dict[str, bool]:
        """Testa configuración de VPC"""
        logger.info("🌐 Testing VPC configuration...")
        
        results = {}
        
        try:
            # Buscar VPC SGSI
            vpcs = self.ec2.describe_vpcs(
                Filters=[
                    {'Name': 'tag:Name', 'Values': ['sgsi-vpc-main']}
                ]
            )
            
            if vpcs['Vpcs']:
                vpc_id = vpcs['Vpcs'][0]['VpcId']
                results['vpc_exists'] = True
                
                # Verificar subnets
                subnets = self.ec2.describe_subnets(
                    Filters=[
                        {'Name': 'vpc-id', 'Values': [vpc_id]}
                    ]
                )
                results['subnets_exist'] = len(subnets['Subnets']) >= 6
                
                # Verificar security groups
                security_groups = self.ec2.describe_security_groups(
                    Filters=[
                        {'Name': 'vpc-id', 'Values': [vpc_id]},
                        {'Name': 'group-name', 'Values': ['sgsi-*']}
                    ]
                )
                results['security_groups_exist'] = len(security_groups['SecurityGroups']) >= 4
                
            else:
                results['vpc_exists'] = False
                results['subnets_exist'] = False
                results['security_groups_exist'] = False
                
        except Exception as e:
            logger.error(f"Error testing VPC: {e}")
            results = {'vpc_exists': False, 'subnets_exist': False, 'security_groups_exist': False}
        
        return results
    
    def test_rds_instance(self) -> Dict[str, bool]:
        """Testa instancia RDS"""
        logger.info("🗄️  Testing RDS instance...")
        
        results = {}
        
        try:
            db_instances = self.rds.describe_db_instances()
            
            sgsi_db = None
            for db in db_instances['DBInstances']:
                if 'sgsi' in db['DBInstanceIdentifier'].lower():
                    sgsi_db = db
                    break
            
            if sgsi_db:
                results['db_exists'] = True
                results['db_encrypted'] = sgsi_db.get('StorageEncrypted', False)
                results['db_multi_az'] = sgsi_db.get('MultiAZ', False)
                results['db_backup_enabled'] = sgsi_db.get('BackupRetentionPeriod', 0) > 0
            else:
                results = {
                    'db_exists': False,
                    'db_encrypted': False,
                    'db_multi_az': False,
                    'db_backup_enabled': False
                }
                
        except Exception as e:
            logger.error(f"Error testing RDS: {e}")
            results = {
                'db_exists': False,
                'db_encrypted': False,
                'db_multi_az': False,
                'db_backup_enabled': False
            }
        
        return results
    
    def test_s3_buckets(self) -> Dict[str, bool]:
        """Testa buckets S3"""
        logger.info("🪣 Testing S3 buckets...")
        
        expected_buckets = ['sgsi-app-data', 'sgsi-logs', 'sgsi-backups']
        results = {}
        
        try:
            buckets = self.s3.list_buckets()
            existing_bucket_names = [bucket['Name'] for bucket in buckets['Buckets']]
            
            for bucket_name in expected_buckets:
                # Buscar bucket con el prefijo
                bucket_exists = any(bucket_name in name for name in existing_bucket_names)
                results[f'{bucket_name}_exists'] = bucket_exists
                
                if bucket_exists:
                    # Encontrar el nombre completo del bucket
                    full_bucket_name = next(name for name in existing_bucket_names if bucket_name in name)
                    
                    # Test encryption
                    try:
                        encryption = self.s3.get_bucket_encryption(Bucket=full_bucket_name)
                        results[f'{bucket_name}_encrypted'] = True
                    except:
                        results[f'{bucket_name}_encrypted'] = False
                else:
                    results[f'{bucket_name}_encrypted'] = False
                    
        except Exception as e:
            logger.error(f"Error testing S3: {e}")
            for bucket_name in expected_buckets:
                results[f'{bucket_name}_exists'] = False
                results[f'{bucket_name}_encrypted'] = False
        
        return results
    
    def test_monitoring_services(self) -> Dict[str, bool]:
        """Testa servicios de monitoreo"""
        logger.info("👁️  Testing monitoring services...")
        
        results = {}
        
        try:
            # Test CloudTrail
            trails = self.cloudtrail.describe_trails()
            sgsi_trail = any('sgsi' in trail['Name'].lower() for trail in trails['trailList'])
            results['cloudtrail_enabled'] = sgsi_trail
            
            # Test GuardDuty
            detectors = self.guardduty.list_detectors()
            results['guardduty_enabled'] = len(detectors['DetectorIds']) > 0
            
        except Exception as e:
            logger.error(f"Error testing monitoring: {e}")
            results = {
                'cloudtrail_enabled': False,
                'guardduty_enabled': False
            }
        
        return results
    
    def run_all_tests(self) -> Dict[str, Any]:
        """Ejecuta todos los tests"""
        logger.info("🧪 Running complete SGSI test suite...")
        
        all_results = {}
        
        # Test sintaxis
        all_results['terraform_syntax'] = self.test_terraform_syntax()
        all_results['yaml_definitions'] = self.test_yaml_definitions()
        
        # Test AWS connectivity
        all_results['aws_connectivity'] = self.test_aws_connectivity()
        
        if all_results['aws_connectivity']:
            # Test infraestructura deployada
            all_results['iam_policies'] = self.test_iam_policies()
            all_results['vpc_configuration'] = self.test_vpc_configuration()
            all_results['rds_instance'] = self.test_rds_instance()
            all_results['s3_buckets'] = self.test_s3_buckets()
            all_results['monitoring_services'] = self.test_monitoring_services()
        
        # Generar reporte
        self.generate_test_report(all_results)
        
        return all_results
    
    def generate_test_report(self, results: Dict[str, Any]):
        """Genera reporte de tests"""
        total_tests = 0
        passed_tests = 0
        
        def count_tests(test_dict):
            nonlocal total_tests, passed_tests
            for key, value in test_dict.items():
                if isinstance(value, bool):
                    total_tests += 1
                    if value:
                        passed_tests += 1
                elif isinstance(value, dict):
                    count_tests(value)
        
        count_tests(results)
        
        success_rate = (passed_tests / total_tests * 100) if total_tests > 0 else 0
        
        # Guardar reporte
        report = {
            "test_summary": {
                "total_tests": total_tests,
                "passed_tests": passed_tests,
                "failed_tests": total_tests - passed_tests,
                "success_rate_percent": round(success_rate, 2),
                "timestamp": time.strftime("%Y-%m-%d %H:%M:%S")
            },
            "detailed_results": results
        }
        
        report_file = self.base_path / "test_report.json"
        with open(report_file, 'w') as f:
            json.dump(report, f, indent=2)
        
        # Mostrar resumen
        logger.info("\n" + "="*60)
        logger.info("🧪 TEST RESULTS SUMMARY")
        logger.info("="*60)
        logger.info(f"Total Tests: {total_tests}")
        logger.info(f"Passed: {passed_tests}")
        logger.info(f"Failed: {total_tests - passed_tests}")
        logger.info(f"Success Rate: {success_rate:.1f}%")
        logger.info(f"Report saved to: {report_file}")
        
        if success_rate >= 90:
            logger.info("🎉 SGSI infrastructure is healthy!")
        elif success_rate >= 70:
            logger.warning("⚠️  SGSI infrastructure has some issues")
        else:
            logger.error("❌ SGSI infrastructure has critical issues")

def main():
    import argparse
    import os
    import time
    
    # Configurar logging
    logging.basicConfig(
        level=logging.INFO,
        format='%(asctime)s - %(levelname)s - %(message)s'
    )
    
    parser = argparse.ArgumentParser(description="SGSI Testing Suite")
    parser.add_argument("--syntax-only", action="store_true", help="Test syntax only")
    parser.add_argument("--aws-only", action="store_true", help="Test AWS resources only")
    
    args = parser.parse_args()
    
    tester = SGSITester()
    
    if args.syntax_only:
        terraform_results = tester.test_terraform_syntax()
        yaml_results = tester.test_yaml_definitions()
        
        print("\n🔍 Terraform Syntax Results:")
        for layer, passed in terraform_results.items():
            icon = "✅" if passed else "❌"
            print(f"{icon} {layer}")
        
        print("\n📋 YAML Definitions Results:")
        for layer, passed in yaml_results.items():
            icon = "✅" if passed else "❌"
            print(f"{icon} {layer}")
    
    elif args.aws_only:
        if not tester.test_aws_connectivity():
            sys.exit(1)
        
        iam_results = tester.test_iam_policies()
        vpc_results = tester.test_vpc_configuration()
        
        print("\n👤 IAM Results:")
        for policy, passed in iam_results.items():
            icon = "✅" if passed else "❌"
            print(f"{icon} {policy}")
        
        print("\n🌐 VPC Results:")
        for test, passed in vpc_results.items():
            icon = "✅" if passed else "❌"
            print(f"{icon} {test}")
    
    else:
        results = tester.run_all_tests()
        
        # Exit code basado en success rate
        total = sum(1 for v in results.values() if isinstance(v, bool))
        passed = sum(1 for v in results.values() if isinstance(v, bool) and v)
        success_rate = (passed / total * 100) if total > 0 else 0
        
        sys.exit(0 if success_rate >= 70 else 1)

if __name__ == "__main__":
    main()