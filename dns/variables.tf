variable "account_id" {
  description = "AWS account ID"
  default     = "878179636352"
}

variable "region" {
  description = "AWS region"
  default     = "eu-north-1"
}

variable "eks_elb_domain" {
  description = "Domain for EKS ELB"
  default     = "k8s-ingressn-ingressn-d7a33e1924-2dcfed4179033b4a.elb.eu-north-1.amazonaws.com"
}

variable "eks_elb_zone_id" {
  description = "Zone ID for EKS ELB"
  default     = "Z1UDT6IFJ4EJM"
}

variable "route53_apex" {
  description = "Domain for Route 53 hosted zone"
  default     = "smithmicro.io"
}

variable "route53_apex_zone_id" {
  description = "Zone ID for Route 53 apex hosted zone"
  default     = "Z1TY55FUWSMGVV"
}

variable "route53_subdomain" {
  description = "Subdomain name for Route 53 hosted zone"
  default     = "mb-eks"
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
