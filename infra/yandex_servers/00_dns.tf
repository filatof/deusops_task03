resource "yandex_dns_zone" "example_zone" {
  name        = "eqlan-su"
  description = "Public DNS zone for eqlan.su"
  zone        = "eqlan.su."
  public      = true
}

resource "yandex_dns_recordset" "bastion" {
  zone_id = yandex_dns_zone.example_zone.id
  name    = "*.eqlan.su."
  type    = "A"
  ttl     = 300
  data =  [yandex_compute_instance.bastion.network_interface[0].nat_ip_address]
}

