# Main configuration for IAM roles deployment

locals {
  # Cargar catálogo de políticas
  policies_catalog_raw = file("${path.root}/../../catalog/policies.yaml")
  policies_catalog = yamldecode(local.policies_catalog_raw)
  
  # Extraer políticas MCI TagBased
  mci_policies = {
    for policy_name, policy_config in local.policies_catalog.policies : 
    policy_name => policy_config
    if can(regex("^MCI-.+-TagBased-.+$", policy_name))
  }

  base_canonical_tags = {
    Ambiente = "dev"
    Pais = "rg"
    Gerencia = "mci"
    Cuenta = data.aws_caller_identity.current.account_id
    Modulo = "iamroles"
  }
}

data "aws_caller_identity" "current" {}

# Crear políticas MCI TagBased
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

# Generar documentos de política dinámicamente
data "aws_iam_policy_document" "mci_policies" {
  for_each = local.mci_policies
  
  # Ejemplo básico - necesitarías expandir según tus policy_lib modules
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
