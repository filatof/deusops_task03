resource "cloudflare_record" "web_dns" {
  zone_id = var.cloudflare_zone_id
  name    = "n8n"
  content   = google_compute_instance.bastion.network_interface[0].access_config[0].nat_ip
  type    = "A"
  ttl     = 1
  proxied = true
}