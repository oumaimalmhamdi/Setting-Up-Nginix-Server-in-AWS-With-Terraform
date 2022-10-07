#creating subnet
resource "aws_subnet" "my-subnet-1" {
  vpc_id = var.my_vpc.id
  cidr_block = var.subnet_cidr_block
  availability_zone = var.current_az
  tags = {
    Name = "${var.current_env}-subnet-1"
  }
}

#configuring the default route table
resource "aws_default_route_table" "my-dflt-route-table" {
  default_route_table_id = var.my_vpc.default_route_table_id
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
  vpc_id = var.my_vpc.id
  tags = {
    Name = "${var.current_env}-igw"
  }
}