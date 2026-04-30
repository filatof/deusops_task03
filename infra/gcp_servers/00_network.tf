# 00_network.tf

# 1. Приватная VPC
resource "google_compute_network" "private_vpc" {
  name                    = "deusops-private-vpc"
  auto_create_subnetworks = false
  project                 = "staging-492617"
}

# 2. Подсеть 10.10.1.0/24
resource "google_compute_subnetwork" "private_subnet" {
  name          = "deusops-private-subnet"
  ip_cidr_range = "10.10.1.0/24"
  region        = "europe-central2"
  network       = google_compute_network.private_vpc.id
  project       = "staging-492617"

  # Позволяет ВМ без внешнего IP обращаться к API Google (опционально, но полезно)
  private_ip_google_access = true
}

# 3. Cloud Router (обязателен для работы Cloud NAT)
resource "google_compute_router" "nat_router" {
  name    = "deusops-nat-router"
  region  = "europe-central2"
  network = google_compute_network.private_vpc.id
  project = "staging-492617"
}

# 4. Cloud NAT (управляемый шлюз в интернет)
resource "google_compute_router_nat" "nat_gateway" {
  name                               = "deusops-nat-gateway"
  router                             = google_compute_router.nat_router.name
  region                             = "europe-central2"
  project                            = "staging-492617"

  nat_ip_allocate_option             = "AUTO_ONLY" # Google сам выделит IP
  source_subnetwork_ip_ranges_to_nat = "ALL_SUBNETWORKS_ALL_IP_RANGES"

  # Логирование (опционально)
  log_config {
    enable = true
    filter = "ERRORS_ONLY"
  }
}

# 5. Фаервол: SSH из интернета ТОЛЬКО к бастиону
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

# 6. Фаервол: Внутренний трафик между ВМ
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
