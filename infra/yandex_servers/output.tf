# output "instance01" {
#   value = yandex_compute_instance.instance01.network_interface.0.nat_ip_address
# }
#
# output "instance01_internal" {
#   value = yandex_compute_instance.instance01.network_interface.0.ip_address
# }

# output "instance02" {
#   value       = yandex_compute_instance.instance02.network_interface.0.ip_address
# }

# output "db01" {
#   value       = yandex_compute_instance.db01.network_interface.0.ip_address
# }

# output "runner01" {
#   value       = yandex_compute_instance.runner01.network_interface.0.ip_address
# }

# output "certificate_nexus_id" {
#   value       = yandex_cm_certificate.wildcard_cert.id
#   description = "Certificate Manager certificate ID for *.eqlan.online"
# }

# output "certificate_nexus_status" {
#   value       = yandex_cm_certificate.wildcard_cert.status
#   description = "Certificate status for nexus"
# }


# # ВАЖНО: DNS записи для проверки доменов
# output "nexus_dns_challenge" {
#   value = {
#     for challenge in yandex_cm_certificate.wildcard_cert.challenges :
#     challenge.domain => {
#       type  = challenge.type
#       value = challenge.dns_name
#       record = challenge.dns_value
#     }
#   }
#   description = "DNS CNAME records required for nexus.eqlan.ru verification"
# }
