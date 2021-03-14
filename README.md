# Terraform Prject demonstrating modules usecase


1. create a VPC
2. create internet gateway
3. create custome route table
4. create a subnet
5. associate a subnet to route table
6. create a security group to allow port 22, 80, 443
7. create a network interface with an ip in subnet created in step 4
8. assign an elastic ip to the interface created in step 7
9. create ubuntu server and install/enable apache2

Finally creating module:
1. Networking services in module named "Subnets"
2. EC2 instance and releated dependencies in module named "WebServer"
