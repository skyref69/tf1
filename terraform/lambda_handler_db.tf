// Create archives for AWS Lambda functions which will be used for and into Step Function

data "archive_file" "lambda_handler_db_zip" {
    type          = "zip"
    source_file   = "../dist/LambdaHandlerDb/index.js"
    output_path   = "${var.aws_output_handler_db}"  
}

// Create IAM role for AWS LAMBDA_handler_db
resource "aws_iam_role" "iam_for_lambda_handler_db" {
  name = "iam_for_lambda_handler_db"

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

// Create policy for Lambda Handler Db
resource "aws_iam_policy" "policy_for_lambda_handler_db" {
  name        = "LambdaHandlerDbPolicy"

  policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "VisualEditor0",
            "Effect": "Allow",
            "Action": [
              "states:StartExecution"
            ],
            "Resource": "*"
        }
    ]
}
EOF
}

// Attach policy to IAM Role for Lambda
resource "aws_iam_role_policy_attachment" "iam_for_lambda_attach_policy_lambda_handler_db" {
  role       = "${aws_iam_role.iam_for_lambda_handler_db.name}"
  policy_arn = "${aws_iam_policy.policy_for_lambda_handler_db.arn}"
}

// Create AWS Lambda functions
resource "aws_lambda_function" "lambda_handler_db" {
  filename         = "${var.aws_output_handler_db}"
  function_name    = "lambda_handler_db"
  role             = aws_iam_role.iam_for_lambda_handler_db.arn
  handler          = "index.LambdaHandlerDbFunction"
  source_code_hash = "${data.archive_file.lambda_handler_db_zip.output_base64sha256}"
  runtime          = "nodejs12.x"
}