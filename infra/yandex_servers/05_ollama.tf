resource "yandex_compute_instance" "ollama" {
  name        = "ollama"
  hostname    = "ollama"
  platform_id = "standard-v3"
  zone        = "ru-central1-a"

  resources {
    cores  = 8
    memory = 32
    #core_fraction = 50
    #gpus = 1
  }

  boot_disk {
    disk_id = yandex_compute_disk.disk_ollama.id
  }

  network_interface {
    index     = 1
    subnet_id = yandex_vpc_subnet.my_subnet.id
    ip_address = "10.10.1.40"
    #nat = "true"
  }

  metadata = {
    user-data = "${file("./cloudinit.d/05_ollama.yaml")}"
    serial-port-enable     = "true"
    enable-monitoring-agent = "true"
  }
}

//
// Create a new Compute Disk.
//
resource "yandex_compute_image" "ubuntu_2204_ollama" {
  //source_family = "ubuntu-2004-lts-gpu"
  source_family = "ubuntu-2204-lts-oslogin"
}


resource "yandex_compute_disk" "disk_ollama" {
  zone     = "ru-central1-a"
  name     = "boot-disk-ollama"
  type     = "network-ssd"
  size     = "50"
  image_id = yandex_compute_image.ubuntu_2204_ollama.id
  labels = {
    environment = "ollama"
  }
}