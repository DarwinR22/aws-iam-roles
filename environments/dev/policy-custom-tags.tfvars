# Configuracion especifica de tags por politica custom
# Solo para politicas que necesiten valores diferentes a los default

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
