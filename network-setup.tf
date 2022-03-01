#Create VPC in us-east-1
resource "aws_vpc" "cloudx" {
  provider             = aws.region-master
  cidr_block           = "10.10.0.0/16"
  enable_dns_support   = true
  enable_dns_hostnames = true
  tags = {
    Project = "Cloudx"
  }

}




#Create IGW in us-east-1
resource "aws_internet_gateway" "cloudx-igw" {
  provider = aws.region-master
  vpc_id   = aws_vpc.cloudx.id
}

resource "aws_eip" "nat_eip" {
  vpc = true
}


resource "aws_nat_gateway" "cloudx-natgw" {
  allocation_id = aws_eip.nat_eip.id
  subnet_id     = aws_subnet.public_a.id

  tags = {
    Name = "gw NAT"
  }

  # To ensure proper ordering, it is recommended to add an explicit dependency
  # on the Internet Gateway for the VPC.
  depends_on = [aws_internet_gateway.cloudx-igw]
}





#Create public route table in us-east-1
resource "aws_route_table" "public_rt" {
  provider = aws.region-master
  vpc_id   = aws_vpc.cloudx.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.cloudx-igw.id
  }

  lifecycle {
    ignore_changes = all
  }
  tags = {
    Name = "public_rt"
  }
}



#Create private route table in us-east-1
resource "aws_route_table" "private_rt" {
  provider = aws.region-master
  vpc_id   = aws_vpc.cloudx.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.cloudx-natgw.id
  }

  lifecycle {
    ignore_changes = all
  }
  tags = {
    Name = "private_rt"
  }
}













#Associate  route table of VPC(cloudx) with our route table entries
resource "aws_route_table_association" "public_a" {
  subnet_id      = aws_subnet.public_a.id
  route_table_id = aws_route_table.public_rt.id
}
resource "aws_route_table_association" "public_b" {
  subnet_id      = aws_subnet.public_b.id
  route_table_id = aws_route_table.public_rt.id
}
resource "aws_route_table_association" "public_c" {
  subnet_id      = aws_subnet.public_c.id
  route_table_id = aws_route_table.public_rt.id
}



resource "aws_route_table_association" "private_a" {
  subnet_id      = aws_subnet.private_a.id
  route_table_id = aws_route_table.private_rt.id
}
resource "aws_route_table_association" "private_b" {
  subnet_id      = aws_subnet.private_b.id
  route_table_id = aws_route_table.private_rt.id
}
resource "aws_route_table_association" "private_c" {
  subnet_id      = aws_subnet.private_c.id
  route_table_id = aws_route_table.private_rt.id
}










#Get all available AZ's in VPC for master region
data "aws_availability_zones" "azs" {
  provider = aws.region-master
  state    = "available"
}






#Create public subnet # 1 in us-east-1
resource "aws_subnet" "public_a" {
  provider          = aws.region-master
  availability_zone = element(data.aws_availability_zones.azs.names, 0)
  vpc_id            = aws_vpc.cloudx.id
  cidr_block        = "10.10.1.0/24"
}

#Create public subnet #2  in us-east-1
resource "aws_subnet" "public_b" {
  provider          = aws.region-master
  vpc_id            = aws_vpc.cloudx.id
  availability_zone = element(data.aws_availability_zones.azs.names, 1)
  cidr_block        = "10.10.2.0/24"
}

#Create public subnet #3  in us-east-1
resource "aws_subnet" "public_c" {
  provider          = aws.region-master
  vpc_id            = aws_vpc.cloudx.id
  availability_zone = element(data.aws_availability_zones.azs.names, 2)
  cidr_block        = "10.10.3.0/24"
}





#Create private subnet # 1 in us-east-1
resource "aws_subnet" "private_a" {
  provider          = aws.region-master
  availability_zone = element(data.aws_availability_zones.azs.names, 0)
  vpc_id            = aws_vpc.cloudx.id
  cidr_block        = "10.10.10.0/24"
}

#Create private subnet #2  in us-east-1
resource "aws_subnet" "private_b" {
  provider          = aws.region-master
  vpc_id            = aws_vpc.cloudx.id
  availability_zone = element(data.aws_availability_zones.azs.names, 1)
  cidr_block        = "10.10.11.0/24"
}

#Create private subnet #3  in us-east-1
resource "aws_subnet" "private_c" {
  provider          = aws.region-master
  vpc_id            = aws_vpc.cloudx.id
  availability_zone = element(data.aws_availability_zones.azs.names, 2)
  cidr_block        = "10.10.12.0/24"
}








#Create database private subnet # 1 in us-east-1
resource "aws_subnet" "private_db_a" {
  provider          = aws.region-master
  availability_zone = element(data.aws_availability_zones.azs.names, 0)
  vpc_id            = aws_vpc.cloudx.id
  cidr_block        = "10.10.20.0/24"
}

#Create database private subnet #2  in us-east-1
resource "aws_subnet" "private_db_b" {
  provider          = aws.region-master
  vpc_id            = aws_vpc.cloudx.id
  availability_zone = element(data.aws_availability_zones.azs.names, 1)
  cidr_block        = "10.10.21.0/24"
}

#Create database private subnet #3  in us-east-1
resource "aws_subnet" "private_db_c" {
  provider          = aws.region-master
  vpc_id            = aws_vpc.cloudx.id
  availability_zone = element(data.aws_availability_zones.azs.names, 2)
  cidr_block        = "10.10.22.0/24"
}













resource "aws_db_subnet_group" "ghost" {
  description = "ghost database subnet group"
  provider    = aws.region-master
  subnet_ids  = [aws_subnet.private_db_a.id, aws_subnet.private_db_b.id, aws_subnet.private_db_c.id]

  tags = {
    Name = "ghost database subnet group"
  }
}







