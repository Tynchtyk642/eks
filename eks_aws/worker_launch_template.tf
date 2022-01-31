data "aws_ami" "workers" {
  count = var.create_with_autoscaling == true ? 1 : 0
  filter {
    name = "name"
    values = ["amazon-eks-node-${var.cluster_version}-v*"]
  }

  most_recent = true
  owners = ["amazon"]
}

resource "aws_launch_template" "workers" {
  count = var.create_with_autoscaling == true ? 1 : 0
  name_prefix = var.cluster_name

    network_interfaces {
      associate_public_ip_address = false
      delete_on_termination = true
      security_groups = [aws_security_group.workers.id]
    }


    iam_instance_profile {
        name = aws_iam_instance_profile.workers[count.index].name
    }
    image_id = data.aws_ami.workers[count.index].id
    instance_type = var.instance_type
    user_data = base64encode(
        data.template_file.userdata[count.index].rendered
    )

    lifecycle {
      create_before_destroy = true
    }
}

resource "aws_autoscaling_group" "workers" {
  count = var.create_with_autoscaling == true ? 1 : 0
  name_prefix = "${var.cluster_name}-workers"
  desired_capacity = var.desired_capacity
  max_size = var.max_workers
  min_size = var.min_workers
  vpc_zone_identifier = tolist([element(var.subnet_ids, count.index)])

  mixed_instances_policy {
    instances_distribution {
        on_demand_base_capacity = var.workers_on_demand_base_capacity
        on_demand_percentage_above_base_capacity = var.workers_on_demand_percentage_above_capacity
        spot_allocation_strategy = var.workers_spot_allocation_strategy
    }    
    launch_template {
        launch_template_specification {
            launch_template_id = aws_launch_template.workers[count.index].id
            version = "$Latest"
        }

        # dynamic "override" {
        #     for_each = var.workers_instance_type_override
        #     content {
        #         instance_type = override.value["instance_type"]
        #         weighted_capacity = override.value["weight"]
        #     }
        # }
    }
    }
}

resource "aws_iam_role" "workers" {
    name = "${var.cluster_name}-worker-node"

    assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      },
    ]
  })
}

resource "aws_iam_role_policy_attachment" "workers_policy" {
  role = aws_iam_role.workers.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
}

resource "aws_iam_role_policy_attachment" "workers_AmazonEKS_CNI_Policy" {
  role = aws_iam_role.workers.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
}

resource "aws_iam_role_policy_attachment" "workers_AmazonEC2ContainerRegistryReadOnly" {
  role = aws_iam_role.workers.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
}

resource "aws_iam_instance_profile" "workers" {
  count = var.create_with_autoscaling == true ? 1 : 0
  name_prefix = var.cluster_name
  role = aws_iam_role.workers.name
}

resource "aws_security_group" "workers" {
  name = "${var.cluster_name}-worker-node-ingress"
  description = "Security group for all nodes in the cluster"
  vpc_id = var.vpc_id

  egress {
      from_port = 0
      to_port = 0
      protocol = "-1"
      cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
      Name = "${var.cluster_name}-worker-node-ingress"
  }
}

resource "aws_security_group_rule" "workers_ingress_self" {
    description = "Allow node to communicate with each other"
    from_port = 0
    protocol = "-1" 
    security_group_id = aws_security_group.workers.id
    source_security_group_id = aws_security_group.workers.id
    to_port = 65535
    type = "ingress"
}

resource "aws_security_group_rule" "workers_ingress_cluster" {
    description = "Allow worker Kubelets and pods to receive communication from the cluster control plane"
    from_port = 1025
    protocol = "tcp"
    security_group_id = aws_security_group.workers.id
    source_security_group_id = aws_security_group.cluster.id
    to_port = 65535
    type = "ingress"
}

resource "aws_security_group_rule" "workers_ingress_cluster_tcp" {
    from_port = 443
    protocol = "tcp"
    security_group_id = aws_security_group.workers.id
    source_security_group_id = aws_security_group.cluster.id
    to_port = 443
    type = "ingress"
}