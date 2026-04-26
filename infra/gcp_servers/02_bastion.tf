# 02_bastion.tf

resource "google_compute_instance" "bastion" {
  name         = "bastion"
  machine_type = "e2-micro" # Или ваш размер
  zone         = "europe-central2-c"
  project      = "staging-492617"

  # Включаем пересылку пакетов (обязательно для NAT шлюза)
  can_ip_forward = true

  boot_disk {
    auto_delete = true
    device_name = "bastion"
    initialize_params {
      image = "projects/ubuntu-os-cloud/global/images/family/ubuntu-2404-lts-amd64"
      size  = 20
      type  = "pd-balanced"
    }
  }

  network_interface {
    subnetwork = google_compute_subnetwork.private_subnet.id
    network_ip = "10.10.1.2"

    # Бастион ЕДИНСТВЕННЫЙ получает внешний IP
    access_config {
      network_tier = "PREMIUM"
    }
  }

  # Скрипт для настройки NAT внутри ОС
  metadata_startup_script = <<-EOT
  #!/bin/bash
  # Включаем IP forwarding в ядре
  sysctl -w net.ipv4.ip_forward=1
  echo "net.ipv4.ip_forward=1" >> /etc/sysctl.conf

  # Настраиваем iptables для маскарадинга (NAT)
  iptables -t nat -A POSTROUTING -o eth0 -j MASQUERADE

  # Сохраняем правила (для Ubuntu 24.04 может потребоваться пакет iptables-persistent,
  # но для задачи достаточно применить при старте)
  EOT

  tags = ["bastion"]

  # ... остальной код (labels, service_account и т.д. как у вас был) ...
  labels = {
    goog-ec-src = "vm_bastion"
  }

  service_account {
    email  = "1087283053554-compute@developer.gserviceaccount.com"
    scopes = ["cloud-platform"]
  }
}

output "bastion_external_ip" {
  value = google_compute_instance.bastion.network_interface[0].access_config[0].nat_ip
}

output "bastion_internal_ip" {
  value = google_compute_instance.bastion.network_interface[0].network_ip
}
