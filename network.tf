### VPCs ###

# create vpc in us-east-1
resource "aws_vpc" "vpc-control" {
  provider             = aws.region-control
  cidr_block           = "10.0.0.0/16"
  enable_dns_support   = true
  enable_dns_hostnames = true
  tags = {
    Name = "control-node-vpc"
  }
}

# create vpc in us-east-2
resource "aws_vpc" "vpc-nodes" {
  provider             = aws.region-nodes
  cidr_block           = "192.168.0.0/16"
  enable_dns_support   = true
  enable_dns_hostnames = true
  tags = {
    Name = "managed-node-vpc"
  }
}

### IGWs ###

# create IGW in us-east-1
resource "aws_internet_gateway" "igw-east1" {
  provider = aws.region-control
  vpc_id   = aws_vpc.vpc-control.id
}

# create IGW in us-east-1
resource "aws_internet_gateway" "igw-east2" {
  provider = aws.region-nodes
  vpc_id   = aws_vpc.vpc-nodes.id
}

# get all available AZs in VPC for control node region
data "aws_availability_zones" "azs" {
  provider = aws.region-control
  state    = "available"
}

### Subnets ###

# create subnet in us-east-1
resource "aws_subnet" "subnet_va_1" {
  provider          = aws.region-control
  availability_zone = element(data.aws_availability_zones.azs.names, 0)
  vpc_id            = aws_vpc.vpc-control.id
  cidr_block        = "10.0.1.0/24"
}

# create subnet in us-east-2
resource "aws_subnet" "subnet_ohio_1" {
  provider   = aws.region-nodes
  vpc_id     = aws_vpc.vpc-nodes.id
  cidr_block = "192.168.1.0/24"
}

### VPC Peering ###

# create peering connection request from us-east-1
resource "aws_vpc_peering_connection" "useast1-useast2" {
  provider    = aws.region-control
  peer_vpc_id = aws_vpc.vpc-nodes.id
  vpc_id      = aws_vpc.vpc-control.id
  peer_region = var.region-nodes
}

resource "aws_vpc_peering_connection_accepter" "accept-peering" {
  provider                  = aws.region-nodes
  vpc_peering_connection_id = aws_vpc_peering_connection.useast1-useast2.id
  auto_accept               = true
}

### Routing tables ###

# create route table in us-east-1
resource "aws_route_table" "internet-route" {
  provider = aws.region-control
  vpc_id   = aws_vpc.vpc-control.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw-east1.id
  }
  route {
    cidr_block                = "192.168.1.0/24"
    vpc_peering_connection_id = aws_vpc_peering_connection.useast1-useast2.id
  }
  lifecycle {
    ignore_changes = all
  }
  tags = {
    Name = "Control-Region-Route-Table"
  }
}

# overwrite default route table of master region VPC with the above route entries
resource "aws_main_route_table_association" "set-control-default-rt-association" {
  provider       = aws.region-control
  vpc_id         = aws_vpc.vpc-control.id
  route_table_id = aws_route_table.internet-route.id
}

# create route table in us-east-2
resource "aws_route_table" "internet-route-ohio" {
  provider = aws.region-nodes
  vpc_id   = aws_vpc.vpc-nodes.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw-east2.id
  }
  route {
    cidr_block                = "10.0.1.0/24"
    vpc_peering_connection_id = aws_vpc_peering_connection.useast1-useast2.id
  }
  lifecycle {
    ignore_changes = all
  }
  tags = {
    Name = "Nodes-Region-Route-Table"
  }
}

# overwrite default route table of master region VPC with the above route entries
resource "aws_main_route_table_association" "set-nodes-default-rt-association" {
  provider       = aws.region-nodes
  vpc_id         = aws_vpc.vpc-nodes.id
  route_table_id = aws_route_table.internet-route-ohio.id
}