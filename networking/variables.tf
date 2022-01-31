variable "vpc_cidr" {
    type = string
}

variable "public_sn_count" {
    type = number
}

variable "private_sn_count" {
    type = number
}

variable "max_subnets" {
    type = number
    default = 20
}