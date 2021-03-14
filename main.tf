/*
terraform {
  required_version = ">=0.12"
  backend "s3" {
    bucket = "myapp-bucket"
    key = "myapp/state.tfstate"   #location of the file in the bucket
    region = "eu-west-1" # it must be same as our selected region in provider configuration
  }
}

running remote state file:

1. terraform init     as we are modifying terraform configuration
*/


provider "aws"{
    region = "eu-west-1"
}



resource "aws_vpc" "myapp-vpc" {
  cidr_block = var.vpc_cider_block
  tags = {
    Name = "${var.env_prefix}-vpc "   #string interpolation for gluing variable inside the string
  }
}

/*
Calling module in the root main, we use module function
*/

module "my-app-subnet"{
   source = "./Modules/Subnets"
   subnet_cider_block = var.subnet_cider_block
   avail_zone = var.avail_zone
   env_prefix = var.env_prefix
   vpc_id = aws_vpc.myapp-vpc.id
   default_route_table_id = aws_vpc.myapp-vpc.default_route_table_id

}



/*  Another way of running commands on the created server is via provisioners, but its not recomended as it 
breaks idempotency, here in this case I will use remote-exec for this it has 2 requirments 
1. connection : whihc will tell how to connect to macine
2. file : which we have to push to the server so that remote exectution can be performed


connection {
     type = "ssh"
     host = self.public_ip
     user = "ec2-user"
     private_key = file(var.private-key-location)

}

provisioners "file" {
      source = "entry-script.sh"
      destination = "/home/ec2-user/entry-script-onec2.sh"
}

provisioners "remote-exec" {
    script = file("entry-script-onec2.sh")
}

*/

module "myapp-server" {
    source = "./Modules/WebServer"
    vpc_id = aws_vpc.myapp-vpc.id
    subnet_id = module.my-app-subnet.subnet.id
    env_prefix = var.env_prefix
    public-key-location = var.public-key-location
    avail_zone = var.avail_zone
    instance-type = var.instance-type

}

