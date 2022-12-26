terraform {

  cloud {
    organization = "mblomdahl"

    workspaces {
      name = "tfc-vs4345-k8s"
    }
  }

  required_version = ">= 1.14.0"
}
