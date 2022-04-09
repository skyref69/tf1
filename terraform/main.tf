provider "aws" {
  region = "${var.aws_region}"
  profile = "${var.aws_profile}"
}
module "dynamodb-test-terraform" {
  source  = "./modules/dynamodb-test-terraform"  
}
module "stepfunction" {
  source  = "./modules/stepfunction" 
  lambda_update_phase_task_token_arn = "${module.lambda-update-phase-task-token.lambda_update_phase_task_token_arn}" 
}
module "lambda-dynamo-stream-handler" {
  source  = "./modules/lambda-dynamo-stream-handler"
  DATABASE-TEST-TERRAFORM-STREAM = "${module.dynamodb-test-terraform.DATABASE-TEST-TERRAFORM-STREAM}"
  STATE_MACHINE_ARN = "${module.stepfunction.STATE_MACHINE_ARN}"
}
module "lambda-update-phase-task-token" {
  source  = "./modules/lambda-update-phase-task-token"
  DATABASENAME = "${module.dynamodb-test-terraform.DATABASENAME}"
}