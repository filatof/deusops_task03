resource "yandex_vpc_security_group" "sg" {
  name        = "eq-security-group"
  description = "description for my security group"
  network_id  = yandex_vpc_network.network.id

  labels = {
    my-label = "sg-label"
  }

  dynamic "ingress" {
    for_each = ["80", "443","22", "2222", "3000", "3100", "8080", "8300", "8301", "8302", "8500", "8600", "9090", "9080", "9093", "9095", "9100", "9113", "9104" ]
    content {
      protocol       = "TCP"
      description    = "rule1 description"
      v4_cidr_blocks = ["0.0.0.0/0"]
      from_port      = ingress.value
      to_port        = ingress.value
    }
  }

  egress {
    protocol       = "ANY"
    description    = "rule2 description"
    v4_cidr_blocks = ["0.0.0.0/0"]
    from_port      = 0
    to_port        = 65535
  }
}
