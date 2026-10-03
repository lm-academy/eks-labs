resource "aws_eks_addon" "pod_identity_agent" {
  cluster_name = module.cluster.cluster_name
  addon_name   = "eks-pod-identity-agent"
}
