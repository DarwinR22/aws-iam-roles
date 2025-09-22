# Configuracion por servicio/area - NO por politica individual
# Escala bien con 100+ politicas

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

# Cost centers por area
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
