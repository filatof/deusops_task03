resource "google_compute_instance" "postgre" {
  boot_disk {
    auto_delete = true
    device_name = "postgre"

    initialize_params {
      image = "projects/ubuntu-os-cloud/global/images/family/ubuntu-2404-lts-amd64"
      size  = 40
      type  = "pd-balanced"
    }

    mode = "READ_WRITE"
  }

  can_ip_forward      = false
  deletion_protection = false
  enable_display      = false

  labels = {
    goog-ec-src = "vm_postgre"
  }

  machine_type = "e2-custom-medium-1024"

  metadata = {
  ssh-keys = "fill:ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIOlPFhFwKepToM3D/5wgUfFsPsv99sZkfUr9gnuhYYr/ fill@MacBookAir.local"
}

  name = "postgre"


  network_interface {
    subnetwork = google_compute_subnetwork.private_subnet.id
    network_ip = "10.10.1.4"
  }
  tags = ["needs-nat"]

  reservation_affinity {
    type = "NO_RESERVATION"
  }

  scheduling {
    automatic_restart   = false
    on_host_maintenance = "TERMINATE"
    preemptible = true
    #provisioning_model  = "SPOT"
  }

  service_account {
    email  = "1087283053554-compute@developer.gserviceaccount.com"
    scopes = ["https://www.googleapis.com/auth/devstorage.read_only", "https://www.googleapis.com/auth/logging.write", "https://www.googleapis.com/auth/monitoring.write", "https://www.googleapis.com/auth/service.management.readonly", "https://www.googleapis.com/auth/servicecontrol", "https://www.googleapis.com/auth/trace.append"]
  }

  shielded_instance_config {
    enable_integrity_monitoring = true
    enable_secure_boot          = false
    enable_vtpm                 = true
  }

  zone = "europe-central2-c"
}

output "postgre_internal_ip" {

  value = google_compute_instance.postgre.network_interface[0].network_ip

}

# output "postgre_external_ip" {
#
#   value = google_compute_instance.postgre.network_interface[0].access_config[0].nat_ip
#
# }
