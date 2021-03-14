/*
here I have modularised the subnet resource and its associated recosources
such as :

1. subnet
2. routing table 
3. subnet and route table association
4. Internet gateway
*/



resource "aws_subnet" "myapp-subnet-1" {
  vpc_id     = var.vpc_id
  cidr_block = var.subnet_cider_block
  availability_zone = var.avail_zone

  tags = {
    Name = "${var.env_prefix}-subnet-1"
  }
}

/*
resource "aws_route_table" "my-app-route-table" {
  vpc_id = aws_vpc.myapp-vpc.id

  route {
    cidr_block = "0.0.0.0/0"   #default route
    gateway_id = aws_internet_gateway.myapp-internet-gateway.id
  }

  tags = {
    Name = "${var.env_prefix}-route-table"
  }
}

#insted of creatig new routig table we can use the default routing table 
#which is created by aws on creation of the VPC

*/




#using default route tabel
resource "aws_default_route_table" "my-app-main-rtb" {
  default_route_table_id = var.default_route_table_id
  # this can also be verified by using "terraform show" command

  route {
      cidr_block = "0.0.0.0/0"   #default route
      gateway_id = aws_internet_gateway.myapp-internet-gateway.id
  } 

  tags = {
    Name = "${var.env_prefix}-main-route-table"
  }
}




resource "aws_internet_gateway" "myapp-internet-gateway" {
  vpc_id = var.vpc_id

  tags = {
    Name = "${var.env_prefix}-internet-gateway"
  }
}

resource "aws_route_table_association" "a-rtb-subnet" {
  subnet_id      = aws_subnet.myapp-subnet-1.id
  route_table_id = aws_default_route_table.my-app-main-rtb.id
  
}
