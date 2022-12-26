terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.46.0"
    }

    random = {
      source  = "hashicorp/random"
      version = "~> 3.4.3"
    }
  }

  cloud {
    organization = "mblomdahl"

    workspaces {
      name = "tfc-vs4345-k8s"
    }
  }

  required_version = ">= 1.3.6"
}
