// Setup for action zip to Lambda function
data "archive_file" "lambda_dynamo_stream_handler_zip" {
    type          = "zip"
    source_file   = "../config-component/lambda-dynamo-stream-handler/.build/index.js"
    output_path   = "${var.aws_output_filezip_dynamo_stream_handler}"  
}

// Create IAM role for AWS LAMBDA-DynamoStreamHandler
resource "aws_iam_role" "iam_for_lambda_dynamo_stream_handler" {
  name = "iam_for_lambda_dynamo_stream_handler"

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

// Create policy for Lambda Dynamo Stream Handler
resource "aws_iam_policy" "policy_for_lambda_dynamo_stream_handler" {
  name        = "LambdaDynamoStreamHandlerFunctionPolicy"

  policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "VisualEditor0",
            "Effect": "Allow",
            "Action": [              
              "states:StartExecution",
              "states:SendTaskSuccess",
              "states:SendTaskHeartbeat",
              "states:SendTaskHeartbeat",
              "dynamodb:GetShardIterator",
              "dynamodb:DescribeStream",
              "dynamodb:GetRecords",
              "dynamodb:ListStreams",
              "logs:CreateLogGroup",
              "logs:CreateLogStream",
              "logs:PutLogEvents"
            ],
            "Resource": "*"
        }
    ]
}
EOF
}

// Attach policy to IAM Role for Lambda
resource "aws_iam_role_policy_attachment" "iam_for_lambda_attach_policy_lambda_dynamo_stream_handler" {
  role       = "${aws_iam_role.iam_for_lambda_dynamo_stream_handler.name}"
  policy_arn = "${aws_iam_policy.policy_for_lambda_dynamo_stream_handler.arn}"
}

resource "aws_lambda_event_source_mapping" "trigger_lambda_dynamo_stream_handler" {                
  event_source_arn  = "${var.database-test-terraform-stream}"
  function_name     = aws_lambda_function.lambda_dynamo_stream_handler.arn                      
  starting_position = "LATEST"
}

// Create AWS Lambda functions
resource "aws_lambda_function" "lambda_dynamo_stream_handler" {
  filename         = "${var.aws_output_filezip_dynamo_stream_handler}"
  function_name    = "lambda_dynamo_stream_handler"
  role             = aws_iam_role.iam_for_lambda_dynamo_stream_handler.arn
  handler          = "index.LambdaDynamoStreamHandlerFunction"
  source_code_hash = "${data.archive_file.lambda_dynamo_stream_handler_zip.output_base64sha256}"
  runtime          = "nodejs14.x" 
  environment {
    variables = {
      state_machine_arn = "${var.state_machine_arn}"
    }
  }
}

