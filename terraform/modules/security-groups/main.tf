locals {
  common_tags = merge(
    var.tags,
    {
      ManagedBy = "Terraform"
      Platform  = var.cluster_name
    }
  )
}

resource "aws_security_group" "control_plane" {
  name        = "${var.cluster_name}-control-plane-sg"
  description = "Security group for EKS control plane communication"
  vpc_id      = var.vpc_id

  tags = merge(local.common_tags, {
    Name = "${var.cluster_name}-control-plane-sg"
  })

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_security_group" "nodes" {
  name        = "${var.cluster_name}-nodes-sg"
  description = "Security group for EKS managed node groups"
  vpc_id      = var.vpc_id

  tags = merge(local.common_tags, {
    Name                                        = "${var.cluster_name}-nodes-sg"
    "kubernetes.io/cluster/${var.cluster_name}" = "owned"
  })

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_security_group_rule" "control_plane_egress" {
  type              = "egress"
  description       = "Allow control plane egress"
  security_group_id = aws_security_group.control_plane.id
  protocol          = "-1"
  from_port         = 0
  to_port           = 0
  cidr_blocks       = ["0.0.0.0/0"]
}

resource "aws_security_group_rule" "nodes_egress" {
  type              = "egress"
  description       = "Allow node egress through managed network paths"
  security_group_id = aws_security_group.nodes.id
  protocol          = "-1"
  from_port         = 0
  to_port           = 0
  cidr_blocks       = ["0.0.0.0/0"]
}

resource "aws_security_group_rule" "nodes_self" {
  type              = "ingress"
  description       = "Allow node-to-node communication"
  security_group_id = aws_security_group.nodes.id
  protocol          = "-1"
  from_port         = 0
  to_port           = 0
  self              = true
}

resource "aws_security_group_rule" "nodes_from_control_plane_webhooks" {
  type                     = "ingress"
  description              = "Allow control plane access to node webhooks"
  security_group_id        = aws_security_group.nodes.id
  protocol                 = "tcp"
  from_port                = 443
  to_port                  = 443
  source_security_group_id = aws_security_group.control_plane.id
}

resource "aws_security_group_rule" "nodes_from_control_plane_kubelet" {
  type                     = "ingress"
  description              = "Allow control plane access to kubelet"
  security_group_id        = aws_security_group.nodes.id
  protocol                 = "tcp"
  from_port                = 10250
  to_port                  = 10250
  source_security_group_id = aws_security_group.control_plane.id
}

resource "aws_security_group_rule" "control_plane_from_nodes" {
  type                     = "ingress"
  description              = "Allow worker nodes to reach the Kubernetes API"
  security_group_id        = aws_security_group.control_plane.id
  protocol                 = "tcp"
  from_port                = 443
  to_port                  = 443
  source_security_group_id = aws_security_group.nodes.id
}
