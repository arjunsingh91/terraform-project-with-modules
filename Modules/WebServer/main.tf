resource "aws_security_group" "myapp-sg" {
  name        = "myapp-sg"
  description = "Allow web inbound traffic"
  vpc_id      = var.vpc_id

  ingress {
    description = "HTTPS from VPC"   
    from_port   = 443                    # from-to_port range allowas ports in that range 
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "HTTP from VPC"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
    ingress {
    description = "SSH from VPC"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"   # "-1" basically allows all the protocols
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.env_prefix}-myapp-sg"
  }
}


# getting latest image of amazon linux from aws using data quiery 

data "aws_ami" "fetching-latest-ami" {
  most_recent      = true
  owners           = ["amazon"]

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-ebs"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}



/*
generating access key is not productive every time we try to create an environment 
it can be automated by using 

if no key os present we can generate it using 
1. ssh-keygen
2. greping output of the key in console by "cat .ssh/id_rsa.pub"

to conect to ec2 instance we can use:
ssh -i ~/ssh/id_rsa ec2@x.x.x.x

or directly by 

ssh ec2@x.x.x.x
as system knows where to check for the ssh key pairs
*/

resource "aws_key_pair" "deployer"{
  key_name   = "deployer-key"
  public_key = file(var.public-key-location)

}



resource "aws_instance" "myapp-server" {
  ami = data.aws_ami.fetching-latest-ami.id
  instance_type = var.instance-type
  availability_zone = var.avail_zone  #if we do not hard code it AWS auto picks any AZ
  subnet_id = var.subnet_id
  vpc_security_group_ids = [aws_security_group.myapp-sg.id]
  key_name = aws_key_pair.deployer.id
  associate_public_ip_address = true
  #user_data = file("entry-script.sh")

  tags = {
    Name = "${var.env_prefix}-server"
  }
}