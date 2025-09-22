# Main configuration for IAM roles deployment

locals {
  # Cargar catalogo de politicas
  policies_catalog_raw = file("${path.root}/../../catalog/policies.yaml")
  policies_catalog = yamldecode(local.policies_catalog_raw)
  
  # Extraer politicas MCI TagBased
  mci_policies = {
    for policy_name, policy_config in local.policies_catalog.policies : 
    policy_name => policy_config
    if can(regex("^MCI-.+-TagBased-.+$", policy_name))
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

# Crear politicas MCI TagBased
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

# Generar documentos de politica dinamicamente
data "aws_iam_policy_document" "mci_policies" {
  for_each = local.mci_policies
  
  # Ejemplo basico - necesitarias expandir segun tus policy_lib modules
  statement {
    effect = "Allow"
    actions = ["s3:GetObject"] # Placeholder - usar policy_document real
    resources = ["*"]
    
    condition {
      test     = "StringEquals"
      variable = "aws:PrincipalTag/Aplicacion"
      values   = ["${data.aws_caller_identity.current.account_id}"]
    }
  }
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
