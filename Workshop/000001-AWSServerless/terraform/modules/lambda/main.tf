data "archive_file" "lambda_zip" {
  type = "zip"
  source_dir = "${path.module}/javascripts/users/"
  output_path = "${path.module}/javascripts/users/users.zip"
}

resource "aws_lambda_function" "lambda_get_user" {
  function_name = "lambda_get_user"
  runtime = "nodejs20.x"
  architectures = ["x86_64"]
  filename = "${path.module}/javascripts/users/users.zip"
  #Update code lambda function
  source_code_hash = data.archive_file.lambda_zip.output_base64sha256
  role = var.lambda_role
  handler = "get_user.handler"
  environment {
    variables = {
      foo = "bar"
    }
  }
}