# Lambda Functions generated from sgsi-lambda-functions.yaml
# Generated: 2025-10-18T22:18:12.512570


# Lambda function zip file
data "archive_file" "sgsi_api_processor_zip" {
  type        = "zip"
  output_path = "sgsi-api-processor.zip"
  
  source {
    content = <<EOF
import json
import boto3
import pymysql
import os
import logging
from botocore.exceptions import ClientError

# Configure logging
logger = logging.getLogger()
logger.setLevel(os.environ.get('LOG_LEVEL', 'INFO'))

def lambda_handler(event, context):
    """
    SGSI API Processor Lambda Function
    Procesa requests de API y se conecta a RDS
    """
    
    try:
        # Log del evento
        logger.info(f"Processing event: {json.dumps(event)}")
        
        # Configuración de base de datos
        db_config = {
            'host': os.environ['DB_HOST'],
            'user': os.environ['DB_USER'], 
            'database': os.environ['DB_NAME'],
            'charset': 'utf8mb4'
        }
        
        # Obtener password desde Secrets Manager
        secret_name = "sgsi-db-credentials"
        region = os.environ['REGION']
        
        session = boto3.session.Session()
        client = session.client(
            service_name='secretsmanager',
            region_name=region
        )
        
        try:
            secret_response = client.get_secret_value(SecretId=secret_name)
            secret = json.loads(secret_response['SecretString'])
            db_config['password'] = secret['password']
        except ClientError as e:
            logger.error(f"Error getting DB password: {e}")
            return {
                'statusCode': 500,
                'body': json.dumps({'error': 'Database configuration error'})
            }
        
        # Procesar según el tipo de evento
        http_method = event.get('httpMethod', 'GET')
        path = event.get('path', '/')
        
        if path == '/api/health':
            return health_check()
        elif path == '/api/data' and http_method == 'GET':
            return get_data(db_config)
        elif path == '/api/data' and http_method == 'POST':
            return post_data(event, db_config)
        else:
            return {
                'statusCode': 404,
                'body': json.dumps({'error': 'Endpoint not found'})
            }
            
    except Exception as e:
        logger.error(f"Unhandled error: {str(e)}")
        return {
            'statusCode': 500,
            'body': json.dumps({
                'error': 'Internal server error',
                'layer': 'SGSI-Layer3'
            })
        }

def health_check():
    """Health check endpoint"""
    return {
        'statusCode': 200,
        'headers': {'Content-Type': 'application/json'},
        'body': json.dumps({
            'status': 'healthy',
            'layer': 'SGSI-Layer3',
            'service': 'api-processor',
            'timestamp': context.aws_request_id
        })
    }

def get_data(db_config):
    """Obtener datos de la base de datos"""
    try:
        connection = pymysql.connect(**db_config)
        with connection.cursor() as cursor:
            cursor.execute("SELECT COUNT(*) as total FROM information_schema.tables")
            result = cursor.fetchone()
            
        return {
            'statusCode': 200,
            'headers': {'Content-Type': 'application/json'},
            'body': json.dumps({
                'tables_count': result[0],
                'layer': 'SGSI-Layer3',
                'status': 'success'
            })
        }
    except Exception as e:
        logger.error(f"Database error: {str(e)}")
        return {
            'statusCode': 500,
            'body': json.dumps({'error': 'Database connection failed'})
        }
    finally:
        if 'connection' in locals():
            connection.close()

def post_data(event, db_config):
    """Insertar datos en la base de datos"""
    try:
        body = json.loads(event.get('body', '{}'))
        
        # Aquí iría la lógica de inserción
        # Por simplicidad, solo validamos la conexión
        
        return {
            'statusCode': 201,
            'headers': {'Content-Type': 'application/json'},
            'body': json.dumps({
                'message': 'Data processed successfully',
                'layer': 'SGSI-Layer3',
                'received_data': body
            })
        }
    except Exception as e:
        logger.error(f"Processing error: {str(e)}")
        return {
            'statusCode': 400,
            'body': json.dumps({'error': 'Invalid request data'})
        }

EOF
    filename = "lambda_function.py"
  }
}

# Lambda function
resource "aws_lambda_function" "sgsi_api_processor" {
  filename         = data.archive_file.sgsi_api_processor_zip.output_path
  function_name    = "sgsi-api-processor"
  role            = aws_iam_role.sgsi_lambda_api_processor_role.arn
  handler         = "lambda_function.lambda_handler"
  runtime         = "python3.11"
  timeout         = 30
  memory_size     = 256
  
  source_code_hash = data.archive_file.sgsi_api_processor_zip.output_base64sha256
  
  environment {
    variables = {
      DB_HOST = "sgsi-main-db.cluster-xyz.us-east-1.rds.amazonaws.com"
      DB_NAME = "sgsidb"
      DB_USER = "sgsi_admin"
      REGION = "us-east-1"
      LOG_LEVEL = "INFO"
      SGSI_LAYER = "Layer3"
    }
  }

  vpc_config {
    subnet_ids = [
      data.aws_subnet.sgsi_app_subnet_us_east_1a.id,
      data.aws_subnet.sgsi_app_subnet_us_east_1b.id,
    ]
    security_group_ids = [
      data.aws_security_group.sgsi_lambda_sg.id,
    ]
  }

  reserved_concurrent_executions = 50

  tags = {
    "Pais" = "RG"
    "Gerencia" = "MejoraContinuaEInformacion"
    "Area" = "DevOps"
    "Ambiente" = "DEV"
    "Direccion" = "TICENAM"
    "Modulo" = "Serverless"
    "AlcanceSOX" = "No"
    "Propietario" = "DarwinLopez"
    "Proveedor" = "InHouse"
    "Layer" = "SGSI-Layer3-Serverless"
    "Dominio" = "BusinessIntelligence"
    "Subdominio" = "ServerlessComputing"
    "Aplicacion" = "SGSI"
    "Name" = "sgsi-lambda-functions"
    "Tipo de Recurso" = "LambdaFunction"
    "Soporte" = "darwin.lopez@claro.com.gt"
    "Contacto" = "darwin.lopez@claro.com.gt"
    "Creado Por" = "DarwinLopez"
    "Ciclo de Vida" = "Desarrollo"
    "Version" = "v1.0.0"
    "Fecha de Creacion" = "2025-10-18"
    "Name" = "sgsi-api-processor"
  }
}

# IAM role for Lambda
resource "aws_iam_role" "sgsi_lambda_api_processor_role" {
  name = "sgsi-lambda-api-processor-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "lambda.amazonaws.com"
        }
      }
    ]
  })
}


resource "aws_iam_role_policy_attachment" "sgsi_api_processor_lambdavpcaccessexecutionrole" {
  role       = aws_iam_role.sgsi_lambda_api_processor_role.name
  policy_arn = "arn:aws:iam::aws:policy/AWSLambdaVPCAccessExecutionRole"
}

resource "aws_iam_role_policy_attachment" "sgsi_api_processor_lambdabasicexecutionrole" {
  role       = aws_iam_role.sgsi_lambda_api_processor_role.name
  policy_arn = "arn:aws:iam::aws:policy/AWSLambdaBasicExecutionRole"
}

resource "aws_iam_role_policy" "sgsi_api_processor_sgsilambdardsaccess" {
  name = "SGSILambdaRDSAccess"
  role = aws_iam_role.sgsi_lambda_api_processor_role.id

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "rds-db:connect"
      ],
      "Resource": "arn:aws:rds-db:us-east-1:051963532279:dbuser:sgsi-main-db/sgsi_admin"
    },
    {
      "Effect": "Allow",
      "Action": [
        "secretsmanager:GetSecretValue"
      ],
      "Resource": "arn:aws:secretsmanager:us-east-1:051963532279:secret:sgsi-db-credentials*"
    }
  ]
}

EOF
}

# Lambda function zip file
data "archive_file" "sgsi_data_processor_zip" {
  type        = "zip"
  output_path = "sgsi-data-processor.zip"
  
  source {
    content = <<EOF
import json
import boto3
import os
import logging
from datetime import datetime
from urllib.parse import unquote_plus

# Configure logging
logger = logging.getLogger()
logger.setLevel(os.environ.get('LOG_LEVEL', 'INFO'))

# AWS clients
s3_client = boto3.client('s3')
sqs_client = boto3.client('sqs')

def lambda_handler(event, context):
    """
    SGSI Data Processor Lambda Function
    Procesa archivos S3 y mensajes SQS
    """
    
    try:
        logger.info(f"Processing event: {json.dumps(event)}")
        
        # Determinar el tipo de evento
        if 'Records' in event:
            for record in event['Records']:
                event_source = record.get('eventSource', '')
                
                if event_source == 'aws:s3':
                    process_s3_event(record)
                elif event_source == 'aws:sqs':
                    process_sqs_event(record)
                else:
                    logger.warning(f"Unknown event source: {event_source}")
        
        return {
            'statusCode': 200,
            'body': json.dumps({
                'message': 'Events processed successfully',
                'layer': 'SGSI-Layer3',
                'processed_count': len(event.get('Records', []))
            })
        }
        
    except Exception as e:
        logger.error(f"Processing error: {str(e)}")
        return {
            'statusCode': 500,
            'body': json.dumps({
                'error': 'Processing failed',
                'layer': 'SGSI-Layer3'
            })
        }

def process_s3_event(record):
    """Procesar eventos de S3"""
    try:
        bucket = record['s3']['bucket']['name']
        key = unquote_plus(record['s3']['object']['key'])
        
        logger.info(f"Processing S3 object: s3://{bucket}/{key}")
        
        # Descargar y procesar el archivo
        response = s3_client.get_object(Bucket=bucket, Key=key)
        content = response['Body'].read().decode('utf-8')
        
        # Procesar el contenido JSON
        data = json.loads(content)
        
        # Procesar datos (lógica de negocio aquí)
        processed_data = {
            'original_file': key,
            'processed_at': datetime.now().isoformat(),
            'layer': 'SGSI-Layer3',
            'record_count': len(data) if isinstance(data, list) else 1,
            'processing_status': 'completed'
        }
        
        # Guardar resultado procesado
        output_key = f"processed/{datetime.now().strftime('%Y/%m/%d')}/{key}"
        s3_client.put_object(
            Bucket=bucket,
            Key=output_key,
            Body=json.dumps(processed_data),
            ContentType='application/json'
        )
        
        logger.info(f"Processed data saved to: s3://{bucket}/{output_key}")
        
    except Exception as e:
        logger.error(f"S3 processing error: {str(e)}")
        raise

def process_sqs_event(record):
    """Procesar eventos de SQS"""
    try:
        body = json.loads(record['body'])
        logger.info(f"Processing SQS message: {body}")
        
        # Procesar mensaje (lógica de negocio aquí)
        message_type = body.get('type', 'unknown')
        
        if message_type == 'data_validation':
            validate_data(body.get('data', {}))
        elif message_type == 'system_event':
            process_system_event(body)
        else:
            logger.warning(f"Unknown message type: {message_type}")
        
    except Exception as e:
        logger.error(f"SQS processing error: {str(e)}")
        raise

def validate_data(data):
    """Validar datos del sistema"""
    # Lógica de validación
    logger.info("Data validation completed")

def process_system_event(event_data):
    """Procesar eventos del sistema"""
    # Lógica de eventos del sistema
    logger.info("System event processed")

EOF
    filename = "lambda_function.py"
  }
}

# Lambda function
resource "aws_lambda_function" "sgsi_data_processor" {
  filename         = data.archive_file.sgsi_data_processor_zip.output_path
  function_name    = "sgsi-data-processor"
  role            = aws_iam_role.sgsi_lambda_data_processor_role.arn
  handler         = "lambda_function.lambda_handler"
  runtime         = "python3.11"
  timeout         = 60
  memory_size     = 512
  
  source_code_hash = data.archive_file.sgsi_data_processor_zip.output_base64sha256
  
  environment {
    variables = {
      S3_BUCKET = "sgsi-data-processing-051963532279"
      SQS_QUEUE_URL = "https://sqs.us-east-1.amazonaws.com/051963532279/sgsi-processing-queue"
      REGION = "us-east-1"
      LOG_LEVEL = "INFO"
      SGSI_LAYER = "Layer3"
    }
  }

  reserved_concurrent_executions = 25

  tags = {
    "Pais" = "RG"
    "Gerencia" = "MejoraContinuaEInformacion"
    "Area" = "DevOps"
    "Ambiente" = "DEV"
    "Direccion" = "TICENAM"
    "Modulo" = "Serverless"
    "AlcanceSOX" = "No"
    "Propietario" = "DarwinLopez"
    "Proveedor" = "InHouse"
    "Layer" = "SGSI-Layer3-Serverless"
    "Dominio" = "BusinessIntelligence"
    "Subdominio" = "ServerlessComputing"
    "Aplicacion" = "SGSI"
    "Name" = "sgsi-lambda-functions"
    "Tipo de Recurso" = "LambdaFunction"
    "Soporte" = "darwin.lopez@claro.com.gt"
    "Contacto" = "darwin.lopez@claro.com.gt"
    "Creado Por" = "DarwinLopez"
    "Ciclo de Vida" = "Desarrollo"
    "Version" = "v1.0.0"
    "Fecha de Creacion" = "2025-10-18"
    "Name" = "sgsi-data-processor"
  }
}

# IAM role for Lambda
resource "aws_iam_role" "sgsi_lambda_data_processor_role" {
  name = "sgsi-lambda-data-processor-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "lambda.amazonaws.com"
        }
      }
    ]
  })
}


resource "aws_iam_role_policy_attachment" "sgsi_data_processor_lambdabasicexecutionrole" {
  role       = aws_iam_role.sgsi_lambda_data_processor_role.name
  policy_arn = "arn:aws:iam::aws:policy/AWSLambdaBasicExecutionRole"
}

resource "aws_iam_role_policy" "sgsi_data_processor_sgsilambdadataprocessingaccess" {
  name = "SGSILambdaDataProcessingAccess"
  role = aws_iam_role.sgsi_lambda_data_processor_role.id

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "s3:GetObject",
        "s3:PutObject"
      ],
      "Resource": "arn:aws:s3:::sgsi-data-processing-051963532279/*"
    },
    {
      "Effect": "Allow",
      "Action": [
        "sqs:ReceiveMessage",
        "sqs:DeleteMessage",
        "sqs:GetQueueAttributes"
      ],
      "Resource": "arn:aws:sqs:us-east-1:051963532279:sgsi-processing-queue"
    }
  ]
}

EOF
}
