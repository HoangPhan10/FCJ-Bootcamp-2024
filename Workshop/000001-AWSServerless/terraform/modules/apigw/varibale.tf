variable "aws_user_pools_arn" {
  type = list(string)
}

variable "invoke_lambda_get_user" {
  type = string
}
variable "invoke_lambda_delete_user" {
  type = string
}
variable "credentials" {
  type = string
}

variable "credentials_apiSQS" {
  type = string
}

variable "queue_name" {
  type = string
}

variable "region" {
  type = string
}