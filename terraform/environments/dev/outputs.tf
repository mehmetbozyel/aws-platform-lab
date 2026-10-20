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

