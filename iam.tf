resource "aws_iam_policy" "worker-policy" {
  name        = "${var.resource_prefix}-worker-policy"
  description = "EKS worker policy for the ELB Ingress"

  policy = file("iam-policies/eks-worker-policy.json")

  tags = {
    Origin         = var.common_origin_tag
    ResourcePrefix = var.resource_prefix
    Owner          = var.common_owner_tag
    Purpose        = var.common_purpose_tag
    Stack          = var.common_stack_tag
  }
}

resource "aws_iam_role_policy_attachment" "additional" {
  for_each = module.eks.eks_managed_node_groups

  policy_arn = aws_iam_policy.worker-policy.arn
  role       = each.value.iam_role_name
}

resource "aws_iam_policy" "aws-eks-efs-csi-driver-policy" {
  name        = "${var.resource_prefix}-efs-csi-driver-policy"
  description = "EKS EFS CSI driver policy for efs-csi-controller-sa SA"

  policy = file("iam-policies/eks-efs-csi-driver-policy.json")

  tags = {
    Origin         = var.common_origin_tag
    ResourcePrefix = var.resource_prefix
    Owner          = var.common_owner_tag
    Purpose        = var.common_purpose_tag
    Stack          = var.common_stack_tag
  }
}

resource "aws_iam_role" "aws-eks-efs-csi-driver-role" {
  name        = "${var.resource_prefix}-efs-csi-driver-role"
  description = "IAM role for the efs-csi-controller-sa SA in EKS"

  assume_role_policy = jsonencode({
    Version   = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRoleWithWebIdentity",
        Effect   = "Allow"
        Principal = {
          Federated = module.eks.oidc_provider_arn
        },
        Condition = {
          StringEquals = {
            "${module.eks.oidc_provider}:sub": "system:serviceaccount:kube-system:efs-csi-controller-sa"
          }
        }
      },
    ]
  })

  managed_policy_arns = [aws_iam_policy.aws-eks-efs-csi-driver-policy.arn]

  tags = {
    Origin         = var.common_origin_tag
    ResourcePrefix = var.resource_prefix
    Owner          = var.common_owner_tag
    Purpose        = var.common_purpose_tag
    Stack          = var.common_stack_tag
  }
}

resource "aws_iam_role" "aws-load-balancer-controller-iam-role" {
  name        = "${var.resource_prefix}-load-balancer-controller-role"
  description = "IAM role for the aws-load-balancer-controller SA in EKS"

  assume_role_policy = jsonencode({
    Version   = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRoleWithWebIdentity",
        Effect   = "Allow"
        Principal = {
          Federated = module.eks.oidc_provider_arn
        },
        Condition = {
          StringEquals = {
            "${module.eks.oidc_provider}:aud": "sts.amazonaws.com"
            "${module.eks.oidc_provider}:sub": "system:serviceaccount:kube-system:aws-load-balancer-controller"
          }
        }
      },
    ]
  })

  tags = {
    Origin         = var.common_origin_tag
    ResourcePrefix = var.resource_prefix
    Owner          = var.common_owner_tag
    Purpose        = var.common_purpose_tag
    Stack          = var.common_stack_tag
  }
}
