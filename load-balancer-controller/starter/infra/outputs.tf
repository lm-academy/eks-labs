output "cluster_name" {
  description = "Name of the EKS cluster."
  value       = module.cluster.cluster_name
}

output "cluster_arn" {
  description = "ARN of the EKS cluster."
  value       = module.cluster.cluster_arn
}

output "cluster_endpoint" {
  description = "Kubernetes API server endpoint."
  value       = module.cluster.cluster_endpoint
}

output "cluster_version" {
  description = "Kubernetes version running on the control plane."
  value       = module.cluster.cluster_version
}

output "oidc_provider_arn" {
  description = "ARN of the IAM OIDC provider for this cluster."
  value       = module.cluster.oidc_provider_arn
}

output "oidc_provider_url" {
  description = "OIDC issuer URL without the https:// scheme."
  value       = module.cluster.oidc_provider_url
}

output "node_iam_role_arn" {
  description = "IAM role assumed by the managed nodes."
  value       = module.cluster.node_iam_role_arn
}

output "update_kubeconfig_command" {
  description = "Run this to point kubectl at the new cluster."
  value       = "aws eks update-kubeconfig --name ${module.cluster.cluster_name}"
}
