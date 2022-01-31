data "aws_ami" "workers" {
  count = var.create_node_groups == true ? 1 : 0
  filter {
    name = "name"
    values = ["amazon-eks-node-${var.eks_version}-v*"]
  }

  most_recent = true
  owners = ["amazon"]
}

resource "aws_eks_node_group" "workers" {
  count = var.create_node_groups == true ? 1 : 0
  node_group_name = var.node_group_name

  cluster_name = var.cluster_name
  node_role_arn = aws_iam_role.eks-node.arn
  subnet_ids = var.subnet

  scaling_config {
    desired_size = var.desired_size
    max_size = var.max_size
    min_size = var.min_size
  }

  ami_type = data.aws_ami.workers[count.index].id
  instance_types = var.instance_types
}