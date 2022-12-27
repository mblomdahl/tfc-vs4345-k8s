locals {
  resource_prefix = var.resource_prefix
  cluster_name    = "${var.resource_prefix}-cluster"
}

data "aws_eks_cluster" "default" {
  name = local.cluster_name
}

data "aws_eks_cluster_auth" "default" {
  name = local.cluster_name
}

provider "kubernetes" {
  host                   = module.eks.cluster_endpoint
  cluster_ca_certificate = base64decode(module.eks.cluster_certificate_authority_data)
  token                  = data.aws_eks_cluster_auth.default.token
}

data "aws_availability_zones" "available" {}

provider "aws" {
  region = var.region
}
