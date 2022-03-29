// Create archives for AWS Lambda functions which will be used for and into Step Function

data "archive_file" "lambda_start_sf_zip" {
    type          = "zip"
    source_file   = "../dist/LambdaStartStepFunction/index.js"
    output_path   = "${var.aws_output_filezip_start_sf}"  
}

data "archive_file" "lambda_fn1_zip" {
    type          = "zip"
    source_file   = "../dist/LambdaStepFunction1/index.js"
    output_path   = "${var.aws_output_filezip_fn1}"    
}

// Create IAM role for AWS LAMBDAStartStepFunction
resource "aws_iam_role" "iam_for_lambda_start_sf" {
  name = "iam_for_lambda_start_sf"

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

resource "aws_iam_policy" "policy_for_lambda_start_sf" {
  name        = "LambdaStartStepFunctionPolicy"

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
resource "aws_iam_role_policy_attachment" "iam_for_lambda_attach_policy_lambda_start_sfn" {
  role       = "${aws_iam_role.iam_for_lambda_start_sf.name}"
  policy_arn = "${aws_iam_policy.policy_for_lambda_start_sf.arn}"
}

// Create AWS Lambda functions
resource "aws_lambda_function" "lambda_start_sf" {
  filename         = "${var.aws_output_filezip_start_sf}"
  function_name    = "lambda_start_sf"
  role             = aws_iam_role.iam_for_lambda_start_sf.arn
  handler          = "index.LambdaStartStepFunction"
  source_code_hash = "${data.archive_file.lambda_start_sf_zip.output_base64sha256}"
  runtime          = "nodejs12.x" 
  environment {
    variables = {
      STATE_MACHINE_ARN = aws_sfn_state_machine.sfn_state_machine.arn
    }
  }
}

resource "aws_lambda_function" "lambda_fn1" {
  filename         = "${var.aws_output_filezip_fn1}"
  function_name    = "lambda_sf"
  role             = aws_iam_role.iam_for_lambda_start_sf.arn  // Remember change arn
  handler          = "index.fn1"
  source_code_hash = "${data.archive_file.lambda_fn1_zip.output_base64sha256}"
  runtime          = "nodejs12.x"
}

