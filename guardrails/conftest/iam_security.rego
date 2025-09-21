# guardrails/conftest/iam_security.rego
# ==========================================
# OPA REGO RULES FOR IAM SECURITY GUARDRAILS
# ==========================================

package terraform.iam

import rego.v1

# DENY WILDCARD ACTIONS WITHOUT CONDITIONS
deny contains msg if {
    some i
    input.resource_changes[i].type == "aws_iam_policy"
    policy_doc := json.unmarshal(input.resource_changes[i].change.after.policy)
    
    some j
    statement := policy_doc.Statement[j]
    statement.Effect == "Allow"
    
    # Check for wildcard actions
    actions_contains_wildcard(statement.Action)
    
    # No conditions present
    not statement.Condition
    
    msg := sprintf("IAM Policy '%s' contains wildcard actions without conditions. All wildcard actions must include appropriate conditions.", [input.resource_changes[i].address])
}

# REQUIRE PERMISSION BOUNDARY ON ALL ROLES
deny contains msg if {
    some i
    input.resource_changes[i].type == "aws_iam_role"
    role := input.resource_changes[i].change.after
    
    # Permission boundary is missing
    not role.permissions_boundary
    
    msg := sprintf("IAM Role '%s' must have a permission boundary attached. Use 'App-StandardBoundary' or 'Platform-Boundary'.", [input.resource_changes[i].address])
}

# REQUIRE CANONICAL TAGS ON ALL IAM RESOURCES
deny contains msg if {
    some i
    resource := input.resource_changes[i]
    resource.type in ["aws_iam_role", "aws_iam_policy"]
    
    required_tags := [
        "Ambiente", "País", "Dirección", "Gerencia", "Cuenta", "Módulo",
        "Alcance SOX", "Propietario", "Proveedor", "Layer", "Dominio", "Subdominio",
        "Aplicación", "Name", "Soporte", "Contacto", "Proyecto", "Fechas de Creación",
        "Creado Por", "Tipo de Recurso", "Ciclo de Vida", "Versión", "Map-migrated"
    ]
    
    resource_tags := object.get(resource.change.after, "tags", {})
    
    some tag
    tag in required_tags
    not resource_tags[tag]
    
    msg := sprintf("IAM Resource '%s' is missing required canonical tag: '%s'. All 23 canonical tags are mandatory.", [resource.address, tag])
}

# VALIDATE CANONICAL TAG VALUES
deny contains msg if {
    some i
    resource := input.resource_changes[i]
    resource.type in ["aws_iam_role", "aws_iam_policy"]
    resource_tags := object.get(resource.change.after, "tags", {})
    
    # Check País value
    pais := object.get(resource_tags, "País", "")
    pais != ""
    not pais in ["GT", "SV", "HN", "NI", "CR", "RG"]
    
    msg := sprintf("IAM Resource '%s' has invalid 'País' tag value '%s'. Must be one of: GT, SV, HN, NI, CR, RG", [resource.address, pais])
}

# REQUIRE TRUST POLICY CONDITIONS FOR SERVICE ROLES
deny contains msg if {
    some i
    resource := input.resource_changes[i]
    resource.type == "aws_iam_role"
    trust_policy := json.unmarshal(resource.change.after.assume_role_policy)
    
    some j
    statement := trust_policy.Statement[j]
    statement.Effect == "Allow"
    statement.Principal.Service
    
    # Missing SourceAccount condition
    not statement.Condition.StringEquals["aws:SourceAccount"]
    
    msg := sprintf("IAM Role '%s' service trust policy must include 'aws:SourceAccount' condition for security.", [resource.address])
}

# REQUIRE s3:prefix CONDITION FOR S3 ListBucket
deny contains msg if {
    some i
    input.resource_changes[i].type == "aws_iam_policy"
    policy_doc := json.unmarshal(input.resource_changes[i].change.after.policy)
    
    some j
    statement := policy_doc.Statement[j]
    statement.Effect == "Allow"
    
    # Contains s3:ListBucket action
    "s3:ListBucket" in array.concat([], statement.Action)
    
    # Missing s3:prefix condition
    not statement.Condition.StringLike["s3:prefix"]
    
    msg := sprintf("IAM Policy '%s' grants s3:ListBucket without s3:prefix condition. This could allow listing all bucket contents.", [input.resource_changes[i].address])
}

# DENY DANGEROUS IAM ACTIONS IN PERMISSION BOUNDARIES
deny contains msg if {
    some i
    input.resource_changes[i].type == "aws_iam_policy"
    policy_name := input.resource_changes[i].change.after.name
    contains(policy_name, "Boundary")
    
    policy_doc := json.unmarshal(input.resource_changes[i].change.after.policy)
    
    some j
    statement := policy_doc.Statement[j]
    statement.Effect == "Allow"
    
    dangerous_actions := [
        "iam:CreateRole",
        "iam:DeleteRole", 
        "iam:AttachRolePolicy",
        "iam:DetachRolePolicy",
        "iam:PutRolePermissionsBoundary",
        "iam:DeleteRolePermissionsBoundary"
    ]
    
    some action
    action in dangerous_actions
    action in array.concat([], statement.Action)
    
    msg := sprintf("Permission Boundary '%s' should not allow dangerous IAM action '%s'. Boundaries should restrict, not grant permissions.", [policy_name, action])
}

# HELPER FUNCTIONS
actions_contains_wildcard(actions) if {
    is_array(actions)
    some action
    action in actions
    contains(action, "*")
}

actions_contains_wildcard(action) if {
    is_string(action)
    contains(action, "*")
}