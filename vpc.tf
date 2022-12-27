module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "3.14.2"

  name = "${local.resource_prefix}-vpc"

  cidr = "10.181.0.0/16"
  azs  = slice(data.aws_availability_zones.available.names, 0, 3)

  public_subnets   = ["10.181.0.0/24", "10.181.1.0/24"]
  private_subnets  = ["10.181.3.0/24", "10.181.4.0/24"]
  database_subnets = ["10.181.6.0/24", "10.181.7.0/24"]

  enable_nat_gateway     = true
  single_nat_gateway     = true
  one_nat_gateway_per_az = false
  enable_dns_hostnames   = true

  public_subnet_tags = {
    "kubernetes.io/cluster/${local.cluster_name}" = "shared"
    "kubernetes.io/role/elb"                      = 1
  }

  private_subnet_tags = {
    "kubernetes.io/cluster/${local.cluster_name}" = "shared"
    "kubernetes.io/role/internal-elb"             = 1
  }

  tags = {
    Origin         = var.common_origin_tag
    ResourcePrefix = var.resource_prefix
    Owner          = var.common_owner_tag
    Purpose        = var.common_purpose_tag
    Stack          = var.common_stack_tag
  }
}
