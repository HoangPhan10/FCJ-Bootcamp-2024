provider "aws" {
  region = "ap-southeast-1"
}

module "aws_cognito" {
  source = "./modules/cognito"
}


module "aws_iam_role" {
  source     = "./modules/IAM"
  queue_arn = module.aws_sqs.queue_arn
}

module "aws_lambda" {
  depends_on  = [module.aws_iam_role]
  source      = "./modules/lambda"
  lambda_role = module.aws_iam_role.lambda_role_arn
  lambda_sqs_role = module.aws_iam_role.lambda_sqs_arn
}

module "aws_sqs" {
  source = "./modules/sqs"
  lambda_post_user_arn = module.aws_lambda.lambda_post_user_arn
}

module "aws_dynamodb" {
  source = "./modules/dynamodb"
}
module "aws_api_gateway" {
  depends_on             = [module.aws_cognito, module.aws_lambda, module.aws_iam_role, module.aws_sqs]
  source                 = "./modules/apigw"
  region                 = "ap-southeast-1"
  queue_name             = module.aws_sqs.queue_name
  credentials_apiSQS     = module.aws_iam_role.apigateway_sqs_arn
  aws_user_pools_arn     = [module.aws_cognito.aws_user_pools_arn]
  invoke_lambda_get_user = module.aws_lambda.invoke_lambda_get_user
  invoke_lambda_delete_user = module.aws_lambda.lambda_delete_user_arn
  credentials            = module.aws_iam_role.apigw_role_invoke_function
}
