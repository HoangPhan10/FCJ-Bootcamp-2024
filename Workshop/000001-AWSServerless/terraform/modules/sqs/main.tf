resource "aws_sqs_queue" "sqs_queue" {
  name       = "KMA-Queue"
  fifo_queue = false

  tags = {
    Environment = "production"
  }
}

resource "aws_lambda_event_source_mapping" "event_source_mapping" {
  batch_size       = 1
  event_source_arn =  aws_sqs_queue.sqs_queue.arn
  enabled          = true
  function_name    =  var.lambda_post_user_arn
}