variable "cluster_name" {
  description = "Name of the EKS cluster. Also used as a prefix for related resources"
  type        = string
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

variable "tags" {
  description = "Additional tags applied to every resource."
  type        = map(string)
  default     = {}
}
