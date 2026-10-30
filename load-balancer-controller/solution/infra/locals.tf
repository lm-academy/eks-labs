locals {
  tags = merge(
    {
      Project   = var.cluster_name
      ManagedBy = "terraform"
    },
    var.tags
  )
}
