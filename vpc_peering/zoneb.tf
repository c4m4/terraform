resource "aws_vpc" "vpcb" {
  cidr_block = "10.2.0.0/16"
  enable_dns_support = true
  enable_dns_hostnames = true
  tags = {
    Name = "vpcb"
  }
}

resource "aws_subnet" "main_subnetb" {
  cidr_block = "10.2.1.0/24"
  availability_zone = "eu-west-1b"
  vpc_id = "${aws_vpc.vpcb.id}"
}

resource "aws_internet_gateway" "gwb" {
  vpc_id = "${aws_vpc.vpcb.id}"

  tags {
    Name = "main_gwb"
  }
}

resource "aws_route" "internet_accessb" {
  route_table_id         = "${aws_vpc.vpcb.main_route_table_id}"
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = "${aws_internet_gateway.gwb.id}"
}


resource "aws_security_group" "natb" {
    name = "vpc_natb"
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

    vpc_id = "${aws_vpc.vpcb.id}"

    tags {
        Name = "NATSGB"
    }
}

resource "aws_instance" "exampleb" {
  ami           = "ami-785db401"
  availability_zone = "eu-west-1b"
  instance_type = "t2.micro"
  key_name      = "emesa"
  associate_public_ip_address = true
  security_groups = ["${aws_security_group.natb.id}"]
  subnet_id = "${aws_subnet.main_subnetb.id}"
  tags = { Name = "my first instance on B" }
}

resource "aws_vpc_peering_connection" "mypeering" {
  peer_vpc_id   = "${aws_vpc.vpca.id}"
  vpc_id        = "${aws_vpc.vpcb.id}"
  auto_accept   = true

  tags {
    Name = "VPC Peering between foo and bar"
  }
}

resource "aws_route" "secondary2primary" {
  route_table_id = "${aws_vpc.vpcb.main_route_table_id}"
  destination_cidr_block = "${aws_vpc.vpca.cidr_block}"
  vpc_peering_connection_id = "${aws_vpc_peering_connection.mypeering.id}"
}

output "public_ipb" {
  value = "${aws_instance.exampleb.public_ip}"
}

