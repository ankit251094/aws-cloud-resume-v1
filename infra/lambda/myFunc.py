import json
import boto3
from decimal import Decimal

dynamodb = boto3.resource('dynamodb')
table = dynamodb.Table('visitor-counter')

def lambda_handler(event, context):
    # Get the current count
    response = table.get_item(Key={ 'id': '1' })
    
    if 'Item' in response:
        views = int(response['Item']['views'])
    else:
        views = 0  # Initialize if no record exists yet

    # Increment the views
    views += 1
    print(f"Updated views: {views}")

    # Update the count in the table
    table.put_item(Item={ 'id': '1', 'views': views })

    # Return the updated count with CORS headers
    return {
        'statusCode': 200,
        'headers': {
            "Access-Control-Allow-Origin": "*",  # Important if you are calling from browser
            "Access-Control-Allow-Methods": "GET, POST, OPTIONS",
        },
        'body': json.dumps({ "count": views })
    }
