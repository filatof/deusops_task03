//
// Create a new VPC NAT Gateway.
//
resource "yandex_vpc_gateway" "my_gw" {
  name = "ru"
  shared_egress_gateway {}
}

//
// Create a new VPC Route Table.
//
resource "yandex_vpc_route_table" "my_table" {
  network_id = yandex_vpc_network.network.id

  static_route {
    destination_prefix = "0.0.0.0/0"
    gateway_id         = yandex_vpc_gateway.my_gw.id
  }
}
