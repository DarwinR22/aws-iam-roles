#!/usr/bin/env python3
"""
SGSI CLEANUP SCRIPT - AWS RESOURCE DESTROYER
===========================================
Este script elimina TODA la infraestructura AWS del proyecto SGSI
manteniendo el código Git intacto para redeploy rápido.

IMPORTANTE: 
- Git Repository: NO SE TOCA
- AWS Resources: SE ELIMINAN TODOS (excepto IAM básico)
- Terraform State: Se limpia
"""

import boto3
import json
import subprocess
import time
from datetime import datetime

class SGSICleanupManager:
    def __init__(self):
        print("🗑️  SGSI CLEANUP SCRIPT")
        print("=" * 50)
        print("🎯 Objetivo: Eliminar infraestructura AWS costosa")
        print("✅ Git Repository: Se mantiene intacto")
        print("❌ AWS Resources: Se eliminan todos")
        print("=" * 50)
        
        # AWS Clients
        self.ec2 = boto3.client('ec2')
        self.rds = boto3.client('rds')
        self.s3 = boto3.client('s3')
        self.efs = boto3.client('efs')
        self.cloudtrail = boto3.client('cloudtrail')
        self.cloudwatch = boto3.client('cloudwatch')
        self.sns = boto3.client('sns')
        self.autoscaling = boto3.client('autoscaling')
        self.elbv2 = boto3.client('elbv2')
        self.backup = boto3.client('backup')
        
        self.account_id = boto3.client('sts').get_caller_identity()['Account']
        self.resources_deleted = 0
        self.errors = []

    def print_section(self, title):
        print(f"\n🔍 {title}")
        print("-" * 40)

    def print_success(self, message):
        print(f"✅ {message}")
        self.resources_deleted += 1

    def print_error(self, message):
        print(f"❌ {message}")
        self.errors.append(message)

    def print_info(self, message):
        print(f"ℹ️  {message}")

    def delete_s3_buckets(self):
        """Eliminar buckets S3 del proyecto SGSI"""
        self.print_section("ELIMINANDO S3 BUCKETS")
        
        sgsi_buckets = [
            f"sgsi-dev-app-data",
            f"sgsi-dev-backup", 
            f"sgsi-dev-logs"
        ]
        
        for bucket_name in sgsi_buckets:
            try:
                # Verificar si existe
                self.s3.head_bucket(Bucket=bucket_name)
                
                # Vaciar bucket primero
                self.print_info(f"Vaciando bucket: {bucket_name}")
                
                # Eliminar objetos
                paginator = self.s3.get_paginator('list_objects_v2')
                for page in paginator.paginate(Bucket=bucket_name):
                    if 'Contents' in page:
                        objects = [{'Key': obj['Key']} for obj in page['Contents']]
                        if objects:
                            self.s3.delete_objects(
                                Bucket=bucket_name,
                                Delete={'Objects': objects}
                            )
                
                # Eliminar versiones
                paginator = self.s3.get_paginator('list_object_versions')
                for page in paginator.paginate(Bucket=bucket_name):
                    if 'Versions' in page:
                        versions = [{'Key': obj['Key'], 'VersionId': obj['VersionId']} 
                                  for obj in page['Versions']]
                        if versions:
                            self.s3.delete_objects(
                                Bucket=bucket_name,
                                Delete={'Objects': versions}
                            )
                
                # Eliminar bucket
                self.s3.delete_bucket(Bucket=bucket_name)
                self.print_success(f"S3 Bucket eliminado: {bucket_name}")
                
            except Exception as e:
                if "NoSuchBucket" in str(e):
                    self.print_info(f"Bucket no existe: {bucket_name}")
                else:
                    self.print_error(f"Error eliminando bucket {bucket_name}: {e}")

    def delete_rds_instances(self):
        """Eliminar instancias RDS"""
        self.print_section("ELIMINANDO RDS INSTANCES")
        
        try:
            response = self.rds.describe_db_instances()
            
            for db in response['DBInstances']:
                db_id = db['DBInstanceIdentifier']
                if 'sgsi' in db_id.lower():
                    try:
                        # Eliminar sin snapshot final para ahorrar
                        self.rds.delete_db_instance(
                            DBInstanceIdentifier=db_id,
                            SkipFinalSnapshot=True,
                            DeleteAutomatedBackups=True
                        )
                        self.print_success(f"RDS Instance eliminando: {db_id}")
                        
                    except Exception as e:
                        self.print_error(f"Error eliminando RDS {db_id}: {e}")
                        
        except Exception as e:
            self.print_error(f"Error listando RDS: {e}")

    def delete_ec2_resources(self):
        """Eliminar recursos EC2 (instances, ASG, ALB, etc)"""
        self.print_section("ELIMINANDO EC2 RESOURCES")
        
        # Auto Scaling Groups
        try:
            asg_response = self.autoscaling.describe_auto_scaling_groups()
            for asg in asg_response['AutoScalingGroups']:
                if 'sgsi' in asg['AutoScalingGroupName'].lower():
                    try:
                        # Reducir a 0 instancias primero
                        self.autoscaling.update_auto_scaling_group(
                            AutoScalingGroupName=asg['AutoScalingGroupName'],
                            MinSize=0,
                            MaxSize=0,
                            DesiredCapacity=0
                        )
                        
                        # Esperar un poco
                        time.sleep(30)
                        
                        # Eliminar ASG
                        self.autoscaling.delete_auto_scaling_group(
                            AutoScalingGroupName=asg['AutoScalingGroupName'],
                            ForceDelete=True
                        )
                        self.print_success(f"ASG eliminado: {asg['AutoScalingGroupName']}")
                        
                    except Exception as e:
                        self.print_error(f"Error eliminando ASG: {e}")
        except Exception as e:
            self.print_error(f"Error con ASG: {e}")

        # Load Balancers
        try:
            elb_response = self.elbv2.describe_load_balancers()
            for lb in elb_response['LoadBalancers']:
                if 'sgsi' in lb['LoadBalancerName'].lower():
                    try:
                        self.elbv2.delete_load_balancer(LoadBalancerArn=lb['LoadBalancerArn'])
                        self.print_success(f"ALB eliminado: {lb['LoadBalancerName']}")
                    except Exception as e:
                        self.print_error(f"Error eliminando ALB: {e}")
        except Exception as e:
            self.print_error(f"Error con ALB: {e}")

    def delete_efs_filesystems(self):
        """Eliminar sistemas de archivos EFS"""
        self.print_section("ELIMINANDO EFS FILESYSTEMS")
        
        try:
            response = self.efs.describe_file_systems()
            
            for fs in response['FileSystems']:
                fs_id = fs['FileSystemId']
                
                # Verificar si es del proyecto (por tags o nombre)
                try:
                    tags_response = self.efs.describe_tags(FileSystemId=fs_id)
                    is_sgsi = any('sgsi' in tag.get('Value', '').lower() 
                                for tag in tags_response.get('Tags', []))
                    
                    if is_sgsi:
                        # Eliminar mount targets primero
                        mt_response = self.efs.describe_mount_targets(FileSystemId=fs_id)
                        for mt in mt_response['MountTargets']:
                            self.efs.delete_mount_target(MountTargetId=mt['MountTargetId'])
                            self.print_info(f"Mount target eliminado: {mt['MountTargetId']}")
                        
                        # Esperar que se eliminen
                        time.sleep(60)
                        
                        # Eliminar filesystem
                        self.efs.delete_file_system(FileSystemId=fs_id)
                        self.print_success(f"EFS eliminado: {fs_id}")
                        
                except Exception as e:
                    self.print_error(f"Error eliminando EFS {fs_id}: {e}")
                    
        except Exception as e:
            self.print_error(f"Error con EFS: {e}")

    def delete_cloudtrail(self):
        """Eliminar CloudTrail"""
        self.print_section("ELIMINANDO CLOUDTRAIL")
        
        try:
            response = self.cloudtrail.describe_trails()
            
            for trail in response['trailList']:
                trail_name = trail['Name']
                if 'sgsi' in trail_name.lower():
                    try:
                        # Parar logging primero
                        self.cloudtrail.stop_logging(Name=trail_name)
                        # Eliminar trail
                        self.cloudtrail.delete_trail(Name=trail_name)
                        self.print_success(f"CloudTrail eliminado: {trail_name}")
                    except Exception as e:
                        self.print_error(f"Error eliminando CloudTrail {trail_name}: {e}")
                        
        except Exception as e:
            self.print_error(f"Error con CloudTrail: {e}")

    def delete_cloudwatch_resources(self):
        """Eliminar recursos CloudWatch"""
        self.print_section("ELIMINANDO CLOUDWATCH RESOURCES")
        
        # Dashboards
        try:
            response = self.cloudwatch.list_dashboards()
            for dashboard in response['DashboardEntries']:
                if 'sgsi' in dashboard['DashboardName'].lower():
                    try:
                        self.cloudwatch.delete_dashboards(
                            DashboardNames=[dashboard['DashboardName']]
                        )
                        self.print_success(f"Dashboard eliminado: {dashboard['DashboardName']}")
                    except Exception as e:
                        self.print_error(f"Error eliminando dashboard: {e}")
        except Exception as e:
            self.print_error(f"Error con CloudWatch: {e}")

        # Alarms
        try:
            response = self.cloudwatch.describe_alarms()
            sgsi_alarms = [alarm['AlarmName'] for alarm in response['MetricAlarms'] 
                          if 'sgsi' in alarm['AlarmName'].lower()]
            
            if sgsi_alarms:
                self.cloudwatch.delete_alarms(AlarmNames=sgsi_alarms)
                self.print_success(f"Alarms eliminadas: {len(sgsi_alarms)}")
        except Exception as e:
            self.print_error(f"Error eliminando alarms: {e}")

    def delete_sns_topics(self):
        """Eliminar topics SNS"""
        self.print_section("ELIMINANDO SNS TOPICS")
        
        try:
            response = self.sns.list_topics()
            
            for topic in response['Topics']:
                topic_arn = topic['TopicArn']
                if 'sgsi' in topic_arn.lower():
                    try:
                        self.sns.delete_topic(TopicArn=topic_arn)
                        self.print_success(f"SNS Topic eliminado: {topic_arn}")
                    except Exception as e:
                        self.print_error(f"Error eliminando SNS: {e}")
                        
        except Exception as e:
            self.print_error(f"Error con SNS: {e}")

    def delete_vpc_resources(self):
        """Eliminar VPC y recursos de red"""
        self.print_section("ELIMINANDO VPC RESOURCES")
        
        try:
            # Buscar VPCs del proyecto
            response = self.ec2.describe_vpcs()
            
            for vpc in response['Vpcs']:
                vpc_id = vpc['VpcId']
                
                # Verificar si es del proyecto por tags
                vpc_detail = self.ec2.describe_vpcs(VpcIds=[vpc_id])
                tags = vpc_detail['Vpcs'][0].get('Tags', [])
                is_sgsi = any('sgsi' in tag.get('Value', '').lower() for tag in tags)
                
                if is_sgsi:
                    self.print_info(f"Eliminando VPC: {vpc_id}")
                    
                    # Eliminar en orden correcto
                    self._delete_vpc_components(vpc_id)
                    
                    # Finalmente eliminar VPC
                    try:
                        self.ec2.delete_vpc(VpcId=vpc_id)
                        self.print_success(f"VPC eliminado: {vpc_id}")
                    except Exception as e:
                        self.print_error(f"Error eliminando VPC: {e}")
                        
        except Exception as e:
            self.print_error(f"Error con VPC: {e}")

    def _delete_vpc_components(self, vpc_id):
        """Eliminar componentes de VPC en orden correcto"""
        
        # NAT Gateways
        try:
            nat_response = self.ec2.describe_nat_gateways(
                Filters=[{'Name': 'vpc-id', 'Values': [vpc_id]}]
            )
            for nat in nat_response['NatGateways']:
                if nat['State'] != 'deleted':
                    self.ec2.delete_nat_gateway(NatGatewayId=nat['NatGatewayId'])
                    self.print_success(f"NAT Gateway eliminado: {nat['NatGatewayId']}")
        except Exception as e:
            self.print_error(f"Error eliminando NAT Gateways: {e}")

        # Esperar que NAT Gateways se eliminen
        time.sleep(60)

        # Internet Gateway
        try:
            igw_response = self.ec2.describe_internet_gateways(
                Filters=[{'Name': 'attachment.vpc-id', 'Values': [vpc_id]}]
            )
            for igw in igw_response['InternetGateways']:
                # Detach first
                self.ec2.detach_internet_gateway(
                    InternetGatewayId=igw['InternetGatewayId'],
                    VpcId=vpc_id
                )
                # Then delete
                self.ec2.delete_internet_gateway(InternetGatewayId=igw['InternetGatewayId'])
                self.print_success(f"Internet Gateway eliminado: {igw['InternetGatewayId']}")
        except Exception as e:
            self.print_error(f"Error eliminando Internet Gateway: {e}")

        # Subnets
        try:
            subnet_response = self.ec2.describe_subnets(
                Filters=[{'Name': 'vpc-id', 'Values': [vpc_id]}]
            )
            for subnet in subnet_response['Subnets']:
                self.ec2.delete_subnet(SubnetId=subnet['SubnetId'])
                self.print_success(f"Subnet eliminado: {subnet['SubnetId']}")
        except Exception as e:
            self.print_error(f"Error eliminando Subnets: {e}")

        # Security Groups (except default)
        try:
            sg_response = self.ec2.describe_security_groups(
                Filters=[{'Name': 'vpc-id', 'Values': [vpc_id]}]
            )
            for sg in sg_response['SecurityGroups']:
                if sg['GroupName'] != 'default':
                    self.ec2.delete_security_group(GroupId=sg['GroupId'])
                    self.print_success(f"Security Group eliminado: {sg['GroupId']}")
        except Exception as e:
            self.print_error(f"Error eliminando Security Groups: {e}")

    def cleanup_terraform_states(self):
        """Limpiar estados de Terraform"""
        self.print_section("LIMPIANDO TERRAFORM STATES")
        
        layers = ['layers/02-network', 'layers/03-compute', 'layers/04-storage', 'layers/05-observability']
        
        for layer in layers:
            try:
                result = subprocess.run(
                    ['terraform', 'destroy', '-auto-approve'],
                    cwd=layer,
                    capture_output=True,
                    text=True
                )
                
                if result.returncode == 0:
                    self.print_success(f"Terraform destroy exitoso: {layer}")
                else:
                    self.print_error(f"Error en terraform destroy {layer}: {result.stderr}")
                    
            except Exception as e:
                self.print_error(f"Error ejecutando terraform destroy en {layer}: {e}")

    def run_cleanup(self):
        """Ejecutar limpieza completa"""
        print(f"\n🚀 INICIANDO CLEANUP - {datetime.now()}")
        print("=" * 50)
        
        # Orden de eliminación (de dependientes a independientes)
        self.delete_cloudtrail()
        self.delete_cloudwatch_resources() 
        self.delete_sns_topics()
        
        self.delete_ec2_resources()  # ASG, ALB primero
        self.delete_rds_instances()
        self.delete_efs_filesystems()
        self.delete_s3_buckets()
        
        # VPC al final (tiene dependencias)
        time.sleep(120)  # Esperar que otros recursos se eliminen
        self.delete_vpc_resources()
        
        # Cleanup via Terraform
        self.cleanup_terraform_states()
        
        # Resumen final
        print("\n" + "=" * 50)
        print("🎯 CLEANUP COMPLETADO")
        print("=" * 50)
        print(f"✅ Recursos eliminados: {self.resources_deleted}")
        print(f"❌ Errores: {len(self.errors)}")
        
        if self.errors:
            print("\n⚠️  ERRORES ENCONTRADOS:")
            for error in self.errors:
                print(f"  - {error}")
        
        print(f"\n💰 RESULTADO: AWS resources destruidos")
        print(f"✅ Git repository: Intacto para redeploy")
        print(f"🎓 Listo para presentación: Solo redeploy antes")

if __name__ == "__main__":
    print("⚠️  ADVERTENCIA: Este script eliminará TODA la infraestructura AWS")
    print("Git repository se mantiene intacto para redeploy rápido")
    
    confirm = input("\n¿Continuar con la destrucción? (escriba 'DESTRUIR'): ")
    
    if confirm == 'DESTRUIR':
        cleanup = SGSICleanupManager()
        cleanup.run_cleanup()
    else:
        print("❌ Operación cancelada")