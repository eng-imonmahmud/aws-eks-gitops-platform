output "aws_region" {
  description = "AWS region used by the production platform."
  value       = var.aws_region
}

output "vpc_id" {
  description = "VPC identifier."
  value       = module.vpc.vpc_id
}

output "public_subnet_ids" {
  description = "Public subnet identifiers."
  value       = module.vpc.public_subnet_ids
}

output "private_subnet_ids" {
  description = "Private subnet identifiers."
  value       = module.vpc.private_subnet_ids
}

output "cluster_name" {
  description = "EKS cluster name."
  value       = module.eks.cluster_name
}

output "cluster_endpoint" {
  description = "EKS Kubernetes API endpoint."
  value       = module.eks.cluster_endpoint
}

output "node_group_names" {
  description = "Managed node group names."
  value       = module.eks.node_group_names
}

output "oidc_provider_arn" {
  description = "IAM OIDC provider ARN."
  value       = module.eks.oidc_provider_arn
}
