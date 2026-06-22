data "aws_availability_zones" "available" {
  state = "available"
}

locals {
  name_prefix                 = "${var.platform_name}-${var.environment}"
  cluster_name                = "${local.name_prefix}-eks"
  selected_availability_zones = slice(data.aws_availability_zones.available.names, 0, var.az_count)

  default_tags = merge(
    {
      Project     = "aws-eks-gitops-platform"
      Environment = var.environment
      ManagedBy   = "Terraform"
      Repository  = "aws-eks-gitops-platform"
    },
    var.tags
  )
}

module "vpc" {
  source = "../../modules/vpc"

  name                      = local.name_prefix
  environment               = var.environment
  cidr_block                = var.vpc_cidr_block
  availability_zones        = local.selected_availability_zones
  public_subnet_cidrs       = var.public_subnet_cidrs
  private_subnet_cidrs      = var.private_subnet_cidrs
  enable_single_nat_gateway = var.enable_single_nat_gateway
  tags                      = local.default_tags
}

module "security_groups" {
  source = "../../modules/security-groups"

  cluster_name = local.cluster_name
  vpc_id       = module.vpc.vpc_id
  tags         = local.default_tags
}

module "eks" {
  source = "../../modules/eks"

  cluster_name                         = local.cluster_name
  cluster_version                      = var.cluster_version
  private_subnet_ids                   = module.vpc.private_subnet_ids
  control_plane_security_group_id      = module.security_groups.control_plane_security_group_id
  node_security_group_id               = module.security_groups.node_security_group_id
  cluster_endpoint_public_access       = var.cluster_endpoint_public_access
  cluster_endpoint_private_access      = var.cluster_endpoint_private_access
  cluster_endpoint_public_access_cidrs = var.cluster_endpoint_public_access_cidrs
  node_groups                          = var.node_groups
  tags                                 = local.default_tags
}
