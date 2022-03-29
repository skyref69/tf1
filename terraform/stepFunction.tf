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

# Create policy
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
              "sns:Publish",
              "sns:SetSMSAttributes",
              "sns:GetSMSAttributes"
            ],
            "Resource": "*"
        }
    ]
}
EOF
}

// Attach policy to IAM Role for Step Function
resource "aws_iam_role_policy_attachment" "iam_for_sfn_attach_policy_publish_sns" {
  role       = "${aws_iam_role.iam_for_sfn.name}"
  policy_arn = "${aws_iam_policy.policy_publish_sns.arn}"
}
// ---


// Create topic
resource "aws_sns_topic" "sns_multi_notification" {
  name = "sns_multi_notification"
}


// CREATE STATE MACHINE FOR STEP FUNCTION
resource "aws_sfn_state_machine" "sfn_state_machine" {
  name     = "sample-state-machine"
  role_arn = "${aws_iam_role.iam_for_sfn.arn}"
  
  definition = <<EOF
{
  "StartAt": "Open-vote",
  "States": {
    "Open-vote": {
      "Comment": "Opening phase vote",
      "Type": "Pass",     
      "ResultPath": "$",
      "Next": "Send-sns"
    },
    "Send-sns": {
      "Comment": "Send sns",
      "Type": "Pass",     
      "ResultPath": "$",
      "Next": "send-multiple-notification"
    },
    "send-multiple-notification": {
      "Type": "Task",
      "Resource": "arn:aws:states:::sns:publish",
      "Parameters": {
        "TopicArn": "${aws_sns_topic.sns_multi_notification.arn}",
        "Message.$": "$"
      },
      "Next": "WaitForTask"
    },
    "WaitForTask": {
      "Type": "Task",
      "Resource": "arn:aws:states:::sqs:sendMessage.waitForTaskToken",
      "Parameters": {
        "QueueUrl": "yyyyy",
        "MessageBody": {
          "MessageTitle": "bla bla",
          "TaskToken.$": "$$.Task.Token"
        }
      },
      "End": true,
      "Catch": [
        {
          "ErrorEquals": [ "States.ALL" ],
          "Next": "Send-sns"
        }
      ]
    }

  }
}
EOF
  
  depends_on = [aws_lambda_function.lambda_fn1]

}