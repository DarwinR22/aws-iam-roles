# MCI AWS IAM - Configuración Backend Terraform DINÁMICA
# ========================================================

def get_backend_config(environment: str = None) -> dict:
    """
    Genera configuración de backend DINÁMICAMENTE
    Usa variables de entorno: ENVIRONMENT, AWS_REGION, AWS_ACCOUNT_ID
    """
    import os
    
    env = environment or os.getenv('ENVIRONMENT', 'dev')
    region = os.getenv('AWS_REGION', 'us-east-1')  
    account_id = os.getenv('AWS_ACCOUNT_ID', '393209814297')
    
    base_config = {
        "bucket": f"s3-data-analytics-{env}-tfstate",
        "key": "iam/terraform.tfstate",
        "region": region,
        "dynamodb_table": f"dynamodb-db-{env}-terraform-lock", 
        "encrypt": True
    }
    
    # KMS solo para DEV (por ahora)
    if env == "dev":
        base_config["kms_key_id"] = f"arn:aws:kms:{region}:{account_id}:key/fe44eac8-0501-4620-bba9-b0155ed1b1a1"
    
    return base_config

def get_aws_config(environment: str = "dev") -> dict:
    """Configuración AWS por ambiente"""
    accounts = {
        "dev": "393209814297",   # Cuenta DEV MCI
        "qa": "TBD",             # Por definir
        "prod": "TBD"            # Por definir
    }
    
    return {
        "account_id": accounts.get(environment, "393209814297"),
        "region": "us-east-1",
        "profile": "darkhn",  # Tu perfil AWS local
        "environment": environment
    }

def get_required_tags(environment: str = "dev") -> dict:
    """Tags obligatorios por ambiente"""
    return {
        "Environment": environment,
        "Department": "mci",
        "ManagedBy": "Terraform", 
        "Repository": "mci-aws-iam",
        "StateLocation": f"s3-data-analytics-{environment}-tfstate"
    }