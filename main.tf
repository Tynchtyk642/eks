module "eks" {
  source       = "./eks_aws"

  cluster_name = "eks"
  vpc_id       = module.networking.vpc_id
  subnet_ids =     [module.networking.private_subnets[0], module.networking.private_subnets[1]]

  create_with_autoscaling = true

  desired_capacity = 2
  min_workers = 2
  max_workers = 5
 
  instance_type = "t2.small"
}



module "networking" {
  source = "./networking"

  vpc_cidr = "10.0.0.0/16"
  public_sn_count = 2
  private_sn_count = 3
}
