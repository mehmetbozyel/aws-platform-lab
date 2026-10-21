
locals {
  ecr_repositories = toset([
    "ui",
    "catalog",
    "cart",
    "orders",
    "checkout"
  ])
}

resource "aws_ecr_repository" "apps" {
  for_each = local.ecr_repositories

  name                 = "${local.name}/${each.key}"
  image_tag_mutability = "IMMUTABLE"
  force_delete         = true

  encryption_configuration {
    encryption_type = "AES256"
  }

  tags = {
    Name    = "${local.name}/${each.key}"
    Service = each.key
  }
}

resource "aws_ecr_lifecycle_policy" "apps" {
  for_each = aws_ecr_repository.apps

  repository = each.value.name

  policy = jsonencode({
    rules = [
      {
        rulePriority = 1
        description  = "Keep the latest 3 images"
        selection = {
          tagStatus   = "any"
          countType   = "imageCountMoreThan"
          countNumber = 3
        }
        action = {
          type = "expire"
        }
      }
    ]
  })
}
