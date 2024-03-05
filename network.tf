resource "aws_vpc" "eks_vpc" {
  cidr_block           = var.vpc_cidr
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = merge(
    {
      Name = "vpc-${var.eks_name}"
    },
    var.common_tags
  )
}

resource "aws_subnet" "eks_public_subnet" {
  count = length(var.public_subnet_cidr)

  vpc_id                  = aws_vpc.eks_vpc.id
  cidr_block              = var.public_subnet_cidr[count.index]
  availability_zone       = data.aws_availability_zones.region_azones.names[count.index]
  map_public_ip_on_launch = true

  tags = merge(
    {
      Name = "public-subnet-${var.eks_name}-${data.aws_availability_zones.region_azones.names[count.index]}",
      #"kubernetes.io/cluster/${var.eks_name}" = "shared", # alb <= v2.1.1
      "kubernetes.io/role/elb" = 1 # deploy load balancers in the public subnet
    },
    var.common_tags
  )
}

resource "aws_subnet" "eks_private_subnet" {
  count = length(var.private_subnet_cidr)

  vpc_id                  = aws_vpc.eks_vpc.id
  cidr_block              = var.private_subnet_cidr[count.index]
  availability_zone       = data.aws_availability_zones.region_azones.names[count.index]
  map_public_ip_on_launch = false

  tags = merge(
    {
      Name = "private-subnet-${var.eks_name}-${data.aws_availability_zones.region_azones.names[count.index]}",
      #"kubernetes.io/cluster/${var.eks_name}" = "shared", # alb <= v2.1.1
      "kubernetes.io/role/internal-elb" = 1 # deploy load balancers in the private subnet
    },
    var.common_tags
  )
}

resource "aws_internet_gateway" "eks_igw" {
  vpc_id = aws_vpc.eks_vpc.id

  tags = merge(
    {
      Name = "igw-${var.eks_name}"
    },
    var.common_tags
  )
}

resource "aws_route_table" "eks_public_route" {
  vpc_id = aws_vpc.eks_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.eks_igw.id
  }

  tags = merge(
    {
      Name = "public-subnet-route-${var.eks_name}"
    },
    var.common_tags
  )
}

resource "aws_route_table_association" "eks_public_subnet_route" {
  count = length(var.public_subnet_cidr)

  route_table_id = aws_route_table.eks_public_route.id
  subnet_id      = aws_subnet.eks_public_subnet[count.index].id
}

resource "aws_eip" "eks_natgw_eip" {
  count = var.eks_private_nodes ? 1 : 0
  domain = "vpc"

  tags = merge(
    {
      Name = "eip-nat-gw-${var.eks_name}"
    },
    var.common_tags
  )
}

#
# NAT gateway must be created in the public subnet
# This is a point of failure
# Saving money using one nat gateway
#
resource "aws_nat_gateway" "eks_natgw" {
  count = var.eks_private_nodes ? 1 : 0

  allocation_id = aws_eip.eks_natgw_eip[0].id
  subnet_id     = aws_subnet.eks_public_subnet[count.index].id

  tags = merge(
    {
      Name = "nat-gw-${var.eks_name}"
    },
    var.common_tags
  )

  # To ensure proper ordering, it is recommended to add an explicit dependency
  # on the Internet Gateway for the VPC.
  depends_on = [aws_internet_gateway.eks_igw]
}

resource "aws_route_table" "eks_private_route" {
  count = var.eks_private_nodes ? 1 : 0

  vpc_id = aws_vpc.eks_vpc.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.eks_natgw[0].id
  }

  tags = merge(
    {
      Name = "private-subnet-route-${var.eks_name}"
    },
    var.common_tags
  )
}

resource "aws_route_table_association" "eks_private_subnet_route" {
  count = var.eks_private_nodes ? length(var.private_subnet_cidr) : 0

  route_table_id = aws_route_table.eks_private_route[0].id
  subnet_id      = aws_subnet.eks_private_subnet[count.index].id
}
