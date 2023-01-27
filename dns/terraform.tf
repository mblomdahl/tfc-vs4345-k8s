terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.51.0"
    }
  }

  cloud {
    organization = "mblomdahl"

    workspaces {
      name = "tfc-vs4345-k8s-dns"
    }
  }

  required_version = ">= 1.3.6"
}
