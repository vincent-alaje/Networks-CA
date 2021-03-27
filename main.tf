provider "aws" {
    region = "eu-west-1"
    access_key = "AKIAS6WKYWOFKVTQDEVS"
    secret_key = "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"
}
# Create a Virtual Private Cloud (VPC)
resource "aws_vpc" "vincent-vpc" {
    cidr_block       = "10.1.0.0/16"
    tags = {
        Name = "Vincent-VPC"
    }
}

#Create Internet Gateway
resource "aws_internet_gateway" "vincent-gw" {
  vpc_id = aws_vpc.vincent-vpc.id
}

#Create Custom Route Table
resource "aws_route_table" "vincent-route" {
    vpc_id = aws_vpc.vincent-vpc.id
    
    route {
        cidr_block = "0.0.0.0/0"
        gateway_id = aws_internet_gateway.vincent-gw.id
    }
    
    route {
        ipv6_cidr_block        = "::/0"
        egress_only_gateway_id = aws_egress_only_internet_gateway.foo.id
    }
    tags = {
        Name = "Vincent-Route"
    }
}
