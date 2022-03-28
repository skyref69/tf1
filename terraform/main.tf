resource "aws_iam_role" "iam_for_lambda" {
  name = "iam_for_lambda"

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

# locals{
#     lambda_zip = "outputs/LambdaTest.zip"
# }

# data "archive_file" "LambdaTest" {
#   type        = "zip"
#   source_file = "config-service/voting-state-handler/lambda/LambdaTest.ts"
#   output_path = "${local.lambda_zip}"
# }

# resource "aws_lambda_function" "test_lambda" {
#   filename      = "${local.lambda_zip}"
#   function_name = "welcome"
#   role          = aws_iam_role.iam_for_lambda.arn
#   handler       = "welcome.hello"

#   #source_code_hash = "${filebase64sha256(local.lambda_zip)}"

#   runtime = "nodejs12.x"

#   environment {
#     variables = {
#       foo = "bar"
#     }
#   }
# }

# Simple AWS Lambda Terraform Example
# requires 'index.js' in the same directory
# to test: run `terraform plan`
# to deploy: run `terraform apply`



provider "aws" {
  region = "${var.aws_region}"
  profile = "${var.aws_profile}"
}

data "archive_file" "lambda_zip" {
    type          = "zip"
    source_file   = "../dist/index.js"
    output_path   = "lambda_function.zip"
}

resource "aws_lambda_function" "test_lambda" {
  filename         = "lambda_function.zip"
  function_name    = "test_lambda"
  role             = aws_iam_role.iam_for_lambda.arn
  handler          = "index.test"
  source_code_hash = "${data.archive_file.lambda_zip.output_base64sha256}"
  runtime          = "nodejs12.x"
}

# resource "aws_iam_role" "iam_for_lambda_tf" {
#   name = "iam_for_lambda_tf"

#   assume_role_policy = <<EOF
# {
#   "Version": "2012-10-17",
#   "Statement": [
#     {
#       "Action": "sts:AssumeRole",
#       "Principal": {
#         "Service": "lambda.amazonaws.com"
#       },
#       "Effect": "Allow",
#       "Sid": ""
#     }
#   ]
# }
# EOF
# }