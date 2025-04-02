resource "aws_api_gateway_rest_api" "rest_api_gw" {
  name        = "aws-serverless"
  description = "AWS Serverless KMA"
  endpoint_configuration {
    types = ["REGIONAL"]
  }
}

resource "aws_api_gateway_authorizer" "authorization_cognito" {
  depends_on    = [aws_api_gateway_rest_api.rest_api_gw]
  name          = "authorizer-cognito-001"
  rest_api_id   = aws_api_gateway_rest_api.rest_api_gw.id
  type          = "COGNITO_USER_POOLS"
  provider_arns = var.aws_user_pools_arn
}

resource "aws_api_gateway_resource" "resource_users" {
  depends_on  = [aws_api_gateway_rest_api.rest_api_gw]
  rest_api_id = aws_api_gateway_rest_api.rest_api_gw.id
  parent_id   = aws_api_gateway_rest_api.rest_api_gw.root_resource_id
  path_part   = "users"
}

#-----------------------------------------------------------------------------OPTIONS /users
resource "aws_api_gateway_method" "options_method" {
  rest_api_id   = aws_api_gateway_rest_api.rest_api_gw.id
  resource_id   = aws_api_gateway_resource.resource_users.id
  http_method   = "OPTIONS"
  authorization = "NONE"
}
resource "aws_api_gateway_method_response" "options_200" {
  depends_on  = [aws_api_gateway_method.options_method]
  rest_api_id = aws_api_gateway_rest_api.rest_api_gw.id
  resource_id = aws_api_gateway_resource.resource_users.id
  http_method = aws_api_gateway_method.options_method.http_method
  status_code = "200"
  response_parameters = {
    "method.response.header.Access-Control-Allow-Headers" = true,
    "method.response.header.Access-Control-Allow-Methods" = true,
    "method.response.header.Access-Control-Allow-Origin"  = true
  }
}
resource "aws_api_gateway_integration" "options_integration" {
  rest_api_id = aws_api_gateway_rest_api.rest_api_gw.id
  resource_id = aws_api_gateway_resource.resource_users.id
  http_method = aws_api_gateway_method.options_method.http_method
  type        = "MOCK"
  depends_on  = [aws_api_gateway_method.options_method]
  request_templates = {
    "application/json" = jsonencode({ "statusCode" : 200 })
  }
}
resource "aws_api_gateway_integration_response" "options_integration_response" {
  rest_api_id = aws_api_gateway_rest_api.rest_api_gw.id
  resource_id = aws_api_gateway_resource.resource_users.id
  http_method = aws_api_gateway_method.options_method.http_method
  status_code = aws_api_gateway_method_response.options_200.status_code
  response_parameters = {
    "method.response.header.Access-Control-Allow-Headers" = "'Content-Type,Authorization,X-Amz-Date,X-Api-Key,X-Amz-Security-Token'",
    "method.response.header.Access-Control-Allow-Methods" = "'DELETE,GET,HEAD,OPTIONS,PATCH,POST,PUT'",
    "method.response.header.Access-Control-Allow-Origin"  = "'*'"
  }
  depends_on = [aws_api_gateway_method_response.options_200]
}
#-----------------------------------------------------------------------------GET /users
resource "aws_api_gateway_method" "method_get_users" {
  depends_on    = [aws_api_gateway_resource.resource_users]
  rest_api_id   = aws_api_gateway_rest_api.rest_api_gw.id
  resource_id   = aws_api_gateway_resource.resource_users.id
  http_method   = "GET"
  authorization = "COGNITO_USER_POOLS"
  authorizer_id = aws_api_gateway_authorizer.authorization_cognito.id
}


resource "aws_api_gateway_integration" "integration_get_users" {
  depends_on              = [aws_api_gateway_method.method_get_users]
  rest_api_id             = aws_api_gateway_rest_api.rest_api_gw.id
  resource_id             = aws_api_gateway_resource.resource_users.id
  http_method             = aws_api_gateway_method.method_get_users.http_method
  integration_http_method = "POST"
  type                    = "AWS"
  uri                     = var.invoke_lambda_get_user
  passthrough_behavior    = "NEVER"
  credentials             = var.credentials
  request_templates = {
    "application/json" = jsonencode({})
  }
}
resource "aws_api_gateway_method_response" "response_200" {
  depends_on  = [aws_api_gateway_method.method_get_users]
  rest_api_id = aws_api_gateway_rest_api.rest_api_gw.id
  resource_id = aws_api_gateway_resource.resource_users.id
  http_method = aws_api_gateway_method.method_get_users.http_method
  status_code = "200"
  response_parameters = {
    "method.response.header.Access-Control-Allow-Origin" = true
  }
}
resource "aws_api_gateway_integration_response" "MyDemoIntegrationResponse" {
  rest_api_id = aws_api_gateway_rest_api.rest_api_gw.id
  resource_id = aws_api_gateway_resource.resource_users.id
  http_method = aws_api_gateway_method.method_get_users.http_method
  status_code = aws_api_gateway_method_response.response_200.status_code

  # Transforms the backend JSON response to XML
  response_templates = {}
  response_parameters = {
    "method.response.header.Access-Control-Allow-Origin" = "'http://localhost:3000'"
  }
}

#-----------------------------------------------------------------------------POST /users
resource "aws_api_gateway_method" "method_post_users" {
  depends_on    = [aws_api_gateway_resource.resource_users]
  rest_api_id   = aws_api_gateway_rest_api.rest_api_gw.id
  resource_id   = aws_api_gateway_resource.resource_users.id
  http_method   = "POST"
  authorization = "COGNITO_USER_POOLS"
  authorizer_id = aws_api_gateway_authorizer.authorization_cognito.id

}

resource "aws_api_gateway_integration" "integration_post_users" {
  depends_on              = [aws_api_gateway_method.method_post_users]
  rest_api_id             = aws_api_gateway_rest_api.rest_api_gw.id
  resource_id             = aws_api_gateway_resource.resource_users.id
  http_method             = aws_api_gateway_method.method_post_users.http_method
  integration_http_method = "POST"
  type                    = "AWS"
  credentials             = var.credentials_apiSQS
  uri                     = "arn:aws:apigateway:${var.region}:sqs:path/${var.queue_name}"
  request_parameters = {
    "integration.request.header.Content-Type" = "'application/x-www-form-urlencoded'"
  }
  request_templates = {
    "application/json" = <<EOF
Action=SendMessage&MessageBody=$input.json('$')
EOF
  }
}


resource "aws_api_gateway_method_response" "response_200_post" {
  depends_on  = [aws_api_gateway_method.method_post_users]
  rest_api_id = aws_api_gateway_rest_api.rest_api_gw.id
  resource_id = aws_api_gateway_resource.resource_users.id
  http_method = aws_api_gateway_method.method_post_users.http_method
  status_code = "200"
  response_parameters = {
    "method.response.header.Access-Control-Allow-Origin" = true
  }
}
resource "aws_api_gateway_integration_response" "MyDemoIntegrationResponse_post" {
  rest_api_id = aws_api_gateway_rest_api.rest_api_gw.id
  resource_id = aws_api_gateway_resource.resource_users.id
  http_method = aws_api_gateway_method.method_post_users.http_method
  status_code = aws_api_gateway_method_response.response_200_post.status_code

  # Transforms the backend JSON response to XML
  response_templates = {}
  response_parameters = {
    "method.response.header.Access-Control-Allow-Origin" = "'http://localhost:3000'"
  }
}

#=================================================================== DELETE /users
resource "aws_api_gateway_request_validator" "validator_delete" {
  rest_api_id                 = aws_api_gateway_rest_api.rest_api_gw.id
  name                        = "RequestValidatorDelete"
  validate_request_body       = false
  validate_request_parameters = true
}
resource "aws_api_gateway_method" "method_delete_users" {
  depends_on    = [aws_api_gateway_resource.resource_users]
  rest_api_id   = aws_api_gateway_rest_api.rest_api_gw.id
  resource_id   = aws_api_gateway_resource.resource_users.id
  http_method   = "DELETE"
  authorization = "COGNITO_USER_POOLS"
  authorizer_id = aws_api_gateway_authorizer.authorization_cognito.id
  request_parameters = {
    "method.request.querystring.id"    = true
    "method.request.querystring.email" = true
  }
  request_validator_id = aws_api_gateway_request_validator.validator_delete.id
}

resource "aws_api_gateway_integration" "integration_delete_users" {
  depends_on              = [aws_api_gateway_method.method_delete_users]
  rest_api_id             = aws_api_gateway_rest_api.rest_api_gw.id
  resource_id             = aws_api_gateway_resource.resource_users.id
  http_method             = aws_api_gateway_method.method_delete_users.http_method
  integration_http_method = "POST"
  type                    = "AWS"
  uri                     = var.invoke_lambda_delete_user
  passthrough_behavior    = "NEVER"
  credentials             = var.credentials
  request_templates = {
    "application/json" = jsonencode({
      id    = "$input.params('id')",
      email = "$input.params('email')"
    })
  }
}
resource "aws_api_gateway_method_response" "response_200_delete_users" {
  depends_on  = [aws_api_gateway_method.method_delete_users]
  rest_api_id = aws_api_gateway_rest_api.rest_api_gw.id
  resource_id = aws_api_gateway_resource.resource_users.id
  http_method = aws_api_gateway_method.method_delete_users.http_method
  status_code = "200"
  response_parameters = {
    "method.response.header.Access-Control-Allow-Origin" = true
  }
}
resource "aws_api_gateway_integration_response" "MyDemoIntegrationResponse_delete" {
  rest_api_id = aws_api_gateway_rest_api.rest_api_gw.id
  resource_id = aws_api_gateway_resource.resource_users.id
  http_method = aws_api_gateway_method.method_delete_users.http_method
  status_code = aws_api_gateway_method_response.response_200_delete_users.status_code

  # Transforms the backend JSON response to XML
  response_templates = {}
  response_parameters = {
    "method.response.header.Access-Control-Allow-Origin" = "'http://localhost:3000'"
  }
}

#===================================================================Deployment
resource "aws_api_gateway_deployment" "deployment_resource_aws_serverless" {
  rest_api_id = aws_api_gateway_rest_api.rest_api_gw.id

  triggers = {
    redeployment = sha1(jsonencode([
      aws_api_gateway_resource.resource_users.id,
      aws_api_gateway_method.method_get_users.id,
      aws_api_gateway_method.method_post_users.id,
      aws_api_gateway_method.method_delete_users.id,
      aws_api_gateway_integration.integration_get_users.id,
      aws_api_gateway_integration.integration_post_users.id,
      aws_api_gateway_integration.integration_delete_users.id,
      aws_api_gateway_integration_response.MyDemoIntegrationResponse.id
    ]))
  }

  lifecycle {
    create_before_destroy = true
  }
}
resource "aws_api_gateway_stage" "stage_dev" {
  deployment_id = aws_api_gateway_deployment.deployment_resource_aws_serverless.id
  rest_api_id   = aws_api_gateway_rest_api.rest_api_gw.id
  stage_name    = "dev"
}
