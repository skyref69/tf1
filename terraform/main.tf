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
  database-test-terraform-stream = "${module.dynamodb-test-terraform.database-test-terraform-stream}"
  state_machine_arn = "${module.stepfunction.state_machine_arn}"
}
module "lambda-update-phase-task-token" {
  source  = "./modules/lambda-update-phase-task-token"
  databasename = "${module.dynamodb-test-terraform.databasename}"
}