import os
import boto3
import uuid
import time
import random
import json

# Initialize clients outside the handler for reuse
dynamodb = boto3.resource("dynamodb")
table_name = os.environ.get("TABLE_NAME")
table = dynamodb.Table(table_name)

# --- CONFIGURATION FOR GRAY FAILURE SIMULATION ---
# Set to True to introduce the artificial latency
INJECT_LATENCY = os.environ.get("INJECT_LATENCY", "false").lower() == "true"
MIN_LATENCY_MS = 150  # Minimum artificial latency in milliseconds
MAX_LATENCY_MS = 500  # Maximum artificial latency in milliseconds

def handler(event, context):
    """
    Handles incoming API Gateway requests.
    Writes a new item to the DynamoDB table.
    Optionally injects a variable sleep to simulate performance degradation.
    """
    
    # Simulate a "gray failure" by adding variable latency
    if INJECT_LATENCY:
        latency_seconds = random.randint(MIN_LATENCY_MS, MAX_LATENCY_MS) / 1000.0
        time.sleep(latency_seconds)

    try:
        item_id = str(uuid.uuid4())
        
        table.put_item(
            Item={
                "id": item_id,
                "created_at": int(time.time())
            }
        )
        
        return {
            "statusCode": 201,
            "body": json.dumps({"id": item_id, "message": "Item created successfully."}),
            "headers": {
                "Content-Type": "application/json"
            }
        }
    except Exception as e:
        # It's crucial to log errors for observability
        print(f"Error processing request: {e}")
        return {
            "statusCode": 500,
            "body": json.dumps({"error": "Internal Server Error"}),
        }
