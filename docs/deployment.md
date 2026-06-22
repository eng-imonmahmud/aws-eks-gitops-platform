# Deployment Documentation

## Operating Guardrails

This repository is designed for manual review before execution. Do not run infrastructure or Kubernetes commands until the configuration has been reviewed, the target AWS account has been confirmed, and the remote state backend has been approved.

## Prerequisites

- AWS account with permissions for VPC, EKS, IAM, KMS, EC2, CloudWatch, and load balancer resources
- Terraform CLI
- AWS CLI
- kubectl
- Git

## Remote State Preparation

Create an S3 bucket and DynamoDB table for Terraform state through the approved platform foundation process. Then create `terraform/environments/prod/backend.tf` from `terraform/environments/prod/backend.tf.example` and update:

- `bucket`
- `key`
- `region`
- `dynamodb_table`

The backend should use encryption, versioning, restricted bucket policies, and separate access for platform operators.

## Infrastructure Deployment

Review `terraform/environments/prod/terraform.tfvars.example` and create an environment-specific `terraform.tfvars` file.

Manual execution order:

```powershell
cd terraform/environments/prod
terraform init
terraform fmt -recursive
terraform validate
terraform plan -out=platform.tfplan
terraform apply platform.tfplan
```

## Kubernetes Access

After infrastructure provisioning, configure local Kubernetes access:

```powershell
aws eks update-kubeconfig --region eu-central-1 --name enterprise-platform-prod-eks
kubectl get nodes
```

This uses AWS-managed API access and does not require inbound connectivity to the local workstation.

## Grafana Credentials

Generate a local Kubernetes Secret manifest for Grafana credentials:

```powershell
.\scripts\create-grafana-credentials.ps1 -AdminPassword "<strong-password>"
kubectl apply -f kubernetes/grafana/admin-credentials.local.yaml
```

The generated local file is ignored by Git.

## ArgoCD Installation

Install ArgoCD and wait for the controller components:

```powershell
kubectl apply -k kubernetes/argocd
kubectl -n argocd rollout status deployment/argocd-server
kubectl -n argocd rollout status deployment/argocd-repo-server
kubectl -n argocd rollout status deployment/argocd-application-controller
```

Replace `<organization>` in the ArgoCD application manifests with the GitHub organization or user that owns the repository:

- `kubernetes/argocd/platform-project.yaml`
- `kubernetes/argocd/platform-root-application.yaml`
- `kubernetes/argocd/applications/nginx-application.yaml`
- `kubernetes/argocd/applications/prometheus-application.yaml`
- `kubernetes/argocd/applications/grafana-application.yaml`

Bootstrap the platform reconciliation:

```powershell
kubectl apply -k kubernetes/argocd/bootstrap
```

## Private Administration Access

ArgoCD:

```powershell
kubectl -n argocd port-forward svc/argocd-server 8080:443
```

Grafana:

```powershell
kubectl -n monitoring port-forward svc/grafana 3000:3000
```

Prometheus:

```powershell
kubectl -n monitoring port-forward svc/prometheus 9090:9090
```

## Public Workload Access

Retrieve the AWS load balancer hostname for NGINX:

```powershell
kubectl -n platform-applications get svc enterprise-nginx
```

Use the `EXTERNAL-IP` or hostname assigned by AWS.

## Cleanup Order

Use the reverse order of deployment:

```powershell
kubectl delete -k kubernetes/argocd/bootstrap
kubectl delete -k kubernetes/nginx
kubectl delete -k kubernetes/grafana
kubectl delete -k kubernetes/prometheus
kubectl delete -k kubernetes/argocd
cd terraform/environments/prod
terraform destroy
```

Confirm retained EBS volumes and remote state resources according to the organization's data retention policy.
