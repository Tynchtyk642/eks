resource "aws_route_table" "public_route_table" {
    vpc_id = aws_vpc.vpc.id

    route {
        cidr_block = "0.0.0.0/0"
        gateway_id = aws_internet_gateway.igw.id
    }

    tags = {
        Name = "public-route-table"
    }
}

resource "aws_route_table_association" "public_assoc" {
    count = var.public_subnets
    subnet_id = aws_subnet.public_subnets.*.id[count.index]
    route_table_id = aws_route_table.public_route_table.id
}




resource "aws_default_route_table" "route_table" {
  default_route_table_id = aws_vpc.vpc.default_route_table_id

  route {
      cidr_block = "0.0.0.0/0"
      gateway_id = aws_nat_gateway.nat.id
  }

  tags = {
    "Name" = "private-route-table"
  }
}

resource "aws_route_table_association" "private_assoc" {
    count = var.private_subnets
    subnet_id = aws_subnet.private_subnets.*.id[count.index]
    route_table_id = aws_default_route_table.route_table.id
}

resource "aws_nat_gateway" "nat" {
    allocation_id = aws_eip.nat_eip.id
    subnet_id = aws_subnet.public_subnets[0].id
}

resource "aws_eip" "nat_eip" {
    tags = {
        Name = "eip-for-nat"
    }
}