resource "yandex_compute_instance" "wiki" {
  name        = "wiki"
  hostname    = "wiki"
  platform_id = "standard-v3"
  zone        = "ru-central1-a"

  resources {
    cores  = 2
    memory = 4
    core_fraction = 50
  }

  boot_disk {
    disk_id = yandex_compute_disk.disk_wiki.id
  }

  network_interface {
    index     = 1
    subnet_id = yandex_vpc_subnet.my_subnet.id
    ip_address = "10.10.1.30"
    #nat = "true"
  }

  metadata = {
    user-data = "${file("./cloudinit.d/04_wiki.yaml")}"
    serial-port-enable     = "true"
    enable-monitoring-agent = "true"
  }
}

//
// Create a new Compute Disk.
//
resource "yandex_compute_image" "ubuntu_2204_wiki" {
  source_family = "ubuntu-2204-lts-oslogin"
}


resource "yandex_compute_disk" "disk_wiki" {
  zone     = "ru-central1-a"
  name     = "boot-disk-wiki"
  type     = "network-hdd"
  size     = "50"
  image_id = yandex_compute_image.ubuntu_2204_wiki.id
  labels = {
    environment = "wiki"
  }
}