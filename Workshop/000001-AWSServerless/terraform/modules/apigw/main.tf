resource "aws_api_gateway_rest_api" "rest_api_gw" {
  name        = "aws-serverless"
  description = "AWS Serverless"
  endpoint_configuration {
    types = ["REGIONAL"]
  }
}

resource "aws_api_gateway_authorizer" "authorization_cognito" {
  name        = "authorizer-cognito-001"
  rest_api_id = aws_api_gateway_rest_api.rest_api_gw.id
  type = "COGNITO_USER_POOLS"
  provider_arns = var.aws_user_pools_arn
}

resource "aws_api_gateway_resource" "resource_users" {
  rest_api_id = aws_api_gateway_rest_api.rest_api_gw.id
  parent_id   = aws_api_gateway_rest_api.rest_api_gw.root_resource_id
  path_part   = "Users"
}

resource "aws_api_gateway_method" "method_get_users" {
  rest_api_id   = aws_api_gateway_rest_api.rest_api_gw.id
  resource_id   = aws_api_gateway_resource.resource_users.id
  http_method   = "GET"
  authorization = "COGNITO_USER_POOLS"
  authorizer_id = aws_api_gateway_authorizer.authorization_cognito.id
}

resource "aws_api_gateway_integration" "integration_get_users" {
  rest_api_id = aws_api_gateway_rest_api.rest_api_gw.id
  resource_id = aws_api_gateway_resource.resource_users.id
  http_method = aws_api_gateway_method.method_get_users.http_method
  type = "AWS"
  uri = var.lambda_get_user_arn
}
