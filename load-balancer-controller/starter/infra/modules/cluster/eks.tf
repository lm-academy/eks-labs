module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "~> 21.24.0"

  name               = local.name
  kubernetes_version = var.kubernetes_version

  authentication_mode                      = var.authentication_mode
  enable_cluster_creator_admin_permissions = true

  endpoint_public_access       = var.endpoint_public_access
  endpoint_public_access_cidrs = var.public_access_cidrs

  vpc_id     = module.vpc.vpc_id
  subnet_ids = module.vpc.private_subnets

  upgrade_policy = {
    support_type = "STANDARD"
  }

  eks_managed_node_groups = {
    default = {
      instance_types = var.node_instance_types
      capacity_type  = "SPOT"
      min_size       = var.node_minimum_size
      max_size       = var.node_maximum_size
      desired_size   = var.node_desired_size

      # Hop limit 2 lets pods reach the instance metadata service. The module default is 1.
      metadata_options = {
        http_endpoint               = "enabled"
        http_tokens                 = "required"
        http_put_response_hop_limit = 2
      }
    }
  }

  addons = {
    kube-proxy = {
      before_compute = true
    }
    vpc-cni = {
      before_compute = true
    }
    coredns = {}
  }

  tags = local.tags
}