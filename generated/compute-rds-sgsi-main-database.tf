# RDS Database generated from sgsi-main-database.yaml
# Generated: 2025-10-18T22:18:12.486163

# DB Subnet Group
resource "aws_db_subnet_group" "sgsi_db_subnet_group" {
  name       = "sgsi-db-subnet-group"
  subnet_ids = [
    data.aws_subnet.sgsi_db_subnet_us_east_1a.id,
    data.aws_subnet.sgsi_db_subnet_us_east_1b.id,
    data.aws_subnet.sgsi_db_subnet_us_east_1c.id,
  ]

  tags = {
    Name = "sgsi-db-subnet-group"
  }
}

# DB Parameter Group
resource "aws_db_parameter_group" "sgsi_mysql_params" {
  family = "mysql8.0"
  name   = "sgsi-mysql-params"

  parameter {
    name  = "innodb_buffer_pool_size"
    value = "2147483648"
  }
  parameter {
    name  = "max_connections"
    value = "200"
  }
  parameter {
    name  = "query_cache_type"
    value = "0"
  }
  parameter {
    name  = "log_bin_trust_function_creators"
    value = "1"
  }
  parameter {
    name  = "slow_query_log"
    value = "1"
  }
  parameter {
    name  = "long_query_time"
    value = "2"
  }
  parameter {
    name  = "general_log"
    value = "0"
  }
  parameter {
    name  = "character_set_server"
    value = "utf8mb4"
  }
  parameter {
    name  = "collation_server"
    value = "utf8mb4_unicode_ci"
  }

  tags = {
    Name = "sgsi-mysql-params"
  }
}

# RDS Instance
resource "aws_db_instance" "sgsi_main_db" {
  identifier = "sgsi-main-db"
  
  engine         = "mysql"
  engine_version = "8.0.35"
  instance_class = "db.t3.medium"
  
  allocated_storage     = 100
  max_allocated_storage = 500
  storage_type          = "gp3"
  storage_encrypted     = true
  
  db_name  = "sgsidb"
  username = "sgsi_admin"
  manage_master_user_password = true
  
  port = 3306
  
  multi_az = true
  
  db_subnet_group_name = aws_db_subnet_group.sgsi_db_subnet_group.name
  parameter_group_name = aws_db_parameter_group.sgsi_mysql_params.name
  
  vpc_security_group_ids = [
    data.aws_security_group.sgsi_db_sg.id,
  ]
  
  backup_retention_period = 7
  backup_window          = "03:00-04:00"
  maintenance_window     = "sun:04:00-sun:05:00"
  
  copy_tags_to_snapshot = true
  deletion_protection   = false
  
  monitoring_interval = 60
  performance_insights_enabled = true
  
  enabled_cloudwatch_logs_exports = ["error", "general", "slow-query"]

  tags = {
    "Pais" = "RG"
    "Gerencia" = "MejoraContinuaEInformacion"
    "Area" = "DevOps"
    "Ambiente" = "DEV"
    "Direccion" = "TICENAM"
    "Modulo" = "Database"
    "AlcanceSOX" = "No"
    "Propietario" = "DarwinLopez"
    "Proveedor" = "InHouse"
    "Layer" = "SGSI-Layer3-Database"
    "Dominio" = "BusinessIntelligence"
    "Subdominio" = "DataPersistence"
    "Aplicacion" = "SGSI"
    "Name" = "sgsi-main-database"
    "Tipo de Recurso" = "RDSInstance"
    "Soporte" = "darwin.lopez@claro.com.gt"
    "Contacto" = "darwin.lopez@claro.com.gt"
    "Creado Por" = "DarwinLopez"
    "Ciclo de Vida" = "Desarrollo"
    "Version" = "v1.0.0"
    "Fecha de Creacion" = "2025-10-18"
    "Confidencialidad" = "Confidencial"
    "Criticidad" = "Critica"
    "BackupRequired" = "Yes"
    "EncryptionRequired" = "Yes"
    "DataClassification" = "Internal"
  }
}

# Data sources are defined in compute-shared-data-sources.tf

