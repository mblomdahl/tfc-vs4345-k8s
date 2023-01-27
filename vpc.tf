module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "3.14.2"

  name = "${local.resource_prefix}-vpc"

  cidr = var.vpc_cidr
  azs  = slice(data.aws_availability_zones.available.names, 0, 3)

  public_subnets   = [var.vpc_public_subnet_cidr_a, var.vpc_public_subnet_cidr_b]
  private_subnets  = [var.vpc_private_subnet_cidr_a, var.vpc_private_subnet_cidr_b]
  database_subnets = [var.vpc_database_subnet_cidr_a, var.vpc_database_subnet_cidr_b]

  enable_nat_gateway     = true
  single_nat_gateway     = true
  one_nat_gateway_per_az = false
  enable_dns_hostnames   = true

  public_subnet_tags = {
    "kubernetes.io/cluster/${local.cluster_name}" = "shared"
    "kubernetes.io/role/elb"                      = 1
    Tier                                          = "Public"
  }

  private_subnet_tags = {
    "kubernetes.io/cluster/${local.cluster_name}" = "shared"
    "kubernetes.io/role/internal-elb"             = 1
    Tier                                          = "Private"
  }

  database_subnet_group_tags = {
    Tier = "Database"
  }

  tags = {
    Origin         = var.common_origin_tag
    ResourcePrefix = var.resource_prefix
    Owner          = var.common_owner_tag
    Purpose        = var.common_purpose_tag
    Stack          = var.common_stack_tag
  }
}

data "aws_subnets" "private" {
  filter {
    name   = "vpc-id"
    values = [module.vpc.vpc_id]
  }

  tags = {
    Tier = "Private"
  }
}
