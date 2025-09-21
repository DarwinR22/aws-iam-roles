# environments/dev/permission-boundaries.tf
# =============================================
# ENTERPRISE PERMISSION BOUNDARIES
# =============================================

# APP STANDARD BOUNDARY
module "app_standard_boundary" {
  source = "../../modules/iam-managed-policy"
  
  policy_name           = "App-StandardBoundary"
  description           = "Standard permission boundary for application roles - restricts dangerous IAM actions"
  policy_document_json  = module.permission_boundaries.app_standard_boundary_policy_json
  
  canonical_tags = {
    Ambiente        = "Multi"
    Pais            = "RG"
    Direccion       = "Tecnologia"
    Gerencia        = "MCI"
    Cuenta          = "393209814297"
    Modulo          = "PermissionBoundaries"
    "Alcance SOX"   = "Si"
    Propietario     = "Security-Team"
    Proveedor       = "Claro"
    Layer           = "Security"
    Dominio         = "PermissionBoundaries"
    Subdominio      = "Application"
    Aplicación      = "permission-boundaries"
    Name            = "App-StandardBoundary"
    Soporte         = "Security-Team"
    Contacto        = "security@claro.com"
    Proyecto        = "Security-Framework"
    "Fechas de Creación" = "2024-01-15T10:00:00Z"
    "Creado Por"    = "terraform-iac"
    "Tipo de Recurso" = "IAM-Policy"
    "Ciclo de Vida" = "Active"
    Versión         = "1.0"
    "Map-migrated"  = "mig_boundary_001"
  }
}

# PLATFORM BOUNDARY
module "platform_boundary" {
  source = "../../modules/iam-managed-policy"
  
  policy_name           = "Platform-Boundary"
  description           = "Platform permission boundary for infrastructure roles - allows more permissions but still restricts critical actions"
  policy_document_json  = module.permission_boundaries.platform_boundary_policy_json
  
  canonical_tags = {
    Ambiente        = "Multi"
    Pais            = "RG"
    Direccion       = "Tecnologia"
    Gerencia        = "MCI"
    Cuenta          = "393209814297"
    Modulo          = "PermissionBoundaries"
    "Alcance SOX"   = "Si"
    Propietario     = "Security-Team"
    Proveedor       = "Claro"
    Layer           = "Security"
    Dominio         = "PermissionBoundaries"
    Subdominio      = "Platform"
    Aplicación      = "permission-boundaries"
    Name            = "Platform-Boundary"
    Soporte         = "Security-Team"
    Contacto        = "security@claro.com"
    Proyecto        = "Security-Framework"
    "Fechas de Creación" = "2024-01-15T10:00:00Z"
    "Creado Por"    = "terraform-iac"
    "Tipo de Recurso" = "IAM-Policy"
    "Ciclo de Vida" = "Active"
    Versión         = "1.0"
    "Map-migrated"  = "mig_boundary_002"
  }
}

# PERMISSION BOUNDARIES POLICY DOCUMENTS
module "permission_boundaries" {
  source = "../../policy_lib/commons"
  
  account_id = "393209814297"
  allowed_regions = ["us-east-1"]
}

# OUTPUTS
output "app_standard_boundary_arn" {
  description = "ARN of the App Standard Boundary policy"
  value       = module.app_standard_boundary.policy_arn
}

output "platform_boundary_arn" {
  description = "ARN of the Platform Boundary policy"
  value       = module.platform_boundary.policy_arn
}