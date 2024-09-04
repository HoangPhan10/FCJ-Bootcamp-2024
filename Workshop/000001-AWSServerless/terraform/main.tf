provider "aws" {
  region = "us-east-1"
}

module "aws_cognito" {
  source = "./modules/cognito"
}


module "aws_iam_role" {
  source = "./modules/IAM"
}

module "aws_lambda" {
  depends_on  = [module.aws_iam_role]
  source      = "./modules/lambda"
  lambda_role = module.aws_iam_role.lambda_role_arn
}

module "aws_api_gateway" {
  depends_on          = [module.aws_cognito, module.aws_lambda]
  source              = "./modules/apigw"
  aws_user_pools_arn  = [module.aws_cognito.aws_user_pools_arn]
  lambda_get_user_arn = module.aws_lambda.lambda_get_user_arn
}
