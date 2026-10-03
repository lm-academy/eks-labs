module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "~> 6.6.1"

  name = local.name
  cidr = var.vpc_cidr
  azs  = local.azs

  private_subnets = [for i, az in local.azs : cidrsubnet(var.vpc_cidr, 4, i)]
  private_subnet_tags = {
    "kubernetes.io/role/internal-elb" = 1
  }

  public_subnets = [for i, az in local.azs : cidrsubnet(var.vpc_cidr, 8, i + local.public_subnet_offset)]
  public_subnet_tags = {
    "kubernetes.io/role/elb" = 1
  }

  enable_nat_gateway = var.enable_outbound_internet_access
  single_nat_gateway = true

  tags = local.tags
}