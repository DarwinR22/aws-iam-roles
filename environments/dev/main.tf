# Main configuration for IAM roles deployment
# Detecta automáticamente roles en la estructura de carpetas

locals {
  # Buscar todos los archivos JSON de roles en gerencias/
  role_files = fileset("${path.root}/../../gerencias", "**/rol-*.json")

  # Procesar cada archivo de rol
  roles = {
    for role_file in local.role_files :
    replace(basename(role_file), ".json", "") => jsondecode(file("${path.root}/../../gerencias/${role_file}"))
    if can(jsondecode(file("${path.root}/../../gerencias/${role_file}")))
  }

  # Procesar políticas personalizadas en gerencias/
  policy_files = fileset("${path.root}/../../gerencias", "**/policy-*.json")

  policies = {
    for policy_file in local.policy_files :
    replace(basename(policy_file), ".json", "") => jsondecode(file("${path.root}/../../gerencias/${policy_file}"))
    if can(jsondecode(file("${path.root}/../../gerencias/${policy_file}")))
  }

  # Buscar políticas genéricas en politicas/
  generic_policy_files = fileset("${path.root}/../../politicas", "**/*.json")

  generic_policies = {
    for policy_file in local.generic_policy_files :
    replace(basename(policy_file), ".json", "") => jsondecode(file("${path.root}/../../politicas/${policy_file}"))
    if can(jsondecode(file("${path.root}/../../politicas/${policy_file}")))
  }
}

# Crear políticas genéricas
resource "aws_iam_policy" "generic_policies" {
  for_each = local.generic_policies

  name   = each.key
  policy = jsonencode(each.value)

  tags = {
    Environment = var.environment
    ManagedBy   = "Terraform"
    PolicyType  = "Generic"
  }
}

# Crear políticas personalizadas
resource "aws_iam_policy" "custom_policies" {
  for_each = local.policies

  name   = each.key
  policy = jsonencode(each.value)

  tags = {
    Environment = var.environment
    ManagedBy   = "Terraform"
    PolicyType  = "Custom"
  }
}

# Crear roles IAM dinámicamente
module "iam_roles" {
  source = "../../modules/iam-role"

  for_each = local.roles

  role_name          = each.value.role_name
  description        = try(each.value.description, "IAM Role managed by Terraform")
  assume_role_policy = jsonencode(each.value.trust_policy)

  # Políticas AWS administradas, genéricas y personalizadas
  policy_arns = concat(
    # Políticas AWS administradas (si existen)
    try(each.value.policies.aws_managed, []),
    # Política genérica (si existe)
    try(each.value.policies.generic_policy != null ? [aws_iam_policy.generic_policies[each.value.policies.generic_policy].arn] : [], []),
    # Políticas custom (si existen)
    [
      for policy_ref in try(each.value.policies.custom_policies, []) :
      aws_iam_policy.custom_policies[replace(basename(policy_ref), ".json", "")].arn
    ]
  )

  # Política inline si existe
  inline_policy = try(each.value.policies.inline != null ? jsonencode(each.value.policies.inline) : null, null)

  # Tags del rol
  tags = each.value.tags
}

# Outputs para mostrar los roles creados
output "created_roles" {
  description = "Map of created IAM roles"
  value = {
    for k, v in module.iam_roles : k => {
      role_name = v.role_name
      role_arn  = v.role_arn
    }
  }
}

output "created_generic_policies" {
  description = "Map of created generic policies"
  value = {
    for k, v in aws_iam_policy.generic_policies : k => {
      policy_name = v.name
      policy_arn  = v.arn
    }
  }
}

output "created_custom_policies" {
  description = "Map of created custom policies"
  value = {
    for k, v in aws_iam_policy.custom_policies : k => {
      policy_name = v.name
      policy_arn  = v.arn
    }
  }
}
