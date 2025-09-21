# guardrails/conftest/abac_validation.rego
# ===============================================
# OPA REGO RULES FOR ABAC POLICY VALIDATION
# ===============================================

package terraform.abac

import rego.v1

# REQUIRE TAG-BASED CONDITIONS IN ABAC POLICIES
deny contains msg if {
    some i
    input.resource_changes[i].type == "aws_iam_policy"
    policy_name := input.resource_changes[i].change.after.name
    contains(policy_name, "TagBased")
    
    policy_doc := json.unmarshal(input.resource_changes[i].change.after.policy)
    
    some j
    statement := policy_doc.Statement[j]
    statement.Effect == "Allow"
    
    # Missing ABAC tag conditions
    not has_abac_conditions(statement)
    
    msg := sprintf("ABAC Policy '%s' must include tag-based conditions comparing aws:PrincipalTag with aws:ResourceTag or service-specific tags.", [input.resource_changes[i].address])
}

# VALIDATE S3 ABAC POLICIES HAVE PROPER CONDITIONS
deny contains msg if {
    some i
    input.resource_changes[i].type == "aws_iam_policy"
    policy_name := input.resource_changes[i].change.after.name
    contains(policy_name, "S3")
    contains(policy_name, "TagBased")
    
    policy_doc := json.unmarshal(input.resource_changes[i].change.after.policy)
    
    some j
    statement := policy_doc.Statement[j]
    statement.Effect == "Allow"
    has_s3_actions(statement.Action)
    
    # Missing proper S3 ABAC conditions
    not has_s3_abac_conditions(statement)
    
    msg := sprintf("S3 ABAC Policy '%s' must include conditions comparing aws:PrincipalTag with s3:ExistingObjectTag or aws:ResourceTag.", [input.resource_changes[i].address])
}

# VALIDATE DYNAMODB ABAC POLICIES
deny contains msg if {
    some i
    input.resource_changes[i].type == "aws_iam_policy"
    policy_name := input.resource_changes[i].change.after.name
    contains(policy_name, "DynamoDB")
    contains(policy_name, "TagBased")
    
    policy_doc := json.unmarshal(input.resource_changes[i].change.after.policy)
    
    some j
    statement := policy_doc.Statement[j]
    statement.Effect == "Allow"
    has_dynamodb_actions(statement.Action)
    
    # Missing proper DynamoDB ABAC conditions
    not has_dynamodb_abac_conditions(statement)
    
    msg := sprintf("DynamoDB ABAC Policy '%s' must include conditions comparing aws:PrincipalTag with aws:ResourceTag.", [input.resource_changes[i].address])
}

# REQUIRE LAMBDA FUNCTION TAGGING CONDITIONS
deny contains msg if {
    some i
    input.resource_changes[i].type == "aws_iam_policy"
    policy_name := input.resource_changes[i].change.after.name
    contains(policy_name, "Lambda")
    contains(policy_name, "TagBased")
    
    policy_doc := json.unmarshal(input.resource_changes[i].change.after.policy)
    
    some j
    statement := policy_doc.Statement[j]
    statement.Effect == "Allow"
    has_lambda_actions(statement.Action)
    
    # Missing proper Lambda ABAC conditions
    not has_lambda_abac_conditions(statement)
    
    msg := sprintf("Lambda ABAC Policy '%s' must include conditions comparing aws:PrincipalTag with lambda:FunctionTag.", [input.resource_changes[i].address])
}

# DENY OVERLY BROAD RESOURCE PATTERNS
deny contains msg if {
    some i
    input.resource_changes[i].type == "aws_iam_policy"
    policy_doc := json.unmarshal(input.resource_changes[i].change.after.policy)
    
    some j
    statement := policy_doc.Statement[j]
    statement.Effect == "Allow"
    
    # Check for overly broad resources
    some resource
    resource in array.concat([], statement.Resource)
    is_overly_broad_resource(resource)
    
    # No appropriate conditions to limit scope
    not has_limiting_conditions(statement)
    
    msg := sprintf("IAM Policy '%s' has overly broad resource pattern '%s' without limiting conditions.", [input.resource_changes[i].address, resource])
}

# HELPER FUNCTIONS
has_abac_conditions(statement) if {
    statement.Condition.StringEquals
    some key, _
    key in object.keys(statement.Condition.StringEquals)
    startswith(key, "aws:PrincipalTag/")
}

has_s3_abac_conditions(statement) if {
    statement.Condition.StringEquals
    has_principal_tag_condition(statement.Condition.StringEquals)
    has_s3_resource_tag_condition(statement.Condition.StringEquals)
}

has_dynamodb_abac_conditions(statement) if {
    statement.Condition.StringEquals
    has_principal_tag_condition(statement.Condition.StringEquals)
    has_resource_tag_condition(statement.Condition.StringEquals)
}

has_lambda_abac_conditions(statement) if {
    statement.Condition.StringEquals
    has_principal_tag_condition(statement.Condition.StringEquals)
    has_lambda_tag_condition(statement.Condition.StringEquals)
}

has_principal_tag_condition(conditions) if {
    some key, _
    key in object.keys(conditions)
    startswith(key, "aws:PrincipalTag/")
}

has_s3_resource_tag_condition(conditions) if {
    some key, _
    key in object.keys(conditions)
    startswith(key, "s3:ExistingObjectTag/") or startswith(key, "aws:ResourceTag/")
}

has_resource_tag_condition(conditions) if {
    some key, _
    key in object.keys(conditions)
    startswith(key, "aws:ResourceTag/")
}

has_lambda_tag_condition(conditions) if {
    some key, _
    key in object.keys(conditions)
    startswith(key, "lambda:FunctionTag/")
}

has_s3_actions(actions) if {
    is_array(actions)
    some action
    action in actions
    startswith(action, "s3:")
}

has_s3_actions(action) if {
    is_string(action)
    startswith(action, "s3:")
}

has_dynamodb_actions(actions) if {
    is_array(actions)
    some action
    action in actions
    startswith(action, "dynamodb:")
}

has_dynamodb_actions(action) if {
    is_string(action)
    startswith(action, "dynamodb:")
}

has_lambda_actions(actions) if {
    is_array(actions)
    some action
    action in actions
    startswith(action, "lambda:")
}

has_lambda_actions(action) if {
    is_string(action)
    startswith(action, "lambda:")
}

is_overly_broad_resource(resource) if {
    contains(resource, ":*/*")
}

is_overly_broad_resource(resource) if {
    endswith(resource, ":*")
}

has_limiting_conditions(statement) if {
    statement.Condition
    count(object.keys(statement.Condition)) > 0
}