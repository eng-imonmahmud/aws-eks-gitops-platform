# AWS EKS GitOps Platform

[![AWS EKS](https://img.shields.io/badge/AWS-EKS-FF9900?logo=amazonaws&logoColor=white)](https://aws.amazon.com/eks/)
[![Terraform](https://img.shields.io/badge/Terraform-1.5+-7B42BC?logo=terraform&logoColor=white)](https://www.terraform.io/)
[![Kubernetes](https://img.shields.io/badge/Kubernetes-v1.35-326CE5?logo=kubernetes&logoColor=white)](https://kubernetes.io/)
[![ArgoCD](https://img.shields.io/badge/ArgoCD-GitOps-EF7B4D?logo=argo&logoColor=white)](https://argoproj.github.io/cd/)
[![Prometheus](https://img.shields.io/badge/Prometheus-Monitoring-E6522C?logo=prometheus&logoColor=white)](https://prometheus.io/)
[![Grafana](https://img.shields.io/badge/Grafana-Observability-F46800?logo=grafana&logoColor=white)](https://grafana.com/)
[![Production Ready](https://img.shields.io/badge/Production-Ready-2ea44f?logo=check&logoColor=white)](#)
[![GitOps](https://img.shields.io/badge/GitOps-Enabled-000000?logo=git&logoColor=white)](#)

## ðŸ“‹ Executive Summary
This project demonstrates an enterprise-grade, highly available Cloud Native platform. It completely automates the provisioning of AWS infrastructure using Terraform and manages Kubernetes workloads dynamically via ArgoCD using the declarative "App of Apps" GitOps pattern. The platform comes pre-instrumented with a fully persistent Prometheus and Grafana observability stack.

## ðŸ’¼ Business Problem
Modern software organizations struggle with "configuration drift" and environment inconsistency. Manual infrastructure updates and imperative Kubernetes deployments (`kubectl apply`) lead to fragile environments that are difficult to replicate, audit, and scale, severely impacting Site Reliability and increasing Mean Time to Recovery (MTTR).

## ðŸ’¡ Solution Overview
This platform solves environment drift by adopting **GitOps** as a core philosophy. Git serves as the single source of truth for both infrastructure (Terraform) and application configuration (ArgoCD). Any change to the cluster must be initiated via a Git commit. If unauthorized changes occur in the live cluster, ArgoCD automatically reconciles and reverts the drift to match the repository state.

## ðŸ—ï¸ Architecture Overview
The platform architecture utilizes a strict separation of concerns between underlying infrastructure and application workloads:

```mermaid
graph TD
  Dev[Developer] --> Git[GitHub Repository]
  Git --> Argo[ArgoCD]
  
  subgraph AWS[AWS Infrastructure]
    VPC[VPC & Private Subnets]
    NodeGroup[Managed Node Group]
    EBS_CSI[EBS CSI Driver]
    EBS_Vol[EBS Volumes]
    
    subgraph EKS[EKS Cluster]
      Argo
      Metrics[Metrics Server]
      Prometheus[Prometheus]
      Grafana[Grafana]
      NGINX[NGINX]
    end
    
    NodeGroup --> EKS
    VPC --> NodeGroup
    EBS_CSI --> EBS_Vol
    EKS --> EBS_CSI
  end
```

## ðŸ› ï¸ Technology Stack
* **Cloud Provider:** Amazon Web Services (AWS)
* **IaC Engine:** Terraform
* **Orchestration:** Kubernetes (EKS v1.35)
* **Continuous Delivery:** ArgoCD
* **Observability:** Prometheus, Grafana, Kubernetes Metrics Server
* **Storage:** Amazon Elastic Block Store (EBS) CSI Driver

## ðŸ“ Repository Structure
```text
.
â”œâ”€â”€ terraform/                # Infrastructure as Code
â”‚   â”œâ”€â”€ modules/              # Reusable modules (VPC, EKS, Security Groups)
â”‚   â””â”€â”€ environments/prod/    # Production environment composition
â”œâ”€â”€ kubernetes/               # Cluster desired state
â”‚   â”œâ”€â”€ argocd/               # Root App-of-Apps configuration
â”‚   â”œâ”€â”€ nginx/                # Sample scalable workload
â”‚   â”œâ”€â”€ prometheus/           # Monitoring agent
â”‚   â””â”€â”€ grafana/              # Observability dashboards
â”œâ”€â”€ scripts/                  # Automation utilities
â””â”€â”€ docs/                     # Supplemental documentation
```

## â˜ï¸ Infrastructure Components
* **Networking:** Secure AWS VPC spanning multiple Availability Zones with isolated Private Subnets for worker nodes.
* **Compute:** Managed EKS Node Group utilizing cost-efficient `c7i-flex.large` instances.
* **IAM/OIDC:** Strict IAM Roles mapped to Kubernetes Service Accounts using OIDC integration.

## ðŸ”„ GitOps Workflow
The deployment utilizes ArgoCD's **App-of-Apps** pattern.
1. The `enterprise-platform-root` application is manually bootstrapped into the cluster.
2. The root application automatically points back to this GitHub repository and discovers child applications (`enterprise-nginx`, `enterprise-prometheus`, `enterprise-grafana`).
3. Child applications are automatically synchronized and deployed to their respective namespaces.

## ðŸ”’ Security Features
* **Private Compute:** EKS nodes are placed in private subnets with no direct public ingress; all outbound traffic routes through a NAT Gateway.
* **No Hardcoded Secrets:** The codebase is thoroughly audited. Secrets are injected at runtime or managed via external tools (no `.tfvars` or credentials committed).
* **Self-Healing:** ArgoCD automatically reverts unauthorized, out-of-band changes to Kubernetes resources.

## ðŸ“Š Monitoring & Observability
* **Metrics Server:** Installed to enable cluster autoscaling (HPA) by providing resource utilization data.
* **Prometheus:** Continuously scrapes and aggregates node, pod, and service metrics.
* **Grafana:** Visualizes infrastructure health with pre-built cluster monitoring dashboards.

## ðŸ’¾ Storage Architecture
The platform implements stateful resilience using the **EBS CSI Driver**. Both Prometheus and Grafana dynamically provision and bind to AWS `gp3` EBS volumes (via PersistentVolumeClaims). If a monitoring pod crashes or is rescheduled to another node, the EBS volume is automatically detached and re-attached, preventing data loss.

## ðŸš€ Deployment Process
1. Initialize and apply Terraform from `terraform/environments/prod`.
2. Update local `.kube/config`.
3. Bootstrap the cluster with ArgoCD (`kubectl apply -n argocd -f ...`).
4. Apply the Root Application manifest to initiate the GitOps cascade.

---

## ðŸ¤– AI-Assisted Development
* **Design & Review:** Terraform, Kubernetes, ArgoCD, and AWS architecture decisions were designed, reviewed, validated, and thoroughly understood by the project owner.
* **Productivity Tools:** AI assistants (OpenAI Codex and Google Gemini) were utilized as engineering productivity tools for troubleshooting, validation, documentation generation, deployment verification, and repository refinement.
* **Responsibility:** All final architectural decisions, testing, deployment approval, and operational responsibilities remained entirely with the project owner.

---

## ðŸ“¸ Screenshot Portfolio
The following visual evidence confirms the successful live deployment of the platform on AWS:

### Infrastructure Validation
![VPC Configuration](screenshots/VPC%20Your%20VPCs%20vpc-0915aa22eddb00f8d.png)
![EKS Cluster Status](screenshots/Amazon%20Elastic%20Kubernetes%20Service%20Clusters.png)
![EKS Compute Tab](screenshots/Amazon%20Elastic%20Kubernetes%20Service%20Clusters%20enterprise-platform-prod-eks%20Compute%20Tab.png)
![EKS Node Group](screenshots/Amazon%20Elastic%20Kubernetes%20Service%20Clusters%20enterprise-platform-prod-eks%20Node%20Group.png)
![EC2 Instance 1](screenshots/EC2Instancesi-02280ef898bd63445.png)
![EC2 Instance 2](screenshots/EC2Instancesi-0a74e55ebb16ebca0.png)
![EBS Volumes (CSI Driver)](screenshots/AWS%20â†’%20EC2%20â†’%20Volumes.png)

### GitOps Validation
![ArgoCD Dashboard](screenshots/AgroCD.png)
![ArgoCD Application Dashboard](screenshots/Agro%20CD%20Application%20Dashboard.png)
![ArgoCD App-of-Apps Tree](screenshots/ArgoCD%20â†’%20enterprise-platform-root%20â†’%20Tree%20%20Graph%20View.png)

### Kubernetes & Observability Validation
![Kubernetes Applications Status](screenshots/Get%20Application%20Powershell%20Screenshot.jpg)
![Kubernetes Pods Status](screenshots/Pods%20A.jpg)
![Kubernetes PVCs Status](screenshots/PVCA.jpg)
![Metrics Server (kubectl top)](screenshots/kubectl%20top%20nodes.jpg)
![Grafana Cluster Monitoring Dashboard](screenshots/Kubernetes%20cluster%20monitoring%20%28via%20Prometheus%29.png)

---

## ðŸ“š Lessons Learned
* **GitOps Bootstrapping:** A chicken-and-egg problem exists when bootstrapping a GitOps controller before external connectivity is fully established. Implementing an in-cluster Git server is a viable workaround for strict sandbox environments.
* **Cloud Limitations:** Account-level restrictions (like limits on creating Load Balancers) require resilient architecture design that functions effectively via local port-forwarding during the development phase.

## ðŸ”­ Future Improvements
* Integration of **External Secrets Operator** with AWS Secrets Manager.
* Migration of Terraform state to a remote AWS S3 backend with DynamoDB locking.
* Implementation of Ingress Controllers (AWS ALB Ingress) when account permissions allow.

## ðŸ§¹ Cleanup Instructions
To safely tear down the environment and avoid lingering cloud charges:
1. Delete ArgoCD child applications via the UI to clear their resources.
2. Run `terraform destroy -auto-approve` from the `prod` directory.

---

## ðŸ“Œ Recruiter Notes
This repository represents a holistic, real-world DevOps/SRE approach. It goes far beyond standard tutorials by dynamically managing persistent storage (CSI), complex multi-stage provisioning (Terraform -> EKS -> ArgoCD), and strict Git-driven drift control. 

## âœï¸ Author
**Imon Mahmud**  
Cloud DevOps Engineer & Platform Architect

