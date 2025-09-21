# Main configuration for IAM roles deployment - ENTERPRISE ARCHITECTURE# Main configuration for IAM roles deployment - ENTERPRISE ARCHITECTURE

# Building blocks approach: Generic policies + Granular roles# Building blocks approach: Generic policies + Granular roles



locals {locals {

  # ============================================================================  # ============================================================================

  # FUNCIÓN DE NORMALIZACIÓN AUTOMÁTICA  # FUNCIÓN DE NORMALIZACIÓN AUTOMÁTICA

  # ============================================================================  # ============================================================================

  # Convierte CUALQUIER input a lowercase sin espacios ni guiones  # Convierte CUALQUIER input a lowercase sin espacios ni guiones

  normalize_value = function(input) {  normalize_value = function(input) {

    return lower(replace(replace(tostring(input), " ", ""), "-", ""))    return lower(replace(replace(tostring(input), " ", ""), "-", ""))

  }  }

    

  # ============================================================================  # ============================================================================

  # DYNAMIC POLICY LOADER  # DYNAMIC POLICY LOADER

  # ============================================================================  # ============================================================================

  # Cargar catálogo de políticas dinámicamente  # Cargar catálogo de políticas dinámicamente

  policies_catalog_raw = file("${path.root}/../../catalog/policies.yaml")  policies_catalog_raw = file("${path.root}/../../catalog/policies.yaml")

  policies_catalog = yamldecode(local.policies_catalog_raw)  policies_catalog = yamldecode(local.policies_catalog_raw)

    

  # Extraer políticas MCI TagBased automáticamente  # Extraer políticas MCI TagBased automáticamente

  mci_policies = {  mci_policies = {

    for policy_name, policy_config in local.policies_catalog.policies :     for policy_name, policy_config in local.policies_catalog.policies : 

    policy_name => policy_config    policy_name => policy_config

    if can(regex("^MCI-.+-TagBased-.+$", policy_name))    if can(regex("^MCI-.+-TagBased-.+$", policy_name))

  }  }

    

  # Tags canónicos base para todos los recursos (TODO LOWERCASE)  # Tags canónicos base para todos los recursos (TODO LOWERCASE)

  base_canonical_tags = {  base_canonical_tags = {

    Ambiente           = "dev"    Ambiente           = "dev"

    País              = "rg"     País              = "rg" 

    Dirección         = "tecnología"    Dirección         = "tecnología"

    Gerencia          = "mci"    Gerencia          = "mci"

    Cuenta            = data.aws_caller_identity.current.account_id    Cuenta            = data.aws_caller_identity.current.account_id

    Módulo            = "iamroles"    Módulo            = "iamroles"

    "Alcance SOX"     = "no"    "Alcance SOX"     = "no"

    Propietario       = "devopsteam"    Propietario       = "devopsteam"

    Proveedor         = "claro"    Proveedor         = "claro"

    Layer             = "security"    Layer             = "security"

    Dominio           = "identity"    Dominio           = "identity"

    Subdominio        = "iam"    Subdominio        = "iam"

    Soporte           = "devopsclarocomm"    Soporte           = "devopsclarocomm"

    Contacto          = "devopsclarocomm"    Contacto          = "devopsclarocomm"

    Proyecto          = "abacframework"    Proyecto          = "abacframework"

    "Fechas de Creación" = formatdate("YYYY-MM-DD'T'hh:mm:ssZ", timestamp())    "Fechas de Creación" = formatdate("YYYY-MM-DD'T'hh:mm:ssZ", timestamp())

    "Creado Por"      = "terraformiac"    "Creado Por"      = "terraformiac"

    "Tipo de Recurso" = "iamrole"    "Tipo de Recurso" = "iamrole"

    "Ciclo de Vida"   = "active"    "Ciclo de Vida"   = "active"

    Versión           = "2.0"    Versión           = "2.0"

    "Map-migrated"    = "migrole001"    "Map-migrated"    = "migrole001"

  }  }



  # Buscar todos los archivos JSON de roles en gerencias/  # Buscar todos los archivos JSON de roles en gerencias/

  role_files = fileset("${path.root}/../../gerencias", "**/rol-*.json")  role_files = fileset("${path.root}/../../gerencias", "**/rol-*.json")



  # Procesar cada archivo de rol  # Procesar cada archivo de rol

  roles = {  roles = {

    for role_file in local.role_files :    for role_file in local.role_files :

    replace(basename(role_file), ".json", "") => jsondecode(file("${path.root}/../../gerencias/${role_file}"))    replace(basename(role_file), ".json", "") => jsondecode(file("${path.root}/../../gerencias/${role_file}"))

    if can(jsondecode(file("${path.root}/../../gerencias/${role_file}")))    if can(jsondecode(file("${path.root}/../../gerencias/${role_file}")))

  }  }



  # Extraer área/gerencia del path del archivo para tags automáticos  # Extraer área/gerencia del path del archivo para tags automáticos

  role_areas = {  role_areas = {

    for role_file in local.role_files :    for role_file in local.role_files :

    replace(basename(role_file), ".json", "") => lower(length(split("/", role_file)) >= 2 ? split("/", role_file)[1] : split("/", role_file)[0])    replace(basename(role_file), ".json", "") => lower(length(split("/", role_file)) >= 2 ? split("/", role_file)[1] : split("/", role_file)[0])

  }  }



  # ============================================================================  # ============================================================================

  # VALIDACIÓN DE TAGS OBLIGATORIOS  # VALIDACIÓN DE TAGS OBLIGATORIOS

  # ============================================================================  # ============================================================================

  # Verificar que todos los roles tengan los tags mínimos requeridos  # Verificar que todos los roles tengan los tags mínimos requeridos

  roles_missing_tags = [  roles_missing_tags = [

    for role_name, role_data in local.roles : {    for role_name, role_data in local.roles : {

      role = role_name      role = role_name

      missing_tags = [      missing_tags = [

        for required_tag in ["Equipo", "Ambiente", "Proyecto"] :        for required_tag in ["Equipo", "Ambiente", "Proyecto"] :

        required_tag if !contains(keys(try(role_data.metadata.tags, {})), required_tag)        required_tag if !contains(keys(try(role_data.metadata.tags, {})), required_tag)

      ]      ]

    }    }

    if length([    if length([

      for required_tag in ["Equipo", "Ambiente", "Proyecto"] :      for required_tag in ["Equipo", "Ambiente", "Proyecto"] :

      required_tag if !contains(keys(try(role_data.metadata.tags, {})), required_tag)      required_tag if !contains(keys(try(role_data.metadata.tags, {})), required_tag)

    ]) > 0    ]) > 0

  ]  ]



  # Generar error si hay roles sin tags - usar validation en data source  # Generar error si hay roles sin tags - usar validation en data source

  validate_tags_count = length(local.roles_missing_tags)  validate_tags_count = length(local.roles_missing_tags)



  # Mapping de policy documents a módulos  # ============================================================================

  policy_documents = {  # VALIDACIÓN DE TAGS ÚNICOS (case-insensitive)

    "s3.s3_tag_based_read"              = module.s3_policies.s3_tag_based_read_policy_json  # ============================================================================

    "s3.s3_tag_based_write"             = module.s3_policies.s3_tag_based_write_policy_json  # Detectar tags duplicados case-insensitive antes del deploy

    "dynamodb.dynamodb_tag_based_read"  = module.dynamodb_policies.dynamodb_tag_based_read_policy_json  roles_with_duplicate_tags = [

    "dynamodb.dynamodb_tag_based_write" = module.dynamodb_policies.dynamodb_tag_based_write_policy_json    for role_name, role_data in local.roles : {

    "lambda.lambda_tag_based_invoke"    = module.lambda_policies.lambda_tag_based_invoke_policy_json      role = role_name

    "sqs.sqs_tag_based_produce"         = module.sqs_policies.sqs_tag_based_produce_policy_json      all_tags = merge(

    "sqs.sqs_tag_based_consume"         = module.sqs_policies.sqs_tag_based_consume_policy_json        {

    "commons.app_standard_boundary"     = module.commons_policies.app_standard_boundary_policy_json          Name = role_data.metadata.role_name

    "commons.platform_boundary"         = module.commons_policies.platform_boundary_policy_json          "Tipo de Recurso" = "IAM Role"

  }          "Fecha de Creacion" = formatdate("YYYY-MM-DD", timestamp())

}          PolicyType = "Role"

          ManagedBy = "Terraform"

# Data source para obtener account ID        },

data "aws_caller_identity" "current" {}        try(role_data.tags, {})

      )

# BUILDING BLOCKS: Módulos de políticas ABAC      tag_keys_lower = [for k in keys(merge(

# ============================================================================        {

# Incluir todos los módulos de building blocks para acceso a sus outputs          Name = role_data.metadata.role_name

          "Tipo de Recurso" = "IAM Role"

module "s3_policies" {          "Fecha de Creacion" = formatdate("YYYY-MM-DD", timestamp())

  source = "../../policy_lib/s3"          PolicyType = "Role"

}          ManagedBy = "Terraform"

        },

module "dynamodb_policies" {        try(role_data.tags, {})

  source = "../../policy_lib/dynamodb"      )) : lower(k)]

}      has_duplicates = length(keys(merge(

        {

module "lambda_policies" {          Name = role_data.metadata.role_name

  source = "../../policy_lib/lambda"          "Tipo de Recurso" = "IAM Role"

}          "Fecha de Creacion" = formatdate("YYYY-MM-DD", timestamp())

          PolicyType = "Role"

module "sqs_policies" {          ManagedBy = "Terraform"

  source = "../../policy_lib/sqs"        },

}        try(role_data.tags, {})

      ))) != length(distinct([for k in keys(merge(

module "commons_policies" {        {

  source = "../../policy_lib/commons"          Name = role_data.metadata.role_name

}          "Tipo de Recurso" = "IAM Role"

          "Fecha de Creacion" = formatdate("YYYY-MM-DD", timestamp())

# Recursos dinámicos para crear todas las políticas MCI-*-TagBased-*          PolicyType = "Role"

resource "aws_iam_policy" "mci_policies" {          ManagedBy = "Terraform"

  for_each = local.mci_policies        },

          try(role_data.tags, {})

  name        = each.key      )) : lower(k)]))

  description = each.value.description    }

      if length(keys(merge(

  # Usar el documento de política desde los módulos building blocks      {

  policy = local.policy_documents[each.value.policy_document]        Name = role_data.metadata.role_name

          "Tipo de Recurso" = "IAM Role"

  # Aplicar tags canónicos desde el catálogo        "Fecha de Creacion" = formatdate("YYYY-MM-DD", timestamp())

  tags = merge(        PolicyType = "Role"

    local.base_canonical_tags,        ManagedBy = "Terraform"

    each.value.canonical_tags      },

  )      try(role_data.tags, {})

}    ))) != length(distinct([for k in keys(merge(

      {

# ============================================================================        Name = role_data.metadata.role_name

# VALIDACIÓN: Check obligatorio de tags         "Tipo de Recurso" = "IAM Role"

# ============================================================================        "Fecha de Creacion" = formatdate("YYYY-MM-DD", timestamp())

check "validate_required_tags" {        PolicyType = "Role"

  assert {        ManagedBy = "Terraform"

    condition = length(local.roles_missing_tags) == 0      },

    error_message = <<-EOT      try(role_data.tags, {})

    ❌ ROLES SIN ETIQUETAS OBLIGATORIAS:    )) : lower(k)]))

      ]

    ${join("\n", [}

      for invalid in local.roles_missing_tags :

      "  - ${invalid.role}: faltan tags ${join(", ", invalid.missing_tags)}"# ============================================================================

    ])}# VALIDACIÓN: Check obligatorio de tags 

    # ============================================================================

    🛡️ Todos los roles deben incluir los tags: Equipo, Ambiente, Proyectocheck "validate_required_tags" {

      assert {

    Ejemplo correcto en archivo JSON del rol:    condition = length(local.roles_missing_tags) == 0

    "tags": {    error_message = <<-EOT

      "Equipo": "BI-Team",    ❌ ROLES SIN ETIQUETAS OBLIGATORIAS:

      "Ambiente": "dev",    

      "Proyecto": "DataAnalytics"    ${join("\n", [

    }      for invalid in local.roles_missing_tags :

    EOT      "  - ${invalid.role}: faltan tags ${join(", ", invalid.missing_tags)}"

  }    ])}

}    

    🛡️ Todos los roles deben incluir los tags: Equipo, Ambiente, Proyecto

# ============================================================================    

# PERMISSION BOUNDARIES: MCI Enterprise Security    Ejemplo correcto en archivo JSON del rol:

# ============================================================================    "tags": {

      "Equipo": "BI-Team",

# Standard Application Boundary      "Ambiente": "dev",

module "app_standard_boundary" {      "Proyecto": "DataAnalytics"

  source = "../../modules/iam-managed-policy"    }

      EOT

  policy_name        = "App-StandardBoundary"  }

  policy_description = "Standard permission boundary for application roles"}

  policy_document    = module.commons_policies.app_standard_boundary_policy_json

  # VALIDACIÓN: Check para tags duplicados case-insensitive

  canonical_tags = merge(check "validate_unique_tags" {

    local.base_canonical_tags,  assert {

    {    condition = length(local.roles_with_duplicate_tags) == 0

      Módulo         = "permissionboundaries"    error_message = <<-EOT

      "Alcance SOX"  = "sí"    ❌ ROLES CON TAGS DUPLICADOS (case-insensitive):

      Aplicación     = "permissionboundaries"    

      Dominio        = "permissionboundaries"    ${join("\n", [

      Subdominio     = "application"      for invalid in local.roles_with_duplicate_tags :

      Proyecto       = "securityframework"      "  - ${invalid.role}: tiene tags que AWS considera duplicados"

    }    ])}

  )    

}    🛡️ AWS no permite tags con nombres similares (case-insensitive)

    Ejemplos de conflictos: Environment vs environment, Team vs team, etc.

# Platform Infrastructure Boundary      

module "platform_boundary" {    Usa nomenclatura única y específica para evitar conflictos.

  source = "../../modules/iam-managed-policy"    EOT

    }

  policy_name        = "Platform-Boundary"}# ============================================================================

  policy_description = "Platform permission boundary for infrastructure roles"# BUILDING BLOCKS: Módulos de políticas ABAC

  policy_document    = module.commons_policies.platform_boundary_policy_json# ============================================================================

  # Incluir todos los módulos de building blocks para acceso a sus outputs

  canonical_tags = merge(

    local.base_canonical_tags,module "s3_policies" {

    {  source = "../../policy_lib/s3"

      Módulo         = "permissionboundaries"}

      "Alcance SOX"  = "sí"

      Aplicación     = "permissionboundaries"module "dynamodb_policies" {

      Dominio        = "permissionboundaries"  source = "../../policy_lib/dynamodb"

      Subdominio     = "platform"}

      Proyecto       = "securityframework"

    }module "lambda_policies" {

  )  source = "../../policy_lib/lambda"

}}



# ============================================================================module "sqs_policies" {

# IAM ROLES: Creación dinámica desde archivos JSON  source = "../../policy_lib/sqs"

# ============================================================================}



module "iam_roles" {module "commons_policies" {

  source = "../../modules/iam-role"  source = "../../policy_lib/commons"

  for_each = local.roles}



  # Configuración básica del rol# BUILDING BLOCKS: Políticas MCI genéricas (RECURSOS DINÁMICOS)

  role_name          = each.value.metadata.role_name# ============================================================================

  assume_role_policy = jsonencode(each.value.assume_role_policy)# Sistema escalable: Se crean automáticamente desde catalog/policies.yaml

  role_description   = try(each.value.description, "IAM role for ${each.value.metadata.role_name}")

# Mapping de policy documents a módulos

  # Permission boundary automático según el tipo de rollocals {

  permission_boundary_arn = try(each.value.metadata.aplicacion, "") != "" ? module.app_standard_boundary.policy_arn : module.platform_boundary.policy_arn  policy_documents = {

    "s3.s3_tag_based_read"              = module.s3_policies.s3_tag_based_read_policy_json

  # Políticas AWS managed    "s3.s3_tag_based_write"             = module.s3_policies.s3_tag_based_write_policy_json

  managed_policy_arns = try(each.value.metadata.policies.aws_managed, [])    "dynamodb.dynamodb_tag_based_read"  = module.dynamodb_policies.dynamodb_tag_based_read_policy_json

    "dynamodb.dynamodb_tag_based_write" = module.dynamodb_policies.dynamodb_tag_based_write_policy_json

  # Políticas inline como mapa    "lambda.lambda_tag_based_invoke"    = module.lambda_policies.lambda_tag_based_invoke_policy_json

  inline_policies = try(each.value.metadata.policies.inline != null ? {    "sqs.sqs_tag_based_produce"         = module.sqs_policies.sqs_tag_based_produce_policy_json

    "inline-policy" = jsonencode(each.value.metadata.policies.inline)    "sqs.sqs_tag_based_consume"         = module.sqs_policies.sqs_tag_based_consume_policy_json

  } : {}, {})    "commons.app_standard_boundary"     = module.commons_policies.app_standard_boundary_policy_json

    "commons.platform_boundary"         = module.commons_policies.platform_boundary_policy_json

  # Tags canónicos requeridos (AUTO-NORMALIZACIÓN a lowercase)  }

  canonical_tags = merge(}

    local.base_canonical_tags,

    {# Recursos dinámicos para crear todas las políticas MCI-*-TagBased-*

      Name        = each.value.metadata.role_nameresource "aws_iam_policy" "mci_policies" {

      Aplicación  = local.normalize_value(try(each.value.metadata.aplicacion, "unknown"))  for_each = local.mci_policies

      Ambiente    = local.normalize_value(try(each.value.metadata.ambiente, "dev"))  

      País        = local.normalize_value(try(each.value.metadata.pais.code, "rg"))  name        = each.key

      Gerencia    = local.normalize_value(try(each.value.metadata.gerencia.code, "mci"))  description = each.value.description

    }  

  )  # Usar el documento de política desde los módulos building blocks

    policy = local.policy_documents[each.value.policy_document]

  # Tags adicionales del rol específico  

  tags = try(each.value.metadata.tags, {})  # Aplicar tags canónicos desde el catálogo

}  tags = merge(

    local.base_canonical_tags,

# ============================================================================    each.value.canonical_tags

# OUTPUTS: Información de las políticas y roles creados  )

# ============================================================================}



output "roles_created" {# Data source para obtener account ID

  description = "Information about IAM roles created"data "aws_caller_identity" "current" {}

  value = {

    for k, v in module.iam_roles : k => {# ============================================================================

      role_name = v.role_name# TAG-BASED POLICIES: Políticas dinámicas basadas en etiquetas

      role_arn  = v.role_arn# ============================================================================

    }

  }# Crear políticas basadas en tags de equipo

}resource "aws_iam_policy" "team_tag_policies" {

  for_each = var.team_tag_policies

output "mci_building_blocks" {

  description = "Available MCI building block policies (DYNAMIC)"  name        = "MCI-${each.key}"

  value = {  description = each.value.description

    for policy_name, policy_data in aws_iam_policy.mci_policies : 

    policy_name => {  policy = templatefile(

      policy_name = policy_data.name    "${path.root}/../../politicas/${each.value.policy_template}.json",

      policy_arn  = policy_data.arn    {

      description = local.mci_policies[policy_name].description      team_name   = each.value.team_name

    }      environment = each.value.environment

  }      project_name = each.value.project_name

}    }

  )

output "app_standard_boundary_arn" {

  description = "ARN of the application standard permission boundary"  tags = merge(

  value       = module.app_standard_boundary.policy_arn    {

}      PolicyType    = "Tag-Based"

      TeamName      = each.value.team_name

output "platform_boundary_arn" {      Environment   = each.value.environment

  description = "ARN of the platform permission boundary"      ProjectName   = each.value.project_name

  value       = module.platform_boundary.policy_arn    },

}    var.policy_tags
  )
}

# Crear roles IAM dinámicamente con tags por área
module "iam_roles" {
  source = "../../modules/iam-role"

  for_each = local.roles

  role_name                = each.value.metadata.role_name
  description              = try(each.value.metadata.description, "IAM Role managed by Terraform")
  trust_policy_document    = jsonencode(each.value.assume_role_policy)
  
  # Políticas AWS administradas
  managed_policy_arns = try(each.value.policies.aws_managed, [])

  # Políticas inline como mapa
  inline_policies = try(each.value.policies.inline != null ? {
    "inline-policy" = jsonencode(each.value.policies.inline)
  } : {}, {})

  # Tags canónicos requeridos (AUTO-NORMALIZACIÓN a lowercase)
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
  
  # Tags adicionales del rol específico
  tags = try(each.value.tags, {})
}

# ============================================================================
# ATTACHMENTS DINÁMICOS: Políticas MCI escalables
# ============================================================================
# Sistema que escala automáticamente con nuevas políticas en el catálogo

# Adjuntar políticas MCI genéricas a los roles (DINÁMICO)
resource "aws_iam_role_policy_attachment" "mci_policy_attachments" {
  for_each = merge([
    for role_key, role_config in local.roles : {
      for policy_name in try(role_config.policies.mci_generic, []) :
      "${role_key}-${policy_name}" => {
        role_key    = role_key
        policy_name = policy_name
      }
      # Solo incluir si la política existe en el catálogo
      if contains(keys(local.mci_policies), policy_name)
    }
  ]...)

  role       = module.iam_roles[each.value.role_key].role_name
  
  # Mapear dinámicamente a ARNs usando el recurso dinámico
  policy_arn = aws_iam_policy.mci_policies[each.value.policy_name].arn
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
  description = "Available MCI building block policies (DYNAMIC)"
  value = {
    for policy_name, policy_data in aws_iam_policy.mci_policies : 
    policy_name => {
      policy_name = policy_data.name
      policy_arn  = policy_data.arn
      description = local.mci_policies[policy_name].description
    }
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
