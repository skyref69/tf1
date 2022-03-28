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

provider "aws" {
  region = "${var.aws_region}"
  profile = "${var.aws_profile}"
}
data "archive_file" "lambda_zip" {
    type          = "zip"
    source_file   = "../dist/index.js"
    output_path   = "${var.aws_output_filezip}"    
}
resource "aws_lambda_function" "test_lambda" {
  filename         = "${var.aws_output_filezip}"
  function_name    = "test_lambda"
  role             = aws_iam_role.iam_for_lambda.arn
  handler          = "index.test"
  source_code_hash = "${data.archive_file.lambda_zip.output_base64sha256}"
  runtime          = "nodejs12.x"
}