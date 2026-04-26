resource "google_compute_instance" "ollama_gpu" {
  name         = "ollama-gpu"
  machine_type = "n1-standard-4"
  zone         = "europe-central2-b"

  boot_disk {
    initialize_params {
      #image = "projects/ml-images/global/images/family/common-cu124-debian-11-py310"
      image = "projects/ml-images/global/images/family/common-cu129-ubuntu-2204-nvidia-580"
      size  = 50
    }
  }

  network_interface {
    subnetwork = google_compute_subnetwork.private_subnet.id
    network_ip = "10.10.1.6"
  }
  tags = ["needs-nat"]

  guest_accelerator {
    type  = "nvidia-tesla-t4"
    count = 1
  }

  # Обязательно для GPU!
  scheduling {
    on_host_maintenance = "TERMINATE"
    automatic_restart   = false
  }
  metadata = {
    ssh-keys = "fill:ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIOlPFhFwKepToM3D/5wgUfFsPsv99sZkfUr9gnuhYYr/ fill@MacBookAir.local"
  }
  service_account {
    email  = "1087283053554-compute@developer.gserviceaccount.com"
    scopes = ["https://www.googleapis.com/auth/devstorage.read_only", "https://www.googleapis.com/auth/logging.write", "https://www.googleapis.com/auth/monitoring.write", "https://www.googleapis.com/auth/service.management.readonly", "https://www.googleapis.com/auth/servicecontrol", "https://www.googleapis.com/auth/trace.append"]
  }
}

output "ollama_internal_ip" {

  value = google_compute_instance.ollama_gpu.network_interface[0].network_ip

}

# output "ollama_external_ip" {
#
#   value = google_compute_instance.ollama_gpu.network_interface[0].access_config[0].nat_ip
#
# }
