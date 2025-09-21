# guardrails/checkov/custom_checks/iam_abac_check.py
"""
Custom Checkov check for ABAC IAM policies
Validates that tag-based policies follow ABAC patterns
"""

from checkov.common.models.enums import TRUE_VALUES, FALSE_VALUES
from checkov.terraform.checks.resource.base_resource_check import BaseResourceCheck
from checkov.common.models.enums import CheckResult, CheckCategories
import json
import re


class IAMABACTagConditionCheck(BaseResourceCheck):
    def __init__(self):
        name = "Ensure IAM policies with 'TagBased' in name include proper ABAC conditions"
        id = "CKV_AWS_ABAC_001"
        supported_resources = ['aws_iam_policy']
        categories = [CheckCategories.IAM]
        super().__init__(name=name, id=id, categories=categories, supported_resources=supported_resources)

    def scan_resource_conf(self, conf):
        """
        Looks for IAM policies with "TagBased" in name and validates ABAC conditions
        """
        policy_name = conf.get('name', [''])[0]
        
        # Only check policies with "TagBased" in the name
        if 'TagBased' not in policy_name:
            return CheckResult.PASSED
            
        policy_document = conf.get('policy', [None])[0]
        if not policy_document:
            return CheckResult.FAILED
            
        try:
            # Parse policy document
            if isinstance(policy_document, str):
                policy_dict = json.loads(policy_document)
            else:
                policy_dict = policy_document
                
            statements = policy_dict.get('Statement', [])
            if not isinstance(statements, list):
                statements = [statements]
                
            for statement in statements:
                if statement.get('Effect') == 'Allow':
                    conditions = statement.get('Condition', {})
                    
                    # Check for ABAC conditions
                    has_principal_tag = False
                    has_resource_tag = False
                    
                    for condition_type, condition_values in conditions.items():
                        if isinstance(condition_values, dict):
                            for key in condition_values.keys():
                                if 'aws:PrincipalTag/' in key:
                                    has_principal_tag = True
                                if ('aws:ResourceTag/' in key or 
                                    's3:ExistingObjectTag/' in key or 
                                    'lambda:FunctionTag/' in key):
                                    has_resource_tag = True
                    
                    # For TagBased policies, require both principal and resource tag conditions
                    if not (has_principal_tag and has_resource_tag):
                        return CheckResult.FAILED
                        
            return CheckResult.PASSED
            
        except (json.JSONDecodeError, KeyError, TypeError):
            return CheckResult.FAILED


class IAMPermissionBoundaryCheck(BaseResourceCheck):
    def __init__(self):
        name = "Ensure all IAM roles have permission boundaries attached"
        id = "CKV_AWS_ABAC_002"
        supported_resources = ['aws_iam_role']
        categories = [CheckCategories.IAM]
        super().__init__(name=name, id=id, categories=categories, supported_resources=supported_resources)

    def scan_resource_conf(self, conf):
        """
        Looks for IAM roles and validates they have permission boundaries
        """
        permissions_boundary = conf.get('permissions_boundary', [None])[0]
        
        if permissions_boundary is None:
            return CheckResult.FAILED
            
        # Check if it's a valid boundary ARN or reference
        if isinstance(permissions_boundary, str) and (
            'arn:aws:iam::' in permissions_boundary or 
            'App-StandardBoundary' in permissions_boundary or
            'Platform-Boundary' in permissions_boundary
        ):
            return CheckResult.PASSED
            
        return CheckResult.FAILED


class IAMCanonicalTagsCheck(BaseResourceCheck):
    def __init__(self):
        name = "Ensure IAM resources have all required canonical tags"
        id = "CKV_AWS_ABAC_003"
        supported_resources = ['aws_iam_role', 'aws_iam_policy']
        categories = [CheckCategories.IAM]
        super().__init__(name=name, id=id, categories=categories, supported_resources=supported_resources)

    def scan_resource_conf(self, conf):
        """
        Validates that IAM resources have all 23 canonical tags
        """
        required_tags = [
            "Ambiente", "País", "Dirección", "Gerencia", "Cuenta", "Módulo",
            "Alcance SOX", "Propietario", "Proveedor", "Layer", "Dominio", "Subdominio",
            "Aplicación", "Name", "Soporte", "Contacto", "Proyecto", "Fechas de Creación",
            "Creado Por", "Tipo de Recurso", "Ciclo de Vida", "Versión", "Map-migrated"
        ]
        
        tags = conf.get('tags', [{}])[0]
        if not isinstance(tags, dict):
            return CheckResult.FAILED
            
        missing_tags = []
        for required_tag in required_tags:
            if required_tag not in tags:
                missing_tags.append(required_tag)
                
        if missing_tags:
            return CheckResult.FAILED
            
        # Validate País tag value
        pais = tags.get('País', '')
        valid_countries = ['GT', 'SV', 'HN', 'NI', 'CR', 'RG']
        if pais not in valid_countries:
            return CheckResult.FAILED
            
        return CheckResult.PASSED


check = IAMABACTagConditionCheck()
boundary_check = IAMPermissionBoundaryCheck()
tags_check = IAMCanonicalTagsCheck()