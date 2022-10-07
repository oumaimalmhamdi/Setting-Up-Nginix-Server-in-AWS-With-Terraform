provider "aws" {}

module "subnet" {
  source = "./modules/subnet"
  subnet_cidr_block = var.vpc_cidr_block
  current_az = var.current_az
  current_env = var.current_env
  my_vpc = aws_vpc.my-vpc
}

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

module "server" {
  source = "./modules/server"
  my_ip = var.my_ip
  my_vpc = aws_vpc.my-vpc
  current_env = var.current_env
  pubkey_location = var.pubkey_location
  instance_type = var.instance_type
  subnet_id = module.subnet.subnet.id
  current_az = var.current_az
}