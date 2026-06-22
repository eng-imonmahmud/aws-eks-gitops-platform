output "cluster_name" {
  description = "EKS cluster name."
  value       = aws_eks_cluster.this.name
}

output "cluster_arn" {
  description = "EKS cluster ARN."
  value       = aws_eks_cluster.this.arn
}

output "cluster_endpoint" {
  description = "EKS Kubernetes API endpoint."
  value       = aws_eks_cluster.this.endpoint
}

output "cluster_certificate_authority_data" {
  description = "Base64 encoded cluster certificate authority data."
  value       = aws_eks_cluster.this.certificate_authority[0].data
  sensitive   = true
}

output "cluster_security_group_id" {
  description = "Primary security group created by EKS."
  value       = aws_eks_cluster.this.vpc_config[0].cluster_security_group_id
}

output "node_role_arn" {
  description = "IAM role ARN used by managed node groups."
  value       = aws_iam_role.nodes.arn
}

output "node_group_names" {
  description = "Managed node group names."
  value       = [for node_group in aws_eks_node_group.this : node_group.node_group_name]
}

output "oidc_provider_arn" {
  description = "IAM OIDC provider ARN for IRSA integrations."
  value       = aws_iam_openid_connect_provider.this.arn
}

output "kms_key_arn" {
  description = "KMS key ARN used for Kubernetes secret encryption."
  value       = aws_kms_key.eks.arn
}
