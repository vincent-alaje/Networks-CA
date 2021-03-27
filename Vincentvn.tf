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
        egress_only_gateway_id = aws_egress_only_internet_gateway.vincent-gw.id
    }
    tags = {
        Name = "Vincent-Route"
    }
}

#Create a Subnet
resource "aws_subnet" "frontend" {
    vpc_id     = aws_vpc.vincent-vpc.id
    cidr_block = "10.1.1.0/24"
    
    tags = {
        Name = "Frontend-sn"
    }
}

#Associate Route table with subnet
resource "aws_route_table_association" "a" {
  subnet_id      = aws_subnet.frontend.id
  route_table_id = aws_route_table.vincent-route.id
}

#Create a securoty group for SSH, HTTP and HTTPS
resource "aws_security_group" "allow_web" {
  name        = "allow_web"
  description = "Allow Web inbound traffic"
  vpc_id      = aws_vpc.vincent-vpc.id

  ingress {
    description = "SSH Traffic"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
   ingress {
    description = "HTTP Traffic"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
    ingress {
    description = "HTTPS Traffic"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "allow_web"
  }
}

#Create a Network Interface
resource "aws_network_interface" "web-server" {
  subnet_id       = aws_subnet.frontend.id
  private_ips     = ["10.1.1.50"]
  security_groups = [aws_security_group.allow_web.id]

}

#Create Elastic IP to the network interface
resource "aws_eip" "one" {
  vpc                       = true
  network_interface         = aws_network_interface.web-server.id
  associate_with_private_ip = "10.1.1.50"
}
