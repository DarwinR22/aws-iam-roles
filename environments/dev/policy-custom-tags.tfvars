# Configuración específica de tags por política custom
# Solo para políticas que necesiten valores diferentes a los default

policy_custom_tags = {
  "policy-rds-readonly" = {
    propietario = "DarwinLopez"
    aplicacion  = "database-monitoring"
    proyecto    = "analytics"
  }
  
  "policy-ec2-basic" = {
    propietario = "PedroMartinez"
    aplicacion  = "server-management"
    proyecto    = "infrastructure"
  }
}
