resource "yandex_compute_instance" "postgre" {
  name        = "postgre"
  hostname    = "postgre"
  platform_id = "standard-v3"
  zone        = "ru-central1-a"

  resources {
    cores  = 2
    memory = 4
    core_fraction = 50
  }

  boot_disk {
    disk_id = yandex_compute_disk.disk_postgre.id
  }

  network_interface {
    index     = 1
    subnet_id = yandex_vpc_subnet.my_subnet.id
    ip_address = "10.10.1.20"
    #nat = "true"
  }

  metadata = {
    user-data = "${file("./cloudinit.d/03_postgre.yaml")}"
    serial-port-enable     = "true"
    enable-monitoring-agent = "true"
  }
}

//
// Create a new Compute Disk.
//
resource "yandex_compute_image" "ubuntu_2204_postgre" {
  source_family = "ubuntu-2204-lts-oslogin"
}


resource "yandex_compute_disk" "disk_postgre" {
  zone        = "ru-central1-a"
  name     = "boot-disk-postgre"
  type     = "network-hdd"
  size     = "50"
  image_id = yandex_compute_image.ubuntu_2204_postgre.id
  labels = {
    environment = "postgre"
  }
}