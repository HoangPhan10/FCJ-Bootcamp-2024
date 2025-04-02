output "queue_name" {
  value = aws_sqs_queue.sqs_queue.name
}

output "queue_arn" {
  value = aws_sqs_queue.sqs_queue.arn
}