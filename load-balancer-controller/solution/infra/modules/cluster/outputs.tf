output "cluster_name" {
  description = "Name of the EKS cluster."
  value       = module.eks.cluster_name
}

output "cluster_arn" {
  description = "ARN of the EKS cluster. Access entries are attached to this cluster by name, but the ARN is what IAM policies target."
  value       = module.eks.cluster_arn
}

output "cluster_version" {
  description = "Kubernetes version running on the control plane."
  value       = module.eks.cluster_version
}

output "cluster_endpoint" {
  description = "Kubernetes API server endpoint."
  value       = module.eks.cluster_endpoint
}

output "cluster_certificate_authority_data" {
  description = "Base64 encoded CA certificate for the API server. Needed to configure a Kubernetes provider against this cluster."
  value       = module.eks.cluster_certificate_authority_data
}

output "oidc_provider_arn" {
  description = "ARN of the IAM OIDC provider for this cluster. IAM roles assumed by service accounts trust this provider."
  value       = module.eks.oidc_provider_arn
}

output "oidc_provider_url" {
  description = "OIDC issuer URL without the https:// scheme, which is the form IAM trust policy conditions use."
  value       = module.eks.oidc_provider
}

output "node_iam_role_arn" {
  description = "IAM role assumed by the managed nodes. EKS creates an access entry for this role automatically, and pods without their own identity fall back to it."
  value       = module.eks.eks_managed_node_groups["default"].iam_role_arn
}

output "node_iam_role_name" {
  description = "Name of the IAM role assumed by the managed nodes."
  value       = module.eks.eks_managed_node_groups["default"].iam_role_name
}
