# 00_network.tf

resource "google_compute_network" "private_vpc" {
  name                    = "deusops-private-vpc"
  auto_create_subnetworks = false
  project                 = "staging-492617"
}

resource "google_compute_subnetwork" "private_subnet" {
  name          = "deusops-private-subnet"
  ip_cidr_range = "10.10.1.0/24"
  region        = "europe-central2"
  network       = google_compute_network.private_vpc.id
  project       = "staging-492617"
}

# 1. Разрешаем SSH из интернета ТОЛЬКО к бастиону
resource "google_compute_firewall" "allow_ssh_bastion" {
  name    = "allow-ssh-bastion"
  network = google_compute_network.private_vpc.name
  project = "staging-492617"

  allow {
    protocol = "tcp"
    ports    = ["22"]
  }

  source_ranges = ["0.0.0.0/0"]
  target_tags   = ["bastion"] # Применяется только к ВМ с этим тегом
}

# 2. Разрешаем весь внутренний трафик
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

# 3. Разрешаем исходящий трафик (Egress)
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

# 4. Маршрут в ИНТЕРНЕТ через шлюз Google (чтобы сам бастион имел доступ)
resource "google_compute_route" "default_internet" {
  name                   = "route-to-internet-gateway"
  dest_range             = "0.0.0.0/0"
  network                = google_compute_network.private_vpc.name
  project                = "staging-492617"
  next_hop_gateway       = "default-internet-gateway"
  priority               = 1000
}

# 5. Маршрут для ОСТАЛЬНЫХ ВМ через Бастион (NAT)
# Важно: priority выше (меньше число), чем у дефолтного, чтобы перехватить трафик
# Но мы исключаем бастион через tags
resource "google_compute_route" "nat_via_bastion" {
  name                   = "route-to-internet-via-bastion"
  dest_range             = "0.0.0.0/0"
  network                = google_compute_network.private_vpc.name
  project                = "staging-492617"
  next_hop_instance      = google_compute_instance.bastion.name
  next_hop_instance_zone = google_compute_instance.bastion.zone

  # Применяем маршрут только к ВМ с тегом 'needs-nat', исключая сам бастион
  tags = ["needs-nat"]

  priority = 900
}
