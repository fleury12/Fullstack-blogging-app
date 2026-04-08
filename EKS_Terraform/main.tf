provider "aws" {
  region = var.aws_region
}

data "aws_ami" "ubuntu" {
  most_recent = true
  owners      = ["099720109477"]

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

resource "aws_vpc" "fleury_vpc" {
  cidr_block = var.vpc_cidr

  tags = {
    Name = "fleury-vpc"
  }
}

resource "aws_subnet" "fleury_public_subnet" {
  count                   = length(var.public_subnet_cidrs)
  vpc_id                  = aws_vpc.fleury_vpc.id
  cidr_block              = var.public_subnet_cidrs[count.index]
  availability_zone       = var.availability_zones[count.index]
  map_public_ip_on_launch = true

  tags = {
    Name = "fleury-public-subnet-${count.index}"
  }
}

resource "aws_internet_gateway" "fleury_igw" {
  vpc_id = aws_vpc.fleury_vpc.id

  tags = {
    Name = "fleury-igw"
  }
}

resource "aws_route_table" "fleury_route_table" {
  vpc_id = aws_vpc.fleury_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.fleury_igw.id
  }

  tags = {
    Name = "fleury-route-table"
  }
}

resource "aws_route_table_association" "public" {
  count          = length(aws_subnet.fleury_public_subnet)
  subnet_id      = aws_subnet.fleury_public_subnet[count.index].id
  route_table_id = aws_route_table.fleury_route_table.id
}

resource "aws_security_group" "fleury_instance_sg" {
  name   = "fleury-instance-sg"
  vpc_id = aws_vpc.fleury_vpc.id

  ingress {
    from_port   = 8
    to_port     = 8
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = var.ssh_ingress_cidrs
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "fleury-instance-sg"
  }
}

locals {
  instance_specs = [
    { name = "SonarQube", instance_type = "t2.medium", volume_size = 25 },
    { name = "Nexus", instance_type = "t2.medium", volume_size = 25 },
    { name = "Monitor", instance_type = "t2.medium", volume_size = 25 },
    { name = "Jenkins", instance_type = "t2.large", volume_size = 30 }
  ]

  instances = {
    for idx, inst in local.instance_specs :
    inst.name => merge(inst, { subnet_index = idx % length(var.public_subnet_cidrs) })
  }
}

resource "aws_instance" "fleet" {
  for_each               = local.instances
  ami                    = data.aws_ami.ubuntu.id
  instance_type          = each.value.instance_type
  key_name               = var.ssh_key_name
  subnet_id              = aws_subnet.fleury_public_subnet[each.value.subnet_index].id
  vpc_security_group_ids = [aws_security_group.fleury_instance_sg.id]

  root_block_device {
    volume_type = var.ebs_volume_type
    volume_size = each.value.volume_size
  }

  tags = {
    Name = each.key
  }
}
