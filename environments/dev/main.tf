# Main configuration for IAM roles deployment

locals {
  base_canonical_tags = {
    Ambiente = "dev"
    Pais = "rg"
    Gerencia = "mci"
    Cuenta = data.aws_caller_identity.current.account_id
    Modulo = "iamroles"
  }
}

data "aws_caller_identity" "current" {}
