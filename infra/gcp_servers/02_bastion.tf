# 02_bastion.tf

resource "google_compute_instance" "bastion" {
  name         = "bastion"
  machine_type = "e2-micro"
  zone         = "europe-central2-c"
  project      = "staging-492617"

  # can_ip_forward больше НЕ нужен, так как NAT делает Cloud NAT
  can_ip_forward = false

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
    network_ip = "10.10.1.2" # Статический внутренний IP для удобства

    # Единственная ВМ с внешним IP
    access_config {
      network_tier = "PREMIUM"
    }
  }

  # Скрипт больше не нужен для NAT, можно оставить пустым или для обновлений
  metadata_startup_script = <<-EOT
  #!/bin/bash
  apt-get update && apt-get upgrade -y
  EOT

  tags = ["bastion"]

  labels = {
    goog-ec-src = "vm_bastion"
  }

  service_account {
    email  = "1087283053554-compute@developer.gserviceaccount.com"
    scopes = ["cloud-platform"]
  }

  metadata = {
    ssh-keys = "fill:ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIOlPFhFwKepToM3D/5wgUfFsPsv99sZkfUr9gnuhYYr/ fill@MacBookAir.local"
  }
}

output "bastion_external_ip" {
  value = google_compute_instance.bastion.network_interface[0].access_config[0].nat_ip
}

output "bastion_internal_ip" {
  value = google_compute_instance.bastion.network_interface[0].network_ip
}

resource "local_file" "ansible_inventory" {
  depends_on = [google_compute_instance.bastion]
  filename = "${path.module}/../../ansible/inventory"
  content = <<EOT
[bastion_host]
bastion ansible_host=${google_compute_instance.bastion.network_interface[0].access_config[0].nat_ip} ansible_user=fill ansible_port=22 ansible_ssh_private_key_file=~/.ssh/id_ed25519 ansible_python_interpreter=/usr/bin/python3

[internal]
n8n         ansible_host=10.10.1.3
postgre     ansible_host=10.10.1.4
wiki        ansible_host=10.10.1.5
ollama      ansible_host=10.10.1.6

# ProxyJump
[internal:vars]
ansible_ssh_common_args='-o ProxyJump=fill@${google_compute_instance.bastion.network_interface[0].access_config[0].nat_ip}'
ansible_user=fill
ansible_port=22
ansible_ssh_private_key_file=~/.ssh/id_ed25519
ansible_python_interpreter=/usr/bin/python3
EOT
}
