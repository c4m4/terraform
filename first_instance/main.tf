provider "aws" {
  region = "eu-west-1"
}

resource "aws_vpc" "mainvpc" {
  cidr_block = "10.0.0.0/16"
  enable_dns_support = true
  enable_dns_hostnames = true
  tags = {
    Name = "example_setup_vpc"
  }
}

resource "aws_subnet" "main_subnet" {
  cidr_block = "10.0.1.0/24"
  vpc_id = "${aws_vpc.mainvpc.id}"
}

resource "aws_internet_gateway" "gw" {
  vpc_id = "${aws_vpc.mainvpc.id}"

  tags {
    Name = "main_gw"
  }
}

resource "aws_route" "internet_access" {
  route_table_id         = "${aws_vpc.mainvpc.main_route_table_id}"
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = "${aws_internet_gateway.gw.id}"
}



resource "aws_security_group" "nat" {
    name = "vpc_nat"
    description = "Allow traffic to pass from the private subnet to the internet"

    ingress {
        from_port = 80
        to_port = 80
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }
    ingress {
        from_port = 443
        to_port = 443
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }
    ingress {
        from_port = 22
        to_port = 22
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }
    ingress {
        from_port = -1
        to_port = -1
        protocol = "icmp"
        cidr_blocks = ["0.0.0.0/0"]
    }

    egress {
        from_port = 0
        to_port = 0
        protocol = -1
        cidr_blocks = ["0.0.0.0/0"]
    }

    vpc_id = "${aws_vpc.mainvpc.id}"

    tags {
        Name = "NATSG"
    }
}

resource "aws_instance" "example" {
  ami           = "ami-785db401"
  instance_type = "t2.micro"
  key_name      = "emesa"
  associate_public_ip_address = true
  security_groups = ["${aws_security_group.nat.id}"]
  subnet_id = "${aws_subnet.main_subnet.id}"
  tags = { Name = "my first instance" }
}

output "public_ip" {
  value = "${aws_instance.example.public_ip}"
}
