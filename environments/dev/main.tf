# Main configuration for IAM roles deployment - ENTERPRISE ARCHITECTURE# Main configuration for IAM roles deployment - ENTERPRISE ARCHITECTURE# Main configuration for IAM roles deployment - ENTERPRISE ARCHITECTURE

# Building blocks approach: Generic policies + Granular roles

# Building blocks approach: Generic policies + Granular roles# Building blocks approach: Generic policies + Granular roles

locals {

  # Convierte CUALQUIER input a lowercase sin espacios ni guiones

  normalize_value = function(input) {

    return lower(replace(replace(tostring(input), " ", ""), "-", ""))locals {locals {

  }

    # ============================================================================  # ============================================================================

  # Cargar catálogo de políticas dinámicamente

  policies_catalog_raw = file("${path.root}/../../catalog/policies.yaml")  # FUNCIÓN DE NORMALIZACIÓN AUTOMÁTICA  # FUNCIÓN DE NORMALIZACIÓN AUTOMÁTICA

  policies_catalog = yamldecode(local.policies_catalog_raw)

    # ============================================================================  # ============================================================================

  # Extraer políticas MCI TagBased automáticamente

  mci_policies = {  # Convierte CUALQUIER input a lowercase sin espacios ni guiones  # Convierte CUALQUIER input a lowercase sin espacios ni guiones

    for policy_name, policy_config in local.policies_catalog.policies : 

    policy_name => policy_config  normalize_value = function(input) {  normalize_value = function(input) {

    if can(regex("^MCI-.+-TagBased-.+$", policy_name))

  }    return lower(replace(replace(tostring(input), " ", ""), "-", ""))    return lower(replace(replace(tostring(input), " ", ""), "-", ""))

  

  # Tags canónicos base para todos los recursos  }  }

  base_canonical_tags = {

    Ambiente           = "dev"    

    País              = "rg" 

    Dirección         = "tecnología"  # ============================================================================  # ============================================================================

    Gerencia          = "mci"

    Cuenta            = data.aws_caller_identity.current.account_id  # DYNAMIC POLICY LOADER  # DYNAMIC POLICY LOADER

    Módulo            = "iamroles"

    "Alcance SOX"     = "no"  # ============================================================================  # ============================================================================

    Propietario       = "devopsteam"

    Proveedor         = "claro"  # Cargar catálogo de políticas dinámicamente  # Cargar catálogo de políticas dinámicamente

    Layer             = "security"

    Dominio           = "identity"  policies_catalog_raw = file("${path.root}/../../catalog/policies.yaml")  policies_catalog_raw = file("${path.root}/../../catalog/policies.yaml")

    Subdominio        = "iam"

    Soporte           = "devopsclarocomm"  policies_catalog = yamldecode(local.policies_catalog_raw)  policies_catalog = yamldecode(local.policies_catalog_raw)

    Contacto          = "devopsclarocomm"

    Proyecto          = "abacframework"    

    "Fechas de Creación" = formatdate("YYYY-MM-DD'T'hh:mm:ssZ", timestamp())

    "Creado Por"      = "terraformiac"  # Extraer políticas MCI TagBased automáticamente  # Extraer políticas MCI TagBased automáticamente

    "Tipo de Recurso" = "iamrole"

    "Ciclo de Vida"   = "active"  mci_policies = {  mci_policies = {

    Versión           = "2.0"

    "Map-migrated"    = "migrole001"    for policy_name, policy_config in local.policies_catalog.policies :     for policy_name, policy_config in local.policies_catalog.policies : 

  }

    policy_name => policy_config    policy_name => policy_config

  # Buscar archivos JSON de roles

  role_files = fileset("${path.root}/../../gerencias", "**/rol-*.json")    if can(regex("^MCI-.+-TagBased-.+$", policy_name))    if can(regex("^MCI-.+-TagBased-.+$", policy_name))



  # Procesar archivos de rol válidos  }  }

  roles = {

    for role_file in local.role_files :    

    replace(basename(role_file), ".json", "") => jsondecode(file("${path.root}/../../gerencias/${role_file}"))

    if can(jsondecode(file("${path.root}/../../gerencias/${role_file}")))  # Tags canónicos base para todos los recursos (TODO LOWERCASE)  # Tags canónicos base para todos los recursos (TODO LOWERCASE)

  }

  base_canonical_tags = {  base_canonical_tags = {

  # Validación de tags obligatorios

  roles_missing_tags = [    Ambiente           = "dev"    Ambiente           = "dev"

    for role_name, role_data in local.roles : {

      role = role_name    País              = "rg"     País              = "rg" 

      missing_tags = [

        for required_tag in ["Equipo", "Ambiente", "Proyecto"] :    Dirección         = "tecnología"    Dirección         = "tecnología"

        required_tag if !contains(keys(try(role_data.metadata.tags, {})), required_tag)

      ]    Gerencia          = "mci"    Gerencia          = "mci"

    }

    if length([    Cuenta            = data.aws_caller_identity.current.account_id    Cuenta            = data.aws_caller_identity.current.account_id

      for required_tag in ["Equipo", "Ambiente", "Proyecto"] :

      required_tag if !contains(keys(try(role_data.metadata.tags, {})), required_tag)    Módulo            = "iamroles"    Módulo            = "iamroles"

    ]) > 0

  ]    "Alcance SOX"     = "no"    "Alcance SOX"     = "no"

}

    Propietario       = "devopsteam"    Propietario       = "devopsteam"

# Data source para obtener account ID

data "aws_caller_identity" "current" {}    Proveedor         = "claro"    Proveedor         = "claro"



# BUILDING BLOCKS: Módulos de políticas ABAC    Layer             = "security"    Layer             = "security"

module "s3_policies" {

  source = "../../policy_lib/s3"    Dominio           = "identity"    Dominio           = "identity"

}

    Subdominio        = "iam"    Subdominio        = "iam"

module "dynamodb_policies" {

  source = "../../policy_lib/dynamodb"    Soporte           = "devopsclarocomm"    Soporte           = "devopsclarocomm"

}

    Contacto          = "devopsclarocomm"    Contacto          = "devopsclarocomm"

module "lambda_policies" {

  source = "../../policy_lib/lambda"    Proyecto          = "abacframework"    Proyecto          = "abacframework"

}

    "Fechas de Creación" = formatdate("YYYY-MM-DD'T'hh:mm:ssZ", timestamp())    "Fechas de Creación" = formatdate("YYYY-MM-DD'T'hh:mm:ssZ", timestamp())

module "sqs_policies" {

  source = "../../policy_lib/sqs"    "Creado Por"      = "terraformiac"    "Creado Por"      = "terraformiac"

}

    "Tipo de Recurso" = "iamrole"    "Tipo de Recurso" = "iamrole"

module "commons_policies" {

  source = "../../policy_lib/commons"    "Ciclo de Vida"   = "active"    "Ciclo de Vida"   = "active"

}

    Versión           = "2.0"    Versión           = "2.0"

# Mapeo de documentos de política

locals {    "Map-migrated"    = "migrole001"    "Map-migrated"    = "migrole001"

  policy_documents = {

    "s3.s3_tag_based_read"              = module.s3_policies.s3_tag_based_read_policy_json  }  }

    "s3.s3_tag_based_write"             = module.s3_policies.s3_tag_based_write_policy_json

    "dynamodb.dynamodb_tag_based_read"  = module.dynamodb_policies.dynamodb_tag_based_read_policy_json

    "dynamodb.dynamodb_tag_based_write" = module.dynamodb_policies.dynamodb_tag_based_write_policy_json

    "lambda.lambda_tag_based_invoke"    = module.lambda_policies.lambda_tag_based_invoke_policy_json  # Buscar todos los archivos JSON de roles en gerencias/  # Buscar todos los archivos JSON de roles en gerencias/

    "sqs.sqs_tag_based_produce"         = module.sqs_policies.sqs_tag_based_produce_policy_json

    "sqs.sqs_tag_based_consume"         = module.sqs_policies.sqs_tag_based_consume_policy_json  role_files = fileset("${path.root}/../../gerencias", "**/rol-*.json")  role_files = fileset("${path.root}/../../gerencias", "**/rol-*.json")

    "commons.app_standard_boundary"     = module.commons_policies.app_standard_boundary_policy_json

    "commons.platform_boundary"         = module.commons_policies.platform_boundary_policy_json

  }

}  # Procesar cada archivo de rol  # Procesar cada archivo de rol



# Crear políticas MCI automáticamente  roles = {  roles = {

resource "aws_iam_policy" "mci_policies" {

  for_each = local.mci_policies    for role_file in local.role_files :    for role_file in local.role_files :

  

  name        = each.key    replace(basename(role_file), ".json", "") => jsondecode(file("${path.root}/../../gerencias/${role_file}"))    replace(basename(role_file), ".json", "") => jsondecode(file("${path.root}/../../gerencias/${role_file}"))

  description = each.value.description

  policy      = local.policy_documents[each.value.policy_document]    if can(jsondecode(file("${path.root}/../../gerencias/${role_file}")))    if can(jsondecode(file("${path.root}/../../gerencias/${role_file}")))

  

  tags = merge(  }  }

    local.base_canonical_tags,

    each.value.canonical_tags

  )

}  # Extraer área/gerencia del path del archivo para tags automáticos  # Extraer área/gerencia del path del archivo para tags automáticos



# Validación de tags obligatorios  role_areas = {  role_areas = {

check "validate_required_tags" {

  assert {    for role_file in local.role_files :    for role_file in local.role_files :

    condition = length(local.roles_missing_tags) == 0

    error_message = <<-EOT    replace(basename(role_file), ".json", "") => lower(length(split("/", role_file)) >= 2 ? split("/", role_file)[1] : split("/", role_file)[0])    replace(basename(role_file), ".json", "") => lower(length(split("/", role_file)) >= 2 ? split("/", role_file)[1] : split("/", role_file)[0])

    ❌ ROLES SIN ETIQUETAS OBLIGATORIAS:

      }  }

    ${join("\n", [

      for invalid in local.roles_missing_tags :

      "  - ${invalid.role}: faltan tags ${join(", ", invalid.missing_tags)}"

    ])}  # ============================================================================  # ============================================================================

    

    🛡️ Todos los roles deben incluir los tags: Equipo, Ambiente, Proyecto  # VALIDACIÓN DE TAGS OBLIGATORIOS  # VALIDACIÓN DE TAGS OBLIGATORIOS

    EOT

  }  # ============================================================================  # ============================================================================

}

  # Verificar que todos los roles tengan los tags mínimos requeridos  # Verificar que todos los roles tengan los tags mínimos requeridos

# Permission Boundaries

module "app_standard_boundary" {  roles_missing_tags = [  roles_missing_tags = [

  source = "../../modules/iam-managed-policy"

      for role_name, role_data in local.roles : {    for role_name, role_data in local.roles : {

  policy_name        = "App-StandardBoundary"

  policy_description = "Standard permission boundary for application roles"      role = role_name      role = role_name

  policy_document    = module.commons_policies.app_standard_boundary_policy_json

        missing_tags = [      missing_tags = [

  canonical_tags = merge(

    local.base_canonical_tags,        for required_tag in ["Equipo", "Ambiente", "Proyecto"] :        for required_tag in ["Equipo", "Ambiente", "Proyecto"] :

    {

      Módulo         = "permissionboundaries"        required_tag if !contains(keys(try(role_data.metadata.tags, {})), required_tag)        required_tag if !contains(keys(try(role_data.metadata.tags, {})), required_tag)

      "Alcance SOX"  = "sí"

      Aplicación     = "permissionboundaries"      ]      ]

      Dominio        = "permissionboundaries"

      Subdominio     = "application"    }    }

      Proyecto       = "securityframework"

    }    if length([    if length([

  )

}      for required_tag in ["Equipo", "Ambiente", "Proyecto"] :      for required_tag in ["Equipo", "Ambiente", "Proyecto"] :



module "platform_boundary" {      required_tag if !contains(keys(try(role_data.metadata.tags, {})), required_tag)      required_tag if !contains(keys(try(role_data.metadata.tags, {})), required_tag)

  source = "../../modules/iam-managed-policy"

      ]) > 0    ]) > 0

  policy_name        = "Platform-Boundary"

  policy_description = "Platform permission boundary for infrastructure roles"  ]  ]

  policy_document    = module.commons_policies.platform_boundary_policy_json

  

  canonical_tags = merge(

    local.base_canonical_tags,  # Generar error si hay roles sin tags - usar validation en data source  # Generar error si hay roles sin tags - usar validation en data source

    {

      Módulo         = "permissionboundaries"  validate_tags_count = length(local.roles_missing_tags)  validate_tags_count = length(local.roles_missing_tags)

      "Alcance SOX"  = "sí"

      Aplicación     = "permissionboundaries"

      Dominio        = "permissionboundaries"

      Subdominio     = "platform"  # Mapping de policy documents a módulos  # ============================================================================

      Proyecto       = "securityframework"

    }  policy_documents = {  # VALIDACIÓN DE TAGS ÚNICOS (case-insensitive)

  )

}    "s3.s3_tag_based_read"              = module.s3_policies.s3_tag_based_read_policy_json  # ============================================================================



# Crear roles IAM    "s3.s3_tag_based_write"             = module.s3_policies.s3_tag_based_write_policy_json  # Detectar tags duplicados case-insensitive antes del deploy

module "iam_roles" {

  source = "../../modules/iam-role"    "dynamodb.dynamodb_tag_based_read"  = module.dynamodb_policies.dynamodb_tag_based_read_policy_json  roles_with_duplicate_tags = [

  for_each = local.roles

    "dynamodb.dynamodb_tag_based_write" = module.dynamodb_policies.dynamodb_tag_based_write_policy_json    for role_name, role_data in local.roles : {

  role_name          = each.value.metadata.role_name

  assume_role_policy = jsonencode(each.value.assume_role_policy)    "lambda.lambda_tag_based_invoke"    = module.lambda_policies.lambda_tag_based_invoke_policy_json      role = role_name

  role_description   = try(each.value.description, "IAM role for ${each.value.metadata.role_name}")

    "sqs.sqs_tag_based_produce"         = module.sqs_policies.sqs_tag_based_produce_policy_json      all_tags = merge(

  permission_boundary_arn = try(each.value.metadata.aplicacion, "") != "" ? module.app_standard_boundary.policy_arn : module.platform_boundary.policy_arn

  managed_policy_arns = try(each.value.metadata.policies.aws_managed, [])    "sqs.sqs_tag_based_consume"         = module.sqs_policies.sqs_tag_based_consume_policy_json        {



  inline_policies = try(each.value.metadata.policies.inline != null ? {    "commons.app_standard_boundary"     = module.commons_policies.app_standard_boundary_policy_json          Name = role_data.metadata.role_name

    "inline-policy" = jsonencode(each.value.metadata.policies.inline)

  } : {}, {})    "commons.platform_boundary"         = module.commons_policies.platform_boundary_policy_json          "Tipo de Recurso" = "IAM Role"



  canonical_tags = merge(  }          "Fecha de Creacion" = formatdate("YYYY-MM-DD", timestamp())

    local.base_canonical_tags,

    {}          PolicyType = "Role"

      Name        = each.value.metadata.role_name

      Aplicación  = local.normalize_value(try(each.value.metadata.aplicacion, "unknown"))          ManagedBy = "Terraform"

      Ambiente    = local.normalize_value(try(each.value.metadata.ambiente, "dev"))

      País        = local.normalize_value(try(each.value.metadata.pais.code, "rg"))# Data source para obtener account ID        },

      Gerencia    = local.normalize_value(try(each.value.metadata.gerencia.code, "mci"))

    }data "aws_caller_identity" "current" {}        try(role_data.tags, {})

  )

        )

  tags = try(each.value.metadata.tags, {})

}# BUILDING BLOCKS: Módulos de políticas ABAC      tag_keys_lower = [for k in keys(merge(



# OUTPUTS# ============================================================================        {

output "roles_created" {

  description = "Information about IAM roles created"# Incluir todos los módulos de building blocks para acceso a sus outputs          Name = role_data.metadata.role_name

  value = {

    for k, v in module.iam_roles : k => {          "Tipo de Recurso" = "IAM Role"

      role_name = v.role_name

      role_arn  = v.role_arnmodule "s3_policies" {          "Fecha de Creacion" = formatdate("YYYY-MM-DD", timestamp())

    }

  }  source = "../../policy_lib/s3"          PolicyType = "Role"

}

}          ManagedBy = "Terraform"

output "mci_building_blocks" {

  description = "Available MCI building block policies"        },

  value = {

    for policy_name, policy_data in aws_iam_policy.mci_policies : module "dynamodb_policies" {        try(role_data.tags, {})

    policy_name => {

      policy_name = policy_data.name  source = "../../policy_lib/dynamodb"      )) : lower(k)]

      policy_arn  = policy_data.arn

      description = local.mci_policies[policy_name].description}      has_duplicates = length(keys(merge(

    }

  }        {

}

module "lambda_policies" {          Name = role_data.metadata.role_name

output "app_standard_boundary_arn" {

  description = "ARN of the application standard permission boundary"  source = "../../policy_lib/lambda"          "Tipo de Recurso" = "IAM Role"

  value       = module.app_standard_boundary.policy_arn

}}          "Fecha de Creacion" = formatdate("YYYY-MM-DD", timestamp())



output "platform_boundary_arn" {          PolicyType = "Role"

  description = "ARN of the platform permission boundary"

  value       = module.platform_boundary.policy_arnmodule "sqs_policies" {          ManagedBy = "Terraform"

}
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
