
locals {
  pod_identities = {
    cart = {
      namespace       = "retail-store"
      service_account = "cart"
    }

    orders = {
      namespace       = "retail-store"
      service_account = "orders"
    }

    external_secrets = {
      namespace       = "external-secrets"
      service_account = "external-secrets"
    }
  }
}

data "aws_iam_policy_document" "pod_identity_trust" {
  statement {
    effect = "Allow"

    actions = [
      "sts:AssumeRole",
      "sts:TagSession"
    ]

    principals {
      type        = "Service"
      identifiers = ["pods.eks.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "pod_identity" {
  for_each = local.pod_identities

  name               = "${local.name}-${replace(each.key, "_", "-")}"
  assume_role_policy = data.aws_iam_policy_document.pod_identity_trust.json

  tags = {
    Name = "${local.name}-${replace(each.key, "_", "-")}"
  }
}


data "aws_iam_policy_document" "cart_dynamodb" {
  statement {
    sid    = "CartTableAccess"
    effect = "Allow"

    actions = [
      "dynamodb:GetItem",
      "dynamodb:PutItem",
      "dynamodb:UpdateItem",
      "dynamodb:DeleteItem",
      "dynamodb:Query",
      "dynamodb:Scan",
      "dynamodb:DescribeTable"
    ]

    resources = [
      aws_dynamodb_table.cart.arn
    ]
  }
}

resource "aws_iam_role_policy" "cart_dynamodb" {
  name   = "cart-dynamodb-access"
  role   = aws_iam_role.pod_identity["cart"].id
  policy = data.aws_iam_policy_document.cart_dynamodb.json
}


data "aws_iam_policy_document" "orders_sqs" {
  statement {
    sid    = "OrdersQueueAccess"
    effect = "Allow"

    actions = [
      "sqs:SendMessage",
      "sqs:ReceiveMessage",
      "sqs:DeleteMessage",
      "sqs:ChangeMessageVisibility",
      "sqs:GetQueueUrl",
      "sqs:GetQueueAttributes"
    ]

    resources = [
      aws_sqs_queue.orders.arn
    ]
  }
}

resource "aws_iam_role_policy" "orders_sqs" {
  name   = "orders-sqs-access"
  role   = aws_iam_role.pod_identity["orders"].id
  policy = data.aws_iam_policy_document.orders_sqs.json
}


data "aws_iam_policy_document" "external_secrets" {
  statement {
    sid    = "ReadRDSSecrets"
    effect = "Allow"

    actions = [
      "secretsmanager:GetSecretValue",
      "secretsmanager:DescribeSecret"
    ]

    resources = [
      for db in aws_db_instance.this :
      db.master_user_secret[0].secret_arn
    ]
  }
}

resource "aws_iam_role_policy" "external_secrets" {
  name   = "read-rds-secrets"
  role   = aws_iam_role.pod_identity["external_secrets"].id
  policy = data.aws_iam_policy_document.external_secrets.json
}


resource "aws_eks_pod_identity_association" "this" {
  for_each = local.pod_identities

  cluster_name    = module.eks.cluster_name
  namespace       = each.value.namespace
  service_account = each.value.service_account
  role_arn        = aws_iam_role.pod_identity[each.key].arn

  depends_on = [
    module.eks
  ]

  tags = {
    Name = "${local.name}-${replace(each.key, "_", "-")}"
  }
}

#github-actions
resource "aws_iam_openid_connect_provider" "github" {
  url = "https://token.actions.githubusercontent.com"

  client_id_list = ["sts.amazonaws.com"]
}

data "aws_iam_policy_document" "github_actions_assume" {
  statement {
    actions = ["sts:AssumeRoleWithWebIdentity"]

    principals {
      type = "Federated"
      identifiers = [
        aws_iam_openid_connect_provider.github.arn
      ]
    }

    condition {
      test     = "StringEquals"
      variable = "token.actions.githubusercontent.com:aud"
      values   = ["sts.amazonaws.com"]
    }

    condition {
      test     = "StringEquals"
      variable = "token.actions.githubusercontent.com:sub"
      values = [
        "repo:mehmetbozyel@42387833/aws-platform-lab@1425783510:ref:refs/heads/main"
      ]
    }
  }
}

resource "aws_iam_role" "github_actions_ecr" {
  name = "${local.name}-github-ecr-push"

  assume_role_policy = data.aws_iam_policy_document.github_actions_assume.json
}

data "aws_iam_policy_document" "github_ecr_push" {
  statement {
    sid       = "ECRAuthentication"
    actions   = ["ecr:GetAuthorizationToken"]
    resources = ["*"]
  }

  statement {
    sid = "PushImages"

    actions = [
      "ecr:BatchCheckLayerAvailability",
      "ecr:InitiateLayerUpload",
      "ecr:UploadLayerPart",
      "ecr:CompleteLayerUpload",
      "ecr:PutImage",
      "ecr:BatchGetImage"
    ]

    resources = [
      for repo in aws_ecr_repository.apps : repo.arn
    ]
  }
}

resource "aws_iam_role_policy" "github_ecr_push" {
  name   = "${local.name}-ecr-push"
  role   = aws_iam_role.github_actions_ecr.id
  policy = data.aws_iam_policy_document.github_ecr_push.json
}
