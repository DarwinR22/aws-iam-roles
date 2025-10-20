# ==============================================================================
# OBSERVABILITY MODULE: SECURITY HUB
# Propósito: SIEM centralizado para compliance y findings
# Compliance: ISO 27001 A.12.4.1, A.12.4.2 | NIST CSF DE.AE-3, RS.AN-1
# ==============================================================================

# ------------------------------------------------------------------------------
# SECURITY HUB ACCOUNT
# ------------------------------------------------------------------------------
resource "aws_securityhub_account" "main" {
  enable_default_standards = var.enable_default_standards
  control_finding_generator = "SECURITY_CONTROL"
  auto_enable_controls      = var.auto_enable_controls
}

# ------------------------------------------------------------------------------
# SECURITY HUB STANDARDS - CIS AWS FOUNDATIONS
# ------------------------------------------------------------------------------
resource "aws_securityhub_standards_subscription" "cis" {
  count = var.enable_cis_standard ? 1 : 0
  
  depends_on    = [aws_securityhub_account.main]
  standards_arn = "arn:aws:securityhub:${data.aws_region.current.name}::standards/cis-aws-foundations-benchmark/v/1.4.0"
}

# ------------------------------------------------------------------------------
# SECURITY HUB STANDARDS - AWS FOUNDATIONAL SECURITY BEST PRACTICES
# ------------------------------------------------------------------------------
resource "aws_securityhub_standards_subscription" "aws_foundational" {
  count = var.enable_aws_foundational_standard ? 1 : 0
  
  depends_on    = [aws_securityhub_account.main]
  standards_arn = "arn:aws:securityhub:${data.aws_region.current.name}::standards/aws-foundational-security-best-practices/v/1.0.0"
}

# ------------------------------------------------------------------------------
# SECURITY HUB STANDARDS - PCI DSS (OPCIONAL)
# ------------------------------------------------------------------------------
resource "aws_securityhub_standards_subscription" "pci_dss" {
  count = var.enable_pci_dss_standard ? 1 : 0
  
  depends_on    = [aws_securityhub_account.main]
  standards_arn = "arn:aws:securityhub:${data.aws_region.current.name}::standards/pci-dss/v/3.2.1"
}

# ------------------------------------------------------------------------------
# SECURITY HUB PRODUCT SUBSCRIPTIONS
# ------------------------------------------------------------------------------
resource "aws_securityhub_product_subscription" "guardduty" {
  count = var.enable_guardduty_integration ? 1 : 0
  
  depends_on  = [aws_securityhub_account.main]
  product_arn = "arn:aws:securityhub:${data.aws_region.current.name}::product/aws/guardduty"
}

resource "aws_securityhub_product_subscription" "config" {
  count = var.enable_config_integration ? 1 : 0
  
  depends_on  = [aws_securityhub_account.main]
  product_arn = "arn:aws:securityhub:${data.aws_region.current.name}::product/aws/config"
}

# ------------------------------------------------------------------------------
# DATA SOURCES
# ------------------------------------------------------------------------------
data "aws_region" "current" {}

