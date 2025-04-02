resource "aws_dynamodb_table" "my_table" {
  name         = "KMA-DynamoDB"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "id"
  range_key    = "email"

  attribute {
    name = "id"
    type = "S"
  }

  attribute {
    name = "email"
    type = "S"
  }

}
