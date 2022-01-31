resource "random_integer" "random" {
    min = 1
    max = 100               
}

resource "aws_vpc" "vpc" {
    cidr_block = var.vpc_cidr_block
    enable_dns_hostnames   = true
    enable_dns_support = true

    tags = {
        Name = "vpc-{random_integer.random.id}"
    }

    lifecycle {
        create_before_destroy = true
    }
}

resource "aws_internet_gateway" "igw" {
    vpc_id = aws_vpc.vpc.id

    tags = {
        Name = "igw"
    }
}