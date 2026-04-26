# 00_network.tf

# 1. Создаем приватную VPC
resource "google_compute_network" "private_vpc" {
  name                    = "deusops-private-vpc"
  auto_create_subnetworks = false
  project                 = "staging-492617" # Ваш проект
}

# 2. Создаем подсеть 10.10.1.0/24
resource "google_compute_subnetwork" "private_subnet" {
  name          = "deusops-private-subnet"
  ip_cidr_range = "10.10.1.0/24"
  region        = "europe-central2"
  network       = google_compute_network.private_vpc.id
  project       = "staging-492617"
}

# 3. Фаервол: Разрешаем SSH из интернета ТОЛЬКО к бастиону
resource "google_compute_firewall" "allow_ssh_bastion" {
  name    = "allow-ssh-bastion"
  network = google_compute_network.private_vpc.name
  project = "staging-492617"

  allow {
    protocol = "tcp"
    ports    = ["22"]
  }

  source_ranges = ["0.0.0.0/0"]
  target_tags   = ["bastion"]
}

# 4. Фаервол: Разрешаем весь внутренний трафик между ВМ в подсети
resource "google_compute_firewall" "allow_internal" {
  name    = "allow-internal-traffic"
  network = google_compute_network.private_vpc.name
  project = "staging-492617"

  allow {
    protocol = "icmp"
  }
  allow {
    protocol = "tcp"
    ports    = ["0-65535"]
  }
  allow {
    protocol = "udp"
    ports    = ["0-65535"]
  }

  source_ranges = ["10.10.1.0/24"]
}

# 5. Фаервол: Разрешаем исходящий трафик в интернет (нужно для работы NAT)
resource "google_compute_firewall" "allow_egress" {
  name    = "allow-egress-internet"
  network = google_compute_network.private_vpc.name
  project = "staging-492617"

  direction = "EGRESS"
  allow {
    protocol = "all"
  }
  destination_ranges = ["0.0.0.0/0"]
}

# 6. Маршрут: Весь интернет-трафик (0.0.0.0/0) отправлять на внутренний IP бастиона
# Этот ресурс будет создан после создания инстанса bastion, поэтому используем depends_on или просто ссылку
resource "google_compute_route" "nat_via_bastion" {
  name                    = "route-to-internet-via-bastion"
  dest_range              = "0.0.0.0/0"
  network                 = google_compute_network.private_vpc.name
  project                 = "staging-492617"
  next_hop_instance       = google_compute_instance.bastion.name
  next_hop_instance_zone  = google_compute_instance.bastion.zone

  # Чтобы маршрут создался после бастиона
  depends_on = [google_compute_instance.bastion]
}
