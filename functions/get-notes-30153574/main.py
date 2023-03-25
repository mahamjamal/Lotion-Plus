import boto3
import json

dynamodb_res = boto3.resource("dynamodb")
table_notes = dynamodb_res.Table("lotion-30153574")
def item_getter(email):
    return table_notes.query(
        KeyConditionExpression = "email = :email",
        ExpressionAttributeValues = {":email": email},
    )

def handler(event, context):
    email = event['queryStringParameters']['email']

    try:
        item = item_getter(email)
        return {
            "statusCode" : 200,
            "body": json.dumps(item["Items"]),
        }
    except Exception as e:
        print(f"exception:{e}")
        return {
            "statusCode" : 500,
            "message": "Error retrieving",
        }