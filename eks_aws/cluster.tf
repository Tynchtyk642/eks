resource "aws_iam_role" "cluster" {
    name = "${var.cluster_name}-iam"
    assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "eks.amazonaws.com"
        }
      },
    ]
  })
}

resource "aws_iam_role_policy_attachment" "cluster_AmazonEKSClusterPolicy" {
    policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
    role = aws_iam_role.cluster.name
}

resource "aws_iam_role_policy_attachment" "cluster_AmazonEKSServicePolicy" {
    policy_arn = "arn:aws:iam::aws:policy/AmazonEKSServicePolicy"
    role = aws_iam_role.cluster.name
}




resource "aws_eks_cluster" "cluster" {
  name = var.cluster_name
#   enabled_cluster_log_types = var.cluster_enabled_log_types
  role_arn = aws_iam_role.cluster.arn
  version = var.cluster_version

  vpc_config {
      security_group_ids = [aws_security_group.cluster.id]
      subnet_ids = var.subnet_ids
  }
}

resource "aws_security_group" "cluster" {
  name_prefix = var.cluster_name
  description = "Cluster communication with worker nodes"
  vpc_id = var.vpc_id

  egress {
      from_port = 0
      to_port = 0
      protocol = "-1"
      cidr_blocks = ["0.0.0.0/0"]
  }
  tags = {
      Name = "SG-${var.cluster_name}"
  }
}

resource "aws_security_group_rule" "cluster_ingress_node_https" {
    description = "Allow pods to communicate with the cluster API Server"
    from_port = 443
    protocol = "tcp"
    security_group_id = aws_security_group.cluster.id
    source_security_group_id = aws_security_group.workers.id
    to_port = 443
    type = "ingress"
}