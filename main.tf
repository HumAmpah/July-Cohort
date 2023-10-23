#provider.tf
provider "aws" {
  region = "eu-west-2"
}

#main.tf
# Create VPC
resource "aws_vpc" "my_vpc" {
  cidr_block = "10.0.0.0/16"
}

# Create public subnet
resource "aws_subnet" "public_subnets" {
  count         = 2
  vpc_id        = aws_vpc.my_vpc.id
  cidr_block    = element(["10.0.1.0/24", "10.0.2.0/24"], count.index)
  availability_zone = element(["eu-west-2a", "eu-west-2b"], count.index)
  map_public_ip_on_launch = true
  tags = {
    Name = "Prod-pub-sub${count.index + 1}"
  }
}

# Create private subnets
resource "aws_subnet" "private_subnets" {
  count         = 2
  vpc_id        = aws_vpc.my_vpc.id
  cidr_block    = element(["10.0.3.0/24", "10.0.4.0/24"], count.index)
  availability_zone = element(["eu-west-2a", "eu-west-2b"], count.index)
  tags = {
    Name = "Prod-priv-sub${count.index + 1}"
  }
}

# Create public route table
resource "aws_route_table" "public_route_table" {
  vpc_id = aws_vpc.my_vpc.id
  tags = {
    Name = "Prod-pub-route-table"
  }
}

# Create private route table
resource "aws_route_table" "private_route_table" {
  vpc_id = aws_vpc.my_vpc.id
  tags = {
    Name = "Prod-priv-route-table"
  }
}

# Create Internet Gateway
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.my_vpc.id
  tags = {
    Name = "Prod-igw"
  }
}

# Associate public subnets with public route table
resource "aws_route_table_association" "public_subnet_association" {
  count          = 2
  subnet_id      = aws_subnet.public_subnets[count.index].id
  route_table_id = aws_route_table.public_route_table.id
}

# Associate private subnets with private route table
resource "aws_route_table_association" "private_subnet_association" {
  count          = 2
  subnet_id      = aws_subnet.private_subnets[count.index].id
  route_table_id = aws_route_table.private_route_table.id
}
# Create a NAT Gateway
resource "aws_nat_gateway" "nat_gateway" {
  allocation_id = "eipalloc-0f629f6ee745fc675" # Replace with your Elastic IP allocation ID
  subnet_id     = aws_subnet.public_subnets[0].id # Choose one of the public subnets
}

# Associate NAT Gateway with private route table
resource "aws_route" "private_route" {
  route_table_id         = aws_route_table.private_route_table.id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.nat_gateway.id
}