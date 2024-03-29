module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "19.4.2"

  cluster_name    = local.cluster_name
  cluster_version = "1.29"

  vpc_id                         = module.vpc.vpc_id
  subnet_ids                     = module.vpc.private_subnets
  cluster_endpoint_public_access = true

  cluster_addons = {
    aws-ebs-csi-driver = {
      most_recent = true
    }
    coredns = {
      most_recent = true
    }
    kube-proxy = {
      most_recent = true
    }
    vpc-cni = {
      most_recent = true
    }
  }

  eks_managed_node_group_defaults = {
    ami_type = var.eks_ami_type
  }

  eks_managed_node_groups = {
    one = {
      name = "${var.resource_prefix}-node-group-1"

      instance_types = [var.node_group_instance_type]

      min_size     = 2
      max_size     = 8
      desired_size = 2
    }

    two = {
      name = "${var.resource_prefix}-node-group-2"

      instance_types = [var.node_group_instance_type]

      min_size     = 2
      max_size     = 8
      desired_size = 2
    }
  }

  # aws-auth configmap
  manage_aws_auth_configmap = true

  aws_auth_users = [
    {
      userarn  = "arn:aws:iam::878179636352:user/mats.blomdahl"
      username = "mblomdahl"
      groups   = ["system:masters"]
    }
  ]

  aws_auth_roles = [
    {
      rolearn  = "arn:aws:iam::878179636352:role/mb-eks-vs7-developer-role"
      username = "vs7-developer-role"
      groups   = ["vs7-developers"]
    }
  ]

  aws_auth_accounts = [
    "878179636352"
  ]

  tags = {
    Origin         = var.common_origin_tag
    ResourcePrefix = var.resource_prefix
    Owner          = var.common_owner_tag
    Purpose        = var.common_purpose_tag
    Stack          = var.common_stack_tag
  }
}
