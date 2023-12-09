variable "resource_prefix" {
  description = "Prefix for AWS EKS resources (VPCs, EKS cluster/namespace)"
  default     = "mb-eks"
}

variable "account_id" {
  description = "AWS account ID"
  default     = "878179636352"
}

variable "region" {
  description = "AWS region"
  default     = "eu-north-1"
}

variable "vpc_cidr" {
  description = "AWS VPC CIDR"
  default     = "10.181.0.0/16"
}

variable "vpc_public_subnet_cidr_a" {
  description = "AWS VPC public subnet A CIDR"
  default     = "10.181.0.0/24"
}

variable "vpc_public_subnet_cidr_b" {
  description = "AWS VPC public subnet B CIDR"
  default     = "10.181.1.0/24"
}

variable "vpc_private_subnet_cidr_a" {
  description = "AWS VPC private subnet A CIDR"
  default     = "10.181.3.0/24"
}

variable "vpc_private_subnet_cidr_b" {
  description = "AWS VPC private subnet B CIDR"
  default     = "10.181.4.0/24"
}

variable "vpc_database_subnet_cidr_a" {
  description = "AWS VPC database subnet A CIDR"
  default     = "10.181.6.0/24"
}

variable "vpc_database_subnet_cidr_b" {
  description = "AWS VPC database subnet B CIDR"
  default     = "10.181.7.0/24"
}

variable "eks_ami_type" {
  description = "AMI type for AWS EKS node group instances"
  default     = "AL2_x86_64"
}

variable "node_group_instance_type" {
  description = "Type of AWS EKS node group instances to provision"
  default     = "t3.large"
}

variable "common_origin_tag" {
  description = "AWS Tag value for key Origin"
  default     = "Terraform Cloud"
}

variable "common_owner_tag" {
  description = "AWS Tag value for key Owner"
  default     = "mblomdahl"
}

variable "common_purpose_tag" {
  description = "AWS Tag value for key Purpose"
  default     = "Getting friendly with EKS"
}

variable "common_stack_tag" {
  description = "AWS Tag value for key Stack"
  default     = "Dev"
}
