# Troubleshooting Documentation

## Terraform Backend Fails To Initialize

Confirm the S3 bucket and DynamoDB table exist, the region is `eu-central-1`, encryption is enabled, and the current AWS identity has state read and write permissions.

## EKS Cluster Creation Is Delayed

EKS control plane provisioning can take several minutes. Confirm IAM role attachments, subnet route tables, NAT Gateway availability, and regional service quotas.

## Managed Node Group Does Not Join The Cluster

Check private subnet egress through NAT Gateway, node IAM role policies, EKS security group rules, and whether the selected instance type has available capacity in the chosen availability zones.

## ArgoCD Application Kind Is Not Recognized

Apply `kubernetes/argocd` first and wait for the ArgoCD CRDs to be established. Then apply `kubernetes/argocd/bootstrap`.

## ArgoCD Cannot Read The Repository

Confirm the repository URL has replaced `<organization>` in all ArgoCD application manifests. For private repositories, configure repository credentials in ArgoCD before bootstrapping applications.

## Grafana Pod Waits For Credentials

Grafana expects a Secret named `grafana-admin-credentials` in the `monitoring` namespace. Generate the local credentials manifest with `scripts/create-grafana-credentials.ps1` or provide the Secret through the approved enterprise secret management process.

## Persistent Volume Claims Remain Pending

Confirm the AWS EBS CSI add-on is active, the `gp3` StorageClass exists, and the node group is available in the selected availability zones.

## NGINX Load Balancer Remains Pending

Confirm public subnet tags are present, AWS load balancer service quotas are available, and the Kubernetes service annotation matches the desired AWS load balancer type.

## Metrics Server Is Unavailable

Confirm the Metrics Server deployment is ready in `kube-system`, the APIService `v1beta1.metrics.k8s.io` is available, and node kubelet metrics are reachable from the cluster network.

## Prometheus Targets Are Down

Confirm the Prometheus service account has cluster read permissions, the Kubernetes API endpoint is reachable from the pod, and the target path is present in the Prometheus targets page.
