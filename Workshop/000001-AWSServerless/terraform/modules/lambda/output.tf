output "lambda_get_user_arn" {
  value = aws_lambda_function.lambda_get_user.arn
}

output "invoke_lambda_get_user" {
  value = aws_lambda_function.lambda_get_user.invoke_arn
}

output "lambda_post_user_arn" {
  value = aws_lambda_function.lambda_post_user.arn
}

output "lambda_delete_user_arn" {
  value = aws_lambda_function.lambda_delete_user.invoke_arn
}