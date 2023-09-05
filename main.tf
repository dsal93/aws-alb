
module "two-tier-arch" {
  source = "./modules"


  region              = var.region
  vpc_cidr            = var.vpc_cidr_block
  public_subnet_cidr  = var.public_subnet_cidr
  private_subnet_cidr = var.private_subnet_cidr

}

