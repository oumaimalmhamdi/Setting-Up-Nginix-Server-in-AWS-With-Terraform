provider "aws" {}

#declaring variables
variable "current_env" {}
variable "vpc_cidr_block" {}
variable "subnet_cidr_block" {}
variable "current_az" {}
variable "my_ip" {}
variable "instance_type" {}
variable "pubkey_location" {}

#creating vpc
resource "aws_vpc" "my-vpc" {
  cidr_block = var.vpc_cidr_block
  tags = {
    Name = "${var.current_env}-vpc"
  }
}

#creating subnet
resource "aws_subnet" "my-subnet-1" {
  vpc_id = aws_vpc.my-vpc.id
  cidr_block = var.subnet_cidr_block
  availability_zone = var.current_az
  tags = {
    Name = "${var.current_env}-subnet-1"
  }
}

# this commented line represent the creation of a new route table and associating it to the subnet

#creating route table
# resource "aws_route_table" "my-route-table" {
#   vpc_id = aws_vpc.my-vpc.id
#   route {
#     cidr_block = "0.0.0.0/0" 
#     gateway_id = aws_internet_gateway.my-igw.id
#   }
#   tags = {
#     Name = "${var.current_env}-routetable"
#   }
# }

#creating route table association
# resource "aws_route_table_association" "my-rtb-assoC" {
#   route_table_id = aws_route_table.my-route-table.id
#   subnet_id = aws_subnet.my-subnet-1.id
# }

# insted of crating new route table we can use the default one created automatically by aws
#configuring the default route table
resource "aws_default_route_table" "my-dflt-route-table" {
  default_route_table_id = aws_vpc.my-vpc.default_route_table_id
  route {
    cidr_block = "0.0.0.0/0" 
    gateway_id = aws_internet_gateway.my-igw.id
  }
  tags = {
    Name = "${var.current_env}-main-routetable"
  }
}

#creating internet gateway
resource "aws_internet_gateway" "my-igw" {
  vpc_id = aws_vpc.my-vpc.id
  tags = {
    Name = "${var.current_env}-igw"
  }
}

#configuring default security group
resource "aws_default_security_group" "my-dflt-sg" {
  vpc_id = aws_vpc.my-vpc.id
  ingress {
    from_port = 22
    to_port = 22
    protocol = "tcp"
    cidr_blocks = [var.my_ip]
  }
  ingress {
    from_port = 8080
    to_port = 8080
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = [ "0.0.0.0/0" ]
    prefix_list_ids = []
  }
  tags = {
    Name = "${var.current_env}-sg"
  }
}

#retrieving EC2 instance ami id from aws
data "aws_ami" "ltst-amzn-linux-img" {
  most_recent = true
  owners = ["amazon"]
  filter {
    name = "name"
    values = ["amzn2-ami-hvm-*-x86_64-gp2"]
  }
  filter {
    name = "virtualization-type"
    values = ["hvm"]
  }
}

#printing the EC2's instance public key
output "aws_public_ip" {
  value = aws_instance.my-ec2-instance.public_ip
}

#creating key pair
resource "aws_key_pair" "my-key-pair" {
  key_name = "my-server-key"
  public_key = file(var.pubkey_location)
}

#creating EC2 instance
resource "aws_instance" "my-ec2-instance" {
  ami = data.aws_ami.ltst-amzn-linux-img.id
  instance_type = var.instance_type

  subnet_id = aws_subnet.my-subnet-1.id
  vpc_security_group_ids = [ aws_default_security_group.my-dflt-sg.id ]
  availability_zone = var.current_az

  key_name = aws_key_pair.my-key-pair.key_name
  associate_public_ip_address = true
  
  user_data = file("initial-script.sh")


  tags = {
    Name = "${var.current_env}-ec2-instance"
  }

}