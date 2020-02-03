## VPC
resource "aws_vpc" "vpc-1" {
  cidr_block = var.vpc_cidr_block
#   enable_dns_hostnames = "true"
  tags = {
       Name = "vpc-1"
   }
}

## internet gateway
resource "aws_internet_gateway" "gw" {
  vpc_id = "${aws_vpc.vpc-1.id}"

  tags = {
    Name = "igw"
  }
}

# data "aws_availability_zones" = "available" {}


## public subnets (2)
resource "aws_subnet" "pub-subnet" {
  count             = "${length(var.subnets_cidr_public)}"
  vpc_id            = "${aws_vpc.vpc-1.id}"
  cidr_block        = "${element(var.subnets_cidr_public,count.index)}"
  availability_zone = "${var.availability_zones[count.index]}"
  map_public_ip_on_launch = true

  tags = {
    Name = "pub-subnet-${count.index+1}"
  }
}

## private subnets (2)
resource "aws_subnet" "prv-subnet" {
  count             = "${length(var.subnets_cidr_private)}"
  vpc_id            = "${aws_vpc.vpc-1.id}"
  cidr_block        = "${element(var.subnets_cidr_private,count.index)}"
  availability_zone = "${var.availability_zones[count.index]}"
  
  tags = {
    Name = "prv-subnet-${count.index+1}"
  }
}

## elastic IP
resource "aws_eip" "nat" {
  count      = "${length(var.subnets_cidr_private)}"
#   depends_on = ["aws_internet_gateway.gw"]
  vpc        = true
}

## NAT gateways (2)
resource "aws_nat_gateway" "ngw" {
   count         = "${length(var.subnets_cidr_public)}"
   allocation_id = "${element(aws_eip.nat.*.id, count.index)}"
   subnet_id     = "${element(aws_subnet.pub-subnet.*.id, count.index)}"
   depends_on = ["aws_internet_gateway.gw", "aws_subnet.pub-subnet"]

    tags = {
      Name = "NAT-gw-${count.index+1}"
    }
}

## public route table (1)
resource "aws_route_table" "public_rtb" {
  vpc_id = "${aws_vpc.vpc-1.id}"
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = "${aws_internet_gateway.gw.id}"
  }

  tags = {
    Name = "public RTB"
  }
}

## private route tables (2)
resource "aws_route_table" "private_rtb" {
  count  = "${length(var.subnets_cidr_private)}"
  vpc_id = "${aws_vpc.vpc-1.id}"
  route {
    cidr_block = "0.0.0.0/0"
    nat_gateway_id = "${element(aws_nat_gateway.ngw.*.id, count.index)}"
    # nat_gateway_id = "${aws_nat_gateway.ngw.*.id}"

  }

  tags = {
    Name = "private RTB-${count.index+1}"
  }
}

## association of public rtb to public subnets
resource "aws_route_table_association" "public" {
  count          = "${length(var.subnets_cidr_public)}"
  subnet_id      = "${element(aws_subnet.pub-subnet.*.id, count.index)}"
  route_table_id = "${aws_route_table.public_rtb.id}"
}

## association of private rtb to private subnets
resource "aws_route_table_association" "private" {
  count          = "${length(var.subnets_cidr_private)}"
  subnet_id      = "${element(aws_subnet.prv-subnet.*.id, count.index)}"
  route_table_id = "${element(aws_route_table.private_rtb.*.id, count.index)}"
}

