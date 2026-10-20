#EKS
output "eks_cluster_name" {
  description = "Amazon EKS cluster name"
  value       = module.eks.cluster_name
}

output "eks_cluster_endpoint" {
  description = "Amazon EKS cluster endpoint"
  value       = module.eks.cluster_endpoint
}

output "eks_cluster_version" {
  description = "Amazon EKS Kubernetes version"
  value       = var.eks.cluster_version
}

output "eks_node_security_group_id" {
  description = "EKS node security group ID"
  value       = module.eks.node_security_group_id
}

#RDS
output "rds_endpoints" {
  description = "RDS database endpoints"

  value = {
    for name, db in aws_db_instance.this :
    name => db.endpoint
  }
}

output "rds_master_secret_arns" {
  description = "RDS-managed master secret ARNs"

  value = {
    for name, db in aws_db_instance.this :
    name => db.master_user_secret[0].secret_arn
  }
}

#DYNAMODB
output "cart_dynamodb_table_name" {
  description = "DynamoDB table name for Cart service"
  value       = aws_dynamodb_table.cart.name
}

output "cart_dynamodb_table_arn" {
  description = "DynamoDB table ARN for Cart service"
  value       = aws_dynamodb_table.cart.arn
}

#Endpoint
output "dynamodb_vpc_endpoint_id" {
  description = "DynamoDB Gateway VPC Endpoint ID"
  value       = aws_vpc_endpoint.dynamodb.id
}

#ElastiCache
output "checkout_cache_endpoint" {
  description = "Primary endpoint for Checkout Valkey cache"
  value       = aws_elasticache_replication_group.checkout.primary_endpoint_address
}

output "checkout_cache_port" {
  description = "Port for Checkout Valkey cache"
  value       = aws_elasticache_replication_group.checkout.port
}

output "checkout_cache_security_group_id" {
  description = "Security group ID of Checkout cache"
  value       = aws_security_group.elasticache.id
}

#SQS
output "orders_sqs_queue_name" {
  description = "Orders SQS queue name"
  value       = aws_sqs_queue.orders.name
}

output "orders_sqs_queue_url" {
  description = "Orders SQS queue URL"
  value       = aws_sqs_queue.orders.url
}

output "orders_sqs_queue_arn" {
  description = "Orders SQS queue ARN"
  value       = aws_sqs_queue.orders.arn
}

output "orders_sqs_dlq_arn" {
  description = "Orders SQS dead letter queue ARN"
  value       = aws_sqs_queue.orders_dlq.arn
}
