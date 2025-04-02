output "lambda_role_id" {
  value = aws_iam_role.lambda_role.id
}

output "lambda_role_arn" {
  value = aws_iam_role.lambda_role.arn
}

output "apigw_role_invoke_function" {
  value = aws_iam_role.apigw_role_execution.arn
}

output "apigateway_sqs_arn" {
  value = aws_iam_role.apiSQS.arn
}

output "lambda_sqs_arn" {
  value = aws_iam_role.lambda_sqs_role.arn
}