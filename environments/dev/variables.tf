variable "aws_region" {
  description = "AWS region for resources"
  type        = string
  default     = "us-east-1"
}

variable "aws_account_id" {
  description = "AWS Account ID"
  type        = string
  default     = "393209814297" # Tu cuenta AWS
}

variable "environment" {
  description = "Environment name"
  type        = string
  default     = "dev"
}

variable "project_name" {
  description = "Project name for resource naming"
  type        = string
  default     = "mci-aws-iam"
}

variable "policy_tags" {
  description = "Standard tags for IAM policies"
  type        = map(string)
  default     = {}
}

variable "area_owners" {
  description = "Owner per business area/gerencia"
  type        = map(string)
  default     = {}
}

variable "area_teams" {
  description = "Team per business area/gerencia"
  type        = map(string)
  default     = {}
}

variable "area_cost_centers" {
  description = "Cost center per business area/gerencia"
  type        = map(string)
  default     = {}
}

# ============================================================================
# TEAM-BASED TAG POLICIES VARIABLES
# ============================================================================

variable "team_tag_policies" {
  description = "Tag-based policies configuration by team"
  type = map(object({
    policy_template = string
    team_name      = string
    environment    = string
    project_name   = string
    description    = string
  }))
  default = {}

  validation {
    condition = alltrue([
      for k, v in var.team_tag_policies : alltrue([
        v.team_name != null && v.team_name != "",
        v.environment != null && v.environment != "",
        v.project_name != null && v.project_name != ""
      ])
    ])
    error_message = <<-EOT
    ❌ FALTAN CAMPOS OBLIGATORIOS EN team_tag_policies:
    
    Cada entrada debe incluir:
    - team_name: Nombre del equipo (ej: "BI-Team", "Development-Team")
    - environment: Ambiente (ej: "dev", "qa", "prod")
    - project_name: Nombre del proyecto (ej: "DataAnalytics")
    
    Ejemplo correcto:
    "bi-team-dynamodb-read" = {
      policy_template = "politicas/MCI-DynamoDB-TagBased-ReadOnly.json"
      team_name       = "BI-Team"
      environment     = "dev"
      project_name    = "DataAnalytics"
      description     = "DynamoDB read access for BI team"
    }
    EOT
  }

  validation {
    condition = alltrue([
      for k, v in var.team_tag_policies : contains(["dev", "qa", "prod"], v.environment)
    ])
    error_message = "❌ Todos los valores de 'environment' deben ser: 'dev', 'qa' o 'prod'"
  }
}

variable "required_resource_tags" {
  description = "Required tags for governance and compliance"
  type = object({
    dynamodb_required_tags = list(string)
    s3_required_tags      = list(string)
  })
  default = {
    dynamodb_required_tags = ["Equipo", "Ambiente", "Proyecto"]
    s3_required_tags      = ["Equipo", "Ambiente", "Proyecto"]
  }
}

variable "tag_validation_rules" {
  description = "Validation rules for tag values"
  type = object({
    valid_teams                = list(string)
    valid_environments         = list(string)
    valid_project_patterns     = list(string)
    valid_data_classifications = list(string)
  })
  default = {
    valid_teams                = ["BI-Team", "Development-Team", "Database-Team"]
    valid_environments         = ["dev", "qa", "prod"]
    valid_project_patterns     = ["DataAnalytics", "WebApps", "MobileApps"]
    valid_data_classifications = ["public", "internal", "confidential"]
  }
}
