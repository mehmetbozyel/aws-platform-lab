module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "~> 21.0"

  name               = "${local.name}-eks"
  kubernetes_version = var.eks.cluster_version

  # Networking
  vpc_id     = module.vpc.vpc_id
  subnet_ids = module.vpc.private_subnets

  endpoint_public_access       = true
  endpoint_private_access      = true
  endpoint_public_access_cidrs = var.eks.public_access_cidrs

  # Initial lab access
  enable_cluster_creator_admin_permissions = true

  # Encryption
  create_kms_key    = false
  encryption_config        = null

  # Logging
  enabled_log_types = [
    "api",
    "audit",
    "authenticator"
  ]

  cloudwatch_log_group_retention_in_days = var.eks.log_retention_days

  # EKS Managed Addons
  addons = {
    coredns = {}

    kube-proxy = {}

    vpc-cni = {
      before_compute = true
    }

    eks-pod-identity-agent = {
      before_compute = true
    }
  }

  # EKS Managed Node Groups
  eks_managed_node_groups = {
    general = {
      ami_type       = "AL2023_x86_64_STANDARD"
      instance_types = var.eks.node_group.instance_types

      min_size     = var.eks.node_group.min_size
      max_size     = var.eks.node_group.max_size
      desired_size = var.eks.node_group.desired_size

      capacity_type = "ON_DEMAND"

      subnet_ids = module.vpc.private_subnets
    }
  }
}