resource "aws_vpc_peering_connection" "mypeering" {
  peer_vpc_id   = "${aws_vpc.vpca.id}"
  vpc_id        = "${aws_vpc.vpcb.id}"
  auto_accept   = true

  tags {
    Name = "VPC Peering between foo and bar"
  }
}

resource "aws_route" "primary2secondary" {
  route_table_id = "${aws_vpc.vpca.main_route_table_id}"
  destination_cidr_block = "${aws_vpc.vpcb.cidr_block}"
  vpc_peering_connection_id = "${aws_vpc_peering_connection.mypeering.id}"
}

resource "aws_route" "secondary2primary" {
  route_table_id = "${aws_vpc.vpcb.main_route_table_id}"
  destination_cidr_block = "${aws_vpc.vpca.cidr_block}"
  vpc_peering_connection_id = "${aws_vpc_peering_connection.mypeering.id}"
}
