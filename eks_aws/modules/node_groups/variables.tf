variable "create_node_groups" {
  type = bool
}

variable "node_group_name" {
  type = string
  default = "worker-node-group"
}

variable "eks_version" {
    type = string
}

variable "cluster_name" {
    type = string
    default = ""
}

variable "subnet" {
    type = list(string)
}

variable "desired_size" {
    type = number
    default = 2
}

variable "min_size" {
    type = number
    default = 2
}

variable "max_size" {
    type = number
    default = 4
}

variable "instance_types" {
    type = list(string)
    default = ["t2.small"]
}