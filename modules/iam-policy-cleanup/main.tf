# modules/iam-policy-cleanup/main.tf
# Módulo para eliminar políticas IAM obsoletas con naming incorrecto

terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

# Data source para obtener políticas existentes con patrón obsoleto
data "aws_iam_policies" "obsolete_policies" {}

# Data source para obtener información de la cuenta
data "aws_caller_identity" "current" {}

# Filtrar políticas que coincidan con el patrón obsoleto: githubactions-*-[números]
locals {
  # Obtener todas las políticas IAM
  all_policies = data.aws_iam_policies.obsolete_policies.names
  
  # Filtrar políticas con el patrón obsoleto (con sufijos numéricos aleatorios)
  obsolete_policy_names = [
    for policy_name in local.all_policies : policy_name
    if can(regex("^githubactions-(basepermissions|iammanagement|terraformbackend)-[0-9]+$", policy_name))
  ]
  
  # Crear mapa de políticas obsoletas para resource for_each
  obsolete_policies_map = {
    for policy_name in local.obsolete_policy_names : policy_name => {
      name = policy_name
      arn  = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:policy/${policy_name}"
    }
  }
}

# Data source para obtener detalles de cada política obsoleta
data "aws_iam_policy" "obsolete" {
  for_each = local.obsolete_policies_map
  name     = each.value.name
}

# Resource para eliminar políticas obsoletas usando null_resource con provisioners
resource "null_resource" "cleanup_obsolete_policies" {
  for_each = var.cleanup_enabled ? local.obsolete_policies_map : {}

  # Trigger cuando cambie la política
  triggers = {
    policy_arn = each.value.arn
    cleanup_id = "${each.key}-cleanup"
    timestamp  = timestamp()
  }

  # Ejecutar script de eliminación
  provisioner "local-exec" {
    command = <<-EOT
      echo "🔍 Checking obsolete policy: ${each.key}"
      
      # Obtener ARN de la política
      POLICY_ARN="${each.value.arn}"
      
      # Verificar si la política existe
      if aws iam get-policy --policy-arn "$POLICY_ARN" >/dev/null 2>&1; then
        echo "📋 Policy ${each.key} exists, proceeding with cleanup..."
        
        # Desacoplar de todos los roles primero
        echo "🔍 Checking attached roles..."
        ATTACHED_ROLES=$(aws iam list-entities-for-policy --policy-arn "$POLICY_ARN" --query "PolicyRoles[].RoleName" --output text)
        
        if [ -n "$ATTACHED_ROLES" ] && [ "$ATTACHED_ROLES" != "None" ]; then
          echo "🔓 Detaching from roles: $ATTACHED_ROLES"
          for role in $ATTACHED_ROLES; do
            echo "🔓 Detaching ${each.key} from role $role"
            aws iam detach-role-policy --role-name "$role" --policy-arn "$POLICY_ARN"
            echo "✅ Detached from role: $role"
          done
        else
          echo "ℹ️ No roles attached to ${each.key}"
        fi
        
        # Eliminar la política
        echo "🗑️ Deleting obsolete policy: ${each.key}"
        aws iam delete-policy --policy-arn "$POLICY_ARN"
        echo "✅ Successfully deleted obsolete policy: ${each.key}"
      else
        echo "ℹ️ Policy ${each.key} does not exist, skipping..."
      fi
    EOT

    # Configurar AWS CLI
    environment = {
      AWS_DEFAULT_REGION = var.aws_region
    }
  }

  # Destruir cuando la política ya no esté en el mapa
  provisioner "local-exec" {
    when    = destroy
    command = "echo '🏁 Cleanup resource for ${self.triggers.cleanup_id} destroyed'"
  }
}