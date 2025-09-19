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

  # Mapeo automático de servicios basado en nombres de políticas
  service_mapping = {
    for policy_name in keys(local.policies) : policy_name => (
      length(regexall("(?i)(s3)", policy_name)) > 0 ? "s3" :
      length(regexall("(?i)(lambda)", policy_name)) > 0 ? "lambda" :
      length(regexall("(?i)(dynamodb)", policy_name)) > 0 ? "dynamodb" :
      length(regexall("(?i)(sqs)", policy_name)) > 0 ? "sqs" :
      length(regexall("(?i)(cloudwatch)", policy_name)) > 0 ? "cloudwatch" :
      length(regexall("(?i)(ec2)", policy_name)) > 0 ? "ec2" :
      length(regexall("(?i)(rds)", policy_name)) > 0 ? "rds" :
      length(regexall("(?i)(apigateway|api)", policy_name)) > 0 ? "apigateway" :
      "general"
    )
  }
}

# Referenciar políticas genéricas existentes
data "aws_iam_policy" "generic_policies" {
  for_each = local.generic_policies
  name     = each.key
}

# Crear políticas personalizadas con tagging automático por servicio
resource "aws_iam_policy" "custom_policies" {
  for_each = local.policies

  name   = each.key
  policy = jsonencode(each.value)

  tags = merge(
    {
      # Tags base/default para todas las políticas custom
      PolicyType    = "Custom"
      modulo        = "IAM"
      layer         = "infrastructure"
      dominio       = "IAM"
      subdominio    = "Policies"
      aplicacion    = "iam-policy-management"
      proyecto      = "mci-iam-automation"
      alcance_sox   = "No"
      ciclo_vida    = "monitoreoymantenimiento"
      version       = "1.0.0"
      
      # Asignación automática por servicio usando locals
      ServiceType   = local.service_mapping[each.key]
      
      propietario   = lookup(var.service_owners, local.service_mapping[each.key], "DarwinLopez")
      Team          = lookup(var.service_teams, local.service_mapping[each.key], "Infrastructure")
      CostCenter    = lookup(var.service_cost_centers, local.service_mapping[each.key], "IT-INFRA-001")
    },
    # Override manual si es necesario (usa policy-custom-tags.tfvars para casos específicos)
    lookup(var.policy_custom_tags, each.key, {})
  )
}

# Crear roles IAM dinámicamente
module "iam_roles" {
  source = "../../modules/iam-role"

  for_each = local.roles

  role_name          = each.value.role_name
  description        = try(each.value.description, "IAM Role managed by Terraform")
  assume_role_policy = jsonencode(each.value.trust_policy)

  # Solo políticas AWS administradas por ahora
  policy_arns = try(each.value.policies.aws_managed, [])

  # Política inline si existe
  inline_policy = try(each.value.policies.inline != null ? jsonencode(each.value.policies.inline) : null, null)

  # Tags del rol
  tags = each.value.tags
}

# Adjuntar políticas genéricas a los roles (múltiples políticas custom)
resource "aws_iam_role_policy_attachment" "generic_policy_attachments" {
  for_each = merge([
    for role_key, role_config in local.roles : {
      for policy_name in try(role_config.policies.custom, []) :
      "${role_key}-${policy_name}" => {
        role_key    = role_key
        policy_name = policy_name
      }
    }
  ]...)

  role       = module.iam_roles[each.value.role_key].role_name
  policy_arn = data.aws_iam_policy.generic_policies[each.value.policy_name].arn
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
  description = "Map of referenced generic policies"
  value = {
    for k, v in data.aws_iam_policy.generic_policies : k => {
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
