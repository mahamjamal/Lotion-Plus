import json
import boto3

dynamodb_resource = boto3.resource("dynamodb")
table = dynamodb_resource.Table("lotion-30153574")


def handler(event, context):
    body = json.loads(event["body"])
    try:
        table.put_item(Item = body)
        return {
            "statusCode": 200,
            "body": json.dumps({
                "message": "Success"
                })
        }

    except Exception as exp:
        print(exp)
        return{
            "statusCode": 500,
            "body": json.dumps({
                "message": str(exp)
            })
        }