
output "region" {
  description = "AWS region"
  value       = var.region
}

output "cluster_name" {
  description = "Kubernetes Cluster Name"
  value       = module.eks.cluster_name
}

output "cluster_endpoint" {
  description = "Endpoint for EKS control plane"
  value       = module.eks.cluster_endpoint
}

output "cluster_security_group_id" {
  description = "Security group ids attached to the cluster control plane"
  value       = module.eks.cluster_security_group_id
}

output "cluster_oidc_id" {
  description = "OIDC ID for the EKS cluster"
  value       = module.eks.oidc_provider
}

output "cluster_oidc_arn" {
  description = "OIDC ID ARN for the EKS cluster"
  value       = module.eks.oidc_provider_arn
}

output "ebs_csi_driver_service_account_iam_role_arn" {
  description = "AWS IAM ARN for the ebs-csi-controller-sa SA"
  value       = aws_iam_role.aws-eks-ebs-csi-driver-role.arn
}

output "efs_csi_driver_service_account_iam_role_arn" {
  description = "AWS IAM ARN for the efs-csi-controller-sa SA"
  value       = aws_iam_role.aws-eks-efs-csi-driver-role.arn
}

output "efs_fs_id" {
  description = "AWS EFS filesystem ID"
  value       = aws_efs_file_system.efs-0.id
}

output "efs_fs_mount_targets" {
  description = "AWS EFS filesystem mount targets"
  value       = aws_efs_file_system.efs-0.number_of_mount_targets
}

output "ack_rds_controller_service_account_iam_role_arn" {
  description = "AWS IAM ARN for the ack-rds-controller SA"
  value       = aws_iam_role.aws-eks-ack-rds-controller-role.arn
}

output "ack_rds_database_subnet_id_1" {
  description = "Database subnet ID 1 for RDS"
  value       = data.aws_subnets.database.ids[0]
}

output "ack_rds_database_subnet_id_2" {
  description = "Database subnet ID 2 for RDS"
  value       = data.aws_subnets.database.ids[1]
}

output "ack_rds_database_subnet_group_name" {
  description = "Database subnet group name"
  value       = module.vpc.database_subnet_group_name
}

output "aws_load_balancer_service_account_iam_role_arn" {
  description = "AWS IAM ARN for the aws-load-balancer-controller SA"
  value       = aws_iam_role.aws-load-balancer-controller-role.arn
}
