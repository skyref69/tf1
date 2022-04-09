# Create IAM role for AWS Step Function
resource "aws_iam_role" "iam_for_sfn" {
  name = "stepFunctionSampleStepFunctionExecutionIAM"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "states.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
}

# Create policy sns-topic ------------------------------------------- //
resource "aws_iam_policy" "policy_publish_sns" {
  name        = "stepFunctionSampleSNSInvocationPolicy"

  policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "VisualEditor0",
            "Effect": "Allow",
            "Action": [
              "sns:Publish"
            ],
            "Resource": "*"
        }
    ]
}
EOF
}

// Attach policy sns-topic to IAM Role for Step Function
resource "aws_iam_role_policy_attachment" "iam_for_sfn_attach_policy_publish_sns" {
  role       = "${aws_iam_role.iam_for_sfn.name}"
  policy_arn = "${aws_iam_policy.policy_publish_sns.arn}"
}
// ---------------------------------------------------------------------------- //

# Create policy invoke lambda handler db -------------------------------------- //
resource "aws_iam_policy" "policy_invoke_lambda" {
  name        = "stepFunctionInvokeLambdaPolicy"

  policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "VisualEditor0",
            "Effect": "Allow",
            "Action": [
                "lambda:InvokeFunction"
            ],
            "Resource": "*"
        }
    ]
}
EOF
}

// Attach policy to IAM Role for Step Function
resource "aws_iam_role_policy_attachment" "iam_for_sfn_attach_policy_invoke_lambda" {
  role       = "${aws_iam_role.iam_for_sfn.name}"
  policy_arn = "${aws_iam_policy.policy_invoke_lambda.arn}"
}
// ----------------------------------------------------------------------------- //


// Create topic
resource "aws_sns_topic" "sns_multi_notification" {
  name = "sns_multi_notification"
}


// CREATE STATE MACHINE FOR STEP FUNCTION
resource "aws_sfn_state_machine" "sfn_state_machine" {
  name     = "state-machine-TERRAFORM"
  role_arn = "${aws_iam_role.iam_for_sfn.arn}"
  
  definition = <<EOF
{
  "StartAt": "Open",
  "States": {
    "Open": {
      "Type": "Task",      
      "Resource": "arn:aws:states:::sns:publish",
      "Parameters": {
        "TopicArn": "${aws_sns_topic.sns_multi_notification.arn}",
        "Message.$": "$"
      }, 
      "ResultPath": null, 
      "Next": "Voting Phase"
    },
    "Voting Phase": {
      "Type": "Task",
      "Resource":"arn:aws:states:::lambda:invoke.waitForTaskToken",
      "Parameters": {
        "FunctionName": "${var.lambda_update_phase_task_token_arn}",
        "Payload":{  
          "token.$":"$$.Task.Token",
          "otherInput.$": "$"
        }
      },
      "ResultPath": null, 
      "Next": "Closed"
    },
    "Closed": {
      "Type": "Task",   
      "Resource": "arn:aws:states:::sns:publish",  
      "Parameters": {
        "TopicArn": "${aws_sns_topic.sns_multi_notification.arn}",
        "Message.$": "$"
      },
      "ResultPath": null,
      "Next": "Aggregate Results"
    },
    "Aggregate Results": {
      "Type": "Pass",  
      "ResultPath": "$",   
      "Next": "Send Results"
    },
    "Send Results": {
      "Type": "Task",
      "Resource": "arn:aws:states:::sns:publish",
      "Parameters": {
        "TopicArn": "${aws_sns_topic.sns_multi_notification.arn}",
        "Message.$": "$"
      },  
      "ResultPath": "$",   
      "End": true
    }
  }
}
EOF
  
}