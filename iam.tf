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
