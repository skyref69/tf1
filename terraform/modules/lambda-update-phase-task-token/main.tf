// Create archives for AWS Lambda functions which will be used for and into Step Function

data "archive_file" "lambda_update_phase_task_token_zip" {
    type          = "zip"
    source_file   = "../config-component/lambda-update-phase-task-token/.build/index.js"
    output_path   = "${var.aws_output_lambda_update_phase_task_token}"  
}

// Create IAM role for AWS LAMBDA_handler_db
resource "aws_iam_role" "iam_for_lambda_update_phase_task_token" {
  name = "iam_for_lambda_update_phase_task_token"

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
resource "aws_iam_policy" "policy_for_lambda_update_phase_task_token" {
  name        = "LambdaUpdatePhaseTaskTokenPolicy"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "VisualEditor0",
      "Effect": "Allow",
      "Action": [
        "logs:CreateLogGroup",
        "logs:CreateLogStream",
        "logs:PutLogEvents",
        "dynamodb:GetItem",
        "dynamodb:UpdateItem"
      ],
      "Resource": "*"
    }
  ]
}
EOF
}

// Attach policy to IAM Role for Lambda
resource "aws_iam_role_policy_attachment" "iam_for_lambda_attach_policy_lambda_update_phase_task_token" {
  role       = "${aws_iam_role.iam_for_lambda_update_phase_task_token.name}"
  policy_arn = "${aws_iam_policy.policy_for_lambda_update_phase_task_token.arn}"
}

// Create AWS Lambda functions
resource "aws_lambda_function" "lambda_update_phase_task_token" {  
  filename         = "${var.aws_output_lambda_update_phase_task_token}"
  function_name    = "lambda_update_phase_task_token"
  role             = aws_iam_role.iam_for_lambda_update_phase_task_token.arn
  handler          = "index.LambdaUpdatePhaseTaskTokenFunction"
  source_code_hash = "${data.archive_file.lambda_update_phase_task_token_zip.output_base64sha256}"
  runtime          = "nodejs14.x"   
  environment {
    variables = {
      DATABASENAME = "${var.DATABASENAME}"
    }
  } 
}