module "node_groups" {
  source = "./modules/node_groups"
  create_node_groups = var.create_node_groups
  eks_version = var.cluster_version
  cluster_name = var.cluster_name
  subnet = var.subnet_ids
  desired_size = var.desired_capacity
  min_size = var.min_workers
  max_size = var.max_workers
  instance_types = ["${var.instance_type}"]
}