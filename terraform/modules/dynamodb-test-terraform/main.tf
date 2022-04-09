resource "aws_dynamodb_table" "DATABASE-TEST-TERRAFORM" {
  name           = "DATABASE-TEST-TERRAFORM"
  billing_mode   = "PAY_PER_REQUEST" 
  hash_key       = "id"
  stream_enabled   = true
  stream_view_type = "NEW_AND_OLD_IMAGES"
  
  attribute {
    name = "id"
    type = "S"
  }

  tags = {
    TODO_TABLE_NAME = "DATABASE-TEST-TERRAFORM"
  }  
}

// Create IAM role for DYNAMODB
resource "aws_iam_role" "iam_for_dynamodb" {
  name = "iam_for_dynamodb"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "dynamodb.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}

# Create policy
resource "aws_iam_policy" "policy_dynamodb" {
  name        = "dynamoDbInvocationPolicy"

  policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "VisualEditor0",
            "Effect": "Allow",
            "Action": [
              "dynamodb:GetShardIterator",
              "dynamodb:DescribeStream",
              "dynamodb:GetRecords",
              "dynamodb:ListStreams"
            ],
            "Resource": "*"
        }
    ]
}
EOF
}

// Attach policy to IAM Role for Lambda
resource "aws_iam_role_policy_attachment" "iam_lambda_attach_policy_dynamodb" {
  role       = "${aws_iam_role.iam_for_dynamodb.name}"
  policy_arn = "${aws_iam_policy.policy_dynamodb.arn}"
}