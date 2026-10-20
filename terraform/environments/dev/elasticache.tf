
resource "aws_elasticache_subnet_group" "checkout" {
  name        = "${local.name}-checkout"
  description = "Private database subnets for Checkout cache"

  subnet_ids = module.vpc.database_subnets

  tags = {
    Name = "${local.name}-checkout"
  }
}

resource "aws_security_group" "elasticache" {
  name_prefix = "${local.name}-elasticache-"
  description = "ElastiCache access for Checkout service"
  vpc_id      = module.vpc.vpc_id

  tags = {
    Name = "${local.name}-elasticache"
  }
}

resource "aws_vpc_security_group_ingress_rule" "elasticache_from_eks" {
  security_group_id            = aws_security_group.elasticache.id
  referenced_security_group_id = module.eks.node_security_group_id

  ip_protocol = "tcp"
  from_port   = 6379
  to_port     = 6379

  description = "Allow EKS nodes to access Valkey"
}

resource "aws_elasticache_replication_group" "checkout" {
  replication_group_id = "${local.name}-checkout"
  description          = "Checkout cache for AWS Retail Store"

  engine         = "valkey"
  engine_version = var.elasticache.engine_version
  node_type      = var.elasticache.node_type

  port                       = 6379
  num_cache_clusters         = 1
  automatic_failover_enabled = false
  multi_az_enabled           = false

  subnet_group_name  = aws_elasticache_subnet_group.checkout.name
  security_group_ids = [aws_security_group.elasticache.id]

  at_rest_encryption_enabled = true
  transit_encryption_enabled = true

  snapshot_retention_limit = 0
  apply_immediately        = true

  tags = {
    Name    = "${local.name}-checkout"
    Service = "checkout"
  }
}
