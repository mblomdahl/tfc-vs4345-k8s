
resource "aws_iam_policy" "aws-load-balancer-controller-policy" {
  name        = "${var.resource_prefix}-aws-load-balancer-controller-policy"
  description = "EKS ELB controller policy for the aws-load-balancer-controller SA"

  policy = file("iam-policies/eks-aws-load-balancer-controller-policy.json")

  tags = {
    Origin         = var.common_origin_tag
    ResourcePrefix = var.resource_prefix
    Owner          = var.common_owner_tag
    Purpose        = var.common_purpose_tag
    Stack          = var.common_stack_tag
  }
}

resource "aws_iam_role" "aws-load-balancer-controller-role" {
  name        = "${var.resource_prefix}-load-balancer-controller-role"
  description = "IAM role for the aws-load-balancer-controller SA in EKS"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"

    Statement = [
      {
        Action = "sts:AssumeRoleWithWebIdentity",
        Effect = "Allow"

        Principal = {
          Federated = module.eks.oidc_provider_arn
        },
        Condition = {
          StringEquals = {
            "${module.eks.oidc_provider}:aud" : "sts.amazonaws.com"
            "${module.eks.oidc_provider}:sub" : "system:serviceaccount:kube-system:aws-load-balancer-controller"
          }
        }
      },
    ]
  })

  managed_policy_arns = [aws_iam_policy.aws-load-balancer-controller-policy.arn]

  tags = {
    Origin         = var.common_origin_tag
    ResourcePrefix = var.resource_prefix
    Owner          = var.common_owner_tag
    Purpose        = var.common_purpose_tag
    Stack          = var.common_stack_tag
  }
}
