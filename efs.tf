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
