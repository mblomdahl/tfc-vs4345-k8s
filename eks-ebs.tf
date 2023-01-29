
resource "aws_iam_policy" "aws-eks-ebs-csi-driver-policy" {
  name        = "${var.resource_prefix}-ebs-csi-driver-policy"
  description = "EKS EBS CSI driver policy for efs-csi-controller-sa SA"

  policy = file("iam-policies/eks-ebs-csi-driver-policy.json")

  tags = {
    Origin         = var.common_origin_tag
    ResourcePrefix = var.resource_prefix
    Owner          = var.common_owner_tag
    Purpose        = var.common_purpose_tag
    Stack          = var.common_stack_tag
  }
}

resource "aws_iam_role" "aws-eks-ebs-csi-driver-role" {
  name        = "${var.resource_prefix}-ebs-csi-driver-role"
  description = "IAM role for the ebs-csi-controller-sa SA in EKS"

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
            "${module.eks.oidc_provider}:aud" : "sts.amazonaws.com",
            "${module.eks.oidc_provider}:sub" : "system:serviceaccount:kube-system:ebs-csi-controller-sa"
          }
        }
      },
    ]
  })

  managed_policy_arns = [aws_iam_policy.aws-eks-ebs-csi-driver-policy.arn]

  tags = {
    Origin         = var.common_origin_tag
    ResourcePrefix = var.resource_prefix
    Owner          = var.common_owner_tag
    Purpose        = var.common_purpose_tag
    Stack          = var.common_stack_tag
  }
}
