#configuring default security group
resource "aws_default_security_group" "my-dflt-sg" {
  vpc_id = var.my_vpc.id
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

#creating key pair
resource "aws_key_pair" "my-key-pair" {
  key_name = "my-server-key"
  public_key = file(var.pubkey_location)
}

#creating EC2 instance
resource "aws_instance" "my-ec2-instance" {
  ami = data.aws_ami.ltst-amzn-linux-img.id
  instance_type = var.instance_type

  subnet_id = var.subnet_id
  vpc_security_group_ids = [ aws_default_security_group.my-dflt-sg.id ]
  availability_zone = var.current_az

  key_name = aws_key_pair.my-key-pair.key_name
  associate_public_ip_address = true
  
  user_data = file("initial-script.sh")


  tags = {
    Name = "${var.current_env}-ec2-instance"
  }

}