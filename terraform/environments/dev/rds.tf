
locals {
  rds_instances = {
    catalog = {
      engine         = "mysql"
      engine_version = "8.4"
      db_name        = "catalog"
      username       = "catalog_admin"
      port           = 3306
    }

    orders = {
      engine         = "postgres"
      engine_version = "18.6"
      db_name        = "orders"
      username       = "orders_admin"
      port           = 5432
    }
  }
}

resource "aws_security_group" "rds" {
  for_each = local.rds_instances

  name_prefix = "${local.name}-${each.key}-rds-"
  description = "RDS access for ${each.key}"
  vpc_id      = module.vpc.vpc_id

  tags = {
    Name = "${local.name}-${each.key}-rds"
  }
}

resource "aws_vpc_security_group_ingress_rule" "rds_from_eks" {
  for_each = local.rds_instances

  security_group_id            = aws_security_group.rds[each.key].id
  referenced_security_group_id = module.eks.node_security_group_id

  ip_protocol = "tcp"
  from_port   = each.value.port
  to_port     = each.value.port

  description = "Allow EKS nodes to access ${each.key} database"
}

resource "aws_db_instance" "this" {
  for_each = local.rds_instances

  identifier     = "${local.name}-${each.key}"
  engine         = each.value.engine
  engine_version = each.value.engine_version
  instance_class = var.rds.instance_class

  db_name  = each.value.db_name
  username = each.value.username
  port     = each.value.port

  allocated_storage = var.rds.allocated_storage
  storage_type      = "gp3"
  storage_encrypted = true

  db_subnet_group_name   = module.vpc.database_subnet_group_name
  vpc_security_group_ids = [aws_security_group.rds[each.key].id]
  publicly_accessible    = false
  multi_az               = false

  manage_master_user_password = true

  backup_retention_period  = 0
  deletion_protection      = false
  skip_final_snapshot      = true
  delete_automated_backups = true

  auto_minor_version_upgrade = true
  apply_immediately          = true

  performance_insights_enabled = false
  monitoring_interval          = 0

  tags = {
    Name    = "${local.name}-${each.key}"
    Service = each.key
  }
}
