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

# Data source para obtener información de la cuenta
data "aws_caller_identity" "current" {}

# External data source para obtener políticas obsoletas via AWS CLI
data "external" "obsolete_policies" {
  program = ["bash", "-c", <<-EOT
    # Buscar todas las políticas IAM y filtrar las obsoletas
    aws iam list-policies --output json | jq -r '.Policies[] | select(.PolicyName | test("^githubactions-(basepermissions|iammanagement|terraformbackend)-[0-9]+$$")) | .PolicyName' > /tmp/obsolete_policies.txt
    
    # Crear JSON válido para Terraform (mapa de strings)
    policy_list=""
    counter=0
    
    while IFS= read -r policy || [[ -n "$$policy" ]]; do
      if [ -n "$$policy" ]; then
        if [ $$counter -gt 0 ]; then
          policy_list="$${policy_list},"
        fi
        policy_list="$${policy_list}\"policy_$${counter}\": \"$${policy}\""
        counter=$$((counter + 1))
      fi
    done < /tmp/obsolete_policies.txt
    
    # Si no hay políticas, retornar objeto vacío
    if [ -z "$$policy_list" ]; then
      echo "{}"
    else
      echo "{$${policy_list}}"
    fi
    
    # Limpiar archivo temporal
    rm -f /tmp/obsolete_policies.txt
  EOT
  ]
}

# Filtrar políticas que coincidan con el patrón obsoleto
locals {
  # Obtener políticas obsoletas del data source external (eliminar claves generadas)
  obsolete_policy_names = [for k, v in data.external.obsolete_policies.result : v if k != "policies"]
  
  # Crear mapa de políticas obsoletas para resource for_each
  obsolete_policies_map = {
    for policy_name in local.obsolete_policy_names : policy_name => {
      name = policy_name
      arn  = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:policy/${policy_name}"
    }
  }
}

# No necesitamos data source adicional, usamos el external data source

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