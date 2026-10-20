
resource "aws_dynamodb_table" "cart" {
  name         = "${local.name}-cart"
  billing_mode = "PAY_PER_REQUEST"
  table_class  = "STANDARD"

  hash_key = "id"

  attribute {
    name = "id"
    type = "S"
  }

  deletion_protection_enabled = false

  point_in_time_recovery {
    enabled = false
  }

  tags = {
    Name    = "${local.name}-cart"
    Service = "cart"
  }
}
