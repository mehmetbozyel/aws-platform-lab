#NETWORKING
variable "aws_region" {
  description = "AWS region for the infrastructure"
  type        = string
  default     = "eu-central-1"
}

variable "project_name" {
  description = "Project name used for resource naming"
  type        = string
  default     = "aws-platform-lab"
}

variable "environment" {
  description = "Deployment environment"
  type        = string
  default     = "dev"
}

variable "vpc" {
  description = "VPC and networking configuration"

  type = object({
    cidr               = string
    az_count           = number
    public_subnets     = list(string)
    private_subnets    = list(string)
    database_subnets   = list(string)
    enable_nat_gateway = bool
    single_nat_gateway = bool
  })
}

#EKS
variable "eks" {
  description = "Amazon EKS cluster configuration"

  type = object({
    cluster_version     = string
    public_access_cidrs = optional(list(string), ["0.0.0.0/0"])
    log_retention_days  = optional(number, 7)

    node_group = object({
      instance_types = list(string)
      min_size       = number
      max_size       = number
      desired_size   = number
    })
  })

  validation {
    condition = (
      var.eks.node_group.min_size <= var.eks.node_group.desired_size &&
      var.eks.node_group.desired_size <= var.eks.node_group.max_size
    )

    error_message = "Node group size must satisfy min_size <= desired_size <= max_size."
  }

}

#RDS
variable "rds" {
  description = "RDS configuration for Retail Store services"

  type = object({
    instance_class    = string
    allocated_storage = number
  })

  validation {
    condition     = var.rds.allocated_storage >= 20
    error_message = "RDS storage must be at least 20 GiB."
  }
}

#ElastiCache
variable "elasticache" {
  description = "ElastiCache configuration for Checkout service"

  type = object({
    engine_version = string
    node_type      = string
  })
}