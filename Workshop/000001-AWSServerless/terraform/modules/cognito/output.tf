output "aws_user_pools_id" {
  value = aws_cognito_user_pool.cognito_pool_001.id
}

output "aws_user_pools_arn" {
  value = aws_cognito_user_pool.cognito_pool_001.arn
}

output "aws_user_pools_web_client_id" {
  value = aws_cognito_user_pool_client.userpool_client.id
}