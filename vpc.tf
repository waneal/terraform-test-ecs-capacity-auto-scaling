resource "aws_vpc" "tmp" {
  cidr_block = "10.100.0.0/16"
}

resource "aws_subnet" "tmp-a" {
  cidr_block = "10.100.10.0/24"
  availability_zone = "ap-northeast-1a"
  vpc_id = aws_vpc.tmp.id
  map_public_ip_on_launch = true
}

resource "aws_subnet" "tmp-c" {
  cidr_block = "10.100.20.0/24"
  availability_zone = "ap-northeast-1c"
  vpc_id = aws_vpc.tmp.id
  map_public_ip_on_launch = true
}

resource "aws_internet_gateway" "tmp" {
  vpc_id = aws_vpc.tmp.id
}

resource "aws_route_table" "tmp" {
  vpc_id = aws_vpc.tmp.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.tmp.id
  }
}

resource "aws_route_table_association" "tmp-a" {
  route_table_id = aws_route_table.tmp.id
  subnet_id = aws_subnet.tmp-a.id
}

resource "aws_route_table_association" "tmp-c" {
  route_table_id = aws_route_table.tmp.id
  subnet_id = aws_subnet.tmp-c.id
}

resource "aws_security_group" "tmp" {
  name = "tmp"
  vpc_id = aws_vpc.tmp.id
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

