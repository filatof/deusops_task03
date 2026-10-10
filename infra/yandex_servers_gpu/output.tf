output "bastion" {
  value = yandex_compute_instance.bastion.network_interface.0.nat_ip_address
}

output "n8n" {
  value       = yandex_compute_instance.n8n.network_interface.0.ip_address
}

output "postgre" {
  value       = yandex_compute_instance.postgre.network_interface.0.ip_address
}

output "wiki" {
  value       = yandex_compute_instance.wiki.network_interface.0.ip_address
}

output "ollama" {
  value       = yandex_compute_instance.ollama.network_interface.0.ip_address
}

