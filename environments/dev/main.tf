# Main configuration for IAM roles deployment

locals {
  # Cargar catálogo V2 modular
  v2_index_raw = file("${path.root}/../../catalog/v2/index.yaml")
  v2_index = yamldecode(local.v2_index_raw)
  
  # Cargar servicio S3 del catálogo V2
  s3_catalog_raw = file("${path.root}/../../catalog/v2/services/s3.yaml")
  s3_catalog = yamldecode(local.s3_catalog_raw)
  
  # Cargar servicio deployment del catálogo V2
  deployment_catalog_raw = file("${path.root}/../../catalog/v2/services/deployment.yaml")
  deployment_catalog = yamldecode(local.deployment_catalog_raw)
  
  # Combinar políticas de todos los servicios V2
  all_v2_policies = merge(
    local.s3_catalog.policies,
    local.deployment_catalog.policies
  )
  
  # Extraer todas las políticas MCI del catálogo V2
  mci_policies = {
    for policy_name, policy_config in local.all_v2_policies : 
    policy_name => policy_config
    if can(regex("^MCI-.+", policy_name))
  }

  # Buscar archivos de roles
  role_files = fileset("${path.root}/../../gerencias", "**/rol-*.json")
  
  # Cargar roles desde archivos JSON
  roles = {
    for role_file in local.role_files :
    replace(basename(role_file), ".json", "") => jsondecode(file("${path.root}/../../gerencias/${role_file}"))
    if can(jsondecode(file("${path.root}/../../gerencias/${role_file}")))
  }

  base_canonical_tags = {
    Ambiente = "dev"
    Pais = "rg"
    Direccion = "tecnologia"
    Gerencia = "mci"
    Cuenta = data.aws_caller_identity.current.account_id
    Modulo = "iamroles"
    "Alcance SOX" = "no"
    Propietario = "devopsteam"
    Proveedor = "claro"
    Layer = "security"
    Dominio = "identity"
    Subdominio = "iam"
    Aplicacion = "iamroles"
    Name = "base-config"
    Soporte = "devopsteam"
    Contacto = "devops@claro.com"
    Proyecto = "abacframework"
    "Fechas de Creacion" = formatdate("YYYY-MM-DD'T'hh:mm:ssZ", timestamp())
    "Creado Por" = "terraformiac"
    "Tipo de Recurso" = "iamrole"
    "Ciclo de Vida" = "active"
    Version = "2.0"
    "Map-migrated" = "migrole001"
  }
}

data "aws_caller_identity" "current" {}

# Crear políticas MCI desde catálogo V2
resource "aws_iam_policy" "mci_policies" {
  for_each = local.mci_policies
  
  name        = each.key
  description = each.value.description
  policy      = data.aws_iam_policy_document.mci_policies[each.key].json
  
  tags = merge(
    local.base_canonical_tags,
    each.value.canonical_tags
  )
}

# Generar documentos de politica usando policy_lib modules
module "deployment_policies" {
  source = "../../policy_lib/deployment"
  
  department  = "MCI"
  environment = "dev"
}

# Asignar documentos de politica desde modules
data "aws_iam_policy_document" "mci_policies" {
  for_each = local.mci_policies
  
  # Usar los documentos de politica reales de policy_lib/deployment
  source_policy_documents = [
    each.key == "MCI-Deployment-TerraformCore" ? module.deployment_policies.terraform_core_deployment_policy :
    each.key == "MCI-Deployment-S3Analytics" ? module.deployment_policies.s3_analytics_deployment_policy :
    each.key == "MCI-Deployment-CloudFormation" ? module.deployment_policies.cloudformation_deployment_policy :
    each.key == "MCI-Deployment-Lambda" ? module.deployment_policies.lambda_deployment_policy :
    each.key == "MCI-Deployment-Logs" ? module.deployment_policies.logs_deployment_policy :
    each.key == "MCI-Deployment-DynamoDB" ? module.deployment_policies.dynamodb_deployment_policy :
    jsonencode({
      Version = "2012-10-17"
      Statement = [{
        Effect = "Deny"
        Action = "*"
        Resource = "*"
      }]
    })
  ]
}

# ============================================================================
# IAM ROLES CREATION
# ============================================================================

# Crear roles IAM dinamicamente
module "iam_roles" {
  source = "../../modules/iam-role"

  for_each = local.roles

  role_name             = each.value.role_name
  description           = try(each.value.description, "IAM Role managed by Terraform")
  trust_policy_document = jsonencode(each.value.trust_policy)
  
  # Politicas AWS administradas
  managed_policy_arns = try(each.value.policies.aws_managed, [])

  # Politicas inline como mapa (si las hay)
  inline_policies = {}

  # Tags canonicos con normalizacion - COMBINAR base + especificos del archivo
  canonical_tags = merge(
    local.base_canonical_tags,
    {
      Name        = each.value.role_name
      Aplicacion  = try(lower(each.value.metadata.aplicacion), "unknown")
      Ambiente    = try(lower(each.value.metadata.ambiente), "dev")
      Pais        = try(upper(each.value.metadata.pais.code), "RG")
      Gerencia    = try(upper(each.value.metadata.gerencia.code), "MCI")
    },
    # NUEVO: Incluir tags especificos del archivo JSON (normalizados)
    {
      for k, v in try(each.value.metadata.tags, {}) : k => v
      # Solo incluir si no es un tag ya definido arriba para evitar conflictos
      if !contains(["Name", "Aplicacion", "Ambiente", "Pais", "Gerencia"], k)
    }
  )
  
  # Tags adicionales del rol especifico (ahora vacio ya que se incluyen arriba)
  tags = {}
}

# ============================================================================
# OUTPUTS
# ============================================================================

output "created_policies" {
  description = "Lista de politicas IAM creadas"
  value = {
    for k, v in aws_iam_policy.mci_policies : k => {
      name = v.name
      arn  = v.arn
    }
  }
}

output "created_roles" {
  description = "Lista de roles IAM creados"
  value = {
    for k, v in module.iam_roles : k => {
      name = v.role_name
      arn  = v.role_arn
    }
  }
}
