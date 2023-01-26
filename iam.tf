resource "aws_iam_policy" "worker_policy" {
  name        = "eks-worker-policy"
  description = "EKS worker policy for the ELB Ingress"

  policy = file("iam-policies/eks-worker-policy.json")
}

resource "aws_iam_role_policy_attachment" "additional" {
  for_each = module.eks.eks_managed_node_groups

  policy_arn = aws_iam_policy.worker_policy.arn
  role       = each.value.iam_role_name
}
