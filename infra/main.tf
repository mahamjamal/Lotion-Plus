terraform {
  required_providers {
    aws = {
      version = ">= 4.0.0"
      source  = "hashicorp/aws"
    }
  }
}

# specify the provider region
provider "aws" {
  region = "ca-central-1"
}

# the locals block is used to declare constants that 
# you can use throughout your code
locals {

# save note
  function_name = "save-note"
  handler_name  = "main.lambda_handler"
  artifact_name = "save-note-artifact.zip"

# get note 
  function_name_2 = "get-note"
  handler_name_2  = "main.lambda_handler_2"
  artifact_name_2 = "get-note-artifact.zip"

# delete note 
  function_name_3 = "delete-note"
  handler_name_3  = "main.lambda_handler_3"
  artifact_name_3 = "delete-note-artifact.zip"


}

# create a role for the Lambda function to assume
# every service on AWS that wants to call other AWS services should first assume a role and
# then any policy attached to the role will give permissions
# to the service so it can interact with other AWS services
# see the docs: https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role
resource "aws_iam_role" "save-note_lambda" {
  name               = "iam-for-lambda-${local.function_name}"
  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "lambda.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}

# get note 
resource "aws_iam_role" "get-note_lambda" {
  name               = "iam-for-lambda-${local.function_name_2}"
  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "lambda.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}

# delete note
resource "aws_iam_role" "delete-note_lambda" {
  name               = "iam-for-lambda-${local.function_name_3}"
  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "lambda.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}

# create archive file from main.py save note
data "archive_file" "lambda" {
  type = "zip"
  # this file (main.py) needs to exist in the same folder as this 
  # Terraform configuration file
  source_file = "../function/save-note/main.py" # file path for where main.py is 
  output_path = "save-note-artifact.zip"
}


# create archive file from main.py get note 
data "archive_file" "lambda" {
  type = "zip"
  # this file (main.py) needs to exist in the same folder as this 
  # Terraform configuration file
  source_file = "../function/get-note/main.py" # file path for where main.py is 
  output_path = "get-note-artifact.zip"
}

# create archive file from main.py delete note 
data "archive_file" "lambda" {
  type = "zip"
  # this file (main.py) needs to exist in the same folder as this 
  # Terraform configuration file
  source_file = "../function/delete-note/main.py" # file path for where main.py is 
  output_path = "delete-note-artifact.zip"
}



# create a Lambda function
# save note 
resource "aws_lambda_function" "save-note_lambda" {
  role             = aws_iam_role.save-note_lambda.arn
  function_name    = local.function_name
  handler          = local.handler_name
  filename         = local.artifact_name
  source_code_hash = data.archive_file.save-note_lambda.output_base64sha256

  # see all available runtimes here: https://docs.aws.amazon.com/lambda/latest/dg/API_CreateFunction.html#SSS-CreateFunction-request-Runtime
  runtime = "python3.9"
}

# get note
resource "aws_lambda_function" "get-note_lambda" {
  role             = aws_iam_role.get-note_lambda.arn
  function_name    = local.function_name_2
  handler          = local.handler_name_2
  filename         = local.artifact_name_2
  source_code_hash = data.archive_file.get-note_lambda.output_base64sha256

  # see all available runtimes here: https://docs.aws.amazon.com/lambda/latest/dg/API_CreateFunction.html#SSS-CreateFunction-request-Runtime
  runtime = "python3.9"
}


# delet note
resource "aws_lambda_function" "delete-note_lambda" {
  role             = aws_iam_role.delete-note_lambda.arn
  function_name    = local.function_name_3
  handler          = local.handler_name_3
  filename         = local.artifact_name_3
  source_code_hash = data.archive_file.delete-note_lambda.output_base64sha256

  # see all available runtimes here: https://docs.aws.amazon.com/lambda/latest/dg/API_CreateFunction.html#SSS-CreateFunction-request-Runtime
  runtime = "python3.9"
}


# create a policy for publishing logs to CloudWatch
# see the docs: https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_policy
resource "aws_iam_policy" "logs" {
  name        = "lambda-logging-${local.function_name}"
  description = "IAM policy for logging from a lambda"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
        "logs:CreateLogGroup",
        "logs:CreateLogStream",
        "logs:PutLogEvents"
        "dynamodb:PutItem"
      ],
      "Resource": "arn:aws:logs:*:*:*", "${aws_dynamodb_table.   .arn}"],
      "Effect": "Allow"
    }
  ]
}
EOF
}

# attach the above policy to the function role save note
# see the docs: https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment
resource "aws_iam_role_policy_attachment" "lambda_logs" {
  role       = aws_iam_role.save-note_lambda.name
  policy_arn = aws_iam_policy.logs.arn
}

# attach the above policy to the function role get note
resource "aws_iam_role_policy_attachment" "lambda_logs" {
  role       = aws_iam_role.get-note_lambda.name
  policy_arn = aws_iam_policy.logs.arn
}

# attach the above policy to the function role delete note
resource "aws_iam_role_policy_attachment" "lambda_logs" {
  role       = aws_iam_role.delete-note_lambda.name
  policy_arn = aws_iam_policy.logs.arn
}



# save note
resource "aws_lambda_function_url" "save-url" {
  function_name      = aws_lambda_function.save-note_lambda.function_name
  authorization_type = "NONE"

  cors {
    allow_credentials = true
    allow_origins     = ["*"]
    allow_methods     = ["GET", "POST", "PUT", "DELETE"]
    allow_headers     = ["*"]
    expose_headers    = ["keep-alive", "date"]
  }
}

# show the Function URL after creation
output "lambda_url" {
  value = aws_lambda_function_url.save-url.function_url
}



# get note 
resource "aws_lambda_function_url" "get-url" {
  function_name      = aws_lambda_function.get-note_lambda.function_name_2
  authorization_type = "NONE"

  cors {
    allow_credentials = true
    allow_origins     = ["*"]
    allow_methods     = ["GET"]
    allow_headers     = ["*"]
    expose_headers    = ["keep-alive", "date"]
  }
}

# show the Function URL after creation
output "lambda_url" {
  value = aws_lambda_function_url.get-url.function_url
}


# delete note 
resource "aws_lambda_function_url" "delete-url" {
  function_name      = aws_lambda_function.delete-note_lambda.function_name_3
  authorization_type = "NONE"

  cors {
    allow_credentials = true
    allow_origins     = ["*"]
    allow_methods     = ["DELETE"]
    allow_headers     = ["*"]
    expose_headers    = ["keep-alive", "date"]
  }
}

# show the Function URL after creation
output "lambda_url" {
  value = aws_lambda_function_url.delete-url.function_url
}


# read the docs: https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/dynamodb_table
resource "aws_dynamodb_table" "users" {
  name         = "notes"
  billing_mode = "PROVISIONED"

  # up to 8KB read per second (eventually consistent)
  read_capacity = 1

  # up to 1KB per second
  write_capacity = 1

  # we only need a student id to find an item in the table; therefore, we 
  # don't need a sort key here
  hash_key = "email"
  range_key = "id"

  attribute{
    name = "email"
    type = "S"
  }


  attribute{
    name = "id"
    type = "S"
  }


}