output "control_plane_security_group_id" {
  description = "Security group identifier for EKS control plane communication."
  value       = aws_security_group.control_plane.id
}

output "node_security_group_id" {
  description = "Security group identifier for EKS managed node groups."
  value       = aws_security_group.nodes.id
}
