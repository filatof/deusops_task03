# 02_bastion.tf

resource "google_compute_instance" "bastion" {
  name         = "bastion"
  machine_type = "e2-micro"
  zone         = "europe-central2-c"
  project      = "staging-492617"

  can_ip_forward = true # Обязательно для NAT

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
    # Статический IP внутри подсети (опционально, но удобно)
    network_ip = "10.10.1.2"

    # Внешний IP для доступа к бастиону и выхода в интернет
    access_config {
      network_tier = "PREMIUM"
    }
  }

  # Исправленный скрипт инициализации
  metadata_startup_script = <<-EOT
  #!/bin/bash
  set -e

  # Включаем IP forwarding
  sysctl -w net.ipv4.ip_forward=1
  echo "net.ipv4.ip_forward=1" >> /etc/sysctl.conf

  # Очищаем старые правила и ставим NAT
  iptables -t nat -F POSTROUTING
  iptables -t nat -A POSTROUTING -o eth0 -j MASQUERADE

  # Разрешаем форвардинг в firewall (на уровне ОС)
  iptables -A FORWARD -i eth0 -o eth0 -j ACCEPT
  iptables -A FORWARD -m state --state RELATED,ESTABLISHED -j ACCEPT

  EOT

  # Теги критически важны для фаервола и маршрутов
  tags = ["bastion"]
  # Обратите внимание: у бастиона НЕТ тега "needs-nat", поэтому маршрут NAT на него не действует

  labels = {
    goog-ec-src = "vm_bastion"
  }

  service_account {
    email  = "1087283053554-compute@developer.gserviceaccount.com"
    scopes = ["cloud-platform"]
  }

  # Явно передаем SSH ключ в метаданные
  metadata = {
    ssh-keys = "fill:ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIOlPFhFwKepToM3D/5wgUfFsPsv99sZkfUr9gnuhYYr/ fill@MacBookAir.local"
  }
}

output "bastion_external_ip" {
  value = google_compute_instance.bastion.network_interface[0].access_config[0].nat_ip
}
