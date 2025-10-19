#!/usr/bin/env python3
"""
SGSI API Handler Lambda Function
Simple handler for SGSI infrastructure
"""

def handler(event, context):
    """
    Simple Lambda handler for SGSI API processing
    """
    return {
        'statusCode': 200,
        'body': {
            'message': 'SGSI API Handler - Ready for development',
            'version': '1.0.0',
            'timestamp': context.aws_request_id
        }
    }

if __name__ == "__main__":
    # Local testing
    class MockContext:
        aws_request_id = "local-test"
    
    result = handler({}, MockContext())
    print(f"Test result: {result}")