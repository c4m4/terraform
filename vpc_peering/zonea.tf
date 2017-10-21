resource "aws_vpc" "vpca" {
  cidr_block = "10.1.0.0/16"
  enable_dns_support = true
  enable_dns_hostnames = true
  tags = {
    Name = "vpca"
  }
}

resource "aws_subnet" "main_subneta" {
  cidr_block = "10.1.1.0/24"
  vpc_id = "${aws_vpc.vpca.id}"
  availability_zone = "eu-west-1a"
}

resource "aws_internet_gateway" "gwa" {
  vpc_id = "${aws_vpc.vpca.id}"

  tags {
    Name = "main_gwa"
  }
}

resource "aws_route" "internet_accessa" {
  route_table_id         = "${aws_vpc.vpca.main_route_table_id}"
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = "${aws_internet_gateway.gwa.id}"
}



resource "aws_security_group" "nata" {
    name = "vpc_nata"
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

    vpc_id = "${aws_vpc.vpca.id}"

    tags {
        Name = "NATSGA"
    }
}

resource "aws_instance" "examplea" {
  ami           = "ami-785db401"
  instance_type = "t2.micro"
  availability_zone = "eu-west-1a"
  key_name      = "emesa"
  associate_public_ip_address = true
  security_groups = ["${aws_security_group.nata.id}"]
  subnet_id = "${aws_subnet.main_subneta.id}"
  tags = { Name = "my first instance on A" }
}

resource "aws_route" "primary2secondary" {
  route_table_id = "${aws_vpc.vpca.main_route_table_id}"
  destination_cidr_block = "${aws_vpc.vpcb.cidr_block}"
  vpc_peering_connection_id = "${aws_vpc_peering_connection.mypeering.id}"
}

output "public_ipa" {
  value = "${aws_instance.examplea.public_ip}"
}

