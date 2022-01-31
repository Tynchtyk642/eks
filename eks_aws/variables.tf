#===================== cluster.tf/variables =======================
variable "cluster_name" {
    type = string
    description = "Name of the EKS cluster"
    default = "EKS-cluster"
}

# variable "cluster_enabled_log_types" {
#     type = bool
#     default = false
# }

variable "cluster_version" {
    type = string
    description = "Version of EKS cluster"
    default = "1.21"
}

variable "vpc_id" {
    type = string
    default = ""
}

#====================== node_groups.tf/variables =====================

variable "create_node_groups" {
    type = bool
    default = false
}

variable "subnet_ids" {
    type = list(string)
    default = [""]
}

variable "desired_capacity" {
    type = number
    default = 2
}

variable "min_workers" {
    type = number
    default = 2
}

variable "max_workers" {
    type = number
    default = 5
}

variable "instance_type" {
    type = string
    default = "t3.small"
}
#=================== worker_launch_template.tf/variables =================

variable "create_with_autoscaling" {
    type = bool
    default = true
}

variable "workers_on_demand_base_capacity" {
    type = number
    default = 0
}

variable "workers_on_demand_percentage_above_capacity" {
    type = number
    default = 100
}

variable "workers_spot_allocation_strategy" {
    type = string
    default = "capacity-optimized"
}
