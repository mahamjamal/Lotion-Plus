import json
import boto3

dynamodb_resource = boto3.resource("dynamodb")
table = dynamodb_resource.Table("lotion-30153574")

def delete_item(email, id_note):
    return table.delete_item (
        Key = {
        "email": email,
        "id": id_note,
        }
    )

def handler(event, context):
    body = json.loads(event["body"])
    email = body["email"]
    id_note = body["id"]

    try:
        delete_item(email, id_note)
        return {
            "statusCode": 200,
            "body": json.dumps({
                "message": "Success"
            })
        }

    except Exception as exp:
        print(exp)
        return {
            "statusCode": 500,
            "body": json.dumps({
                "message": str(exp)
            })
        }