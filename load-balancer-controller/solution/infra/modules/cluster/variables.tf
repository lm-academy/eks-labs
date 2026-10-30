variable "vpc_cidr" {
  description = "CIDR block for the VPC."
  type        = string
  default     = "10.0.0.0/16"
}

variable "enable_outbound_internet_access" {
  description = "Whether to deploy a NAT gateway to enable access from private subnets to the internet."
  type        = bool
  default     = true
}

variable "cluster_name" {
  description = "Name of the EKS cluster. Also used as a prefix for related resources"
  type        = string
}

variable "kubernetes_version" {
  description = "Kubernetes minor version for the control plane and managed addons."
  type        = string
  default     = "1.36"
}

variable "authentication_mode" {
  description = "Cluster authentication mode. API uses access entries only (the default). API_AND_CONFIG_MAP additionally keeps the legacy aws-auth ConfigMap path available. Moving a live cluster from API_AND_CONFIG_MAP to API is a one-way change."
  type        = string
  default     = "API"

  validation {
    condition     = contains(["API", "API_AND_CONFIG_MAP"], var.authentication_mode)
    error_message = "authentication_mode must be API or API_AND_CONFIG_MAP."
  }
}

variable "endpoint_public_access" {
  description = "Expose the Kubernetes API endpoint publicly so kubectl can reach from outside the VPC."
  type        = bool
  default     = true
}

variable "public_access_cidrs" {
  description = "CIDRs allowed to reach the public API endpoint."
  type        = list(string)
  default     = ["0.0.0.0/0"]
}

variable "node_instance_types" {
  description = "Instance types for the Spot node group"
  type        = list(string)
  default     = ["t3.small", "t3a.small", "t3.medium", "t3a.medium", "t3.large", "t3a.large"]
}

variable "node_desired_size" {
  description = "Desired number of nodes"
  type        = number
  default     = 2
}

variable "node_minimum_size" {
  description = "Minimum number of nodes"
  type        = number
  default     = 1
}

variable "node_maximum_size" {
  description = "Maximum number of nodes"
  type        = number
  default     = 3
}

variable "tags" {
  description = "Tags applied to the VPC and cluster resources this module creates."
  type        = map(string)
  default     = {}
}
