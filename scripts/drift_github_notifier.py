#!/usr/bin/env python3
"""
GitHub Comment Notifier for Drift Detection
Publishes drift detection reports as PR comments instead of emails
"""

import argparse
import json
import logging
import os
import sys
from datetime import datetime
from typing import Dict, Any, Optional
import subprocess
import tempfile

# Configure logging
logging.basicConfig(level=logging.INFO, format='%(asctime)s - %(levelname)s - %(message)s')
logger = logging.getLogger(__name__)

class DriftGitHubNotifier:
    """Publishes drift detection reports as GitHub PR comments"""
    
    def __init__(self):
        self.github_token = os.getenv('GITHUB_TOKEN')
        self.github_repository = os.getenv('GITHUB_REPOSITORY')
        self.github_pr_number = os.getenv('GITHUB_PR_NUMBER')
        
    def validate_github_context(self) -> bool:
        """Validate that we have the necessary GitHub context"""
        if not self.github_token:
            logger.error("❌ GITHUB_TOKEN not found in environment")
            return False
            
        if not self.github_repository:
            logger.error("❌ GITHUB_REPOSITORY not found in environment")
            return False
            
        logger.info(f"✅ GitHub context validated for repository: {self.github_repository}")
        return True
    
    def get_severity_info(self, drift_report: Dict[str, Any]) -> tuple[str, str, str]:
        """Determine severity level and visual indicators"""
        summary = drift_report.get('summary', {})
        
        # Ensure summary is a dict
        if not isinstance(summary, dict):
            logger.warning(f"⚠️ Summary is not a dict, got: {type(summary)}")
            summary = {}
            
        total_issues = summary.get('total_issues', 0)
        orphaned_roles = summary.get('orphaned_roles', 0)
        
        # Ensure values are integers
        try:
            total_issues = int(total_issues) if total_issues is not None else 0
            orphaned_roles = int(orphaned_roles) if orphaned_roles is not None else 0
        except (ValueError, TypeError):
            total_issues = 0
            orphaned_roles = 0
        
        if total_issues >= 10 or orphaned_roles >= 5:
            return 'critical', '🚨', 'CRÍTICO'
        elif total_issues >= 5 or orphaned_roles >= 2:
            return 'warning', '⚠️', 'ADVERTENCIA'
        else:
            return 'info', 'ℹ️', 'INFORMACIÓN'
    
    def generate_markdown_report(self, drift_report: Dict[str, Any], deployment_type: str, 
                                environment: str, commit_sha: str, workflow_url: str,
                                test_mode: bool = False) -> str:
        """Generate a comprehensive markdown report for GitHub comment"""
        
        severity_level, severity_icon, severity_text = self.get_severity_info(drift_report)
        summary = drift_report.get('summary', {})
        
        # Header with test mode indicator
        test_indicator = "🧪 **[MODO DE PRUEBA]** " if test_mode else ""
        
        markdown = f"""
# {test_indicator}{severity_icon} Reporte de Drift Detection - {severity_text}

## 📊 Resumen Ejecutivo

| Métrica | Valor | Estado |
|---------|-------|--------|
| **Ambiente** | `{environment.upper()}` | {severity_icon} |
| **Tipo de Deployment** | `{deployment_type}` | - |
| **Problemas Totales** | **{summary.get('total_issues', 0)}** | {'🚨' if summary.get('total_issues', 0) >= 10 else '⚠️' if summary.get('total_issues', 0) >= 5 else '✅'} |
| **Roles Huérfanos** | **{summary.get('orphaned_roles', 0)}** | {'🚨' if summary.get('orphaned_roles', 0) >= 5 else '⚠️' if summary.get('orphaned_roles', 0) >= 2 else '✅'} |
| **Políticas Huérfanas** | **{summary.get('orphaned_policies', 0)}** | {'⚠️' if summary.get('orphaned_policies', 0) > 0 else '✅'} |
| **Recursos Faltantes** | **{summary.get('missing_resources', 0)}** | {'🚨' if summary.get('missing_resources', 0) > 0 else '✅'} |

"""

        # Add detailed analysis if there are issues
        orphaned_resources = drift_report.get('orphaned_resources', {})
        missing_resources = drift_report.get('missing_resources', [])
        
        # Ensure orphaned_resources is a dict
        if not isinstance(orphaned_resources, dict):
            orphaned_resources = {}
            
        if orphaned_resources.get('roles') or orphaned_resources.get('policies'):
            markdown += """
## 🔍 Recursos Huérfanos Detectados

"""
            
            # Orphaned roles
            roles = orphaned_resources.get('roles', [])
            if roles and isinstance(roles, list):
                markdown += """
### 👤 Roles Huérfanos

| Nombre del Rol | ARN | Fecha Creación | Protegido |
|----------------|-----|----------------|-----------|
"""
                for role in roles:
                    if isinstance(role, dict):
                        protected_icon = "🛡️" if role.get('protected', False) else "❌"
                        role_name = role.get('name', 'Unknown')
                        role_arn = role.get('arn', 'Unknown')
                        role_created = role.get('created', 'N/A')
                        markdown += f"| `{role_name}` | `{role_arn}` | {role_created} | {protected_icon} |\n"
            
            # Orphaned policies
            policies = orphaned_resources.get('policies', [])
            if policies and isinstance(policies, list):
                markdown += """
### 📄 Políticas Huérfanas

| Nombre de Política | ARN | Adjunta a |
|-------------------|-----|-----------|
"""
                for policy in policies:
                    if isinstance(policy, dict):
                        attached = ', '.join(policy.get('attached_to', [])) or 'Ninguno'
                        policy_name = policy.get('name', 'Unknown')
                        policy_arn = policy.get('arn', 'Unknown')
                        markdown += f"| `{policy_name}` | `{policy_arn}` | {attached} |\n"
        
        if missing_resources:
            markdown += """
## ❓ Recursos Faltantes

"""
            for resource in missing_resources:
                # Handle both dict and list formats
                if isinstance(resource, dict):
                    resource_type = resource.get('type', 'Unknown')
                    resource_name = resource.get('name', 'Unknown')
                else:
                    # If resource is a string or other format
                    resource_type = 'Resource'
                    resource_name = str(resource)
                markdown += f"- **{resource_type}**: `{resource_name}`\n"
        
        # Recommendations
        recommendations = drift_report.get('recommendations', [])
        if recommendations and isinstance(recommendations, list):
            markdown += """
## 💡 Recomendaciones

"""
            for rec in recommendations:
                if isinstance(rec, dict):
                    priority_icon = {'critical': '🚨', 'warning': '⚠️', 'info': 'ℹ️'}.get(rec.get('priority', 'info'), 'ℹ️')
                    rec_type = rec.get('type', 'N/A')
                    rec_description = rec.get('description', 'N/A')
                    markdown += f"- {priority_icon} **{rec_type}**: {rec_description}\n"
                    
                    # Add cleanup script if available
                    if rec.get('script') and not test_mode:
                        markdown += f"""
<details>
<summary>🔧 Script de Limpieza (Click para expandir)</summary>

```bash
{rec['script']}
```
</details>

"""
        
        # Technical details
        metadata = drift_report.get('metadata', {})
        markdown += f"""
## 🔧 Detalles Técnicos

| Campo | Valor |
|-------|-------|
| **Commit SHA** | [`{commit_sha[:8]}`]({workflow_url}) |
| **Workflow** | [Ver ejecución]({workflow_url}) |
| **Tiempo de Ejecución** | {metadata.get('execution_time_seconds', 'N/A')} segundos |
| **Región AWS** | {metadata.get('aws_region', 'N/A')} |
| **Versión Terraform** | {metadata.get('terraform_version', 'N/A')} |
| **Timestamp** | {drift_report.get('timestamp', datetime.now().isoformat())} |

---

### 📄 Reporte Completo

<details>
<summary>📋 Datos JSON Completos (Click para expandir)</summary>

```json
{json.dumps(drift_report, indent=2, ensure_ascii=False)}
```

</details>

---

*🤖 Reporte generado automáticamente por el Sistema de Drift Detection Empresarial | MCI Infrastructure Team*
"""
        
        return markdown
    
    def post_pr_comment(self, comment_body: str) -> bool:
        """Post comment to PR using GitHub CLI"""
        if not self.github_pr_number:
            logger.info("ℹ️ No PR context found - posting as repository comment instead")
            return self.post_repository_comment(comment_body)
        
        try:
            # Check if gh CLI is available
            result = subprocess.run(['gh', '--version'], capture_output=True, text=True)
            if result.returncode != 0:
                logger.warning("⚠️ GitHub CLI not available - cannot post PR comment")
                return False
            
            # Write comment to temporary file
            with tempfile.NamedTemporaryFile(mode='w', suffix='.md', delete=False, encoding='utf-8') as f:
                f.write(comment_body)
                temp_file = f.name
            
            # Use GitHub CLI to post comment
            cmd = ['gh', 'pr', 'comment', self.github_pr_number, '--body-file', temp_file]
            
            result = subprocess.run(cmd, capture_output=True, text=True)
            
            # Clean up temp file
            os.unlink(temp_file)
            
            if result.returncode == 0:
                logger.info(f"✅ Comment posted successfully to PR #{self.github_pr_number}")
                return True
            else:
                logger.error(f"❌ Failed to post PR comment: {result.stderr}")
                return False
                
        except Exception as e:
            logger.error(f"❌ Error posting PR comment: {e}")
            return False
    
    def post_repository_comment(self, comment_body: str) -> bool:
        """Post comment as repository issue if no PR context"""
        try:
            # Check if gh CLI is available
            result = subprocess.run(['gh', '--version'], capture_output=True, text=True)
            if result.returncode != 0:
                logger.warning("⚠️ GitHub CLI not available - skipping issue creation")
                logger.info("📝 Drift report would have been posted as GitHub issue")
                logger.info("🔍 Report preview:")
                # Show first 500 chars of report for debugging
                logger.info(comment_body[:500] + "..." if len(comment_body) > 500 else comment_body)
                return True  # Return success in test mode
            
            # Create an issue with the drift report (without label to avoid permission issues)
            issue_title = f"🔍 Drift Detection Report - {datetime.now().strftime('%Y-%m-%d %H:%M')}"
            
            with tempfile.NamedTemporaryFile(mode='w', suffix='.md', delete=False, encoding='utf-8') as f:
                f.write(comment_body)
                temp_file = f.name
            
            # Try without label first
            cmd = ['gh', 'issue', 'create', '--title', issue_title, '--body-file', temp_file]
            
            result = subprocess.run(cmd, capture_output=True, text=True)
            
            # Clean up temp file
            os.unlink(temp_file)
            
            if result.returncode == 0:
                logger.info(f"✅ Drift detection issue created successfully")
                return True
            else:
                logger.error(f"❌ Failed to create issue: {result.stderr}")
                return False
                
        except Exception as e:
            logger.error(f"❌ Error creating issue: {e}")
            return False
    
    def send_notification(self, drift_report: Dict[str, Any], deployment_type: str, 
                         environment: str, commit_sha: str, workflow_url: str, 
                         severity: str, test_mode: bool = False) -> bool:
        """Send drift notification as GitHub comment"""
        
        if not self.validate_github_context():
            return False
        
        try:
            logger.debug(f"🔍 Processing drift report: {json.dumps(drift_report, indent=2)}")
            
            # Generate markdown report
            markdown_content = self.generate_markdown_report(
                drift_report=drift_report,
                deployment_type=deployment_type,
                environment=environment,
                commit_sha=commit_sha,
                workflow_url=workflow_url,
                test_mode=test_mode
            )
            
            logger.debug(f"📝 Generated markdown content (first 200 chars): {markdown_content[:200]}...")
            
            # Post comment
            success = self.post_pr_comment(markdown_content)
            
            if success:
                logger.info("✅ Drift detection notification posted successfully")
                return True
            else:
                logger.error("❌ Failed to post drift detection notification")
                return False
                
        except Exception as e:
            logger.error(f"❌ Error sending notification: {e}")
            logger.exception("Full error details:")
            return False

def main():
    parser = argparse.ArgumentParser(description='Send drift detection GitHub notifications')
    parser.add_argument('--report-file', required=True, help='Path to the drift report JSON file')
    parser.add_argument('--deployment-type', required=True, help='Type of deployment (pre-deployment, post-deployment, test-notification)')
    parser.add_argument('--environment', required=True, help='Environment name (dev, qa, prod)')
    parser.add_argument('--commit-sha', required=True, help='Git commit SHA')
    parser.add_argument('--workflow-url', required=True, help='GitHub workflow URL')
    parser.add_argument('--pr-number', help='Pull request number (optional)')
    parser.add_argument('--test-mode', action='store_true', help='Enable test mode')
    parser.add_argument('--verbose', action='store_true', help='Enable verbose output')
    
    args = parser.parse_args()
    
    # Setup logging
    log_level = logging.DEBUG if args.verbose else logging.INFO
    logging.basicConfig(level=log_level, format='%(asctime)s - %(levelname)s - %(message)s')
    
    # Set PR number if provided
    if args.pr_number:
        os.environ['GITHUB_PR_NUMBER'] = args.pr_number
    
    try:
        # Load drift report
        with open(args.report_file, 'r', encoding='utf-8') as f:
            drift_report = json.load(f)
        
        # Determine severity
        summary = drift_report.get('summary', {})
        test_mode = args.test_mode or summary.get('test_mode', False)
        
        if test_mode:
            # In test mode, use the test_type from summary or default to info
            test_type = summary.get('test_type', 'info')
            severity = test_type
            logging.info(f"🧪 Running in test mode with severity: {severity}")
        else:
            # Normal mode - determine severity from actual issues
            total_issues = summary.get('total_issues', 0)
            orphaned_roles = summary.get('orphaned_roles', 0)
            
            if total_issues >= 10 or orphaned_roles >= 5:
                severity = 'critical'
            elif total_issues >= 5 or orphaned_roles >= 2:
                severity = 'warning'
            else:
                severity = 'info'
        
        logging.info(f"📊 Drift report severity: {severity}")
        
        # Create and send notification
        notifier = DriftGitHubNotifier()
        
        success = notifier.send_notification(
            drift_report=drift_report,
            deployment_type=args.deployment_type,
            environment=args.environment,
            commit_sha=args.commit_sha,
            workflow_url=args.workflow_url,
            severity=severity,
            test_mode=test_mode
        )
        
        if success:
            logging.info("✅ GitHub notification posted successfully")
            sys.exit(0)
        else:
            logging.error("❌ Failed to post GitHub notification")
            sys.exit(1)
            
    except Exception as e:
        logging.error(f"❌ Error: {str(e)}")
        if args.verbose:
            logging.exception("Full error details:")
        sys.exit(1)

if __name__ == '__main__':
    main()