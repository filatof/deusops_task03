//
// Create a new VPC Network.
//
resource "yandex_vpc_network" "network" {
  name = "eqlan"
}

resource "yandex_vpc_subnet" "my_subnet" {
  v4_cidr_blocks = ["10.10.1.0/24"]
  zone           = "ru-central1-a"
  network_id     = yandex_vpc_network.network.id
  route_table_id = yandex_vpc_route_table.my_table.id
}
