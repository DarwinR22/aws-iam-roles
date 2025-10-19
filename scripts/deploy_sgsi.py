#!/usr/bin/env python3
"""
🚀 SGSI Complete Deployment Script

Este script maneja el deployment completo de toda la infraestructura SGSI:
- Valida prerequisites
- Ejecuta layers en orden correcto
- Maneja rollback en caso de errores
- Genera reportes de deployment
"""

import subprocess
import sys
import os
import json
import time
from pathlib import Path
from typing import Dict, List, Tuple, Optional
import logging

# Configurar logging
logging.basicConfig(
    level=logging.INFO,
    format='%(asctime)s - %(levelname)s - %(message)s',
    handlers=[
        logging.FileHandler('sgsi_deployment.log'),
        logging.StreamHandler()
    ]
)
logger = logging.getLogger(__name__)

class SGSIDeploymentManager:
    """Manejador completo de deployment SGSI"""
    
    def __init__(self, base_path: str = "."):
        self.base_path = Path(base_path)
        self.layers_path = self.base_path / "layers"
        
        # Orden de deployment según dependencias
        self.deployment_order = [
            "01-foundation",
            "02-network", 
            "03-compute",
            "04-storage",
            "05-observability"
        ]
        
        self.deployment_status = {}
        self.start_time = time.time()
    
    def validate_prerequisites(self) -> bool:
        """Valida que todos los prerequisites estén en lugar"""
        logger.info("🔍 Validating prerequisites...")
        
        # Verificar Terraform
        try:
            result = subprocess.run(["terraform", "version"], 
                                  capture_output=True, text=True)
            if result.returncode != 0:
                logger.error("❌ Terraform not found")
                return False
            logger.info(f"✅ Terraform found: {result.stdout.split()[1]}")
        except FileNotFoundError:
            logger.error("❌ Terraform not installed")
            return False
        
        # Verificar AWS CLI
        try:
            result = subprocess.run(["aws", "sts", "get-caller-identity"], 
                                  capture_output=True, text=True)
            if result.returncode != 0:
                logger.error("❌ AWS credentials not configured")
                return False
            caller_info = json.loads(result.stdout)
            logger.info(f"✅ AWS configured for account: {caller_info['Account']}")
        except (FileNotFoundError, json.JSONDecodeError):
            logger.error("❌ AWS CLI not available or not configured")
            return False
        
        # Verificar estructura de layers
        for layer in self.deployment_order:
            layer_path = self.layers_path / layer
            main_tf = layer_path / "main.tf"
            if not main_tf.exists():
                logger.error(f"❌ {layer}/main.tf not found")
                return False
        
        logger.info("✅ All prerequisites validated")
        return True
    
    def deploy_layer(self, layer_name: str) -> Tuple[bool, str]:
        """Deploya una layer específica"""
        logger.info(f"🚀 Deploying layer: {layer_name}")
        
        layer_path = self.layers_path / layer_name
        os.chdir(str(layer_path))
        
        try:
            # Terraform init
            logger.info(f"  📦 Initializing {layer_name}...")
            result = subprocess.run(["terraform", "init"], 
                                  capture_output=True, text=True)
            if result.returncode != 0:
                return False, f"Init failed: {result.stderr}"
            
            # Terraform validate
            logger.info(f"  🔍 Validating {layer_name}...")
            result = subprocess.run(["terraform", "validate"], 
                                  capture_output=True, text=True)
            if result.returncode != 0:
                return False, f"Validation failed: {result.stderr}"
            
            # Terraform plan
            logger.info(f"  📋 Planning {layer_name}...")
            result = subprocess.run(["terraform", "plan", "-out=tfplan"], 
                                  capture_output=True, text=True)
            if result.returncode != 0:
                return False, f"Planning failed: {result.stderr}"
            
            # Terraform apply
            logger.info(f"  ⚡ Applying {layer_name}...")
            result = subprocess.run(["terraform", "apply", "-auto-approve", "tfplan"], 
                                  capture_output=True, text=True)
            if result.returncode != 0:
                return False, f"Apply failed: {result.stderr}"
            
            logger.info(f"✅ {layer_name} deployed successfully")
            return True, "Success"
            
        except Exception as e:
            return False, f"Exception: {str(e)}"
        finally:
            # Volver al directorio base
            os.chdir(str(self.base_path))
    
    def get_layer_outputs(self, layer_name: str) -> Dict:
        """Obtiene outputs de una layer deployada"""
        layer_path = self.layers_path / layer_name
        os.chdir(str(layer_path))
        
        try:
            result = subprocess.run(["terraform", "output", "-json"], 
                                  capture_output=True, text=True)
            if result.returncode == 0:
                return json.loads(result.stdout)
            return {}
        except:
            return {}
        finally:
            os.chdir(str(self.base_path))
    
    def rollback_layer(self, layer_name: str) -> bool:
        """Rollback de una layer en caso de error"""
        logger.warning(f"🔄 Rolling back layer: {layer_name}")
        
        layer_path = self.layers_path / layer_name
        os.chdir(str(layer_path))
        
        try:
            result = subprocess.run(["terraform", "destroy", "-auto-approve"], 
                                  capture_output=True, text=True)
            if result.returncode == 0:
                logger.info(f"✅ {layer_name} rolled back successfully")
                return True
            else:
                logger.error(f"❌ Rollback failed for {layer_name}: {result.stderr}")
                return False
        except Exception as e:
            logger.error(f"❌ Rollback exception for {layer_name}: {str(e)}")
            return False
        finally:
            os.chdir(str(self.base_path))
    
    def deploy_all_layers(self, rollback_on_failure: bool = True) -> bool:
        """Deploya todas las layers en orden"""
        logger.info("🚀 Starting complete SGSI deployment...")
        
        if not self.validate_prerequisites():
            logger.error("❌ Prerequisites validation failed")
            return False
        
        deployed_layers = []
        
        for layer_name in self.deployment_order:
            logger.info(f"\n{'='*60}")
            logger.info(f"🏗️  LAYER: {layer_name}")
            logger.info(f"{'='*60}")
            
            success, message = self.deploy_layer(layer_name)
            
            if success:
                deployed_layers.append(layer_name)
                self.deployment_status[layer_name] = {
                    "status": "success",
                    "message": message,
                    "outputs": self.get_layer_outputs(layer_name)
                }
                logger.info(f"✅ {layer_name} completed successfully")
            else:
                logger.error(f"❌ {layer_name} failed: {message}")
                self.deployment_status[layer_name] = {
                    "status": "failed",
                    "message": message,
                    "outputs": {}
                }
                
                if rollback_on_failure:
                    logger.warning("🔄 Starting rollback process...")
                    for deployed_layer in reversed(deployed_layers):
                        self.rollback_layer(deployed_layer)
                
                return False
        
        self.generate_deployment_report()
        logger.info("🎉 SGSI deployment completed successfully!")
        return True
    
    def destroy_all_layers(self) -> bool:
        """Destruye todas las layers en orden inverso"""
        logger.info("🗑️  Starting complete SGSI destruction...")
        
        # Orden inverso para destrucción
        destruction_order = list(reversed(self.deployment_order))
        
        for layer_name in destruction_order:
            logger.info(f"\n🗑️  Destroying layer: {layer_name}")
            if not self.rollback_layer(layer_name):
                logger.error(f"❌ Failed to destroy {layer_name}")
                return False
        
        logger.info("✅ All layers destroyed successfully")
        return True
    
    def generate_deployment_report(self):
        """Genera reporte completo del deployment"""
        duration = time.time() - self.start_time
        
        report = {
            "deployment_summary": {
                "total_duration_seconds": round(duration, 2),
                "total_duration_minutes": round(duration / 60, 2),
                "deployment_timestamp": time.strftime("%Y-%m-%d %H:%M:%S"),
                "total_layers": len(self.deployment_order),
                "successful_layers": len([l for l in self.deployment_status.values() if l["status"] == "success"]),
                "failed_layers": len([l for l in self.deployment_status.values() if l["status"] == "failed"])
            },
            "layer_details": self.deployment_status
        }
        
        # Guardar reporte
        report_file = self.base_path / "deployment_report.json"
        with open(report_file, 'w') as f:
            json.dump(report, f, indent=2)
        
        logger.info(f"📊 Deployment report saved to: {report_file}")
        
        # Mostrar resumen
        logger.info("\n" + "="*60)
        logger.info("📊 DEPLOYMENT SUMMARY")
        logger.info("="*60)
        logger.info(f"Duration: {report['deployment_summary']['total_duration_minutes']:.1f} minutes")
        logger.info(f"Success: {report['deployment_summary']['successful_layers']}/{report['deployment_summary']['total_layers']} layers")
        
        for layer, details in self.deployment_status.items():
            status_icon = "✅" if details["status"] == "success" else "❌"
            logger.info(f"{status_icon} {layer}: {details['status']}")

def main():
    """Función principal"""
    import argparse
    
    parser = argparse.ArgumentParser(description="SGSI Complete Deployment Manager")
    parser.add_argument("--deploy", action="store_true", help="Deploy all layers")
    parser.add_argument("--destroy", action="store_true", help="Destroy all layers")
    parser.add_argument("--layer", type=str, help="Deploy specific layer only")
    parser.add_argument("--no-rollback", action="store_true", help="Don't rollback on failure")
    
    args = parser.parse_args()
    
    manager = SGSIDeploymentManager()
    
    if args.destroy:
        success = manager.destroy_all_layers()
        sys.exit(0 if success else 1)
    
    elif args.layer:
        success, message = manager.deploy_layer(args.layer)
        if success:
            logger.info(f"✅ {args.layer} deployed successfully")
        else:
            logger.error(f"❌ {args.layer} failed: {message}")
        sys.exit(0 if success else 1)
    
    elif args.deploy:
        rollback = not args.no_rollback
        success = manager.deploy_all_layers(rollback_on_failure=rollback)
        sys.exit(0 if success else 1)
    
    else:
        parser.print_help()

if __name__ == "__main__":
    main()