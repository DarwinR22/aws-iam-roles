# Main configuration for IAM roles deployment

locals {
  normalize_value = function(input) {
    return lower(replace(replace(tostring(input), " ", ""), "-", ""))
  }
  
  policies_catalog_raw = file("${path.root}/../../catalog/policies.yaml")
  policies_catalog = yamldecode(local.policies_catalog_raw)
  
  mci_policies = {
    for policy_name, policy_config in local.policies_catalog.policies : 
    policy_name => policy_config
    if can(regex("^MCI-.+-TagBased-.+$", policy_name))
  }
  
  base_canonical_tags = {
    Ambiente           = "dev"
    País              = "rg" 
    Dirección         = "tecnología"
    Gerencia          = "mci"
    Cuenta            = data.aws_caller_identity.current.account_id
    Módulo            = "iamroles"
    "Alcance SOX"     = "no"
    Propietario       = "devopsteam"
    Proveedor         = "claro"
    Layer             = "security"
    Dominio           = "identity"
    Subdominio        = "iam"
    Soporte           = "devopsclarocomm"
    Contacto          = "devopsclarocomm"
    Proyecto          = "abacframework"
    "Fechas de Creación" = formatdate("YYYY-MM-DD'T'hh:mm:ssZ", timestamp())
    "Creado Por"      = "terraformiac"
    "Tipo de Recurso" = "iamrole"
    "Ciclo de Vida"   = "active"
    Versión           = "2.0"
    "Map-migrated"    = "migrole001"
  }

  role_files = fileset("${path.root}/../../gerencias", "**/rol-*.json")

  roles = {
    for role_file in local.role_files :
    replace(basename(role_file), ".json", "") => jsondecode(file("${path.root}/../../gerencias/${role_file}"))
    if can(jsondecode(file("${path.root}/../../gerencias/${role_file}")))
  }
}

data "aws_caller_identity" "current" {}

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

data "aws_iam_policy_document" "mci_policies" {
  for_each = local.mci_policies
  
  dynamic "statement" {
    for_each = each.value.statements
    content {
      effect = statement.value.effect
      actions = statement.value.actions
      resources = statement.value.resources
      
      dynamic "condition" {
        for_each = try(statement.value.condition, {})
        content {
          test     = condition.value.test
          variable = condition.value.variable
          values   = condition.value.values
        }
      }
    }
  }
}

module "iam_roles" {
  source = "../../modules/iam-role"
  for_each = local.roles

  role_name          = each.value.metadata.role_name
  assume_role_policy = jsonencode(each.value.assume_role_policy)
  role_description   = try(each.value.description, "IAM role for ${each.value.metadata.role_name}")

  canonical_tags = merge(
    local.base_canonical_tags,
    {
      Name        = each.value.metadata.role_name
      Aplicación  = local.normalize_value(try(each.value.metadata.aplicacion, "unknown"))
      Ambiente    = local.normalize_value(try(each.value.metadata.ambiente, "dev"))
      País        = local.normalize_value(try(each.value.metadata.pais.code, "rg"))
      Gerencia    = local.normalize_value(try(each.value.metadata.gerencia.code, "mci"))
    }
  )
  
  tags = try(each.value.metadata.tags, {})
}
