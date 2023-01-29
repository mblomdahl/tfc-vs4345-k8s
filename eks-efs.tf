
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
            "${module.eks.oidc_provider}:sub" : "system:serviceaccount:kube-system:efs-csi-controller-sa"
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

resource "aws_security_group" "efs" {
  name        = "${local.resource_prefix}-cluster-efs"
  description = "Allow EFS traffic for EKS nodes"
  vpc_id      = module.vpc.vpc_id

  ingress {
    description = "EFS for EKS"
    from_port   = 2049
    to_port     = 2049
    protocol    = "tcp"
    cidr_blocks = module.vpc.private_subnets_cidr_blocks
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = {
    Name           = "${local.resource_prefix}-cluster-efs"
    Origin         = var.common_origin_tag
    ResourcePrefix = var.resource_prefix
    Owner          = var.common_owner_tag
    Purpose        = var.common_purpose_tag
    Stack          = var.common_stack_tag
  }
}

resource "aws_efs_file_system" "efs-0" {
  creation_token = "${local.resource_prefix}-cluster-efs-0"

  tags = {
    Name           = "${local.resource_prefix}-cluster-efs-0"
    Origin         = var.common_origin_tag
    ResourcePrefix = var.resource_prefix
    Owner          = var.common_owner_tag
    Purpose        = var.common_purpose_tag
    Stack          = var.common_stack_tag
  }
}

resource "aws_efs_mount_target" "efs-0" {
  for_each = toset(data.aws_subnets.private.ids)

  file_system_id  = aws_efs_file_system.efs-0.id
  subnet_id       = each.value
  security_groups = [aws_security_group.efs.id]
}
