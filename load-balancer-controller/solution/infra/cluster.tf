module "cluster" {
  source = "./modules/cluster"

  cluster_name        = var.cluster_name
  kubernetes_version  = var.kubernetes_version
  authentication_mode = var.authentication_mode

  tags = local.tags
}
