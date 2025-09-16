# Main configuration for IAM roles deployment
# Detecta automáticamente roles en la estructura de carpetas

locals {
  # Buscar todos los archivos JSON de roles en la estructura de carpetas
  role_files = fileset("${path.root}/../../", "**/rol-*.json")
  
  # Procesar cada archivo de rol
  roles = {
    for role_file in local.role_files :
    replace(basename(role_file), ".json", "") => jsondecode(file("${path.root}/../../${role_file}"))
    if can(jsondecode(file("${path.root}/../../${role_file}")))
  }
  
  # Procesar políticas personalizadas
  policy_files = fileset("${path.root}/../../", "**/policy-*.json")
  
  policies = {
    for policy_file in local.policy_files :
    replace(basename(policy_file), ".json", "") => jsondecode(file("${path.root}/../../${policy_file}"))
    if can(jsondecode(file("${path.root}/../../${policy_file}")))
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
  
  # Políticas AWS administradas y personalizadas
  policy_arns = concat(
    try(each.value.policies.aws_managed, []),
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

output "created_policies" {
  description = "Map of created custom policies"
  value = {
    for k, v in aws_iam_policy.custom_policies : k => {
      policy_name = v.name
      policy_arn  = v.arn
    }
  }
}
