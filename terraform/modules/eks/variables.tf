variable "cluster_name" {
  description = "EKS cluster name."
  type        = string
}

variable "cluster_version" {
  description = "Kubernetes control plane version."
  type        = string
}

variable "private_subnet_ids" {
  description = "Private subnet identifiers used by the EKS control plane and node groups."
  type        = list(string)
}

variable "control_plane_security_group_id" {
  description = "Additional security group for control plane communication."
  type        = string
}

variable "node_security_group_id" {
  description = "Security group attached to worker nodes."
  type        = string
}

variable "cluster_endpoint_public_access" {
  description = "Enable public Kubernetes API endpoint access."
  type        = bool
  default     = true
}

variable "cluster_endpoint_private_access" {
  description = "Enable private Kubernetes API endpoint access inside the VPC."
  type        = bool
  default     = true
}

variable "cluster_endpoint_public_access_cidrs" {
  description = "CIDR ranges allowed to reach the public Kubernetes API endpoint. Shared IP environments often require broad access plus strict IAM and RBAC."
  type        = list(string)
  default     = ["0.0.0.0/0"]
}

variable "enabled_cluster_log_types" {
  description = "EKS control plane log types sent to CloudWatch Logs."
  type        = list(string)
  default     = ["api", "audit", "authenticator", "controllerManager", "scheduler"]
}

variable "cloudwatch_log_retention_days" {
  description = "Retention period for EKS control plane logs."
  type        = number
  default     = 30
}

variable "cluster_addons" {
  description = "Managed EKS add-ons enabled for the cluster."
  type = map(object({
    version                  = optional(string)
    service_account_role_arn = optional(string)
  }))
  default = {
    coredns            = {}
    kube-proxy         = {}
    vpc-cni            = {}
    aws-ebs-csi-driver = {}
  }
}

variable "node_groups" {
  description = "Managed node group configuration."
  type = map(object({
    instance_types = list(string)
    capacity_type  = string
    desired_size   = number
    min_size       = number
    max_size       = number
    disk_size      = number
    ami_type       = string
    labels         = map(string)
    taints = optional(list(object({
      key    = string
      value  = string
      effect = string
    })), [])
  }))
}

variable "tags" {
  description = "Common tags applied to all supported resources."
  type        = map(string)
  default     = {}
}
