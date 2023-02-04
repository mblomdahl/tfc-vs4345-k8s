
resource "aws_iam_role" "aws-eks-ack-s3-controller-role" {
  name        = "${var.resource_prefix}-ack-s3-controller-role"
  description = "IAM role for the ack-s3-controller SA in EKS"

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
            "${module.eks.oidc_provider}:sub" : "system:serviceaccount:ack-system:ack-s3-controller"
          }
        }
      },
    ]
  })

  managed_policy_arns = ["arn:aws:iam::aws:policy/AmazonS3FullAccess"]

  tags = {
    Origin         = var.common_origin_tag
    ResourcePrefix = var.resource_prefix
    Owner          = var.common_owner_tag
    Purpose        = var.common_purpose_tag
    Stack          = var.common_stack_tag
  }
}

resource "aws_iam_role" "aws-eks-ack-rds-controller-role" {
  name        = "${var.resource_prefix}-ack-rds-controller-role"
  description = "IAM role for the ack-rds-controller SA in EKS"

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
            "${module.eks.oidc_provider}:sub" : "system:serviceaccount:ack-system:ack-rds-controller"
          }
        }
      },
    ]
  })

  managed_policy_arns = ["arn:aws:iam::aws:policy/AmazonRDSFullAccess"]

  tags = {
    Origin         = var.common_origin_tag
    ResourcePrefix = var.resource_prefix
    Owner          = var.common_owner_tag
    Purpose        = var.common_purpose_tag
    Stack          = var.common_stack_tag
  }
}

resource "aws_security_group_rule" "ack-rds" {
  type              = "ingress"
  security_group_id = module.vpc.default_security_group_id
  description       = "Postgres connections from EKS"
  from_port         = 5432
  to_port           = 5432
  protocol          = "tcp"
  cidr_blocks       = module.vpc.private_subnets_cidr_blocks
}
