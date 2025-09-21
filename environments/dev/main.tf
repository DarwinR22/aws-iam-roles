# Main configuration for IAM roles deployment - ENTERPRISE ARCHITECTURE
# Building blocks approach: Generic policies + Granular roles

locals {
  # Buscar todos los archivos JSON de roles en gerencias/
  role_files = fileset("${path.root}/../../gerencias", "**/rol-*.json")

  # Procesar cada archivo de rol
  roles = {
    for role_file in local.role_files :
    replace(basename(role_file), ".json", "") => jsondecode(file("${path.root}/../../gerencias/${role_file}"))
    if can(jsondecode(file("${path.root}/../../gerencias/${role_file}")))
  }

  # Extraer área/gerencia del path del archivo para tags automáticos
  role_areas = {
    for role_file in local.role_files :
    replace(basename(role_file), ".json", "") => lower(length(split("/", role_file)) >= 2 ? split("/", role_file)[1] : split("/", role_file)[0])
  }

  # ============================================================================
  # VALIDACIÓN DE TAGS OBLIGATORIOS
  # ============================================================================
  # Verificar que todos los roles tengan los tags mínimos requeridos
  roles_missing_tags = [
    for role_name, role_data in local.roles : {
      role = role_name
      missing_tags = [
        for required_tag in ["Equipo", "Ambiente", "Proyecto"] :
        required_tag if !contains(keys(try(role_data.tags, {})), required_tag)
      ]
    }
    if length([
      for required_tag in ["Equipo", "Ambiente", "Proyecto"] :
      required_tag if !contains(keys(try(role_data.tags, {})), required_tag)
    ]) > 0
  ]

  # Generar error si hay roles sin tags - usar validation en data source
  validate_tags_count = length(local.roles_missing_tags)

  # ============================================================================
  # VALIDACIÓN DE TAGS ÚNICOS (case-insensitive)
  # ============================================================================
  # Detectar tags duplicados case-insensitive antes del deploy
  roles_with_duplicate_tags = [
    for role_name, role_data in local.roles : {
      role = role_name
      all_tags = merge(
        {
          Name = role_data.role_name
          "Tipo de Recurso" = "IAM Role"
          "Fecha de Creacion" = formatdate("YYYY-MM-DD", timestamp())
          PolicyType = "Role"
          ManagedBy = "Terraform"
        },
        try(role_data.tags, {})
      )
      tag_keys_lower = [for k in keys(merge(
        {
          Name = role_data.role_name
          "Tipo de Recurso" = "IAM Role"
          "Fecha de Creacion" = formatdate("YYYY-MM-DD", timestamp())
          PolicyType = "Role"
          ManagedBy = "Terraform"
        },
        try(role_data.tags, {})
      )) : lower(k)]
      has_duplicates = length(keys(merge(
        {
          Name = role_data.role_name
          "Tipo de Recurso" = "IAM Role"
          "Fecha de Creacion" = formatdate("YYYY-MM-DD", timestamp())
          PolicyType = "Role"
          ManagedBy = "Terraform"
        },
        try(role_data.tags, {})
      ))) != length(distinct([for k in keys(merge(
        {
          Name = role_data.role_name
          "Tipo de Recurso" = "IAM Role"
          "Fecha de Creacion" = formatdate("YYYY-MM-DD", timestamp())
          PolicyType = "Role"
          ManagedBy = "Terraform"
        },
        try(role_data.tags, {})
      )) : lower(k)]))
    }
    if length(keys(merge(
      {
        Name = role_data.role_name
        "Tipo de Recurso" = "IAM Role"
        "Fecha de Creacion" = formatdate("YYYY-MM-DD", timestamp())
        PolicyType = "Role"
        ManagedBy = "Terraform"
      },
      try(role_data.tags, {})
    ))) != length(distinct([for k in keys(merge(
      {
        Name = role_data.role_name
        "Tipo de Recurso" = "IAM Role"
        "Fecha de Creacion" = formatdate("YYYY-MM-DD", timestamp())
        PolicyType = "Role"
        ManagedBy = "Terraform"
      },
      try(role_data.tags, {})
    )) : lower(k)]))
  ]
}

# ============================================================================
# VALIDACIÓN: Check obligatorio de tags 
# ============================================================================
check "validate_required_tags" {
  assert {
    condition = length(local.roles_missing_tags) == 0
    error_message = <<-EOT
    ❌ ROLES SIN ETIQUETAS OBLIGATORIAS:
    
    ${join("\n", [
      for invalid in local.roles_missing_tags :
      "  - ${invalid.role}: faltan tags ${join(", ", invalid.missing_tags)}"
    ])}
    
    🛡️ Todos los roles deben incluir los tags: Equipo, Ambiente, Proyecto
    
    Ejemplo correcto en archivo JSON del rol:
    "tags": {
      "Equipo": "BI-Team",
      "Ambiente": "dev",
      "Proyecto": "DataAnalytics"
    }
    EOT
  }
}

# VALIDACIÓN: Check para tags duplicados case-insensitive
check "validate_unique_tags" {
  assert {
    condition = length(local.roles_with_duplicate_tags) == 0
    error_message = <<-EOT
    ❌ ROLES CON TAGS DUPLICADOS (case-insensitive):
    
    ${join("\n", [
      for invalid in local.roles_with_duplicate_tags :
      "  - ${invalid.role}: tiene tags que AWS considera duplicados"
    ])}
    
    🛡️ AWS no permite tags con nombres similares (case-insensitive)
    Ejemplos de conflictos: Environment vs environment, Team vs team, etc.
    
    Usa nomenclatura única y específica para evitar conflictos.
    EOT
  }
}# ============================================================================
# BUILDING BLOCKS: Políticas MCI genéricas (Data Sources)
# ============================================================================

data "aws_iam_policy" "mci_s3_readonly" {
  name = "MCI-S3-ReadOnly"
}

data "aws_iam_policy" "mci_s3_write" {
  name = "MCI-S3-Write"
}

data "aws_iam_policy" "mci_lambda_invoke" {
  name = "MCI-Lambda-Invoke"
}

data "aws_iam_policy" "mci_dynamodb_readonly" {
  name = "MCI-DynamoDB-ReadOnly"
}

data "aws_iam_policy" "mci_dynamodb_write" {
  name = "MCI-DynamoDB-Write"
}

# Data source para obtener account ID
data "aws_caller_identity" "current" {}

# ============================================================================
# TAG-BASED POLICIES: Políticas dinámicas basadas en etiquetas
# ============================================================================

# Crear políticas basadas en tags de equipo
resource "aws_iam_policy" "team_tag_policies" {
  for_each = var.team_tag_policies

  name        = "MCI-${each.key}"
  description = each.value.description

  policy = templatefile(
    "${path.root}/../../politicas/${each.value.policy_template}.json",
    {
      team_name   = each.value.team_name
      environment = each.value.environment
      project_name = each.value.project_name
    }
  )

  tags = merge(
    {
      PolicyType    = "Tag-Based"
      TeamName      = each.value.team_name
      Environment   = each.value.environment
      ProjectName   = each.value.project_name
    },
    var.policy_tags
  )
}

# Crear roles IAM dinámicamente con tags por área
module "iam_roles" {
  source = "../../modules/iam-role"

  for_each = local.roles

  role_name          = each.value.role_name
  description        = try(each.value.description, "IAM Role managed by Terraform")
  assume_role_policy = jsonencode(each.value.trust_policy)

  # Políticas AWS administradas
  policy_arns = try(each.value.policies.aws_managed, [])

  # Política inline si existe
  inline_policy = try(each.value.policies.inline != null ? jsonencode(each.value.policies.inline) : null, null)

  # Tags automáticos por área + tags específicos del rol
  # Crear tags en orden de prioridad: automáticos primero, JSON del rol sobreescribe
  tags = merge(
    {
      # Tags esenciales del sistema solamente - sin duplicar conceptos
      Name                = each.value.role_name
      "Tipo de Recurso"   = "IAM Role"
      "Fecha de Creacion" = formatdate("YYYY-MM-DD", timestamp())
      PolicyType          = "Role"
      ManagedBy           = "Terraform"
    },
    # Tags específicos del rol (desde JSON) - estos SOBREESCRIBEN los automáticos
    try(each.value.tags, {})
  )
}

# Adjuntar políticas MCI genéricas a los roles
resource "aws_iam_role_policy_attachment" "mci_policy_attachments" {
  for_each = merge([
    for role_key, role_config in local.roles : {
      for policy_name in try(role_config.policies.mci_generic, []) :
      "${role_key}-${policy_name}" => {
        role_key    = role_key
        policy_name = policy_name
      }
    }
  ]...)

  role       = module.iam_roles[each.value.role_key].role_name
  
  # Mapear nombres a ARNs de políticas MCI
  policy_arn = (
    each.value.policy_name == "MCI-S3-ReadOnly" ? data.aws_iam_policy.mci_s3_readonly.arn :
    each.value.policy_name == "MCI-S3-Write" ? data.aws_iam_policy.mci_s3_write.arn :
    each.value.policy_name == "MCI-Lambda-Invoke" ? data.aws_iam_policy.mci_lambda_invoke.arn :
    each.value.policy_name == "MCI-DynamoDB-ReadOnly" ? data.aws_iam_policy.mci_dynamodb_readonly.arn :
    each.value.policy_name == "MCI-DynamoDB-Write" ? data.aws_iam_policy.mci_dynamodb_write.arn :
    "arn:aws:iam::${data.aws_caller_identity.current.account_id}:policy/${each.value.policy_name}"
  )
}

# Adjuntar políticas TAG-BASED a los roles
resource "aws_iam_role_policy_attachment" "team_tag_policy_attachments" {
  for_each = merge([
    for role_key, role_config in local.roles : {
      for policy_name in try(role_config.policies.tag_based, []) :
      "${role_key}-${policy_name}" => {
        role_key    = role_key
        policy_name = policy_name
      }
    }
  ]...)

  role       = module.iam_roles[each.value.role_key].role_name
  policy_arn = aws_iam_policy.team_tag_policies[each.value.policy_name].arn
}

# ============================================================================
# OUTPUTS: Enterprise visibility
# ============================================================================

output "created_roles" {
  description = "Map of created IAM roles with enterprise metadata"
  value = {
    for k, v in module.iam_roles : k => {
      role_name  = v.role_name
      role_arn   = v.role_arn
      area       = local.role_areas[k]
      propietario = lookup(var.area_owners, local.role_areas[k], "DarwinLopez")
    }
  }
}

output "mci_building_blocks" {
  description = "Available MCI building block policies"
  value = {
    s3_readonly     = data.aws_iam_policy.mci_s3_readonly.arn
    s3_write        = data.aws_iam_policy.mci_s3_write.arn
    lambda_invoke   = data.aws_iam_policy.mci_lambda_invoke.arn
    dynamodb_read   = data.aws_iam_policy.mci_dynamodb_readonly.arn
    dynamodb_write  = data.aws_iam_policy.mci_dynamodb_write.arn
  }
}

output "team_tag_policies" {
  description = "Created tag-based policies by team"
  value = {
    for k, v in aws_iam_policy.team_tag_policies : k => {
      policy_name  = v.name
      policy_arn   = v.arn
      team_name    = var.team_tag_policies[k].team_name
      environment  = var.team_tag_policies[k].environment
      project_name = var.team_tag_policies[k].project_name
    }
  }
}
