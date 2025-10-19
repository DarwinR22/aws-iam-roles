import json
import os
import logging

# Configure logging
logger = logging.getLogger()
logger.setLevel(logging.INFO)

def handler(event, context):
    """
    SGSI API Handler Lambda Function
    Handles basic API requests for SGSI implementation
    """
    
    logger.info(f"Received event: {json.dumps(event)}")
    
    # Get environment variables
    environment = os.environ.get('ENVIRONMENT', 'unknown')
    db_host = os.environ.get('DB_HOST', 'localhost')
    
    # Basic response
    response = {
        'statusCode': 200,
        'headers': {
            'Content-Type': 'application/json',
            'Access-Control-Allow-Origin': '*'
        },
        'body': json.dumps({
            'message': 'SGSI API Handler is running',
            'environment': environment,
            'db_host': db_host,
            'timestamp': context.aws_request_id,
            'function_name': context.function_name,
            'layer': 'Layer 3 - Compute'
        })
    }
    
    logger.info(f"Returning response: {json.dumps(response)}")
    return response