output "aws_user_pools_id" {
  value = module.aws_cognito.aws_user_pools_id
}

output "aws_user_pools_web_client_id" {
  value = module.aws_cognito.aws_user_pools_web_client_id
}

output "aws_invoke_url" {
  value = module.aws_api_gateway.invoke_url
}
