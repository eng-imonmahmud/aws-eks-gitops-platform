variable "aws_region" {
  description = "AWS region for the production platform."
  type        = string
  default     = "eu-central-1"
}

variable "environment" {
  description = "Environment name."
  type        = string
  default     = "prod"
}

variable "platform_name" {
  description = "Enterprise platform name prefix."
  type        = string
  default     = "enterprise-platform"
}

variable "vpc_cidr_block" {
  description = "VPC CIDR block."
  type        = string
  default     = "10.40.0.0/16"
}

variable "az_count" {
  description = "Number of availability zones used by the platform."
  type        = number
  default     = 2
}

variable "public_subnet_cidrs" {
  description = "Public subnet CIDR blocks."
  type        = list(string)
  default     = ["10.40.0.0/20", "10.40.16.0/20"]
}

variable "private_subnet_cidrs" {
  description = "Private subnet CIDR blocks."
  type        = list(string)
  default     = ["10.40.64.0/20", "10.40.80.0/20"]
}

variable "enable_single_nat_gateway" {
  description = "Use one NAT Gateway to reduce cost. Keep false for zonal resilience."
  type        = bool
  default     = false
}

variable "cluster_version" {
  description = "Kubernetes version for the EKS control plane."
  type        = string
  default     = "1.35"
}

variable "cluster_endpoint_public_access" {
  description = "Enable public Kubernetes API endpoint access for cloud-native administration from shared IP networks."
  type        = bool
  default     = true
}

variable "cluster_endpoint_private_access" {
  description = "Enable private Kubernetes API endpoint access inside the VPC."
  type        = bool
  default     = true
}

variable "cluster_endpoint_public_access_cidrs" {
  description = "CIDR ranges allowed to reach the public Kubernetes API endpoint."
  type        = list(string)
  default     = ["0.0.0.0/0"]
}

variable "node_groups" {
  description = "Managed node groups for platform workloads."
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
  default = {
    system = {
      instance_types = ["t3.medium"]
      capacity_type  = "ON_DEMAND"
      desired_size   = 2
      min_size       = 2
      max_size       = 4
      disk_size      = 40
      ami_type       = "AL2023_x86_64_STANDARD"
      labels = {
        workload = "system"
      }
      taints = []
    }
  }
}

variable "tags" {
  description = "Additional tags applied to supported resources."
  type        = map(string)
  default     = {}
}
