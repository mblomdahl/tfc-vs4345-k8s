variable "resource_prefix" {
  description = "Prefix for AWS EKS resources (VPCs, EKS cluster/namespace)"
  default     = "mb-eks"
}

variable "account_id" {
  description = "AWS account ID"
  default     = "878179636352"
}

variable "role_arn" {
  description = "AWS role ARN"
  default = "arn:aws:iam::878179636352:role/SPFAM-Dev-TerraformAdmin"
}

variable "region" {
  description = "AWS region"
  default     = "eu-north-1"
}

variable "eks_ami_type" {
  description = "AMI type for AWS EKS node group instances"
  default     = "AL2_x86_64"
}

variable "node_group_instance_type" {
  description = "Type of AWS EKS node group instances to provision"
  default     = "t3.small"
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
