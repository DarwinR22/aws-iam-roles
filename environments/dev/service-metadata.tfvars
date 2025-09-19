# Configuración por servicio/área - NO por política individual
# Escala bien con 100+ políticas

# Propietarios por servicio AWS
service_owners = {
  "rds"        = "DarwinLopez"
  "ec2"        = "PedroMartinez"
  "lambda"     = "JorgeLopez"
  "s3"         = "CesarCalmo"
  "dynamodb"   = "DarwinLopez"
  "sqs"        = "JorgeLopez"
  "iam"        = "MCI-IAM-System"
  "cloudwatch" = "DevOpsTeam"
}

# Teams por servicio
service_teams = {
  "rds"        = "Database-Team"
  "ec2"        = "Infrastructure-Team"
  "lambda"     = "Development-Team"
  "s3"         = "Data-Team"
  "dynamodb"   = "Database-Team"
  "sqs"        = "Integration-Team"
  "iam"        = "Security-Team"
  "cloudwatch" = "Monitoring-Team"
}

# Cost centers por área
service_cost_centers = {
  "rds"        = "Infrastructure"
  "ec2"        = "Infrastructure"
  "lambda"     = "Engineering"
  "s3"         = "DataEngineering"
  "dynamodb"   = "Infrastructure"
  "sqs"        = "Engineering"
  "iam"        = "Security"
  "cloudwatch" = "Operations"
}
