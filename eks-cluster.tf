module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "19.0.4"

  cluster_name    = local.cluster_name
  cluster_version = "1.24"

  vpc_id                         = module.vpc.vpc_id
  subnet_ids                     = module.vpc.private_subnets
  cluster_endpoint_public_access = true

  eks_managed_node_group_defaults = {
    ami_type = var.eks_ami_type
  }

  eks_managed_node_groups = {
    one = {
      name = "node-group-1"

      instance_types = [var.node_group_instance_type]

      min_size     = 1
      max_size     = 3
      desired_size = 2
    }

    two = {
      name = "node-group-2"

      instance_types = [var.node_group_instance_type]

      min_size     = 1
      max_size     = 2
      desired_size = 1
    }
  }

  tags = {
    Origin         = var.common_origin_tag
    ResourcePrefix = var.resource_prefix
    Owner          = var.common_owner_tag
    Purpose        = var.common_purpose_tag
    Stack          = var.common_stack_tag
  }
}
