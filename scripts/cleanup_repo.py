#!/usr/bin/env python3
"""
🧹 IAM Cleanup Utility
======================

Script para limpiar archivos obsoletos y mantener el repositorio ordenado.

Uso:
    python scripts/cleanup_repo.py --scan      # Escanear archivos obsoletos
    python scripts/cleanup_repo.py --clean     # Limpiar archivos obsoletos
    python scripts/cleanup_repo.py --report    # Generar reporte de limpieza
"""

import os
import json
from pathlib import Path
from datetime import datetime, timedelta
from typing import List, Dict
import argparse

class RepoCleanup:
    def __init__(self, base_path: Path = None):
        self.base_path = base_path or Path(__file__).parent.parent
        
        # Patrones de archivos a limpiar
        self.cleanup_patterns = {
            'obsolete_scripts': [
                '**/create_role_old*.py',
                '**/demo_*.py',
                '**/test_*.py',
                '**/validate_old*.py',
                '**/*_backup.py',
                '**/*_tmp.py'
            ],
            'temp_files': [
                '**/*.tmp',
                '**/*.bak',
                '**/*~',
                '**/.DS_Store',
                '**/Thumbs.db',
                '**/*.pyc',
                '**/__pycache__'
            ],
            'duplicate_docs': [
                '**/README-old*.md',
                '**/ARCHITECTURE-old*.md',
                '**/docs-old/**',
                '**/*_duplicate.md'
            ],
            'log_files': [
                '**/*.log',
                '**/audit_*.json',
                '**/governance_report_*.json'
            ]
        }
        
        # Archivos protegidos (nunca eliminar)
        self.protected_files = [
            'README.md',
            'scripts/create_role_scalable.py',
            'scripts/iam_lint.py',
            'scripts/governance_engine.py',
            'scripts/migrate_catalog.py',
            '.gitignore',
            'CODEOWNERS'
        ]
        
        self.cleanup_results = {
            'scanned': [],
            'cleaned': [],
            'protected': [],
            'errors': []
        }

    def scan_obsolete_files(self) -> Dict[str, List[Path]]:
        """Escanear archivos obsoletos por categoría."""
        obsolete_files = {}
        
        for category, patterns in self.cleanup_patterns.items():
            obsolete_files[category] = []
            
            for pattern in patterns:
                matches = list(self.base_path.glob(pattern))
                for match in matches:
                    if match.is_file() and not self.is_protected_file(match):
                        obsolete_files[category].append(match)
                        self.cleanup_results['scanned'].append(str(match.relative_to(self.base_path)))
        
        return obsolete_files

    def is_protected_file(self, file_path: Path) -> bool:
        """Verificar si un archivo está protegido."""
        relative_path = str(file_path.relative_to(self.base_path))
        
        for protected in self.protected_files:
            if relative_path.endswith(protected) or protected in relative_path:
                return True
        
        return False

    def scan_old_log_files(self, days_old: int = 30) -> List[Path]:
        """Buscar archivos de log antiguos."""
        cutoff_date = datetime.now() - timedelta(days=days_old)
        old_logs = []
        
        for log_pattern in ['**/*.log', '**/audit_*.json', '**/governance_report_*.json']:
            for log_file in self.base_path.glob(log_pattern):
                if log_file.is_file():
                    mod_time = datetime.fromtimestamp(log_file.stat().st_mtime)
                    if mod_time < cutoff_date:
                        old_logs.append(log_file)
        
        return old_logs

    def clean_files(self, files_to_clean: Dict[str, List[Path]], dry_run: bool = True) -> bool:
        """Limpiar archivos obsoletos."""
        total_cleaned = 0
        
        print(f"🧹 {'SIMULANDO' if dry_run else 'EJECUTANDO'} LIMPIEZA")
        print("=" * 50)
        
        for category, files in files_to_clean.items():
            if not files:
                continue
                
            print(f"\n📂 Categoría: {category}")
            print(f"   Archivos encontrados: {len(files)}")
            
            for file_path in files:
                try:
                    if self.is_protected_file(file_path):
                        print(f"🛡️  PROTEGIDO: {file_path.relative_to(self.base_path)}")
                        self.cleanup_results['protected'].append(str(file_path.relative_to(self.base_path)))
                        continue
                    
                    if not dry_run:
                        if file_path.is_file():
                            file_path.unlink()
                        elif file_path.is_dir():
                            import shutil
                            shutil.rmtree(file_path)
                        
                        self.cleanup_results['cleaned'].append(str(file_path.relative_to(self.base_path)))
                        print(f"🗑️  ELIMINADO: {file_path.relative_to(self.base_path)}")
                        total_cleaned += 1
                    else:
                        print(f"🔍 Se eliminaría: {file_path.relative_to(self.base_path)}")
                
                except Exception as e:
                    error_msg = f"Error eliminando {file_path}: {e}"
                    self.cleanup_results['errors'].append(error_msg)
                    print(f"❌ {error_msg}")
        
        print(f"\n✅ Total archivos {'eliminados' if not dry_run else 'a eliminar'}: {total_cleaned}")
        return total_cleaned > 0

    def generate_cleanup_report(self) -> str:
        """Generar reporte de limpieza."""
        report = {
            'timestamp': datetime.now().isoformat(),
            'summary': {
                'scanned': len(self.cleanup_results['scanned']),
                'cleaned': len(self.cleanup_results['cleaned']),
                'protected': len(self.cleanup_results['protected']),
                'errors': len(self.cleanup_results['errors'])
            },
            'details': self.cleanup_results
        }
        
        report_file = self.base_path / 'audit' / f"cleanup_report_{datetime.now().strftime('%Y%m%d_%H%M%S')}.json"
        report_file.parent.mkdir(exist_ok=True)
        
        with open(report_file, 'w', encoding='utf-8') as f:
            json.dump(report, f, indent=2, ensure_ascii=False)
        
        return str(report_file)

    def print_summary(self):
        """Imprimir resumen de limpieza."""
        print("\n" + "="*50)
        print("📊 RESUMEN DE LIMPIEZA")
        print("="*50)
        
        print(f"🔍 Archivos escaneados: {len(self.cleanup_results['scanned'])}")
        print(f"🗑️  Archivos limpiados: {len(self.cleanup_results['cleaned'])}")
        print(f"🛡️  Archivos protegidos: {len(self.cleanup_results['protected'])}")
        print(f"❌ Errores: {len(self.cleanup_results['errors'])}")
        
        if self.cleanup_results['errors']:
            print(f"\n❌ ERRORES:")
            for error in self.cleanup_results['errors']:
                print(f"  • {error}")

def main():
    parser = argparse.ArgumentParser(description='Utilidad de limpieza del repositorio')
    parser.add_argument('--scan', action='store_true', help='Escanear archivos obsoletos')
    parser.add_argument('--clean', action='store_true', help='Limpiar archivos obsoletos')
    parser.add_argument('--report', action='store_true', help='Generar reporte de limpieza')
    parser.add_argument('--dry-run', action='store_true', help='Solo simular, no eliminar archivos')
    parser.add_argument('--days-old', type=int, default=30, help='Días para considerar logs antiguos')
    
    args = parser.parse_args()
    
    cleanup = RepoCleanup()
    
    if args.scan or args.clean:
        print("🧹 UTILIDAD DE LIMPIEZA DEL REPOSITORIO")
        print("=" * 50)
        
        # Escanear archivos obsoletos
        obsolete_files = cleanup.scan_obsolete_files()
        
        # Agregar logs antiguos
        old_logs = cleanup.scan_old_log_files(args.days_old)
        if old_logs:
            obsolete_files['old_logs'] = old_logs
        
        print(f"\n📊 ARCHIVOS OBSOLETOS ENCONTRADOS:")
        total_files = 0
        for category, files in obsolete_files.items():
            if files:
                print(f"  📂 {category}: {len(files)} archivos")
                total_files += len(files)
        
        print(f"\n📈 Total: {total_files} archivos obsoletos")
        
        if args.clean:
            # Limpiar archivos
            cleanup.clean_files(obsolete_files, dry_run=args.dry_run)
        
        if args.report:
            report_file = cleanup.generate_cleanup_report()
            print(f"\n📄 Reporte guardado en: {report_file}")
        
        cleanup.print_summary()
    
    else:
        print("🧹 Utilidad de Limpieza del Repositorio")
        print("Use --scan para escanear archivos obsoletos")
        print("Use --clean para limpiar archivos obsoletos")
        print("Use --help para ver todas las opciones")

if __name__ == "__main__":
    main()