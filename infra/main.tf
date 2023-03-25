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
resource "aws_s3_bucket" "lambda" {}

locals {
  function_name_get    = "get-notes-30153574"
  function_name_save   = "save-note-30153574"
  function_name_delete = "delete-note-30153574"
  handler_name         = "main.handler"
  artifact_name_get    = "get_artifact.zip"
  artifact_name_save   = "save_artifact.zip"
  artifact_name_delete = "delete_artifact.zip"
}

resource "aws_iam_role" "lambda-get" {
  name               = "iam-for-lambda-${local.function_name_get}"
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

resource "aws_iam_role" "lambda-delete" {
  name               = "iam-for-lambda-${local.function_name_delete}"
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

resource "aws_iam_role" "lambda-save" {
  name               = "iam-for-lambda-${local.function_name_save}"
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

data "archive_file" "lambda-get" {
  type = "zip"
  source_file = "../functions/get-notes-30153574/main.py"
  output_path = "artifact_get.zip"
}

data "archive_file" "lambda-save" {
  type = "zip"
  source_file = "../functions/save-note-30153574/main.py"
  output_path = "artifact_save.zip"
}

data "archive_file" "lambda-delete" {
  type = "zip"
  source_file = "../functions/delete-note-30153574/main.py"
  output_path = "artifact_delete.zip"
}

resource "aws_lambda_function" "get-notes-30153574" {
   role = aws_iam_role.lambda-get.arn
    function_name = local.function_name_get
    handler = local.handler_name
    filename = local.artifact_name_get
    source_code_hash = data.archive_file.lambda-get.output_base64sha256
    runtime = "python3.9"
}

resource "aws_lambda_function" "save-note-30153574" {
    role = aws_iam_role.lambda-save.arn
    function_name = local.function_name_save
    handler = local.handler_name
    filename = local.artifact_name_save
    source_code_hash = data.archive_file.lambda-save.output_base64sha256
    runtime = "python3.9"
}

resource "aws_lambda_function" "delete-note-30153574" {
  role = aws_iam_role.lambda-delete.arn
  function_name = local.function_name_delete
  handler = local.handler_name
  filename = local.artifact_name_delete
  source_code_hash = data.archive_file.lambda-delete.output_base64sha256
  runtime = "python3.9"
}



resource "aws_iam_policy" "logs-get" {
  name        = "lambda-logging-${local.function_name_get}"
  description = "IAM policy for logging from a lambda"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
        "logs:CreateLogGroup",
        "logs:CreateLogStream",
        "logs:PutLogEvents",
        "dynamodb:GetItem",
        "dynamodb:Query"
      ],
      "Resource": ["arn:aws:logs:*:*:*","${aws_dynamodb_table.lotion-30153574.arn}"],
      "Effect": "Allow"
    }
  ]
}
EOF
}

resource "aws_iam_policy" "logs-delete" {
  name        = "lambda-logging-${local.function_name_delete}"
  description = "IAM policy for logging from a lambda"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
{
  "Action": [
    "logs:CreateLogGroup",
    "logs:CreateLogStream",
    "logs:PutLogEvents",
    "dynamodb:DeleteItem"
  ],
"Resource": ["arn:aws:logs:*:*:*","${aws_dynamodb_table.lotion-30153574.arn}"],
"Effect": "Allow"
    }
  ]
}
EOF
}

resource "aws_iam_policy" "logs-save" {
name = "lambda-logging-${local.function_name_save}"
description = "IAM policy for logging from a lambda"

policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
{
  "Action": [
    "logs:CreateLogGroup",
    "logs:CreateLogStream",
    "logs:PutLogEvents",
    "dynamodb:PutItem"
  ],
  "Resource": ["arn:aws:logs:*:*:*","${aws_dynamodb_table.lotion-30153574.arn}"],
  "Effect": "Allow"
    }
  ]
}
EOF
}


resource "aws_iam_role_policy_attachment" "lambda-logs-get"   {
  role = aws_iam_role.lambda-get.name
  policy_arn = aws_iam_policy.logs-get.arn      
}

resource "aws_iam_role_policy_attachment" "lambda-logs-delete" {
  role = aws_iam_role.lambda-delete.name
  policy_arn = aws_iam_policy.logs-delete.arn      
}

resource "aws_iam_role_policy_attachment" "lambda-logs-save" {  
  role = aws_iam_role.lambda-save.name
  policy_arn = aws_iam_policy.logs-save.arn    
}

resource "aws_lambda_function_url" "url-save" {
  function_name      = aws_lambda_function.save-note-30153574.function_name
  authorization_type = "NONE"

  cors {
    allow_credentials = true
    allow_origins     = ["*"]
    allow_methods     = ["POST"]
    allow_headers     = ["*"]
    expose_headers    = ["keep-alive", "date"]
  }
}

resource "aws_lambda_function_url" "url-get" {
  function_name      = aws_lambda_function.get-notes-30153574.function_name
  authorization_type = "NONE"

  cors {
    allow_credentials = true
    allow_origins     = ["*"]
    allow_methods     = ["GET"]
    allow_headers     = ["*"]
    expose_headers    = ["keep-alive", "date"]
  }
}
resource "aws_lambda_function_url" "url-delete" {
  function_name      = aws_lambda_function.delete-note-30153574.function_name
  authorization_type = "NONE"

  cors {
    allow_credentials = true
    allow_origins     = ["*"]
    allow_methods     = ["DELETE"]
    allow_headers     = ["*"]
    expose_headers    = ["keep-alive", "date"]
  }
}

output "lambda-get_url" {
  value = aws_lambda_function_url.url-get.function_url
}

output "lambda-save_url" {
  value = aws_lambda_function_url.url-save.function_url
}

output "lambda-delete_url" {
  value = aws_lambda_function_url.url-delete.function_url
}

resource "aws_dynamodb_table" "lotion-30153574" {
  name = "lotion-30153574"
  billing_mode = "PROVISIONED"
  read_capacity = 1
  write_capacity = 1

  hash_key = "email"
  range_key = "id"

  attribute {
    name = "email"
    type = "S"
  }

  attribute {
    name = "id"
    type = "S"
  }
}
