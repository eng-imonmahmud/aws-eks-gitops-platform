# Architecture Documentation

## Platform Context

This platform provisions a production-ready Amazon EKS environment in `eu-central-1`. Terraform owns the AWS foundation, while ArgoCD owns Kubernetes workload reconciliation from Git.

The network design avoids any requirement for inbound access to a local workstation. Engineers can administer the platform through AWS-managed endpoints, IAM, RBAC, and short-lived `kubectl port-forward` sessions.

## Network Architecture

- One VPC with DNS support enabled
- Two public subnets across separate availability zones
- Two private subnets across separate availability zones
- Internet Gateway for public subnet egress and load balancer reachability
- NAT Gateway per availability zone by default for private subnet egress
- Route tables separated by public and private tier
- Public subnet tags for external AWS load balancers
- Private subnet tags for internal AWS load balancers

## EKS Architecture

- EKS control plane with public and private API endpoint support
- Managed node groups placed in private subnets
- Dedicated IAM roles for control plane and worker nodes
- Dedicated KMS key for Kubernetes secret encryption
- CloudWatch control plane logging enabled
- IAM OIDC provider prepared for IRSA integrations
- Managed add-ons for VPC CNI, CoreDNS, kube-proxy, and EBS CSI

## GitOps Architecture

ArgoCD is installed in the `argocd` namespace. The repository uses a root application pattern:

1. `kubernetes/argocd/bootstrap` creates the ArgoCD project and root application.
2. `enterprise-platform-root` watches `kubernetes/argocd/applications`.
3. Child applications reconcile NGINX, Prometheus, Grafana, and Metrics Server.

## Observability Architecture

Prometheus runs in the `monitoring` namespace with persistent gp3 storage. Grafana consumes Prometheus through an internal service and is kept private by default.

Metrics Server runs in `kube-system` and supports Kubernetes autoscaling decisions.

## Access Model

- Public application traffic enters through an AWS Network Load Balancer.
- ArgoCD and Grafana remain private ClusterIP services.
- Administrative access uses `kubectl port-forward` after IAM and Kubernetes authorization.
- No part of the platform requires home router changes, a dedicated public IP, or inbound access to a local machine.

## Architecture Diagram Placeholder

The source diagram is stored in [platform-architecture.mmd](platform-architecture.mmd). Exported diagrams and approved platform screenshots can be placed in `docs/screenshots/`.
