resource "aws_iam_role" "aws-eks-vs7-developer-role" {
  name        = "${var.resource_prefix}-vs7-developer-role"
  description = "IAM role for developer access in EKS"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"

    Statement = [
      {
        Action = "sts:AssumeRole",
        Effect = "Allow"

        Principal = {
          AWS = var.account_id
        },
        Condition = {}
      },
    ]
  })

  inline_policy {
    name   = "developer-eks-policy"
    policy = jsonencode({
      Version   = "2012-10-17"
      Statement = [
        {
          Effect   = "Allow"
          Action   = [
            "eks:ListClusters",
            "eks:DescribeCluster",
          ]
          Resource = "arn:aws:eks:*:${var.account_id}:cluster/*"
        },
        {
          Effect   = "Allow"
          Action   = [
            "eks:AccessKubernetesApi",
            "eks:Describe",
            "eks:List"
          ]
          Resource = "arn:aws:eks:*:${var.account_id}:*${var.resource_prefix}*"
        },
      ]
    })
  }

  tags = {
    Origin         = var.common_origin_tag
    ResourcePrefix = var.resource_prefix
    Owner          = var.common_owner_tag
    Purpose        = var.common_purpose_tag
    Stack          = var.common_stack_tag
  }
}
