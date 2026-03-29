resource "yandex_compute_instance" "n8n" {
  name        = "n8n"
  hostname    = "n8n"
  platform_id = "standard-v3"
  zone        = "ru-central1-a"

  resources {
    cores  = 4
    memory = 8
    core_fraction = 50
  }

  boot_disk {
    disk_id = yandex_compute_disk.disk_n8n.id
  }

  network_interface {
    index     = 1
    subnet_id = yandex_vpc_subnet.my_subnet.id
    ip_address = "10.10.1.10"
    #nat = "true"
  }

  metadata = {
    user-data = "${file("./cloudinit.d/02_n8n.yaml")}"
    serial-port-enable     = "true"
    enable-monitoring-agent = "true"
  }
}

//
// Create a new Compute Disk.
//
resource "yandex_compute_image" "ubuntu_2204_n8n" {
  source_family = "ubuntu-2204-lts-oslogin"
}


resource "yandex_compute_disk" "disk_n8n" {
  zone        = "ru-central1-a"
  name     = "boot-disk-n8n"
  type     = "network-hdd"
  size     = "40"
  image_id = yandex_compute_image.ubuntu_2204_n8n.id
  labels = {
    environment = "n8n"
  }
}