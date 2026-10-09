module "cluster" {
  source = "./modules/cluster"

  cluster_name        = var.cluster_name
  authentication_mode = var.authentication_mode

  tags = local.tags
}
