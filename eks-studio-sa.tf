resource "aws_iam_role" "aws-eks-viewspot-studio-sa-role" {
  name        = "${var.resource_prefix}-viewspot-studio-sa-role"
  description = "IAM role for the studio-sa service account in EKS"

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
            "${module.eks.oidc_provider}:sub" : "system:serviceaccount:*:studio-sa"
          }
        }
      },
    ]
  })

  managed_policy_arns = [
    "arn:aws:iam::aws:policy/AWSElementalMediaConvertFullAccess",
    "arn:aws:iam::aws:policy/CloudWatchReadOnlyAccess"
  ]

  inline_policy {
    name   = "studio-sa-s3-policy"
    policy = jsonencode({
      Version   = "2012-10-17"
      Statement = [
        {
          Effect   = "Allow"
          Action   = ["s3:*"]
          Resource = "arn:aws:s3:::*${var.resource_prefix}*"
        }
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
