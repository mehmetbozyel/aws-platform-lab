
resource "aws_sqs_queue" "orders_dlq" {
  name = "${local.name}-orders-dlq"

  message_retention_seconds = 1209600

  sqs_managed_sse_enabled = true

  tags = {
    Name    = "${local.name}-orders-dlq"
    Service = "orders"
  }
}

resource "aws_sqs_queue" "orders" {
  name = "${local.name}-orders"

  visibility_timeout_seconds = 30
  message_retention_seconds  = 345600
  receive_wait_time_seconds  = 20

  sqs_managed_sse_enabled = true

  redrive_policy = jsonencode({
    deadLetterTargetArn = aws_sqs_queue.orders_dlq.arn
    maxReceiveCount     = 5
  })

  tags = {
    Name    = "${local.name}-orders"
    Service = "orders"
  }
}
